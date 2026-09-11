package com.safini.app

import android.app.*
import android.app.usage.UsageEvents
import android.app.usage.UsageStatsManager
import android.content.*
import android.content.pm.ServiceInfo
import android.os.*
import android.provider.Settings
import org.json.JSONObject
import java.util.concurrent.Executors

/** Native enforcement and sync continue even when Flutter is suspended. */
class AppBlockForegroundService : Service(), BlockOverlay.Host {
    companion object {
        const val ACTION_SYNC = "com.safini.app.ENFORCEMENT_SYNC"
        var instance: AppBlockForegroundService? = null
            private set
    }
    private val handler = Handler(Looper.getMainLooper())
    private val network = Executors.newSingleThreadExecutor()
    private lateinit var store: EnforcementStore
    private lateinit var client: EnforcementClient
    private lateinit var overlay: BlockOverlay
    private var syncing = false
    private var stopped = false
    private var nextSync = 0L
    private var nextPersist = 0L
    private var purchase = false
    private val waiters = mutableListOf<(Throwable?) -> Unit>()

    override fun onCreate() {
        super.onCreate()
        instance = this
        store = EnforcementStore(this)
        client = EnforcementClient(this)
        overlay = BlockOverlay(this, this)
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
        waiters.toList().forEach { it(IllegalStateException("App limits stopped.")) }
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
                        pkg != null && pkg != packageName && store.remaining(pkg, now) == 0L) showOverlay(pkg, now)
                    // The success screen stays over the reopened app until the child leaves it.
                    else if (!interactive || pkg == null || !overlay.holds(pkg)) removeOverlay()
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

    fun syncNow(done: ((Throwable?) -> Unit)? = null) {
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
                response.onSuccess { store.applySnapshot(it); if (!purchase) refreshOverlay() }
                syncing = false
                val callbacks = waiters.toList(); waiters.clear()
                callbacks.forEach { it(response.exceptionOrNull()) }
            }
        }
    }

    fun purchaseTime(slug: String, cost: Int, minutes: Int, done: (JSONObject?, Throwable?) -> Unit) {
        // A sync already in flight is joined below, so only a second purchase has to wait.
        if (purchase) { done(null, IllegalStateException("Please wait for the current operation.")); return }
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
                    if (stopped) { done(null, IllegalStateException("App limits stopped.")); return@post }
                    // The block screen switches to its success state itself; the tick drops it once the child leaves.
                    result.onSuccess { client.purchased(); store.applySnapshot(it); done(it, null) }
                        .onFailure { error ->
                            if (error is EnforcementHttpException && error.status in 400..499 && error.status != 408 && error.status != 429) client.purchased()
                            done(null, error)
                        }
                }
            }
        }
    }

    private fun text(en: String, ru: String, uz: String): String = when (store.language) { "ru" -> ru; "uz" -> uz; else -> en }
    private fun showOverlay(pkg: String, now: Long) {
        overlay.show(pkg, store.blockFacts(pkg, now) ?: return)
        store.covered = true
    }
    private fun removeOverlay() {
        overlay.hide()
        store.covered = store.foreground?.let { store.remaining(it, System.currentTimeMillis()) == 0L } ?: false
    }
    /** New rules or balance re-render the takeover in place; an app that opened up again loses it. */
    private fun refreshOverlay() {
        val pkg = overlay.pkg ?: return
        val now = System.currentTimeMillis()
        if (store.remaining(pkg, now) == 0L) store.blockFacts(pkg, now)?.let { overlay.update(it) }
        else if (!overlay.holds(pkg)) removeOverlay()
    }

    override val language: String get() = store.language
    override fun facts(pkg: String) = store.blockFacts(pkg, System.currentTimeMillis())
    override fun buy(facts: BlockFacts, done: (Throwable?) -> Unit) = purchaseTime(facts.slug, facts.cost, facts.minutes) { _, error -> done(error) }
    override fun dismiss() = removeOverlay()

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
