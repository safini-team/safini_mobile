package com.safini.app

import android.content.Context
import android.content.pm.PackageInfo
import android.os.Build

/** SAF-253: every native Safini API call names this binary. */
object AppClientHeaders {
    const val VERSION = "X-App-Version"
    const val BUILD = "X-App-Build"
    const val PLATFORM = "X-App-Platform"

    fun values(versionName: String?, versionCode: Long): Map<String, String> = mapOf(
        VERSION to (versionName ?: ""),
        BUILD to versionCode.toString(),
        PLATFORM to "android",
    )

    fun from(context: Context): Map<String, String> {
        val info = context.packageManager.getPackageInfo(context.packageName, 0)
        return values(info.versionName, versionCode(info))
    }

    @Suppress("DEPRECATION")
    private fun versionCode(info: PackageInfo): Long =
        if (Build.VERSION.SDK_INT >= 28) info.longVersionCode else info.versionCode.toLong()
}
