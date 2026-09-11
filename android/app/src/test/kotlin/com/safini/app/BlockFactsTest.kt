package com.safini.app

import org.junit.Assert.assertEquals
import org.junit.Test

class BlockFactsTest {
    private val roblox = BlockFacts("roblox", "Roblox", paused = false, dayCap = false, canUnlock = true, cost = 60,
        minutes = 30, balance = 240, allowanceMinutes = 60, resetInMinutes = 432, remainingSeconds = 0)

    @Test fun outOfTimeOffersTheUnlock() = assertEquals(BlockScreen.OUT_OF_TIME, roblox.screen)
    @Test fun shortOfCoinsPointsAtTasks() = assertEquals(BlockScreen.NEED_COINS, roblox.copy(balance = 20).screen)
    @Test fun exactBalanceCanUnlock() = assertEquals(BlockScreen.OUT_OF_TIME, roblox.copy(balance = 60).screen)
    @Test fun parentPauseBeatsEverything() =
        assertEquals(BlockScreen.PAUSED, roblox.copy(paused = true, dayCap = true, balance = 0).screen)
    @Test fun overallCapBeatsCoins() = assertEquals(BlockScreen.DAY_CAP, roblox.copy(dayCap = true).screen)
    @Test fun noCoinUnlockIsNeverShortOfCoins() =
        assertEquals(BlockScreen.OUT_OF_TIME, roblox.copy(canUnlock = false, balance = 0).screen)
}
