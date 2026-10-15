package com.safini.app

/** Pure policy; all times are foreground milliseconds, never countdown wall time. */
data class BlockingRule(
    val blocked: Boolean,
    val limited: Boolean,
    val dailyMs: Long,
    val serverUsedMs: Long,
    val bonusRemainingMs: Long,
) {
    fun remaining(usedMs: Long, sameDay: Boolean): Long? {
        if (blocked) return 0L
        if (!limited) return null
        val allowance = if (sameDay) maxOf(dailyMs, serverUsedMs) + bonusRemainingMs else dailyMs
        return (allowance - usedMs).coerceAtLeast(0)
    }
}

object BlockingPolicy {
    /**
     * Time left in a Fini pool (SAF-274): one daily limit shared by every app in it. [localMs] is what
     * the pool's apps ran here today; the server's figure only counts on its own day, like an app's.
     */
    fun poolRemaining(limitMinutes: Long, serverUsedMinutes: Long, localMs: Long, sameDay: Boolean): Long {
        val used = if (sameDay) maxOf(localMs, serverUsedMinutes*60000) else localMs
        return limitMinutes*60000-used
    }

    fun remaining(rule: BlockingRule, usedMs: Long, sameDay: Boolean, globalRemaining: Long?): Long? {
        val appRemaining = rule.remaining(usedMs, sameDay)
        return when {
            globalRemaining == null -> appRemaining
            appRemaining == null -> globalRemaining.coerceAtLeast(0)
            else -> minOf(appRemaining, globalRemaining.coerceAtLeast(0))
        }
    }
}
