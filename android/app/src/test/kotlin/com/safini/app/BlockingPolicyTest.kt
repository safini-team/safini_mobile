package com.safini.app

import org.junit.Assert.*
import org.junit.Test

class BlockingPolicyTest {
    private val minute = 60_000L
    @Test fun unlimitedIsNotBlocked() {
        assertNull(BlockingPolicy.remaining(BlockingRule(false, false, 0, 0, 0), 100, true, null))
    }
    @Test fun manualBlockWins() {
        assertEquals(0L, BlockingPolicy.remaining(BlockingRule(true, false, 60*minute, 0, 30*minute), 0, true, null))
    }
    @Test fun purchasedMinutesAreNotDeductedTwice() {
        val rule = BlockingRule(false, true, 60*minute, 68*minute, 12*minute)
        assertEquals(12*minute, rule.remaining(68*minute, true))
        assertEquals(11*minute, rule.remaining(69*minute, true))
    }
    @Test fun resyncDoesNotResetConsumedTime() {
        val rule = BlockingRule(false, true, 60*minute, 20*minute, 0)
        assertEquals(39*minute, rule.remaining(21*minute, true))
        assertEquals(39*minute, rule.copy(serverUsedMs=21*minute).remaining(21*minute, true))
    }
    @Test fun dailyResetExpiresPurchasedTime() {
        val rule = BlockingRule(false, true, 60*minute, 68*minute, 12*minute)
        assertEquals(60*minute, rule.remaining(0, false))
    }
    @Test fun overallCapAppliesToUnlimitedApps() {
        assertEquals(15L, BlockingPolicy.remaining(BlockingRule(false, false, 0, 0, 0), 0, true, 15))
    }
    @Test fun zeroAllowanceRequiresPurchase() {
        assertEquals(0L, BlockingRule(false, true, 0, 0, 0).remaining(0, true))
        assertEquals(30*minute, BlockingRule(false, true, 0, 0, 30*minute).remaining(0, true))
    }
}
