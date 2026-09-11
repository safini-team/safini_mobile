package com.safini.app

import android.app.NotificationChannel
import android.app.NotificationManager
import android.content.Intent
import android.net.Uri
import android.os.Build
import android.os.Handler
import android.os.Looper
import android.provider.Settings
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        createProtectionChannel()
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, "com.safini.app/app_block")
            .setMethodCallHandler { call, result ->
                try {
                    val client = EnforcementClient(this)
                    when (call.method) {
                        "hasUsageAccess" -> result.success(usageAccess(this))
                        "hasOverlayPermission" -> result.success(Settings.canDrawOverlays(this))
                        "requestUsageAccess" -> {
                            startActivity(Intent(Settings.ACTION_USAGE_ACCESS_SETTINGS)); result.success(null)
                        }
                        "requestOverlayPermission" -> {
                            startActivity(Intent(Settings.ACTION_MANAGE_OVERLAY_PERMISSION, Uri.parse("package:$packageName")))
                            result.success(null)
                        }
                        "requestBatterySettings" -> {
                            startActivity(Intent(Settings.ACTION_IGNORE_BATTERY_OPTIMIZATION_SETTINGS)); result.success(null)
                        }
                        "isConfigured" -> result.success(client.configured(call.argument<String>("childId")!!))
                        "configure" -> {
                            val childId = call.argument<String>("childId")!!
                            if (client.childId() != childId) {
                                AppBlockForegroundService.instance?.shutdown()
                                EnforcementStore(this).clear()
                            }
                            client.configure(call.argument<String>("baseUrl")!!, childId,
                                call.argument<String>("token")!!, call.argument<String>("expiresAt")!!)
                            call.argument<String>("language")?.let { EnforcementStore(this).language = it }
                            result.success(null)
                        }
                        "syncNow", "startService" -> {
                            if (!usageAccess(this) || !Settings.canDrawOverlays(this)) {
                                result.error("permissions", "Grant both app-limit permissions.", null)
                            } else {
                                if (Build.VERSION.SDK_INT >= 33 && checkSelfPermission(android.Manifest.permission.POST_NOTIFICATIONS) != android.content.pm.PackageManager.PERMISSION_GRANTED) {
                                    requestPermissions(arrayOf(android.Manifest.permission.POST_NOTIFICATIONS), 4711)
                                }
                                startForegroundService(Intent(this, AppBlockForegroundService::class.java))
                                syncWhenStarted(result, 0)
                            }
                        }
                        "purchaseTime" -> {
                            val service = AppBlockForegroundService.instance
                            if (service == null) result.error("service", "Connect app limits first.", null)
                            else service.purchaseTime(call.argument<String>("slug")!!,
                                call.argument<Int>("cost")!!, call.argument<Int>("minutes")!!) { snapshot, error ->
                                if (error == null) result.success(snapshot.toString()) else result.error("purchase", error.message, null)
                            }
                        }
                        "isRunning" -> result.success(AppBlockForegroundService.instance != null)
                        "hasSnapshot" -> result.success(EnforcementStore(this).snapshot.has("usage_date"))
                        "setLanguage" -> { EnforcementStore(this).language = call.argument<String>("language") ?: "en"; result.success(null) }
                        "stopService" -> {
                            AppBlockForegroundService.instance?.shutdown()
                            EnforcementStore(this).clear()
                            // Best effort remote revocation; local cleanup must also work offline.
                            Thread {
                                runCatching { client.request("/session", null, "DELETE") }
                                client.clear()
                                runOnUiThread { result.success(null) }
                            }.start()
                        }
                        "installedApps" -> result.success(installedLaunchableApps())
                        else -> result.notImplemented()
                    }
                } catch (e: Exception) { result.error("enforcement", e.message, null) }
            }
    }
    private fun syncWhenStarted(result: MethodChannel.Result, attempt: Int) {
        val service = AppBlockForegroundService.instance
        if (service != null) service.syncNow { error ->
            if (error == null) result.success(null) else result.error("sync", error.message, null)
        } else if (attempt < 30) Handler(Looper.getMainLooper()).postDelayed({ syncWhenStarted(result, attempt+1) },100)
        else result.error("service", "Unable to start app limits.", null)
    }

    /// Protection alerts are posted here. Importance is HIGH because a parent
    /// losing app limits is the one thing this app must not deliver silently.
    private fun createProtectionChannel() {
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.O) return
        val manager = getSystemService(NotificationManager::class.java) ?: return
        manager.createNotificationChannel(
            NotificationChannel(
                "safini_protection",
                getString(R.string.protection_channel_name),
                NotificationManager.IMPORTANCE_HIGH,
            )
        )
    }

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
