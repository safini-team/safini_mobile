package com.safini.app

import android.app.Notification
import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.PendingIntent
import android.app.Service
import android.app.usage.UsageEvents
import android.app.usage.UsageStatsManager
import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.content.IntentFilter
import android.content.pm.ServiceInfo
import android.graphics.Color
import android.graphics.PixelFormat
import android.os.Build
import android.os.Handler
import android.os.IBinder
import android.os.Looper
import android.view.Gravity
import android.view.View
import android.view.WindowManager
import android.widget.Button
import android.widget.FrameLayout
import android.widget.LinearLayout
import android.widget.TextView
import java.util.Calendar
import kotlin.math.max

/**
 * Polls the current foreground app every [POLL_INTERVAL_MS] and, when it matches
 * a manual block or an exceeded time limit, draws a full-screen [WindowManager]
 * overlay that prevents further use.
 *
 * Enforcement is millisecond-accurate: usage is measured from the event log via
 * [UsageStatsManager.queryEvents], not `queryUsageStats` (which is ~1-minute
 * granular and would break short limits).
 *
 * Rules are read from [AppBlockStore]; the service reloads them whenever it
 * receives [AppBlockStore.ACTION_UPDATE].
 */
class AppBlockForegroundService : Service() {

    companion object {
        private const val POLL_INTERVAL_MS = 500L
        private const val FOREGROUND_LOOKBACK_MS = 10_000L
        private const val NOTIF_CHANNEL = "safini_app_block"
        private const val NOTIF_ID = 4711
    }

    private val handler = Handler(Looper.getMainLooper())
    private lateinit var windowManager: WindowManager
    private lateinit var usageStatsManager: UsageStatsManager

    private var limits: Map<String, Long> = emptyMap()
    private var limitStarts: Map<String, Long> = emptyMap()
    private var blocked: Set<String> = emptySet()

    private var currentApp: String? = null
    private var lastEventQuery = 0L

    private var overlayView: View? = null
    private var overlayTitle: String? = null

    private val updateReceiver = object : BroadcastReceiver() {
        override fun onReceive(context: Context?, intent: Intent?) = loadRules()
    }

    private val poll = object : Runnable {
        override fun run() {
            try {
                enforce()
            } finally {
                handler.postDelayed(this, POLL_INTERVAL_MS)
            }
        }
    }

    override fun onCreate() {
        super.onCreate()
        windowManager = getSystemService(WINDOW_SERVICE) as WindowManager
        usageStatsManager = getSystemService(USAGE_STATS_SERVICE) as UsageStatsManager
        registerUpdateReceiver()
        loadRules()
    }

    override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int {
        startForegroundSafely()
        AppBlockStore.setEnforcing(this, true)
        handler.removeCallbacks(poll)
        handler.post(poll)
        return START_STICKY
    }

    override fun onDestroy() {
        handler.removeCallbacks(poll)
        runCatching { unregisterReceiver(updateReceiver) }
        removeOverlay()
        super.onDestroy()
    }

    override fun onBind(intent: Intent?): IBinder? = null

    // ── Rule loading ────────────────────────────────────────────────────────────

    private fun loadRules() {
        limits = AppBlockStore.readLimits(this)
        limitStarts = AppBlockStore.readLimitStarts(this)
        blocked = AppBlockStore.readBlocked(this)
    }

    // ── Enforcement loop ─────────────────────────────────────────────────────────

    private fun enforce() {
        updateForegroundApp()
        val fg = currentApp

        // Never block ourselves or an unknown/home state.
        if (fg == null || fg == packageName) {
            removeOverlay()
            return
        }

        if (blocked.contains(fg)) {
            showOverlay("App Blocked", "This app is blocked right now.")
            return
        }

        val limitMs = limits[fg]
        if (limitMs != null) {
            val measureFrom = max(startOfDay(), limitStarts[fg] ?: startOfDay())
            val usedMs = computeUsageMs(fg, measureFrom, System.currentTimeMillis())
            if (usedMs >= limitMs) {
                showOverlay("Time Limit Reached", "You've reached today's limit for this app.")
                return
            }
        }

        removeOverlay()
    }

    /** Keeps [currentApp] sticky between polls by consuming new foreground events. */
    private fun updateForegroundApp() {
        val now = System.currentTimeMillis()
        val from = if (lastEventQuery == 0L) now - FOREGROUND_LOOKBACK_MS else lastEventQuery
        val events = usageStatsManager.queryEvents(from, now)
        val event = UsageEvents.Event()
        while (events.hasNextEvent()) {
            events.getNextEvent(event)
            if (event.eventType == UsageEvents.Event.MOVE_TO_FOREGROUND) {
                currentApp = event.packageName
            }
        }
        lastEventQuery = now
    }

