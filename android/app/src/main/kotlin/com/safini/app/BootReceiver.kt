package com.safini.app

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent

class BootReceiver : BroadcastReceiver() {
    override fun onReceive(context: Context, intent: Intent?) {
        if (intent?.action !in setOf(Intent.ACTION_BOOT_COMPLETED, Intent.ACTION_LOCKED_BOOT_COMPLETED, Intent.ACTION_MY_PACKAGE_REPLACED)) return
        val store = EnforcementStore(context)
        if (!store.enabled) return
        if (intent?.action != Intent.ACTION_MY_PACKAGE_REPLACED && AppBlockForegroundService.instance == null) {
            // An abrupt shutdown may have no UsageStats shutdown event. Never
            // replay the powered-off interval as foreground usage after boot.
            store.foreground = null
            store.covered = false
            store.cursor = System.currentTimeMillis()
            store.persist()
        }
        // The service waits for credential unlock before querying UsageStats or networking.
        runCatching { context.startForegroundService(Intent(context, AppBlockForegroundService::class.java)) }
    }
}
