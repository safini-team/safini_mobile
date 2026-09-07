package com.safini.app

import android.app.*
import android.app.usage.UsageEvents
import android.app.usage.UsageStatsManager
import android.content.*
import android.content.pm.ServiceInfo
import android.graphics.Color
import android.graphics.PixelFormat
import android.graphics.drawable.GradientDrawable
import android.view.View
import android.os.*
import android.provider.Settings
import android.view.Gravity
import android.view.WindowManager
import android.widget.*
import org.json.JSONObject
import java.util.concurrent.Executors

/** Native enforcement and sync continue even when Flutter is suspended. */
class AppBlockForegroundService : Service() {
    companion object {
        const val ACTION_SYNC = "com.safini.app.ENFORCEMENT_SYNC"
        var instance: AppBlockForegroundService? = null
            private set
    }
    private val handler = Handler(Looper.getMainLooper())
    private val network = Executors.newSingleThreadExecutor()
    private lateinit var store: EnforcementStore
    private lateinit var client: EnforcementClient
    private lateinit var windows: WindowManager
    private var overlay: View? = null
    private var overlayPackage: String? = null
    private var syncing = false
    private var stopped = false
    private var nextSync = 0L
    private var nextPersist = 0L
    private var purchase = false
    private val waiters = mutableListOf<(String?) -> Unit>()

    override fun onCreate() {
        super.onCreate()
        instance = this
        store = EnforcementStore(this)
        client = EnforcementClient(this)
        windows = getSystemService(WindowManager::class.java)
        notification()
        handler.post(tick)
    }
    override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int {
        store.enabled = true
        if (intent?.action == ACTION_SYNC) syncNow()
        return START_STICKY
    }
    override fun onBind(intent: Intent?): IBinder? = null
    fun shutdown() {
        stopped = true
        if (instance === this) instance = null
        store.enabled = false
        store.clear()
        stopSelf()
    }

    override fun onDestroy() {
        if (!stopped) store.persist()
        stopped = true
        handler.removeCallbacks(tick)
        removeOverlay()
        network.shutdownNow()
        waiters.toList().forEach { it("App limits stopped.") }
        waiters.clear()
        if (instance === this) instance = null
        super.onDestroy()
    }

    private val tick = object : Runnable {
        override fun run() {
            if (stopped) return
            val now = System.currentTimeMillis()
            try {
                if (getSystemService(UserManager::class.java).isUserUnlocked) {
                    if (usageAccess(this@AppBlockForegroundService)) account(now)
                    else { store.foreground = null; store.cursor = now }
                    val interactive = getSystemService(PowerManager::class.java).isInteractive &&
                        !getSystemService(KeyguardManager::class.java).isKeyguardLocked
                    val pkg = store.foreground
                    if (interactive && Settings.canDrawOverlays(this@AppBlockForegroundService) &&
                        pkg != null && pkg != packageName && store.remaining(pkg, now) == 0L) showOverlay(pkg)
                    else removeOverlay()
                    if (SystemClock.elapsedRealtime() >= nextSync && !syncing) syncNow()
                }
                if (SystemClock.elapsedRealtime() >= nextPersist) { store.persist(); nextPersist = SystemClock.elapsedRealtime()+5000 }
            } catch (_: Exception) {
                // Revoked Usage Access or a failed overlay must not crash the service.
                removeOverlay()
            } finally { if (!stopped) handler.postDelayed(this, 500) }
        }
    }

