package com.safini.app

import android.app.usage.UsageEvents
import android.app.usage.UsageStatsManager
import android.content.Context

/** One app in front from [from] to [to], in epoch ms. */
data class Stretch(val pkg: String, val from: Long, val to: Long)

/**
 * The week before Safini was watching. Usage Access opens up everything Android
 * already kept, not only what happens after it is granted, so a new pairing can
 * show the parent last week on its first day instead of an empty screen.
 *
 * Exact stretches come from the UsageStats events, read the same way the live
 * service reads them. Android keeps those for fewer days than its daily totals,
 * and some phones keep only a few, so the days before the oldest event fall back
 * to the daily buckets: right per day, but only roughly on the day boundary.
 */
object UsageBackfill {
    const val DAYS = 7

    class Event(val type: Int, val pkg: String, val activity: String?, val at: Long)

    fun read(context: Context, since: Long, until: Long): List<Stretch> {
        if (until <= since) return emptyList()
        val manager = context.getSystemService(UsageStatsManager::class.java)
        val events = ArrayList<Event>()
        manager.queryEvents(since, until)?.let { query ->
            val event = UsageEvents.Event()
            while (query.hasNextEvent()) {
                query.getNextEvent(event)
                events.add(Event(event.eventType, event.packageName, event.className, event.timeStamp))
            }
        }
        val oldest = events.minOfOrNull { it.at } ?: until
        val daily = manager.queryUsageStats(UsageStatsManager.INTERVAL_DAILY, since, oldest).orEmpty()
            .map { Stretch(it.packageName, it.firstTimeStamp, it.lastTimeStamp) to it.totalTimeInForeground }
        return buckets(daily, since, oldest) + stretches(events, until)
    }

    /**
     * Daily totals as stretches from the start of their bucket. Only buckets that
     * end before the oldest event, so no minute is counted by both sources.
     */
    fun buckets(daily: List<Pair<Stretch, Long>>, since: Long, oldest: Long): List<Stretch> =
        daily.filter { (bucket, total) -> total > 0 && bucket.from >= since && bucket.to <= oldest }
            .map { (bucket, total) -> Stretch(bucket.pkg, bucket.from, bucket.from+minOf(total, bucket.to-bucket.from)) }

    /** Front-app stretches from activity events, ending at [until] for an app still in front. */
    fun stretches(events: List<Event>, until: Long): List<Stretch> {
        val front = object : FrontApp {
            override var foreground: String? = null
            override var foregroundActivity: String? = null
            override var covered = false
        }
        val tracker = ForegroundTracker(front)
        val found = ArrayList<Stretch>()
        var from = events.firstOrNull()?.at ?: return found
        fun accrue(to: Long) {
            val pkg = front.foreground
            if (pkg != null && to > from) found.add(Stretch(pkg, from, to))
            from = to
        }
        for (event in events.sortedBy { it.at }) {
            // A phone that died without a shutdown event was not in any app while it was off.
            if (event.type == UsageEvents.Event.DEVICE_STARTUP) { tracker.screenOff(); from = event.at; continue }
            accrue(event.at)
            when (event.type) {
                UsageEvents.Event.MOVE_TO_FOREGROUND -> tracker.resumed(event.pkg, event.activity)
                UsageEvents.Event.MOVE_TO_BACKGROUND -> tracker.paused(event.pkg, event.activity)
                UsageEvents.Event.SCREEN_NON_INTERACTIVE,
                UsageEvents.Event.KEYGUARD_SHOWN,
                UsageEvents.Event.DEVICE_SHUTDOWN -> tracker.screenOff()
                UsageEvents.Event.ACTIVITY_STOPPED -> tracker.stopped(event.pkg, event.activity)
            }
        }
        accrue(until)
        return found
    }
}
