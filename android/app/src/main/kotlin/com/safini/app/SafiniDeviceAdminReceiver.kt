package com.safini.app

import android.app.admin.DeviceAdminReceiver
import android.app.admin.DevicePolicyManager
import android.content.ComponentName
import android.content.Context
import android.content.Intent
import android.os.Build
import android.os.Handler
import android.os.Looper
import android.provider.Settings
import org.json.JSONObject
import java.util.concurrent.atomic.AtomicBoolean

/**
 * Being an active device admin is what stops a child from just uninstalling
 * Safini (or clearing its data, or force-stopping it) to drop the limits. We ask
 * for no policy - no lock, wipe or password control - so the activation dialog
 * is honest and there is nothing invasive for the child or Play review to weigh.
 *
 * The one thing we do with the callbacks: the moment admin is removed, push a
 * heartbeat that says so, because removing admin is the last step before an
 * uninstall and it fires while the app still works. The catch is timing: the
 * platform only strips the admin *after* onDisabled returns, so a plain
 * heartbeat here would still read `isAdminActive() == true`. We report an
 * explicit `false` and hold the broadcast open with goAsync() until it is sent.
 */
class SafiniDeviceAdminReceiver : DeviceAdminReceiver() {
    override fun onEnabled(context: Context, intent: Intent) {
        // Only nudge a service that is already up; never start one here, or a
        // sign-out (which deactivates admin) would resurrect a stopped service.
        AppBlockForegroundService.instance?.syncNow()
    }

    override fun onDisabled(context: Context, intent: Intent) {
        // A sanctioned sign-out clears the pairing before deactivating admin, so
        // enabled is already false: nothing to report, and no false alert.
        if (!EnforcementStore(context).enabled) return
        reportRemoved(context)
    }

    override fun onDisableRequested(context: Context, intent: Intent): CharSequence =
        context.getString(R.string.device_admin_disable_warning)

    /**
     * Post one heartbeat with `device_admin_active=false`, holding the broadcast
     * open until it lands. The uninstall path force-stops us ~10s after this
     * returns (DEVICE_ADMIN_DEACTIVATE_TIMEOUT), and EnforcementClient is a 10s
     * connect + 10s read, so we cap our own wait at 8s and finish regardless.
     */
    private fun reportRemoved(context: Context) {
        val pending = goAsync()
        val done = AtomicBoolean(false)
        val main = Handler(Looper.getMainLooper())
        val finish = Runnable { if (done.compareAndSet(false, true)) runCatching { pending.finish() } }
        main.postDelayed(finish, 8000)
        // The running service, if any, will not report the true state fast enough
        // and reads isAdminActive() as still-true, so we send false directly.
        EnforcementStore(context).deviceAdminSeen = true
        Thread {
            runCatching {
                val body = JSONObject()
                    .put("usage_access", usageAccess(context))
                    .put("overlay_permission", Settings.canDrawOverlays(context))
                    .put("service_running", AppBlockForegroundService.instance != null)
                    .put("manufacturer", Build.MANUFACTURER.take(80))
                    .put("device_admin_active", false)
                EnforcementClient(context).request("/sync", body)
            }
            main.removeCallbacks(finish)
            finish.run()
        }.start()
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
