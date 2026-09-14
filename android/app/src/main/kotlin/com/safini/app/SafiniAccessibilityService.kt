package com.safini.app

import android.accessibilityservice.AccessibilityService
import android.content.ComponentName
import android.content.Context
import android.content.Intent
import android.os.SystemClock
import android.provider.Settings
import android.view.accessibility.AccessibilityEvent
import android.view.accessibility.AccessibilityNodeInfo

/**
 * The extra pair of eyes UsageStats does not have. UsageStats only reports the
 * one foreground app, so a video playing in a picture-in-picture or a limited
 * app running in a split-screen pane slips past the block engine. This service
 * watches window changes and publishes the set of packages that currently own a
 * visible window; [AppBlockForegroundService] reads it every tick and covers a
 * limited app that is out of time whichever window it is in.
 *
 * It also bounces the child off Safini's own App-info page, which is the road to
 * Force stop and Uninstall. Device admin already blocks the uninstall itself;
 * this closes the force-stop route too. Best effort: if an OEM's Settings does
 * not expose our package on that screen we simply do not bounce.
 *
 * We only ever look at which app owns a window and, on the Settings screen, at
 * whether our own package is named there. We never read app content or keystrokes.
 */
class SafiniAccessibilityService : AccessibilityService() {
    private var lastBounce = 0L

    override fun onServiceConnected() {
        instance = this
        publishWindows()
        // Let the server know the guard came on.
        AppBlockForegroundService.instance?.syncNow()
    }

    override fun onUnbind(intent: Intent?): Boolean {
        if (instance === this) instance = null
        visible = emptySet()
        AppBlockForegroundService.instance?.syncNow()
        return super.onUnbind(intent)
    }

    override fun onInterrupt() {}

    override fun onAccessibilityEvent(event: AccessibilityEvent?) {
        publishWindows()
        // A limited app may have just floated into view: re-evaluate now rather
        // than waiting up to 500ms for the next poll.
        AppBlockForegroundService.instance?.let { runCatching { it.reblockNow() } }
        guardOwnSettingsPage(event)
    }

    /** Every package that owns a visible window right now, PiP and split panes included. */
    private fun publishWindows() {
        val packages = HashSet<String>()
        runCatching {
            for (window in windows) {
                val root = window.root ?: continue
                root.packageName?.let { packages.add(it.toString()) }
                root.recycle()
            }
        }
        if (packages.isNotEmpty() || visible.isNotEmpty()) visible = packages
    }

    /** Send the child home when they open Safini's own App-info page (Force stop / Uninstall). */
    private fun guardOwnSettingsPage(event: AccessibilityEvent?) {
        val front = event?.packageName?.toString() ?: return
        if (front !in settingsPackages(this)) return
        // Only a paired child device guards itself; a parent may open our App info freely.
        if (!EnforcementStore(this).enabled) return
        val root = runCatching { rootInActiveWindow }.getOrNull() ?: return
        val ours = namesOwnPackage(root)
        root.recycle()
        if (!ours) return
        val now = SystemClock.elapsedRealtime()
        if (now - lastBounce < 3000) return
        lastBounce = now
        performGlobalAction(GLOBAL_ACTION_HOME)
        AppBlockForegroundService.instance?.syncNow()
    }

    /** True when this Settings window is showing our own package (its App-info page). */
    private fun namesOwnPackage(root: AccessibilityNodeInfo): Boolean {
        val self = packageName
        val queue = ArrayDeque<AccessibilityNodeInfo>()
        queue.add(root)
        var scanned = 0
        while (queue.isNotEmpty() && scanned < 400) {
            val node = queue.removeFirst()
            scanned++
            val id = node.viewIdResourceName
            if (node.text?.contains(self) == true ||
                node.contentDescription?.contains(self) == true ||
                (id != null && id.contains(self))
            ) return true
            for (i in 0 until node.childCount) node.getChild(i)?.let { queue.add(it) }
        }
        return false
    }

    companion object {
        @Volatile
        var instance: SafiniAccessibilityService? = null
            private set

        /** Packages with a visible window. Read from the enforcement tick. */
        @Volatile
        var visible: Set<String> = emptySet()
            private set
    }
}

/** Android's Settings app(s), resolved once. The AOSP package is the common case. */
private fun settingsPackages(context: Context): Set<String> {
    val names = HashSet<String>()
    names.add("com.android.settings")
    runCatching {
        context.packageManager.resolveActivity(Intent(Settings.ACTION_SETTINGS), 0)
            ?.activityInfo?.packageName?.let { names.add(it) }
    }
    return names
}

/** Whether our accessibility service is enabled, robust across process restarts. */
fun accessibilityEnabled(context: Context): Boolean {
    val expected = ComponentName(context, SafiniAccessibilityService::class.java)
    val enabled = Settings.Secure.getString(
        context.contentResolver, Settings.Secure.ENABLED_ACCESSIBILITY_SERVICES
    ) ?: return false
    return enabled.split(':').any {
        runCatching { ComponentName.unflattenFromString(it) }.getOrNull() == expected
    }
}
