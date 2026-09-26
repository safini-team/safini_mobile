package com.safini.app

import android.app.usage.UsageEvents.Event.ACTIVITY_STOPPED
import android.app.usage.UsageEvents.Event.DEVICE_STARTUP
import android.app.usage.UsageEvents.Event.MOVE_TO_BACKGROUND
import android.app.usage.UsageEvents.Event.MOVE_TO_FOREGROUND
import android.app.usage.UsageEvents.Event.SCREEN_NON_INTERACTIVE
import org.junit.Assert.*
import org.junit.Test

class UsageBackfillTest {
    private val home = "com.launcher"
    private fun ev(type: Int, pkg: String, activity: String?, at: Long) = UsageBackfill.Event(type, pkg, activity, at)

    @Test fun countsTheAppInFrontUntilItLeaves() {
        val found = UsageBackfill.stretches(listOf(
            ev(MOVE_TO_FOREGROUND, "com.game", "Main", 1_000),
            ev(MOVE_TO_BACKGROUND, "com.game", "Main", 61_000),
            ev(MOVE_TO_FOREGROUND, home, "Home", 61_500),
        ), until = 100_000)
        assertEquals(listOf(Stretch("com.game", 1_000, 61_000), Stretch(home, 61_500, 100_000)), found)
    }

    @Test fun screenOffEndsTheStretch() {
        val found = UsageBackfill.stretches(listOf(
            ev(MOVE_TO_FOREGROUND, "com.video", "Player", 0),
            ev(SCREEN_NON_INTERACTIVE, "android", null, 30_000),
        ), until = 3_600_000)
        assertEquals(listOf(Stretch("com.video", 0, 30_000)), found)
    }

    @Test fun aPhoneThatDiedIsNotCountedWhileItWasOff() {
        // No shutdown event: the battery ran out with the game in front.
        val found = UsageBackfill.stretches(listOf(
            ev(MOVE_TO_FOREGROUND, "com.game", "Main", 0),
            ev(DEVICE_STARTUP, "android", null, 7_200_000),
            ev(MOVE_TO_FOREGROUND, home, "Home", 7_210_000),
            ev(MOVE_TO_BACKGROUND, home, "Home", 7_220_000),
        ), until = 7_300_000)
        assertEquals(listOf(Stretch(home, 7_210_000, 7_220_000)), found)
    }

    @Test fun aTrampolineStopDoesNotEndTheRealActivity() {
        val found = UsageBackfill.stretches(listOf(
            ev(MOVE_TO_FOREGROUND, "com.files", "Launcher", 0),
            ev(MOVE_TO_BACKGROUND, "com.files", "Launcher", 100),
            ev(MOVE_TO_FOREGROUND, "com.files", "Files", 200),
            ev(ACTIVITY_STOPPED, "com.files", "Launcher", 1_000),
        ), until = 10_000)
        // Only the 100 ms between the trampoline pausing and the real screen resuming is missing.
        assertEquals(listOf(Stretch("com.files", 0, 100), Stretch("com.files", 200, 10_000)),
            found.filter { it.pkg == "com.files" }.fold(listOf<Stretch>()) { merged, next ->
                val last = merged.lastOrNull()
                if (last != null && last.to == next.from) merged.dropLast(1)+last.copy(to = next.to) else merged+next
            })
    }

    @Test fun noEventsNoStretches() {
        assertTrue(UsageBackfill.stretches(emptyList(), until = 10_000).isEmpty())
    }

    @Test fun dailyBucketsOnlyFillTheDaysBeforeTheOldestEvent() {
        val day = 86_400_000L
        val found = UsageBackfill.buckets(listOf(
            Stretch("com.game", 0, day) to 3_600_000L,
            // Overlaps the days the events cover, so the events count it.
            Stretch("com.game", day, 2*day) to 1_800_000L,
            Stretch("com.idle", 0, day) to 0L,
        ), since = 0, oldest = day+10)
        assertEquals(listOf(Stretch("com.game", 0, 3_600_000)), found)
    }
}
