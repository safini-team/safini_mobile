package com.safini.app

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.os.Build

/**
 * Restarts the enforcement service after a reboot, but only when it was active
 * before shutdown (tracked via [AppBlockStore.isEnforcing]). This does not
 * recover from a user Force-Stop — Android only redelivers BOOT_COMPLETED, not
 * force-stop events.
 */
class BootReceiver : BroadcastReceiver() {
    override fun onReceive(context: Context, intent: Intent?) {
        val action = intent?.action ?: return
        if (action != Intent.ACTION_BOOT_COMPLETED &&
            action != Intent.ACTION_LOCKED_BOOT_COMPLETED
        ) {
            return
        }
        if (!AppBlockStore.isEnforcing(context)) return

        val serviceIntent = Intent(context, AppBlockForegroundService::class.java)
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            context.startForegroundService(serviceIntent)
        } else {
            context.startService(serviceIntent)
        }
    }
}
