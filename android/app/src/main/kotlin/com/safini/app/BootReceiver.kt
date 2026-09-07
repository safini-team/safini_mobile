package com.safini.app

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent

class BootReceiver : BroadcastReceiver() {
    override fun onReceive(context: Context, intent: Intent?) {
        if (intent?.action !in setOf(Intent.ACTION_BOOT_COMPLETED, Intent.ACTION_LOCKED_BOOT_COMPLETED, Intent.ACTION_MY_PACKAGE_REPLACED)) return
        if (!EnforcementStore(context).enabled) return
        // The service waits for credential unlock before querying UsageStats or networking.
        runCatching { context.startForegroundService(Intent(context, AppBlockForegroundService::class.java)) }
    }
}