    private fun computeUsageMs(packageName: String, from: Long, to: Long): Long {
        if (to <= from) return 0L
        val events = usageStatsManager.queryEvents(from, to)
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

    // ── Overlay ───────────────────────────────────────────────────────────────────

    private fun showOverlay(title: String, message: String) {
        if (overlayView != null) {
            if (overlayTitle != title) updateOverlayText(title, message)
            return
        }

        val view = buildOverlayView(title, message)
        val type = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            WindowManager.LayoutParams.TYPE_APPLICATION_OVERLAY
        } else {
            @Suppress("DEPRECATION")
            WindowManager.LayoutParams.TYPE_PHONE
        }
        val params = WindowManager.LayoutParams(
            WindowManager.LayoutParams.MATCH_PARENT,
            WindowManager.LayoutParams.MATCH_PARENT,
            type,
            WindowManager.LayoutParams.FLAG_KEEP_SCREEN_ON or
                WindowManager.LayoutParams.FLAG_LAYOUT_IN_SCREEN,
            PixelFormat.OPAQUE,
        )
        runCatching {
            windowManager.addView(view, params)
            overlayView = view
            overlayTitle = title
        }
    }

    private fun updateOverlayText(title: String, message: String) {
        overlayTitle = title
        val root = overlayView as? FrameLayout ?: return
        val column = root.getChildAt(0) as? LinearLayout ?: return
        (column.getChildAt(0) as? TextView)?.text = title
        (column.getChildAt(1) as? TextView)?.text = message
    }

    private fun removeOverlay() {
        val view = overlayView ?: return
        runCatching { windowManager.removeView(view) }
        overlayView = null
        overlayTitle = null
    }

    private fun buildOverlayView(title: String, message: String): View {
        val density = resources.displayMetrics.density
        fun dp(value: Int) = (value * density).toInt()

        val titleView = TextView(this).apply {
            text = title
            setTextColor(Color.WHITE)
            textSize = 26f
            gravity = Gravity.CENTER
        }
        val messageView = TextView(this).apply {
            text = message
            setTextColor(Color.parseColor("#CCFFFFFF"))
            textSize = 16f
            gravity = Gravity.CENTER
            setPadding(0, dp(12), 0, dp(28))
        }
        val homeButton = Button(this).apply {
            text = "Go to Home"
            setOnClickListener {
                startActivity(
                    Intent(Intent.ACTION_MAIN).apply {
                        addCategory(Intent.CATEGORY_HOME)
                        flags = Intent.FLAG_ACTIVITY_NEW_TASK
                    },
                )
                removeOverlay()
            }
        }

        val column = LinearLayout(this).apply {
            orientation = LinearLayout.VERTICAL
            gravity = Gravity.CENTER
            setPadding(dp(32), dp(32), dp(32), dp(32))
            addView(titleView)
            addView(messageView)
            addView(homeButton)
        }

        return FrameLayout(this).apply {
            setBackgroundColor(Color.parseColor("#F25100D1"))
            addView(
                column,
                FrameLayout.LayoutParams(
                    FrameLayout.LayoutParams.MATCH_PARENT,
                    FrameLayout.LayoutParams.MATCH_PARENT,
                ).apply { gravity = Gravity.CENTER },
            )
        }
    }

    // ── Foreground notification ────────────────────────────────────────────────────

    private fun startForegroundSafely() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            val channel = NotificationChannel(
                NOTIF_CHANNEL,
                "App time enforcement",
                NotificationManager.IMPORTANCE_LOW,
            ).apply { description = "Keeps app time limits active." }
            (getSystemService(NOTIFICATION_SERVICE) as NotificationManager)
                .createNotificationChannel(channel)
        }

        val contentIntent = PendingIntent.getActivity(
            this,
            0,
            packageManager.getLaunchIntentForPackage(packageName),
            PendingIntent.FLAG_IMMUTABLE or PendingIntent.FLAG_UPDATE_CURRENT,
        )

        val notification: Notification =
            Notification.Builder(this, NOTIF_CHANNEL)
                .setContentTitle("Safini")
                .setContentText("App time limits are active.")
                .setSmallIcon(applicationInfo.icon)
                .setOngoing(true)
                .setContentIntent(contentIntent)
                .build()

        if (Build.VERSION.SDK_INT >= 34) {
            startForeground(
                NOTIF_ID,
                notification,
                ServiceInfo.FOREGROUND_SERVICE_TYPE_SPECIAL_USE,
            )
        } else {
            startForeground(NOTIF_ID, notification)
        }
    }

    private fun registerUpdateReceiver() {
        val filter = IntentFilter(AppBlockStore.ACTION_UPDATE)
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
            registerReceiver(updateReceiver, filter, Context.RECEIVER_NOT_EXPORTED)
        } else {
            @Suppress("UnspecifiedRegisterReceiverFlag")
            registerReceiver(updateReceiver, filter)
        }
    }
}
