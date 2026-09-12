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

class BlockTasksTest {
    private val short = BlockFacts("roblox", "Roblox", paused = false, dayCap = false, canUnlock = true, cost = 60,
        minutes = 30, balance = 20, allowanceMinutes = 60, resetInMinutes = 432, remainingSeconds = 0,
        tasks = listOf(BlockTask("Read for 20 mins", "learn", 25), BlockTask("Tidy the room", "home", 15), BlockTask("Walk", "outdoor", 5)))

    @Test fun twoTasksCloseTheGap() = assertEquals(2, short.tasksToGo)
    @Test fun oneTaskIsEnough() = assertEquals(1, short.copy(balance = 40).tasksToGo)
    @Test fun allTasksFallShort() = assertEquals(null, short.copy(balance = 0, cost = 100).tasksToGo)
    @Test fun noTasksNoPlan() = assertEquals(null, short.copy(tasks = emptyList()).tasksToGo)
}
