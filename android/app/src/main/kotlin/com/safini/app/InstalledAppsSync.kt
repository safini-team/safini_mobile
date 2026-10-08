package com.safini.app

import android.content.Context
import android.content.Intent

/** Where [InstalledAppsSync] keeps its last attempt and last success. [EnforcementStore] in the app. */
interface InstalledAppsStore {
    fun installedAppsFingerprint(): String?
    fun installedAppsSuccessAt(): Long?
    fun installedAppsAttemptAt(): Long?
    fun markInstalledAppsAttempt(at: Long)
    fun markInstalledAppsSuccess(fingerprint: String, at: Long)
}

/**
 * Uploads the launchable-app list from the native service so a parent sees
 * installs and removals without the child opening Safini.
 */
object InstalledAppsSync {
    @Synchronized
    fun uploadIfDue(context: Context, client: EnforcementClient, store: EnforcementStore): Boolean {
        if (!store.enabled || client.childId().isNullOrEmpty()) return false
        return upload(
            store = store,
            now = System.currentTimeMillis(),
            scan = { scanPackages(context) },
            listApps = { AppIcons.installedApps(context).map { InstalledAppRecord.fromNative(it) } },
            put = { apps, attach ->
                InstalledAppsUpload.missingHashes(client.putInstalledApps(InstalledAppsUpload.toRequest(apps, attach)))
            },
        )
    }

    /**
     * True when the parent's list is current: uploaded now, or skipped while
     * nothing is due and the last attempt went through. False tells Flutter to
     * fall back to its own PUT. [put] sends the apps with the icon hashes to
     * attach and returns the hashes the server still lacks.
     */
    internal fun upload(
        store: InstalledAppsStore,
        now: Long,
        scan: () -> List<PackageStamp>,
        listApps: () -> List<InstalledAppRecord>,
        put: (List<InstalledAppRecord>, Set<String>) -> List<String>,
    ): Boolean {
        val stamps = runCatching(scan).getOrElse { return false }
        val fingerprint = InstalledAppsUpload.fingerprint(stamps)
        val lastSuccessAt = store.installedAppsSuccessAt()
        val lastAttemptAt = store.installedAppsAttemptAt()
        if (!InstalledAppsUpload.shouldUpload(
                fingerprint = fingerprint,
                lastSuccessFingerprint = store.installedAppsFingerprint(),
                lastSuccessAt = lastSuccessAt,
                lastAttemptAt = lastAttemptAt,
                now = now,
            )
        ) return InstalledAppsUpload.lastAttemptSucceeded(lastSuccessAt, lastAttemptAt)
        store.markInstalledAppsAttempt(now)
        return try {
            val apps = listApps()
            InstalledAppsUpload.putSnapshot(apps) { attach -> put(apps, attach) }
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
