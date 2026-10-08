package com.safini.app

import org.json.JSONArray
import org.json.JSONObject
import java.util.Base64

data class PackageStamp(val packageName: String, val lastUpdateTime: Long)

data class InstalledAppRecord(
    val packageName: String,
    val appName: String,
    val alwaysAllowed: Boolean = false,
    val iconSha256: String? = null,
    val iconPng: ByteArray? = null,
) {
    companion object {
        fun fromNative(map: Map<String, Any?>) = InstalledAppRecord(
            packageName = map["packageName"]?.toString().orEmpty(),
            appName = map["appName"]?.toString().orEmpty(),
            alwaysAllowed = map["alwaysAllowed"] == true,
            iconSha256 = map["iconSha256"] as? String,
            iconPng = map["iconPng"] as? ByteArray,
        )
    }
}

/**
 * When the child's installed-apps snapshot should go to the API, and how to
 * PUT it. Pure so the service can call it off the main thread and tests can
 * cover the throttle without Android.
 */
object InstalledAppsUpload {
    const val PERIODIC_MS = 4L * 60 * 60 * 1000
    const val RETRY_MS = 10L * 60 * 1000
    const val CHANGE_DEBOUNCE_MS = 30_000L
    const val MAX_APPS = 1000
    const val ICON_BATCH_BYTES = 1024 * 1024

    fun fingerprint(entries: List<PackageStamp>): String =
        entries.sortedBy { it.packageName }.joinToString("\n") { "${it.packageName}\t${it.lastUpdateTime}" }

    /**
     * Upload when the package set (or an update time) changed, or when the
     * last successful PUT is old enough that the parent's "Synced" stamp
     * should move, even if the list is unchanged. Identical lists inside the
     * periodic window are skipped. Failures retry on a longer interval, even
     * when the list changed since, so an offline phone or a 401 from an older
     * API does not render every icon once a minute.
     */
    fun shouldUpload(
        fingerprint: String,
        lastSuccessFingerprint: String?,
        lastSuccessAt: Long?,
        lastAttemptAt: Long?,
        now: Long,
        periodicMs: Long = PERIODIC_MS,
        retryMs: Long = RETRY_MS,
        changeDebounceMs: Long = CHANGE_DEBOUNCE_MS,
    ): Boolean {
        // A transient empty scan must not replace the parent's real list.
        if (fingerprint.isEmpty()) return false
        val changed = lastSuccessFingerprint != null && fingerprint != lastSuccessFingerprint
        val due = lastSuccessAt == null || now - lastSuccessAt >= periodicMs
        if (!changed && !due) return false
        val wait = if (changed && lastAttemptSucceeded(lastSuccessAt, lastAttemptAt)) changeDebounceMs else retryMs
        if (lastAttemptAt != null && now - lastAttemptAt < wait) return false
        return true
    }

    /** A success stamps the attempt with the same time, so a later attempt is one that failed. */
    fun lastAttemptSucceeded(lastSuccessAt: Long?, lastAttemptAt: Long?): Boolean =
        lastSuccessAt != null && (lastAttemptAt == null || lastAttemptAt <= lastSuccessAt)

    fun iconBatch(pending: List<String>, sizes: Map<String, Int>, limit: Int = ICON_BATCH_BYTES): Set<String> {
        val batch = linkedSetOf<String>()
        var bytes = 0
        for (hash in pending) {
            val size = sizes[hash] ?: continue
            if (batch.isNotEmpty() && bytes + size > limit) break
            batch.add(hash)
            bytes += size
        }
        return batch
    }

    fun toRequest(apps: List<InstalledAppRecord>, attach: Set<String>): JSONObject {
        val inBody = HashSet<String>()
        val list = JSONArray()
        for (app in apps.take(MAX_APPS)) {
            val obj = JSONObject().put("package_name", app.packageName).put("app_name", app.appName)
            if (app.alwaysAllowed) obj.put("always_allowed", true)
            val hash = app.iconSha256
            if (!hash.isNullOrEmpty()) {
                obj.put("icon_sha256", hash)
                if (hash in attach && inBody.add(hash) && app.iconPng != null) {
                    obj.put("icon_png", Base64.getEncoder().encodeToString(app.iconPng))
                }
            }
            list.put(obj)
        }
        return JSONObject().put("apps", list)
    }

    fun missingHashes(response: JSONObject): List<String> {
        val raw = response.optJSONArray("missing_icon_sha256") ?: return emptyList()
        return (0 until raw.length()).mapNotNull { raw.optString(it).takeIf { hash -> hash.isNotEmpty() } }
    }

    /** [put] is given the icon hashes to attach and must return hashes the server still lacks. */
    fun putSnapshot(apps: List<InstalledAppRecord>, put: (Set<String>) -> List<String>) {
        val payload = apps.take(MAX_APPS)
        val icons = payload.mapNotNull { app ->
            val hash = app.iconSha256
            val png = app.iconPng
            if (hash != null && png != null) hash to png.size else null
        }.toMap()
        val sent = mutableSetOf<String>()
        var attach = emptySet<String>()
        while (true) {
            val missing = put(attach)
            sent.addAll(attach)
            val pending = missing.filter { it in icons && it !in sent }
            if (pending.isEmpty()) break
            attach = iconBatch(pending, icons)
        }
    }
}
