package com.safini.app

import org.junit.Assert.*
import org.junit.Test

class ForegroundTrackerTest {
    private class Front(
        override var foreground: String? = null,
        override var foregroundActivity: String? = null,
        override var covered: Boolean = false,
    ) : FrontApp

    private val files = "com.google.android.documentsui"
    private val home = "com.google.android.apps.nexuslauncher"

    @Test fun trampolineStopDoesNotClearTheRealActivity() {
        // The Files event order from the SAF-191 repro, opened from its home-screen icon.
        val front = Front()
        val tracker = ForegroundTracker(front)
        tracker.resumed(home, "$home.NexusLauncherActivity")
        tracker.paused(home, "$home.NexusLauncherActivity")
        tracker.resumed(files, "$files.LauncherActivity")
        tracker.paused(files, "$files.LauncherActivity")
        tracker.resumed(files, "$files.files.FilesActivity")
        tracker.stopped(home, "$home.NexusLauncherActivity")
        tracker.stopped(files, "$files.LauncherActivity")
        assertEquals(files, front.foreground)
        assertEquals("$files.files.FilesActivity", front.foregroundActivity)
        assertEquals(listOf(files), tracker.visible)
    }

    @Test fun movingBetweenScreensOfOneAppKeepsItInFront() {
        val front = Front()
        val tracker = ForegroundTracker(front)
        tracker.resumed("com.game", "com.game.Menu")
        tracker.paused("com.game", "com.game.Menu")
        tracker.resumed("com.game", "com.game.Level")
        tracker.stopped("com.game", "com.game.Menu")
        assertEquals("com.game", front.foreground)
    }

    @Test fun leavingTheFrontActivityClearsIt() {
        val front = Front()
        val tracker = ForegroundTracker(front)
        tracker.resumed(files, "$files.files.FilesActivity")
        tracker.paused(files, "$files.files.FilesActivity")
        assertNull(front.foreground)
        assertNull(front.foregroundActivity)
        tracker.resumed(home, "$home.NexusLauncherActivity")
        tracker.stopped(files, "$files.files.FilesActivity")
        assertEquals(home, front.foreground)
        assertEquals(listOf(home), tracker.visible)
    }

    @Test fun pausedPipActivityStaysVisibleUntilStopped() {
        val front = Front()
        val tracker = ForegroundTracker(front)
        tracker.resumed("com.video", "com.video.Player")
        tracker.paused("com.video", "com.video.Player")
        tracker.resumed("com.chat", "com.chat.Main")
        assertEquals("com.chat", front.foreground)
        assertEquals(listOf("com.video", "com.chat"), tracker.visible)
        tracker.stopped("com.video", "com.video.Player")
        assertEquals(listOf("com.chat"), tracker.visible)
    }

    @Test fun visibleKeepsAPackageWhileAnyOfItsActivitiesIsShown() {
        val tracker = ForegroundTracker(Front())
        tracker.resumed("com.video", "com.video.Player")
        tracker.resumed("com.video", "com.video.Details")
        tracker.stopped("com.video", "com.video.Details")
        assertEquals(listOf("com.video"), tracker.visible)
    }

    @Test fun coveredAppStaysInFrontUntilSomethingElseResumes() {
        val front = Front()
        val tracker = ForegroundTracker(front)
        tracker.resumed(files, "$files.files.FilesActivity")
        front.covered = true
        tracker.paused(files, "$files.files.FilesActivity")
        tracker.stopped(files, "$files.files.FilesActivity")
        assertEquals(files, front.foreground)
        tracker.resumed(home, "$home.NexusLauncherActivity")
        assertEquals(home, front.foreground)
    }

    @Test fun stateSavedWithoutAnActivityFallsBackToThePackage() {
        // Persisted by a build before the class was tracked, then the service restarted.
        val front = Front(foreground = files)
        ForegroundTracker(front).stopped(files, "$files.LauncherActivity")
        assertNull(front.foreground)
    }

    @Test fun screenOffClearsEverything() {
        val front = Front()
        val tracker = ForegroundTracker(front)
        tracker.resumed(files, "$files.files.FilesActivity")
        front.covered = true
        tracker.screenOff()
        assertNull(front.foreground)
        assertFalse(front.covered)
        assertTrue(tracker.visible.isEmpty())
    }
}
