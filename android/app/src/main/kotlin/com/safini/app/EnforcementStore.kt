package com.safini.app

import android.content.Context
import org.json.JSONObject
import org.json.JSONArray
import java.time.Instant
import java.time.ZoneId

/** Non-secret budgets live in device-protected storage so boot can resume offline. */
class EnforcementStore(context: Context) {
    private val prefs = context.createDeviceProtectedStorageContext()
        .getSharedPreferences("safini_enforcement_v2", Context.MODE_PRIVATE)
    var snapshot: JSONObject = JSONObject(prefs.getString("snapshot", "{}")!!)
        private set
    private val usage = JSONObject(prefs.getString("usage", "{}")!!)
    var cursor: Long = prefs.getLong("cursor", System.currentTimeMillis())
    var foreground: String? = prefs.getString("foreground", null)
    var covered: Boolean = prefs.getBoolean("covered", false)
    var enabled: Boolean
        get() = prefs.getBoolean("enabled", false)
        set(value) { prefs.edit().putBoolean("enabled", value).commit() }
    var language: String
        get() = prefs.getString("language", "en")!!
        set(value) { prefs.edit().putString("language", value).apply() }

    fun day(at: Long): String = Instant.ofEpochMilli(at).atZone(zone()).toLocalDate().toString()
    private fun zone(): ZoneId = runCatching { ZoneId.of(snapshot.optString("family_timezone", "UTC")) }.getOrDefault(ZoneId.of("UTC"))
    fun apps(): List<JSONObject> = snapshot.optJSONArray("apps")?.let { list ->
        (0 until list.length()).map { list.getJSONObject(it) }
    } ?: emptyList()
    fun app(pkg: String): JSONObject? = apps().firstOrNull { it.optString("package_name") == pkg }
    fun used(pkg: String, date: String): Long = usage.optJSONObject(date)?.optLong(pkg) ?: 0

    fun record(pkg: String, from: Long, to: Long) {
        var start = from
        while (start < to) {
            val date = day(start)
            val endOfDay = Instant.ofEpochMilli(start).atZone(zone()).toLocalDate().plusDays(1).atStartOfDay(zone()).toInstant().toEpochMilli()
            val end = minOf(to, endOfDay)
            val values = usage.optJSONObject(date) ?: JSONObject().also { usage.put(date, it) }
            values.put(pkg, (used(pkg, date) + end - start).coerceAtMost(86_400_000))
            start = end
        }
    }

    fun remaining(pkg: String, now: Long): Long? {
        val app = app(pkg) ?: return null
        val date = day(now)
        val sameDay = date == snapshot.optString("usage_date")
        val policy = BlockingRule(app.optBoolean("is_blocked"), app.optBoolean("is_limited", true),
            app.optLong("daily_limit_minutes")*60000, app.optLong("used_minutes")*60000,
            app.optLong("bonus_minutes_remaining")*60000)
        val cap = snapshot.optJSONObject("screen_time")
        val globalRemaining = if (cap == null || cap.isNull("global_limit_minutes")) null else {
            val localTotal = apps().sumOf { used(it.optString("package_name"), date) }
            val knownServer = apps().filter { it.optString("package_name").isNotEmpty() && it.optString("package_name") != "null" }.sumOf { it.optLong("used_minutes")*60000 }
            val other = if (sameDay) (cap.optLong("global_used_minutes")*60000-knownServer).coerceAtLeast(0) else 0
            cap.optLong("global_limit_minutes")*60000-localTotal-other
        }
        return BlockingPolicy.remaining(policy, used(pkg, date), sameDay, globalRemaining)
    }

    fun applySnapshot(data: JSONObject) {
        val date = data.getString("usage_date")
        snapshot = data
        val values = usage.optJSONObject(date) ?: JSONObject().also { usage.put(date, it) }
        for (app in apps()) {
            val pkg = app.optString("package_name")
            if (pkg.isNotEmpty() && pkg != "null") values.put(pkg, maxOf(used(pkg, date), app.optLong("used_minutes")*60000))
        }
        persist()
    }

    fun reports(): JSONArray {
        val reports = JSONArray()
        for (date in usage.keys().asSequence().sorted().toList().takeLast(7)) {
            for (app in apps()) {
                val minutes = used(app.optString("package_name"), date)/60000
                if (minutes > 0) reports.put(JSONObject().put("app_slug", app.getString("app_slug"))
                    .put("usage_date", date).put("used_minutes", minutes).put("source", "android"))
            }
        }
        return reports
    }

    fun persist() {
        usage.keys().asSequence().sorted().toList().dropLast(7).forEach { usage.remove(it) }
        prefs.edit().putString("snapshot", snapshot.toString()).putString("usage", usage.toString())
            .putLong("cursor", cursor).putString("foreground", foreground).putBoolean("covered", covered).commit()
    }
    fun clear() {
        prefs.edit().clear().commit()
        snapshot = JSONObject()
        usage.keys().asSequence().toList().forEach { usage.remove(it) }
        cursor = System.currentTimeMillis()
        foreground = null
        covered = false
    }
}
