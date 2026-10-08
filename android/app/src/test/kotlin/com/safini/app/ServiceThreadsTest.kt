package com.safini.app

import org.junit.Assert.assertEquals
import org.junit.Assert.assertTrue
import org.junit.Test
import java.util.concurrent.CountDownLatch
import java.util.concurrent.TimeUnit
import java.util.concurrent.atomic.AtomicInteger

class ServiceThreadsTest {
    @Test fun aStuckUploadDoesNotHoldUpAHeartbeat() {
        val threads = ServiceThreads()
        val release = CountDownLatch(1)
        val heartbeat = CountDownLatch(1)
        threads.uploads.execute { release.await() }
        threads.network.execute { heartbeat.countDown() }
        val ran = heartbeat.await(5, TimeUnit.SECONDS)
        release.countDown()
        threads.uploads.shutdown()
        threads.network.shutdown()
        assertTrue("the heartbeat waited behind the upload", ran)
    }

    @Test fun aStuckUploadKeepsAtMostOneMoreWaiting() {
        val threads = ServiceThreads()
        val release = CountDownLatch(1)
        val ran = AtomicInteger()
        threads.uploads.execute { release.await() }
        repeat(5) { threads.uploads.execute { ran.incrementAndGet() } }
        release.countDown()
        threads.uploads.shutdown()
        assertTrue(threads.uploads.awaitTermination(5, TimeUnit.SECONDS))
        assertEquals(1, ran.get())
        threads.shutdownNow()
    }

    @Test fun shutdownStopsBothThreads() {
        val threads = ServiceThreads()
        val interrupted = CountDownLatch(1)
        threads.uploads.execute {
            try { Thread.sleep(60_000) } catch (_: InterruptedException) { interrupted.countDown() }
        }
        threads.shutdownNow()
        assertTrue(interrupted.await(5, TimeUnit.SECONDS))
        assertTrue(threads.network.isShutdown)
        assertTrue(threads.uploads.isShutdown)
    }
}