    private fun account(now: Long) {
        if (now < store.cursor) { store.cursor = now; return }
        val events = getSystemService(UsageStatsManager::class.java).queryEvents(store.cursor, now) ?: return
        val event = UsageEvents.Event()
        var from = store.cursor
        fun accrue(until: Long) {
            val pkg = store.foreground
            if (pkg != null && !store.covered && store.app(pkg) != null) {
                // Do not charge more usage than the budget, including during restart recovery.
                val allowed = store.remaining(pkg, from)
                val end = if (allowed == null) until else minOf(until, from+allowed)
                if (end > from) store.record(pkg, from, end)
            }
            from = until
        }
        while (events.hasNextEvent()) {
            events.getNextEvent(event)
            if (event.timeStamp < from) continue
            accrue(event.timeStamp)
            when (event.eventType) {
                UsageEvents.Event.MOVE_TO_FOREGROUND -> {
                    store.foreground = event.packageName
                    store.covered = store.remaining(event.packageName, event.timeStamp) == 0L
                }
                UsageEvents.Event.MOVE_TO_BACKGROUND -> if (store.foreground == event.packageName && !store.covered) store.foreground = null
                UsageEvents.Event.SCREEN_NON_INTERACTIVE,
                UsageEvents.Event.KEYGUARD_SHOWN,
                UsageEvents.Event.DEVICE_SHUTDOWN -> { store.foreground = null; store.covered = false }
            }
        }
        accrue(now)
        store.cursor = now
    }

    fun syncNow(done: ((String?) -> Unit)? = null) {
        done?.let { waiters.add(it) }
        if (syncing || stopped) return
        if (!getSystemService(UserManager::class.java).isUserUnlocked) return
        // Heartbeats must still run when Usage Access has been revoked.
        if (usageAccess(this)) runCatching { account(System.currentTimeMillis()) }
        syncing = true
        nextSync = SystemClock.elapsedRealtime()+60_000
        val body = JSONObject().put("usage", store.reports())
            .put("usage_access", usageAccess(this)).put("overlay_permission", Settings.canDrawOverlays(this))
            .put("service_running", true).put("manufacturer", Build.MANUFACTURER.take(80))
        network.execute {
            val response = runCatching { client.request("/sync", body) }
            handler.post {
                if (stopped) return@post
                response.onSuccess { store.applySnapshot(it); if (!purchase) removeOverlay() }
                syncing = false
                val callbacks = waiters.toList(); waiters.clear()
                callbacks.forEach { it(response.exceptionOrNull()?.message) }
            }
        }
    }

    fun purchaseTime(slug: String, cost: Int, minutes: Int, done: (JSONObject?, String?) -> Unit) {
        if (purchase || syncing) { done(null, "Please wait for the current operation."); return }
        purchase = true
        syncNow { syncError ->
            if (syncError != null) { purchase = false; done(null, syncError) }
            else network.execute {
                val result = runCatching {
                    client.request("/redeem", JSONObject().put("app_slug", slug)
                        .put("request_id", client.purchaseId(slug)).put("expected_coin_cost", cost)
                        .put("expected_reward_minutes", minutes))
                }
                handler.post {
                    purchase = false
                    if (stopped) { done(null, "App limits stopped."); return@post }
                    result.onSuccess { client.purchased(); store.applySnapshot(it); removeOverlay(); done(it, null) }
                        .onFailure { error ->
                            if (error is EnforcementHttpException && error.status in 400..499 && error.status != 408 && error.status != 429) client.purchased()
                            done(null, error.message)
                        }
                }
            }
        }
    }

