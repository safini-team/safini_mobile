package com.safini.app

import java.time.LocalTime
import java.time.ZonedDateTime

/**
 * Bedtime, school hours and dinner (SAF-277), worked out on the phone so a
 * window starts on the minute even offline. Same rules as the API's
 * `app/services/fini/windows.py`, checked against the shared fixture:
 * the start minute is in, the end minute out; an overnight window belongs
 * to the day it starts; when two overlap, the later end wins.
 */
object TimeWindows {
    /** [days]: Mon=1, Tue=2, Wed=4 ... Sun=64. */
    data class Window(val intent: String, val start: LocalTime, val end: LocalTime, val days: Int)

    fun active(windows: List<Window>, now: ZonedDateTime): Pair<Window, ZonedDateTime>? {
        var found: Pair<Window, ZonedDateTime>? = null
        val today = now.toLocalDate()
        for (window in windows) for (startDay in listOf(today.minusDays(1), today)) {
            if (window.days and (1 shl (startDay.dayOfWeek.value - 1)) == 0) continue
            val start = startDay.atTime(window.start).atZone(now.zone)
            val endDay = if (window.end.isAfter(window.start)) startDay else startDay.plusDays(1)
            val end = endDay.atTime(window.end).atZone(now.zone)
            if (!now.isBefore(start) && now.isBefore(end) && (found == null || end.isAfter(found.second))) {
                found = window to end
            }
        }
        return found
    }
}
