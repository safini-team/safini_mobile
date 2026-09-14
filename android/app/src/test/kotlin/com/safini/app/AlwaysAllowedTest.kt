package com.safini.app

import org.junit.Assert.assertEquals
import org.junit.Assert.assertFalse
import org.junit.Assert.assertTrue
import org.junit.Test

class AlwaysAllowedTest {
    @Test fun knownPhoneMessagesAndSettingsAreAlwaysAllowed() {
        val packages = AlwaysAllowed.merge(emptyList())
        listOf("com.google.android.dialer", "com.samsung.android.dialer", "com.google.android.apps.messaging",
            "com.samsung.android.messaging", "com.android.settings").forEach { assertTrue(it, it in packages) }
        assertFalse("com.whatsapp" in packages)
    }

    @Test fun thePhonesOwnDefaultsAreAddedToTheKnownOnes() {
        val packages = AlwaysAllowed.merge(listOf("com.android.contacts", null, "", "com.android.settings"))
        assertTrue("com.android.contacts" in packages)
        assertEquals(AlwaysAllowed.KNOWN + "com.android.contacts", packages)
    }
}
