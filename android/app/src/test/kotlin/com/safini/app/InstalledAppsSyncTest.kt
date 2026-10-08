package com.safini.app

import org.junit.Assert.assertEquals
import org.junit.Assert.assertFalse
import org.junit.Assert.assertNull
import org.junit.Assert.assertTrue
import org.junit.Test

class InstalledAppsSyncTest {
    private class MemoryStore : InstalledAppsStore {
        var fingerprint: String? = null
        var successAt: Long? = null
        var attemptAt: Long? = null
        override fun installedAppsFingerprint() = fingerprint
        override fun installedAppsSuccessAt() = successAt
        override fun installedAppsAttemptAt() = attemptAt
        override fun markInstalledAppsAttempt(at: Long) { attemptAt = at }
        override fun markInstalledAppsSuccess(fingerprint: String, at: Long) {
            this.fingerprint = fingerprint
            successAt = at
            attemptAt = at
        }
    }

    // The real store reads 0 as "never", so the clock starts at a real time.
    private val t0 = 1_760_000_000_000L
    private val minute = 60 * 1000L
    private val puts = mutableListOf<List<InstalledAppRecord>>()

    private fun upload(
        store: InstalledAppsStore,
        now: Long,
        apps: List<InstalledAppRecord> = listOf(InstalledAppRecord("com.game", "Game")),
        fail: Boolean = false,
    ) = InstalledAppsSync.upload(
        store = store,
        now = now,
        scan = { listOf(PackageStamp("com.game", 1)) },
        listApps = { apps },
    ) { sent, _ ->
        puts.add(sent)
        if (fail) throw EnforcementHttpException(401, "Unable to connect (401). Open Safini or try again.")
        emptyList()
    }

    @Test fun aSkipInsideTheRetryWaitAfterAFailureLetsFlutterFallBack() {
        val store = MemoryStore()
        assertFalse(upload(store, t0, fail = true))
        assertFalse(upload(store, t0 + minute))
        assertEquals(1, puts.size)
    }

    @Test fun aSkipAfterAnUploadThatWentThroughIsFresh() {
        val store = MemoryStore()
        assertTrue(upload(store, t0))
        assertTrue(upload(store, t0 + minute))
        assertEquals(1, puts.size)
    }

    @Test fun anEmptyIconListIsNeverUploaded() {
        val store = MemoryStore()
        assertFalse(upload(store, t0, apps = emptyList()))
        assertTrue(puts.isEmpty())
        assertNull(store.successAt)
        assertEquals(t0, store.attemptAt)
    }
}
