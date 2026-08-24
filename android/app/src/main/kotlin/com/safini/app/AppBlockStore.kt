package com.safini.app

import android.content.Context
import android.content.Intent

/**
 * Single source of truth for the app-blocking rule set persisted on the child
 * device. Both [MainActivity] (writer, via the MethodChannel) and
 * [AppBlockForegroundService] (reader/enforcer) go through here so the key
 * scheme never drifts.
 *
 * Stored in a dedicated SharedPreferences file to avoid clashing with Flutter's
 * own `shared_preferences` store.
 */
object AppBlockStore {
    private const val PREFS = "safini_app_block"
    const val ACTION_UPDATE = "com.safini.app.UPDATE_BLOCKED_APPS"

    private const val KEY_BLOCKED = "blocked_set"
    private const val KEY_ENFORCING = "enforcing"
    private const val PREFIX_LIMIT = "limit_"
    private const val PREFIX_LIMIT_START = "limitStart_"

    private fun prefs(context: Context) =
        context.getSharedPreferences(PREFS, Context.MODE_PRIVATE)

    // ── Enforcing flag (used by BootReceiver) ──────────────────────────────────

    fun setEnforcing(context: Context, enforcing: Boolean) {
        prefs(context).edit().putBoolean(KEY_ENFORCING, enforcing).apply()
    }

    fun isEnforcing(context: Context): Boolean =
        prefs(context).getBoolean(KEY_ENFORCING, false)

    // ── Reads (service side) ───────────────────────────────────────────────────

    fun readLimits(context: Context): Map<String, Long> {
        val out = HashMap<String, Long>()
        for ((key, value) in prefs(context).all) {
            if (key.startsWith(PREFIX_LIMIT) && !key.startsWith(PREFIX_LIMIT_START) && value is Long) {
                out[key.removePrefix(PREFIX_LIMIT)] = value
            }
        }
        return out
    }

    fun readLimitStarts(context: Context): Map<String, Long> {
        val out = HashMap<String, Long>()
        for ((key, value) in prefs(context).all) {
            if (key.startsWith(PREFIX_LIMIT_START) && value is Long) {
                out[key.removePrefix(PREFIX_LIMIT_START)] = value
            }
        }
        return out
    }

    fun readBlocked(context: Context): Set<String> =
        prefs(context).getStringSet(KEY_BLOCKED, emptySet())?.toSet() ?: emptySet()

    // ── Writes (MethodChannel side) ────────────────────────────────────────────

    /**
     * Sets a per-app time limit (ms). The measurement window start is preserved
     * when the limit value is unchanged, so a periodic re-sync does not reset the
     * user's consumed time; it only resets when the limit actually changes.
     */
    fun setLimit(context: Context, packageName: String, limitMs: Long) {
        val p = prefs(context)
        val previous = p.getLong(PREFIX_LIMIT + packageName, -1L)
        val editor = p.edit().putLong(PREFIX_LIMIT + packageName, limitMs)
        if (previous != limitMs) {
            editor.putLong(PREFIX_LIMIT_START + packageName, System.currentTimeMillis())
        }
        editor.apply()
        broadcastUpdate(context)
    }

    fun removeLimit(context: Context, packageName: String) {
        prefs(context).edit()
            .remove(PREFIX_LIMIT + packageName)
            .remove(PREFIX_LIMIT_START + packageName)
            .apply()
        broadcastUpdate(context)
    }

    fun setManualBlock(context: Context, packageName: String, blocked: Boolean) {
        val current = readBlocked(context).toMutableSet()
        if (blocked) current.add(packageName) else current.remove(packageName)
        prefs(context).edit().putStringSet(KEY_BLOCKED, current).apply()
        broadcastUpdate(context)
    }

    /**
     * Atomically replaces the whole rule set. Each rule map has:
     *  - `packageName: String`
     *  - `limitMs: Number?`  (null when the app is only manually blocked)
     *  - `blocked: Boolean`
     */
    fun syncRules(context: Context, rules: List<Map<String, Any?>>) {
        val p = prefs(context)
        val oldLimits = readLimits(context)
        val oldStarts = readLimitStarts(context)
        val now = System.currentTimeMillis()

        val editor = p.edit()
        // Clear existing limits/starts; blocked set is rebuilt below.
        for (key in p.all.keys) {
            if (key.startsWith(PREFIX_LIMIT) || key.startsWith(PREFIX_LIMIT_START)) {
                editor.remove(key)
            }
        }

        val blocked = mutableSetOf<String>()
        for (rule in rules) {
            val pkg = rule["packageName"] as? String ?: continue
            if ((rule["blocked"] as? Boolean) == true) blocked.add(pkg)
            val limitMs = (rule["limitMs"] as? Number)?.toLong()
            if (limitMs != null) {
                editor.putLong(PREFIX_LIMIT + pkg, limitMs)
                val start = if (oldLimits[pkg] == limitMs) (oldStarts[pkg] ?: now) else now
                editor.putLong(PREFIX_LIMIT_START + pkg, start)
            }
        }
        editor.putStringSet(KEY_BLOCKED, blocked)
        editor.apply()
        broadcastUpdate(context)
    }

    private fun broadcastUpdate(context: Context) {
        context.sendBroadcast(Intent(ACTION_UPDATE).setPackage(context.packageName))
    }
}
