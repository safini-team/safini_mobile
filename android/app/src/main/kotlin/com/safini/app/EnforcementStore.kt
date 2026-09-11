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

    private fun rule(app: JSONObject) = BlockingRule(app.optBoolean("is_blocked"), app.optBoolean("is_limited", true),
        app.optLong("daily_limit_minutes")*60000, app.optLong("used_minutes")*60000,
        app.optLong("bonus_minutes_remaining")*60000)

    /** The overall daily cap left in ms, or null when the parent has not set one. */
    private fun globalRemaining(date: String, sameDay: Boolean): Long? {
        val cap = snapshot.optJSONObject("screen_time")
        if (cap == null || cap.isNull("global_limit_minutes")) return null
        val localTotal = apps().sumOf { used(it.optString("package_name"), date) }
        val knownServer = apps().filter { it.optString("package_name").isNotEmpty() && it.optString("package_name") != "null" }.sumOf { it.optLong("used_minutes")*60000 }
        val other = if (sameDay) (cap.optLong("global_used_minutes")*60000-knownServer).coerceAtLeast(0) else 0
        return cap.optLong("global_limit_minutes")*60000-localTotal-other
    }

    fun remaining(pkg: String, now: Long): Long? {
        val app = app(pkg) ?: return null
        val date = day(now)
        val sameDay = date == snapshot.optString("usage_date")
        return BlockingPolicy.remaining(rule(app), used(pkg, date), sameDay, globalRemaining(date, sameDay))
    }

    /** What the block screen tells the child about [pkg]: why it is closed and what coins can still do. */
    fun blockFacts(pkg: String, now: Long): BlockFacts? {
        val app = app(pkg) ?: return null
        val date = day(now)
        val sameDay = date == snapshot.optString("usage_date")
        val rule = rule(app)
        val global = globalRemaining(date, sameDay)
        // The server refuses purchases once the overall cap is spent, so that reason wins over the app's own.
        val dayCap = !rule.blocked && global != null && global <= 0
        val allowance = when {
            dayCap -> snapshot.getJSONObject("screen_time").optLong("global_limit_minutes")*60000
            sameDay -> maxOf(rule.dailyMs, rule.serverUsedMs)+rule.bonusRemainingMs
            else -> rule.dailyMs
        }
        val reset = Instant.ofEpochMilli(now).atZone(zone()).toLocalDate().plusDays(1).atStartOfDay(zone()).toInstant().toEpochMilli()
        return BlockFacts(
            slug = app.optString("app_slug"),
            appName = app.optString("display_name").ifBlank { app.optString("app_slug") },
            paused = rule.blocked,
            dayCap = dayCap,
            canUnlock = app.optBoolean("can_redeem") && app.optInt("redeem_reward_minutes") > 0,
            cost = app.optInt("redeem_coin_cost"),
            minutes = app.optInt("redeem_reward_minutes"),
            balance = snapshot.optInt("balance"),
            allowanceMinutes = allowance/60000,
            resetInMinutes = (reset-now+59_999)/60_000,
            remainingSeconds = BlockingPolicy.remaining(rule, used(pkg, date), sameDay, global)?.let { it/1000 },
            tasks = snapshot.optJSONArray("tasks")?.let { list -> (0 until list.length()).map { list.getJSONObject(it) } }.orEmpty()
                .map { BlockTask(it.optString("title"), it.optString("category"), it.optInt("coin_reward")) }
                .filter { it.title.isNotBlank() }.sortedByDescending { it.coins },
        )
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
