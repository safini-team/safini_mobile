package com.safini.app

import android.content.Context
import android.content.Intent
import android.os.Build
import android.os.SystemClock
import android.provider.Settings
import android.provider.Telephony
import android.telecom.TelecomManager

/**
 * Phone, Messages and Settings stay open whatever the parent's rules say, so a child can always
 * call or text a parent. Apple's Screen Time keeps the Phone app always allowed for the same reason.
 *
 * The phone's own default dialer, default SMS app and Settings are asked for, since a dialer is not
 * always a package called "dialer" (Xiaomi ships it inside Contacts). The known packages mirror the
 * API's list, for a phone that reports no default.
 */
object AlwaysAllowed {
    val KNOWN = setOf(
        "com.android.dialer", "com.android.phone", "com.google.android.dialer", "com.samsung.android.dialer",
        "com.android.messaging", "com.android.mms", "com.google.android.apps.messaging", "com.samsung.android.messaging",
        "com.android.settings",
    )

    /** Defaults can change, but not every 500ms tick needs to ask the system. */
    private const val REFRESH_MS = 60_000L
    private var cached: Set<String> = KNOWN
    private var cachedAt = 0L

    @Synchronized
    fun packages(context: Context): Set<String> {
        val now = SystemClock.elapsedRealtime()
        if (cachedAt == 0L || now - cachedAt >= REFRESH_MS) {
            cached = merge(resolve(context.applicationContext))
            cachedAt = now
        }
        return cached
    }

    fun contains(context: Context, pkg: String): Boolean = pkg in packages(context)

    /** The known packages plus whatever this phone named; a blank or missing answer adds nothing. */
    fun merge(resolved: List<String?>): Set<String> = KNOWN + resolved.filterNotNull().filter { it.isNotBlank() }

    private fun resolve(context: Context): List<String?> {
        val telecom = runCatching { context.getSystemService(TelecomManager::class.java) }.getOrNull()
        return listOf(
            runCatching { telecom?.defaultDialerPackage }.getOrNull(),
            if (Build.VERSION.SDK_INT >= 29) runCatching { telecom?.systemDialerPackage }.getOrNull() else null,
            runCatching { Telephony.Sms.getDefaultSmsPackage(context) }.getOrNull(),
            runCatching {
                context.packageManager.resolveActivity(Intent(Settings.ACTION_SETTINGS), 0)?.activityInfo?.packageName
            }.getOrNull(),
        )
    }
}
