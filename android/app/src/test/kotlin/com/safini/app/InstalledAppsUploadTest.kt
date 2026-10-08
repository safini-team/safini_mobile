package com.safini.app

import org.json.JSONObject
import org.junit.Assert.assertEquals
import org.junit.Assert.assertFalse
import org.junit.Assert.assertTrue
import org.junit.Test
import java.util.Base64

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
        val puts = mutableListOf<JSONObject>()
        InstalledAppsUpload.putSnapshot(listOf(youtube, phone)) { body ->
            puts.add(body)
            val apps = body.getJSONArray("apps")
            if (puts.size == 1) {
                assertFalse(apps.getJSONObject(0).has("icon_png"))
                assertTrue(apps.getJSONObject(1).getBoolean("always_allowed"))
                JSONObject().put("missing_icon_sha256", org.json.JSONArray().put("aa"))
            } else {
                JSONObject().put("missing_icon_sha256", org.json.JSONArray())
            }
        }
        assertEquals(2, puts.size)
        val second = puts.last().getJSONArray("apps").getJSONObject(0)
        assertEquals("aa", second.getString("icon_sha256"))
        assertEquals(Base64.getEncoder().encodeToString(byteArrayOf(1, 2, 3, 4)), second.getString("icon_png"))
        assertFalse(puts.last().getJSONArray("apps").getJSONObject(1).has("icon_png"))
    }

    @Test fun aHashTheServerKeepsAskingForDoesNotLoop() {
        val app = InstalledAppRecord("com.app", "App", iconSha256 = "aa", iconPng = byteArrayOf(1))
        val puts = mutableListOf<JSONObject>()
        InstalledAppsUpload.putSnapshot(listOf(app)) { body ->
            puts.add(body)
            JSONObject().put("missing_icon_sha256", org.json.JSONArray().put("aa"))
        }
        assertEquals(2, puts.size)
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
