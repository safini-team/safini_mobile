package com.safini.app

import android.app.admin.DeviceAdminReceiver
import android.app.admin.DevicePolicyManager
import android.content.ComponentName
import android.content.Context
import android.content.Intent

/**
 * Being an active device admin is what stops a child from just uninstalling
 * Safini (or clearing its data) to drop the limits. We ask for no policy - no
 * lock, wipe or password control - so the activation dialog is honest and there
 * is nothing invasive for the child or Play review to worry about.
 *
 * The one thing we do with the callbacks: the moment admin is removed, push a
 * heartbeat so the server sees it and alerts the parent. Removing admin is the
 * gate to uninstalling, so this fires while the app still works, before the app
 * can be gone.
 */
class SafiniDeviceAdminReceiver : DeviceAdminReceiver() {
    override fun onEnabled(context: Context, intent: Intent) = ping(context)
    override fun onDisabled(context: Context, intent: Intent) = ping(context)

    override fun onDisableRequested(context: Context, intent: Intent): CharSequence {
        // The confirm dialog before removal. Also nudge a heartbeat, so even if
        // onDisabled is delayed the parent hears about it as early as possible.
        ping(context)
        return context.getString(R.string.device_admin_disable_warning)
    }

    /** Report the new state now instead of waiting up to a minute for the next tick. */
    private fun ping(context: Context) {
        val running = AppBlockForegroundService.instance
        if (running != null) running.syncNow()
        else runCatching {
            context.startForegroundService(
                Intent(context, AppBlockForegroundService::class.java)
                    .setAction(AppBlockForegroundService.ACTION_SYNC)
            )
        }
    }

    companion object {
        fun component(context: Context) =
            ComponentName(context.applicationContext, SafiniDeviceAdminReceiver::class.java)

        fun isActive(context: Context): Boolean = runCatching {
            context.getSystemService(DevicePolicyManager::class.java)
                .isAdminActive(component(context))
        }.getOrDefault(false)

        /** Called on explicit sign-out so the app can be uninstalled normally again. */
        fun deactivate(context: Context) {
            runCatching {
                val dpm = context.getSystemService(DevicePolicyManager::class.java)
                val admin = component(context)
                if (dpm.isAdminActive(admin)) dpm.removeActiveAdmin(admin)
            }
        }
    }
}
