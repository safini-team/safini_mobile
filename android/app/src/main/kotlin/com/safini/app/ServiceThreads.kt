package com.safini.app

import java.util.concurrent.ArrayBlockingQueue
import java.util.concurrent.ExecutorService
import java.util.concurrent.Executors
import java.util.concurrent.ThreadPoolExecutor
import java.util.concurrent.TimeUnit

/**
 * The enforcement service's background threads. Heartbeats, the backfill and
 * purchases run on [network]. An installed-apps upload renders every icon and
 * can hold a slow connection for minutes, so it runs on [uploads] and never
 * delays a heartbeat or a purchase.
 */
class ServiceThreads {
    val network: ExecutorService = Executors.newSingleThreadExecutor()

    /** One thread, and at most one upload waiting behind it: each upload rescans, so a second would add nothing. */
    val uploads: ExecutorService =
        ThreadPoolExecutor(1, 1, 0L, TimeUnit.MILLISECONDS, ArrayBlockingQueue(1), ThreadPoolExecutor.DiscardPolicy())

    fun shutdownNow() {
        network.shutdownNow()
        uploads.shutdownNow()
    }
}
