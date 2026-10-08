package com.safini.app

import android.content.Context
import android.content.Intent
import org.json.JSONObject

/**
 * Uploads the launchable-app list from the native service so a parent sees
 * installs and removals without the child opening Safini.
 */
object InstalledAppsSync {
    @Synchronized
    fun uploadIfDue(
        context: Context,
        client: EnforcementClient,
        store: EnforcementStore,
        now: Long = System.currentTimeMillis(),
        scan: () -> List<PackageStamp> = { scanPackages(context) },
        listApps: () -> List<InstalledAppRecord> = {
            AppIcons.installedApps(context).map { InstalledAppRecord.fromNative(it) }
        },
        put: (JSONObject) -> JSONObject = { client.putInstalledApps(it) },
    ): Boolean {
        if (!store.enabled || client.childId().isNullOrEmpty()) return false
        val stamps = runCatching(scan).getOrElse { return false }
        val fingerprint = InstalledAppsUpload.fingerprint(stamps)
        if (!InstalledAppsUpload.shouldUpload(
                fingerprint = fingerprint,
                lastSuccessFingerprint = store.installedAppsFingerprint(),
                lastSuccessAt = store.installedAppsSuccessAt(),
                lastAttemptAt = store.installedAppsAttemptAt(),
                now = now,
            )
        ) return true
        store.markInstalledAppsAttempt(now)
        return try {
            val apps = listApps()
            InstalledAppsUpload.putSnapshot(apps) { attach ->
                InstalledAppsUpload.missingHashes(put(InstalledAppsUpload.toRequest(apps, attach)))
            }
            store.markInstalledAppsSuccess(fingerprint, now)
            true
        } catch (_: Exception) {
            false
        }
    }

    fun scanPackages(context: Context): List<PackageStamp> {
        val pm = context.packageManager
        val launcher = Intent(Intent.ACTION_MAIN).addCategory(Intent.CATEGORY_LAUNCHER)
        return pm.queryIntentActivities(launcher, 0)
            .mapNotNull { it.activityInfo?.packageName }
            .filter { it != context.packageName }
            .distinct()
            .map { pkg ->
                val updated = runCatching { pm.getPackageInfo(pkg, 0).lastUpdateTime }.getOrDefault(0L)
                PackageStamp(pkg, updated)
            }
    }
}
