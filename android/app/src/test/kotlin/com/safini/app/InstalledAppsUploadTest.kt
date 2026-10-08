package com.safini.app

import org.junit.Assert.assertEquals
import org.junit.Assert.assertFalse
import org.junit.Assert.assertTrue
import org.junit.Test

class InstalledAppsUploadTest {
    private val hour = 60 * 60 * 1000L
    private val minute = 60 * 1000L

    @Test fun firstUploadGoesOutImmediately() {
        assertTrue(InstalledAppsUpload.shouldUpload("a", null, null, null, 0))
    }

    @Test fun identicalListInsideThePeriodicWindowIsSkipped() {
        assertFalse(
            InstalledAppsUpload.shouldUpload(
                fingerprint = "a",
                lastSuccessFingerprint = "a",
                lastSuccessAt = 0,
                lastAttemptAt = 0,
                now = hour,
            ),
        )
    }

    @Test fun unchangedListIsReuploadedAfterAFewHoursSoFreshnessMoves() {
        assertTrue(
            InstalledAppsUpload.shouldUpload(
                fingerprint = "a",
                lastSuccessFingerprint = "a",
                lastSuccessAt = 0,
                lastAttemptAt = 0,
                now = InstalledAppsUpload.PERIODIC_MS,
            ),
        )
    }

    @Test fun installOrUpdateUploadsWithoutWaitingForThePeriodicWindow() {
        assertTrue(
            InstalledAppsUpload.shouldUpload(
                fingerprint = "a\nb",
                lastSuccessFingerprint = "a",
                lastSuccessAt = 0,
                lastAttemptAt = 0,
                now = minute,
            ),
        )
    }

    @Test fun aPackageBurstIsDebounced() {
        assertFalse(
            InstalledAppsUpload.shouldUpload(
                fingerprint = "a\nb",
                lastSuccessFingerprint = "a",
                lastSuccessAt = 0,
                lastAttemptAt = 0,
                now = 10_000,
            ),
        )
    }

    @Test fun aFailedFirstUploadRetriesOnTheLongerIntervalNotEveryHeartbeat() {
        assertFalse(
            InstalledAppsUpload.shouldUpload(
                fingerprint = "a",
                lastSuccessFingerprint = null,
                lastSuccessAt = null,
                lastAttemptAt = 0,
                now = minute,
            ),
        )
        assertTrue(
            InstalledAppsUpload.shouldUpload(
                fingerprint = "a",
                lastSuccessFingerprint = null,
                lastSuccessAt = null,
                lastAttemptAt = 0,
                now = InstalledAppsUpload.RETRY_MS,
            ),
        )
    }

    @Test fun fingerprintChangesWhenAnAppIsUpdated() {
        val before = InstalledAppsUpload.fingerprint(listOf(PackageStamp("com.game", 1)))
        val after = InstalledAppsUpload.fingerprint(listOf(PackageStamp("com.game", 2)))
        assertTrue(before != after)
    }

    @Test fun fingerprintIgnoresPackageOrder() {
        assertEquals(
            InstalledAppsUpload.fingerprint(listOf(PackageStamp("b", 1), PackageStamp("a", 2))),
            InstalledAppsUpload.fingerprint(listOf(PackageStamp("a", 2), PackageStamp("b", 1))),
        )
    }

    @Test fun iconsGoUpInMegabyteBatchesAndAtLeastOneAlwaysFits() {
        val sizes = mapOf("a" to 400 * 1024, "b" to 400 * 1024, "c" to 400 * 1024, "big" to 2 * 1024 * 1024)
        assertEquals(setOf("a", "b"), InstalledAppsUpload.iconBatch(listOf("a", "b", "c"), sizes))
        assertEquals(setOf("big"), InstalledAppsUpload.iconBatch(listOf("big", "a"), sizes))
    }

    @Test fun aFirstPutNamesHashesThenSendsOnlyTheMissingIcon() {
        val youtube = InstalledAppRecord(
            "com.google.android.youtube",
            "YouTube",
            iconSha256 = "aa",
            iconPng = byteArrayOf(1, 2, 3, 4),
        )
        val phone = InstalledAppRecord(
            "com.android.dialer",
            "Phone",
            alwaysAllowed = true,
            iconSha256 = "bb",
            iconPng = byteArrayOf(9),
        )
        val attaches = mutableListOf<Set<String>>()
        InstalledAppsUpload.putSnapshot(listOf(youtube, phone)) { attach ->
            attaches.add(attach)
            if (attaches.size == 1) listOf("aa") else emptyList()
        }
        assertEquals(listOf(emptySet<String>(), setOf("aa")), attaches)
    }

    @Test fun aHashTheServerKeepsAskingForDoesNotLoop() {
        val app = InstalledAppRecord("com.app", "App", iconSha256 = "aa", iconPng = byteArrayOf(1))
        val attaches = mutableListOf<Set<String>>()
        InstalledAppsUpload.putSnapshot(listOf(app)) { attach ->
            attaches.add(attach)
            listOf("aa")
        }
        assertEquals(2, attaches.size)
        assertEquals(emptySet<String>(), attaches.first())
        assertEquals(setOf("aa"), attaches.last())
    }
}

class AppClientHeadersTest {
    @Test fun nativeHeadersComeFromTheBuildNotLiterals() {
        val headers = AppClientHeaders.values("1.0.9", 33)
        assertEquals("1.0.9", headers[AppClientHeaders.VERSION])
        assertEquals("33", headers[AppClientHeaders.BUILD])
        assertEquals("android", headers[AppClientHeaders.PLATFORM])
    }

    @Test fun aMissingVersionNameIsStillSentAsAnEmptyHeader() {
        val headers = AppClientHeaders.values(null, 1)
        assertEquals("", headers[AppClientHeaders.VERSION])
        assertEquals("1", headers[AppClientHeaders.BUILD])
    }
}