    private fun text(en: String, ru: String, uz: String): String = when (store.language) { "ru" -> ru; "uz" -> uz; else -> en }
    private fun showOverlay(pkg: String) {
        if (overlayPackage == pkg && overlay != null) return
        removeOverlay()
        val app = store.app(pkg) ?: return
        val box = LinearLayout(this).apply {
            orientation = LinearLayout.VERTICAL
            gravity = Gravity.CENTER
            setPadding(48, 64, 48, 64)
            setBackgroundColor(Color.rgb(247,245,240))
        }
        fun label(value: String, size: Float) = TextView(this).apply {
            text = value; textSize = size; gravity = Gravity.CENTER
            setTextColor(Color.rgb(31,65,49)); setPadding(0,16,0,16)
            box.addView(this, LinearLayout.LayoutParams(-1,-2))
        }
        label("Safini", 32f)
        label(text("Time for a break", "Время для перерыва", "Tanaffus vaqti"), 25f)
        label(app.optString("display_name"), 20f)
        label(text("Time Coins", "Монеты времени", "Vaqt tangalari")+": "+store.snapshot.optInt("balance"), 18f)
        val blocked = app.optBoolean("is_blocked")
        val cost = app.optInt("redeem_coin_cost")
        val minutes = app.optInt("redeem_reward_minutes")
        val message = label(if (blocked) text("Your parent has paused this app.", "Родитель приостановил это приложение.", "Ota-onangiz bu ilovani to‘xtatgan.") else
            text("Earn coins with tasks, or use your coins for more time.", "Выполняй задания или обменяй монеты на время.", "Topshiriqlar bilan tanga to‘pla yoki vaqt sotib ol."), 17f)
        if (!blocked && app.optBoolean("can_redeem") && minutes > 0) {
            val buy = Button(this).apply {
                text = "$cost "+this@AppBlockForegroundService.text("coins", "монет", "tanga")+" → $minutes "+this@AppBlockForegroundService.text("min", "мин", "daq")
                isAllCaps = false
                setTextColor(Color.WHITE)
                background = GradientDrawable().apply { setColor(Color.rgb(31,65,49)); cornerRadius = 24f }
                isEnabled = !purchase && !syncing && store.snapshot.optInt("balance") >= cost
            }
            box.addView(buy, LinearLayout.LayoutParams(-1,-2))
            buy.setOnClickListener {
                buy.isEnabled = false
                purchaseTime(app.getString("app_slug"), cost, minutes) { _, error ->
                    if (error != null) {
                        message.text = text("Unable to buy time. Check your connection, balance and parent limits in Safini.",
                            "Не удалось купить время. Проверь интернет, баланс и лимиты в Safini.",
                            "Vaqt sotib olinmadi. Internet, balans va limitlarni Safini’da tekshiring.")
                        buy.isEnabled = true
                    }
                }
            }
        }
        box.addView(Button(this).apply {
            text = this@AppBlockForegroundService.text("Open Safini", "Открыть Safini", "Safini’ni ochish")
            setOnClickListener {
                startActivity(packageManager.getLaunchIntentForPackage(packageName)!!.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK))
                removeOverlay()
            }
        }, LinearLayout.LayoutParams(-1,-2))
        val scroll = ScrollView(this).apply {
            isFillViewport = true
            setBackgroundColor(Color.rgb(247,245,240))
            addView(box, FrameLayout.LayoutParams(-1,-2))
        }
        windows.addView(scroll, WindowManager.LayoutParams(-1,-1,WindowManager.LayoutParams.TYPE_APPLICATION_OVERLAY,
            WindowManager.LayoutParams.FLAG_LAYOUT_IN_SCREEN, PixelFormat.OPAQUE))
        overlay = scroll; overlayPackage = pkg; store.covered = true
    }
    private fun removeOverlay() {
        overlay?.let { runCatching { windows.removeView(it) } }
        overlay = null; overlayPackage = null
        store.covered = store.foreground?.let { store.remaining(it, System.currentTimeMillis()) == 0L } ?: false
    }
    private fun notification() {
        val manager = getSystemService(NotificationManager::class.java)
        manager.createNotificationChannel(NotificationChannel("safini_limits", "Safini", NotificationManager.IMPORTANCE_LOW))
        val pending = PendingIntent.getActivity(this, 0, packageManager.getLaunchIntentForPackage(packageName), PendingIntent.FLAG_IMMUTABLE or PendingIntent.FLAG_UPDATE_CURRENT)
        val notification = Notification.Builder(this, "safini_limits").setContentTitle("Safini")
            .setContentText(text("Keeping your app limits", "Контроль времени приложений", "Ilova vaqtini nazorat qilish"))
            .setSmallIcon(applicationInfo.icon).setOngoing(true).setContentIntent(pending).build()
        if (Build.VERSION.SDK_INT >= 34) startForeground(4711, notification, ServiceInfo.FOREGROUND_SERVICE_TYPE_SPECIAL_USE)
        else startForeground(4711, notification)
    }
}

fun usageAccess(context: Context): Boolean {
    val ops = context.getSystemService(AppOpsManager::class.java)
    @Suppress("DEPRECATION")
    return ops.checkOpNoThrow(AppOpsManager.OPSTR_GET_USAGE_STATS, android.os.Process.myUid(), context.packageName) == AppOpsManager.MODE_ALLOWED
}
