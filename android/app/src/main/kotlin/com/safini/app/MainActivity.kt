package com.safini.app

import android.app.AppOpsManager
import android.app.usage.UsageEvents
import android.app.usage.UsageStatsManager
import android.content.Context
import android.content.Intent
import android.net.Uri
import android.os.Build
import android.os.Process
import android.provider.Settings
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import java.util.Calendar
import kotlin.math.max

class MainActivity : FlutterActivity() {

    private companion object {
        const val CHANNEL = "com.safini.app/app_block"
    }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL)
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "hasUsageAccess" -> result.success(hasUsageAccess())
                    "hasOverlayPermission" -> result.success(Settings.canDrawOverlays(this))

                    "requestUsageAccess" -> {
                        startActivity(
                            Intent(Settings.ACTION_USAGE_ACCESS_SETTINGS)
                                .addFlags(Intent.FLAG_ACTIVITY_NEW_TASK),
                        )
                        result.success(null)
                    }

                    "requestOverlayPermission" -> {
                        startActivity(
                            Intent(
                                Settings.ACTION_MANAGE_OVERLAY_PERMISSION,
                                Uri.parse("package:$packageName"),
                            ).addFlags(Intent.FLAG_ACTIVITY_NEW_TASK),
                        )
                        result.success(null)
                    }

                    "startService" -> {
                        val intent = Intent(this, AppBlockForegroundService::class.java)
                        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
                            startForegroundService(intent)
                        } else {
                            startService(intent)
                        }
                        result.success(null)
                    }

                    "stopService" -> {
                        AppBlockStore.setEnforcing(this, false)
                        stopService(Intent(this, AppBlockForegroundService::class.java))
                        result.success(null)
                    }

                    "setAppLimit" -> {
                        val pkg = call.argument<String>("packageName")
                        val limitMs = (call.argument<Number>("limitMs"))?.toLong()
                        if (pkg == null || limitMs == null) {
                            result.error("bad_args", "packageName and limitMs required", null)
                        } else {
                            AppBlockStore.setLimit(this, pkg, limitMs)
                            result.success(null)
                        }
                    }

                    "removeAppLimit" -> {
                        val pkg = call.argument<String>("packageName")
                        if (pkg == null) {
                            result.error("bad_args", "packageName required", null)
                        } else {
                            AppBlockStore.removeLimit(this, pkg)
                            result.success(null)
                        }
                    }

                    "setManualBlock" -> {
                        val pkg = call.argument<String>("packageName")
                        val blocked = call.argument<Boolean>("blocked") ?: false
                        if (pkg == null) {
                            result.error("bad_args", "packageName required", null)
                        } else {
                            AppBlockStore.setManualBlock(this, pkg, blocked)
                            result.success(null)
                        }
                    }

                    "syncRules" -> {
                        @Suppress("UNCHECKED_CAST")
                        val rules = call.argument<List<Map<String, Any?>>>("rules") ?: emptyList()
                        AppBlockStore.syncRules(this, rules)
                        result.success(null)
                    }

                    "measuredUsageMs" -> result.success(measuredUsageMs())

                    "usageSinceMidnight" -> {
                        val packages = call.argument<List<String>>("packages") ?: emptyList()
                        result.success(usageSinceMidnight(packages))
                    }

                    "installedApps" -> result.success(installedLaunchableApps())

                    else -> result.notImplemented()
                }
            }
    }

    // ── Permissions ─────────────────────────────────────────────────────────────

    private fun hasUsageAccess(): Boolean {
        val appOps = getSystemService(Context.APP_OPS_SERVICE) as AppOpsManager
        val mode = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
            appOps.unsafeCheckOpNoThrow(
                AppOpsManager.OPSTR_GET_USAGE_STATS,
                Process.myUid(),
                packageName,
            )
        } else {
            @Suppress("DEPRECATION")
            appOps.checkOpNoThrow(
                AppOpsManager.OPSTR_GET_USAGE_STATS,
                Process.myUid(),
                packageName,
            )
        }
        return mode == AppOpsManager.MODE_ALLOWED
    }

    // ── Usage measurement (mirrors the service's window) ──────────────────────────

    private fun measuredUsageMs(): Map<String, Long> {
        val limits = AppBlockStore.readLimits(this)
        if (limits.isEmpty()) return emptyMap()
        val starts = AppBlockStore.readLimitStarts(this)
        val usm = getSystemService(Context.USAGE_STATS_SERVICE) as UsageStatsManager
        val now = System.currentTimeMillis()
        val out = HashMap<String, Long>()
        for (pkg in limits.keys) {
            val from = max(startOfDay(), starts[pkg] ?: startOfDay())
            out[pkg] = computeUsageMs(usm, pkg, from, now)
        }
        return out
    }

    /**
     * Usage per package measured from midnight to now — the day total the
     * backend expects for `used_minutes` (independent of any limit window).
     */
    private fun usageSinceMidnight(packages: List<String>): Map<String, Long> {
        if (packages.isEmpty()) return emptyMap()
        val usm = getSystemService(Context.USAGE_STATS_SERVICE) as UsageStatsManager
        val now = System.currentTimeMillis()
        val from = startOfDay()
        val out = HashMap<String, Long>()
        for (pkg in packages) {
            out[pkg] = computeUsageMs(usm, pkg, from, now)
        }
        return out
    }

    private fun computeUsageMs(
        usm: UsageStatsManager,
        packageName: String,
        from: Long,
        to: Long,
    ): Long {
        if (to <= from) return 0L
        val events = usm.queryEvents(from, to)
        val event = UsageEvents.Event()
        var total = 0L
        var lastForeground = -1L
        while (events.hasNextEvent()) {
            events.getNextEvent(event)
            if (event.packageName != packageName) continue
            when (event.eventType) {
                UsageEvents.Event.MOVE_TO_FOREGROUND -> lastForeground = event.timeStamp
                UsageEvents.Event.MOVE_TO_BACKGROUND -> {
                    if (lastForeground >= 0) {
                        total += event.timeStamp - lastForeground
                        lastForeground = -1
                    }
                }
            }
        }
        if (lastForeground >= 0) total += to - lastForeground
        return total
    }

    private fun startOfDay(): Long {
        val cal = Calendar.getInstance()
        cal.set(Calendar.HOUR_OF_DAY, 0)
        cal.set(Calendar.MINUTE, 0)
        cal.set(Calendar.SECOND, 0)
        cal.set(Calendar.MILLISECOND, 0)
        return cal.timeInMillis
    }

    // ── Installed apps (optional picker support) ──────────────────────────────────

    private fun installedLaunchableApps(): List<Map<String, String>> {
        val pm = packageManager
        val intent = Intent(Intent.ACTION_MAIN).addCategory(Intent.CATEGORY_LAUNCHER)
        return pm.queryIntentActivities(intent, 0)
            .mapNotNull { info ->
                val appPackage = info.activityInfo?.packageName ?: return@mapNotNull null
                if (appPackage == packageName) return@mapNotNull null
                mapOf(
                    "packageName" to appPackage,
                    "appName" to info.loadLabel(pm).toString(),
                )
            }
            .distinctBy { it["packageName"] }
    }
}
