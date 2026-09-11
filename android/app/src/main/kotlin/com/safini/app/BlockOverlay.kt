package com.safini.app

import android.animation.ObjectAnimator
import android.animation.ValueAnimator
import android.annotation.SuppressLint
import android.content.Context
import android.content.Intent
import android.content.res.Configuration
import android.content.res.Resources
import android.graphics.Color
import android.graphics.PixelFormat
import android.graphics.Typeface
import android.graphics.drawable.GradientDrawable
import android.os.Build
import android.text.TextUtils
import android.util.TypedValue
import android.view.Gravity
import android.view.HapticFeedbackConstants
import android.view.KeyEvent
import android.view.MotionEvent
import android.view.View
import android.view.ViewGroup.LayoutParams.MATCH_PARENT
import android.view.ViewGroup.LayoutParams.WRAP_CONTENT
import android.view.ViewTreeObserver
import android.view.WindowInsets
import android.view.WindowInsetsController
import android.view.WindowManager
import android.view.accessibility.AccessibilityNodeInfo
import android.view.animation.PathInterpolator
import android.widget.Button
import android.widget.FrameLayout
import android.widget.ImageView
import android.widget.LinearLayout
import android.widget.ScrollView
import android.widget.TextView
import android.window.OnBackInvokedCallback
import android.window.OnBackInvokedDispatcher
import java.io.IOException
import java.util.Locale
import kotlin.math.roundToInt

/** Why an app is closed and what the child can do about it. Plain values, so the choice of screen is unit tested. */
data class BlockFacts(
    val slug: String,
    val appName: String,
    /** A parent switched the app off. Coins cannot open it. */
    val paused: Boolean,
    /** The overall daily screen-time cap ran out. The server refuses purchases then. */
    val dayCap: Boolean,
    /** Coins may buy time for this app. */
    val canUnlock: Boolean,
    val cost: Int,
    val minutes: Int,
    val balance: Int,
    /** Today's allowance for the app, or the overall cap when [dayCap]. */
    val allowanceMinutes: Long,
    /** Until family-local midnight, when budgets reset. */
    val resetInMinutes: Long,
    /** Time left on the app, or null when nothing caps it. */
    val remainingSeconds: Long?,
    /** Today's tasks the child can still do, best paid first. */
    val tasks: List<BlockTask> = emptyList(),
) {
    val screen: BlockScreen get() = when {
        paused -> BlockScreen.PAUSED
        dayCap -> BlockScreen.DAY_CAP
        canUnlock && balance < cost -> BlockScreen.NEED_COINS
        else -> BlockScreen.OUT_OF_TIME
    }

    /** How many of the best-paid tasks cover the coins still missing, or null when all of them fall short. */
    val tasksToGo: Int? get() {
        var earned = 0
        tasks.forEachIndexed { i, task ->
            earned += task.coins
            if (earned >= cost-balance) return i+1
        }
        return null
    }
}

data class BlockTask(val title: String, val category: String, val coins: Int)

/** The base takeovers. Confirming, unlocking and a failed purchase are steps on top of OUT_OF_TIME. */
enum class BlockScreen { PAUSED, DAY_CAP, OUT_OF_TIME, NEED_COINS }

// Pine & Sand, mirrored from lib/core/theme/app_colors.dart. Change a colour there first.
private val PINE_DEEP = 0xFF103B2F.toInt()
private val PINE = 0xFF1A5C4A.toInt()
private val INK = 0xFF0C231C.toInt()
private val SHEET = 0xFFFBFAF6.toInt()
private val FILL = 0xFFEFEBE3.toInt()
private val FILL_DEEPER = 0xFFDED8CC.toInt()
private val BAR = 0xFF7FAF9C.toInt()
private val CHEVRON = 0xFFB5C2BC.toInt()
private val TEXT_SECONDARY = 0xFF4A5A54.toInt()
private val TEXT_TERTIARY = 0xFF64736D.toInt()
private val COIN = 0xFFE8A33D.toInt()
private val COIN_INK = 0xFF3A2A08.toInt()
private val COIN_PILL_BG = 0xFFFBF1DF.toInt()
private val COIN_PILL_FG = 0xFF9A6512.toInt()
private val SCRIM = Color.argb(107, 12, 35, 28)
private val DANGER_TINT = Color.argb(56, 194, 69, 45)

// lib/core/theme/app_motion.dart: the house spring, the sheet curve and ease. Nothing else moves.
private val SPRING = PathInterpolator(0.23f, 1f, 0.32f, 1f)
private val SHEET_IN = PathInterpolator(0.32f, 0.72f, 0f, 1f)
private val EASE = PathInterpolator(0.25f, 0.1f, 0.25f, 1f)

// lib/core/utils/task_category.dart: the same emoji per category; `real_world` was folded into home.
private fun emoji(category: String) = when (category.lowercase()) {
    "home", "real_world" -> "🏠"
    "school" -> "🎓"
    "health" -> "🦷"
    "outdoor" -> "⚽"
    "learn" -> "📚"
    "fitness" -> "🏃"
    "logic" -> "🧩"
    else -> "⭐"
}

/** Marks hero rows that span the column, like the meter. */
private val WIDE = Any()

private object ButtonRole : View.AccessibilityDelegate() {
    override fun onInitializeAccessibilityNodeInfo(host: View, info: AccessibilityNodeInfo) {
        super.onInitializeAccessibilityNodeInfo(host, info)
        info.className = Button::class.java.name
    }
}

/**
 * The takeover drawn over an app whose time is up: SAF-166 direction 1a. Full-bleed pine where the app
 * stops and Safini speaks, a mascot mood per state, and a sand sheet carrying the spend.
 */
class BlockOverlay(private val context: Context, private val host: Host) {
    interface Host {
        val language: String
        fun facts(pkg: String): BlockFacts?
        fun buy(facts: BlockFacts, done: (Throwable?) -> Unit)
        /** Take the takeover down now, e.g. the child left the success screen. */
        fun dismiss()
    }

    private sealed interface Step {
        object Base : Step
        object Confirm : Step
        data class Unlocked(val minutes: Int, val cost: Int) : Step
        data class Failed(val offline: Boolean) : Step
    }

    private val windows = context.getSystemService(WindowManager::class.java)
    private val density = context.resources.displayMetrics.density
    private val regular = Typeface.create("sans-serif", Typeface.NORMAL)
    private val medium = Typeface.create("sans-serif-medium", Typeface.NORMAL)
    private val bold = Typeface.create("sans-serif", Typeface.BOLD)
    private var res: Resources = context.resources
    private var root: FrameLayout? = null
    private var page: View? = null
    private var confirm: FrameLayout? = null
    private var backIn: TextView? = null
    private var busyLabel: TextView? = null
    private var meterFill: View? = null
    private var idle: ValueAnimator? = null
    private var back: Any? = null
    private var facts: BlockFacts? = null
    private var step: Step = Step.Base
    private var busy = false
    // System bar insets. Not `top`/`bottom`: inside View extensions those names resolve to the view's own edges.
    private var statusBar = 0
    private var navBar = 0
    private val padTop = mutableListOf<Pair<View, Int>>()
    private val padBottom = mutableListOf<Pair<View, Int>>()

    /** The package the takeover covers, or null when it is down. */
    var pkg: String? = null
        private set

    /** The success screen stays over the reopened app until the child leaves it. */
    fun holds(pkg: String) = this.pkg == pkg && step is Step.Unlocked

    fun show(pkg: String, facts: BlockFacts) {
        if (this.pkg == pkg && root != null) return update(facts)
        hide()
        this.pkg = pkg
        this.facts = facts
        step = Step.Base
        res = context.createConfigurationContext(Configuration(context.resources.configuration)
            .apply { setLocale(Locale.forLanguageTag(host.language)) }).resources
        val root = object : FrameLayout(context) {
            // Below API 33 back arrives as a key: it closes the spend sheet and never reaches the app.
            override fun dispatchKeyEvent(event: KeyEvent): Boolean {
                if (event.keyCode != KeyEvent.KEYCODE_BACK) return super.dispatchKeyEvent(event)
                if (event.action == KeyEvent.ACTION_UP) onBack()
                return true
            }
        }
        root.isFocusableInTouchMode = true
        root.setOnApplyWindowInsetsListener { _, insets -> onInsets(insets); insets }
        this.root = root
        render(entrance = true)
        windows.addView(root, layoutParams())
        root.requestFocus()
        if (Build.VERSION.SDK_INT >= 33) root.post { registerBack(root) }
        if (animations()) {
            root.alpha = 0f
            root.animate().alpha(1f).setDuration(200).setInterpolator(EASE).start()
        }
    }

    fun update(facts: BlockFacts) {
        val previous = this.facts
        if (facts == previous) return
        this.facts = facts
        // A purchase in flight re-renders with its own result.
        if (busy || root == null) return
        // Only the countdown moved: retext it, a rebuild would restart the motion.
        if (previous != null && facts.copy(resetInMinutes = previous.resetInMinutes) == previous) {
            backIn?.text = backInText(facts)
            return
        }
        // A pause, the overall cap or a new price makes a half-finished spend meaningless.
        if ((step == Step.Confirm || step is Step.Failed) && (facts.screen != BlockScreen.OUT_OF_TIME ||
                !facts.canUnlock || facts.cost != previous?.cost || facts.minutes != previous.minutes)) step = Step.Base
        render(entrance = previous?.screen != facts.screen)
    }

    fun hide() {
        val root = root ?: return
        idle?.cancel()
        idle = null
        if (Build.VERSION.SDK_INT >= 33) (back as? OnBackInvokedCallback)?.let {
            root.findOnBackInvokedDispatcher()?.unregisterOnBackInvokedCallback(it)
        }
        back = null
        runCatching { windows.removeView(root) }
        this.root = null
        page = null; confirm = null; backIn = null; busyLabel = null; meterFill = null
        padTop.clear(); padBottom.clear()
        pkg = null; facts = null; step = Step.Base; busy = false
    }

    private fun layoutParams() = WindowManager.LayoutParams(
        WindowManager.LayoutParams.MATCH_PARENT, WindowManager.LayoutParams.MATCH_PARENT,
        WindowManager.LayoutParams.TYPE_APPLICATION_OVERLAY,
        WindowManager.LayoutParams.FLAG_LAYOUT_IN_SCREEN or WindowManager.LayoutParams.FLAG_HARDWARE_ACCELERATED,
        PixelFormat.TRANSLUCENT,
    ).apply {
        title = "Safini block"
        // Full bleed: pine runs under the status bar and the cutout, the sheet under the gesture bar.
        if (Build.VERSION.SDK_INT >= 30) {
            fitInsetsTypes = 0
            layoutInDisplayCutoutMode = WindowManager.LayoutParams.LAYOUT_IN_DISPLAY_CUTOUT_MODE_ALWAYS
        } else if (Build.VERSION.SDK_INT >= 28) {
            layoutInDisplayCutoutMode = WindowManager.LayoutParams.LAYOUT_IN_DISPLAY_CUTOUT_MODE_SHORT_EDGES
        }
    }

    private fun registerBack(root: View) {
        if (Build.VERSION.SDK_INT < 33 || this.root !== root) return
        val callback = OnBackInvokedCallback { onBack() }
        root.findOnBackInvokedDispatcher()?.registerOnBackInvokedCallback(OnBackInvokedDispatcher.PRIORITY_DEFAULT, callback)
        back = callback
    }

    private fun onBack() {
        if (step == Step.Confirm && !busy) closeConfirm()
    }

    @Suppress("DEPRECATION")
    private fun onInsets(insets: WindowInsets) {
        val (top, bottom) = if (Build.VERSION.SDK_INT >= 30) insets.getInsets(WindowInsets.Type.systemBars()).let { it.top to it.bottom }
            else insets.systemWindowInsetTop to insets.systemWindowInsetBottom
        if (top == statusBar && bottom == navBar) return
        statusBar = top
        navBar = bottom
        padTop.forEach { (view, base) -> view.setPadding(view.paddingLeft, base+top, view.paddingRight, view.paddingBottom) }
        padBottom.forEach { (view, base) -> view.setPadding(view.paddingLeft, view.paddingTop, view.paddingRight, base+bottom) }
    }

    private fun <T : View> T.insetTop(base: Int) = apply {
        padTop += this to base
        setPadding(paddingLeft, base+statusBar, paddingRight, paddingBottom)
    }

    private fun <T : View> T.insetBottom(base: Int) = apply {
        padBottom += this to base
        setPadding(paddingLeft, paddingTop, paddingRight, base+navBar)
    }

    /** Light status icons over pine; dark gesture bar over the sand sheet. */
    @Suppress("DEPRECATION")
    private fun systemBars(root: View, lightNav: Boolean) {
        if (Build.VERSION.SDK_INT >= 30) root.windowInsetsController?.setSystemBarsAppearance(
            if (lightNav) WindowInsetsController.APPEARANCE_LIGHT_NAVIGATION_BARS else 0,
            WindowInsetsController.APPEARANCE_LIGHT_STATUS_BARS or WindowInsetsController.APPEARANCE_LIGHT_NAVIGATION_BARS)
        else root.systemUiVisibility = View.SYSTEM_UI_FLAG_LAYOUT_STABLE or View.SYSTEM_UI_FLAG_LAYOUT_FULLSCREEN or
            View.SYSTEM_UI_FLAG_LAYOUT_HIDE_NAVIGATION or (if (lightNav) View.SYSTEM_UI_FLAG_LIGHT_NAVIGATION_BAR else 0)
    }

    private fun render(entrance: Boolean, celebrate: Boolean = false) {
        val root = root ?: return
        val f = facts ?: return
        idle?.cancel()
        idle = null
        root.removeAllViews()
        padTop.clear(); padBottom.clear()
        confirm = null; backIn = null; busyLabel = null; meterFill = null
        val unlocked = step is Step.Unlocked
        val night = step == Step.Base && f.screen == BlockScreen.DAY_CAP
        val ground = when { unlocked -> PINE; night -> INK; else -> PINE_DEEP }
        if (celebrate && animations()) ValueAnimator.ofArgb(PINE_DEEP, ground).apply {
            duration = 320
            interpolator = EASE
            addUpdateListener { root.setBackgroundColor(it.animatedValue as Int) }
        }.start() else root.setBackgroundColor(ground)

        val mascot = ImageView(context).apply {
            setImageResource(art(f))
            importantForAccessibility = View.IMPORTANT_FOR_ACCESSIBILITY_NO
        }
        val halo = FrameLayout(context).apply { background = oval(white(when { unlocked -> .16f; night -> .07f; else -> .10f })) }
        halo.addView(mascot, FrameLayout.LayoutParams(px(124), px(124), Gravity.CENTER))
        val hero = LinearLayout(context).apply {
            orientation = LinearLayout.VERTICAL
            gravity = Gravity.CENTER
            setPadding(px(30), px(28), px(30), px(28))
        }
        hero.addView(halo, LinearLayout.LayoutParams(px(158), px(158)))
        val parts = heroParts(f, night)
        for ((view, gap) in parts) hero.addView(view, LinearLayout.LayoutParams(
            if (view.tag === WIDE) MATCH_PARENT else WRAP_CONTENT, WRAP_CONTENT).apply { topMargin = px(gap) })

        val footer = footer(f)
        val page = LinearLayout(context).apply {
            orientation = LinearLayout.VERTICAL
            addView(header(f, night), row())
            addView(hero, LinearLayout.LayoutParams(MATCH_PARENT, 0, 1f))
            addView(footer, row())
        }
        this.page = page
        root.addView(ScrollView(context).apply {
            isFillViewport = true
            isVerticalScrollBarEnabled = false
            overScrollMode = View.OVER_SCROLL_NEVER
            addView(page, FrameLayout.LayoutParams(MATCH_PARENT, WRAP_CONTENT))
        }, FrameLayout.LayoutParams(MATCH_PARENT, MATCH_PARENT))
        if (step == Step.Confirm) {
            page.alpha = .35f
            root.addView(confirmLayer(f).also { confirm = it })
        }
        root.post { if (this.root === root) systemBars(root, lightNav = !night) }
        if (entrance) enter(parts.map { it.first }, halo, mascot, footer, celebrate) else breathe(mascot)
    }

    /** One SAF-166 mood per state. */
    private fun art(f: BlockFacts) = when (step) {
        is Step.Unlocked -> R.drawable.mascot_superhero
        is Step.Failed -> R.drawable.mascot_unimpressed
        else -> when (f.screen) {
            BlockScreen.PAUSED -> R.drawable.mascot_stop
            BlockScreen.DAY_CAP -> R.drawable.mascot_relaxed
            BlockScreen.NEED_COINS -> R.drawable.mascot_encouraging
            BlockScreen.OUT_OF_TIME -> R.drawable.mascot_firm
        }
    }

    private fun header(f: BlockFacts, night: Boolean) = LinearLayout(context).apply {
        orientation = LinearLayout.HORIZONTAL
        gravity = Gravity.CENTER_VERTICAL
        setPadding(px(20), 0, px(20), 0)
        insetTop(px(6))
        addView(LinearLayout(context).apply {
            orientation = LinearLayout.HORIZONTAL
            gravity = Gravity.CENTER_VERTICAL
            addView(ImageView(context).apply {
                setImageResource(R.drawable.safini_mark)
                importantForAccessibility = View.IMPORTANT_FOR_ACCESSIBILITY_NO
            }, LinearLayout.LayoutParams(px(24), px(24)))
            addView(caption("Safini", white(if (night) .4f else .55f)), row(WRAP_CONTENT).apply { marginStart = px(8) })
        }, LinearLayout.LayoutParams(0, WRAP_CONTENT, 1f))
        addView(LinearLayout(context).apply {
            orientation = LinearLayout.HORIZONTAL
            gravity = Gravity.CENTER_VERTICAL
            background = round(white(if (night) .08f else .141f), dp(100))
            setPadding(px(10), px(8), px(14), px(8))
            addView(coin(22))
            addView(label("${f.balance}", 16f, white(if (night) .85f else 1f), bold, -.01f).tabular(), row(WRAP_CONTENT).apply { marginStart = px(7) })
            contentDescription = res.getQuantityString(R.plurals.block_coins, f.balance, f.balance)
        })
    }

    /** Chip, headline, explanation, then the state's pill and meter, in the design's order. */
    private fun heroParts(f: BlockFacts, night: Boolean): List<Pair<View, Int>> {
        val s = step
        val unlocked = s is Step.Unlocked
        val parts = mutableListOf<Pair<View, Int>>()
        parts += chip(f, fill = when { unlocked -> .16f; night -> .07f; else -> .10f }, ink = when { unlocked -> .9f; night -> .7f; else -> .85f }) to 20
        val (title, body) = copy(f)
        parts += label(title, 32f, white(if (night) .94f else 1f), bold, -.022f).leading(1.08f) to 26
        parts += label(body, 15.5f, white(when { unlocked -> .78f; night -> .6f; else -> .72f }), regular).leading(1.45f) to 10
        when {
            s is Step.Unlocked -> parts += timer(f.remainingSeconds?.takeIf { it > 0 } ?: s.minutes*60L) to 26
            s is Step.Failed -> parts += pill(res.getQuantityString(R.plurals.block_still_coins, f.balance, f.balance), COIN, DANGER_TINT, Color.WHITE) to 22
            f.screen == BlockScreen.OUT_OF_TIME && f.allowanceMinutes > 0 -> {
                parts += backInPill(f, night) to 22
                parts += meter(res.getString(R.string.block_today),
                    res.getString(R.string.block_minutes_of, f.allowanceMinutes, f.allowanceMinutes), 1f, BAR) to 34
            }
            f.screen == BlockScreen.NEED_COINS -> {
                parts += meter(res.getString(R.string.block_towards, f.minutes), "${f.balance} / ${f.cost}",
                    f.balance.toFloat()/f.cost, COIN) to 22
                if (f.allowanceMinutes > 0) parts += backInPill(f, night) to 20
            }
            f.screen == BlockScreen.DAY_CAP -> parts += backInPill(f, night) to 22
        }
        return parts
    }

    private fun copy(f: BlockFacts): Pair<String, String> = when (val s = step) {
        is Step.Unlocked -> res.getQuantityString(R.plurals.block_unlocked_title, s.minutes, s.minutes) to
            res.getQuantityString(R.plurals.block_unlocked_body, s.cost, s.cost)
        is Step.Failed -> if (s.offline) res.getString(R.string.block_offline_title) to res.getString(R.string.block_offline_body)
            else res.getString(R.string.block_failed_title, f.appName) to res.getString(R.string.block_failed_body)
        else -> when (f.screen) {
            BlockScreen.PAUSED -> res.getString(R.string.block_paused_title, f.appName) to res.getString(R.string.block_paused_body)
            BlockScreen.DAY_CAP -> res.getString(R.string.block_day_title) to res.getString(R.string.block_day_body)
            BlockScreen.NEED_COINS -> (f.cost-f.balance).let { res.getQuantityString(R.plurals.block_need_title, it, it) } to
                res.getString(R.string.block_need_body)
            BlockScreen.OUT_OF_TIME -> res.getString(R.string.block_resting_title, f.appName) to res.getString(when {
                f.allowanceMinutes > 0 -> R.string.block_resting_body
                f.canUnlock -> R.string.block_coins_only_body
                else -> R.string.block_unavailable_body
            })
        }
    }

    private fun footer(f: BlockFacts): View {
        val s = step
        val close = { textButton(res.getString(R.string.block_close_app, f.appName), TEXT_TERTIARY) { leave(home()) } }
        return when {
            s is Step.Unlocked -> sheet(
                primary(res.getString(R.string.block_back_to_app, f.appName)) { backToApp() } to 0,
                textButton(res.getString(R.string.block_open_safini), TEXT_TERTIARY) { leave(safini()) } to 10)
            s is Step.Failed -> sheet(
                primary(res.getString(R.string.block_try_again), busyTarget = true) { buy() } to 0,
                secondary(res.getString(R.string.block_open_safini)) { leave(safini()) } to 10,
                label(res.getString(R.string.block_failed_hint), 13f, TEXT_TERTIARY).leading(1.45f) to 12)
            f.screen == BlockScreen.DAY_CAP -> nightFooter(f)
            f.screen == BlockScreen.OUT_OF_TIME && f.canUnlock -> sheet(
                unlockButton(f) to 0,
                (f.tasks.firstOrNull()?.let { taskRow(it, res.getString(R.string.block_task_instead)) } ?: earnRow()) to 10,
                LinearLayout(context).apply {
                    orientation = LinearLayout.HORIZONTAL
                    addView(textButton(res.getString(R.string.block_open_safini), PINE) { leave(safini()) }, LinearLayout.LayoutParams(0, WRAP_CONTENT, 1f))
                    addView(close(), LinearLayout.LayoutParams(0, WRAP_CONTENT, 1f).apply { marginStart = px(10) })
                } to 16)
            f.screen == BlockScreen.NEED_COINS && f.tasks.isNotEmpty() -> {
                // "Two tasks, 40 coins" when the best ones cover the gap, otherwise just today's list.
                val enough = f.tasksToGo?.takeIf { it <= 2 }
                val shown = f.tasks.take(enough ?: 2)
                val coins = shown.sumOf { it.coins }
                val title = if (enough == null) res.getString(R.string.block_tasks_today)
                    else res.getQuantityString(R.plurals.block_task_count, enough, enough)+", "+res.getQuantityString(R.plurals.block_coins, coins, coins)
                sheet(caption(title, TEXT_TERTIARY).apply { setPadding(px(4), 0, px(4), 0) } to 0,
                    *shown.map { taskRow(it, null) to 8 }.toTypedArray(),
                    primary(res.getString(R.string.block_open_safini)) { leave(safini()) } to 14,
                    close() to 10)
            }
            f.screen == BlockScreen.NEED_COINS -> sheet(
                primary(res.getString(R.string.block_earn_coins)) { leave(safini()) } to 0,
                close() to 10)
            f.screen == BlockScreen.PAUSED && f.tasks.isNotEmpty() -> sheet(
                taskRow(f.tasks.first(), res.getString(R.string.block_task_meanwhile)) to 0,
                primary(res.getString(R.string.block_open_safini)) { leave(safini()) } to 14,
                close() to 10)
            else -> sheet(primary(res.getString(R.string.block_open_safini)) { leave(safini()) } to 0, close() to 10)
        }
    }

    private fun sheet(vararg rows: Pair<View, Int>) = LinearLayout(context).apply {
        orientation = LinearLayout.VERTICAL
        background = topRounded(SHEET, dp(30))
        setPadding(px(20), px(22), px(20), 0)
        insetBottom(px(26))
        for ((view, gap) in rows) addView(view, row().apply { topMargin = px(gap) })
    }

    /** The day is done and coins can't change it: no sheet, just a quiet way out (the design's bedtime). */
    private fun nightFooter(f: BlockFacts) = LinearLayout(context).apply {
        orientation = LinearLayout.VERTICAL
        setPadding(px(26), px(22), px(26), 0)
        insetBottom(px(34))
        addView(label(res.getString(R.string.block_close_app, f.appName), 17f, white(.9f), medium, -.01f).apply {
            background = round(white(.10f), dp(18))
            setPadding(px(17), px(17), px(17), px(17))
        }.tap { leave(home()) }, row())
        addView(textButton(res.getString(R.string.block_open_safini), white(.45f)) { leave(safini()) }, row().apply { topMargin = px(12) })
    }

    private fun confirmLayer(f: BlockFacts) = FrameLayout(context).apply {
        addView(View(context).apply {
            setBackgroundColor(SCRIM)
            importantForAccessibility = View.IMPORTANT_FOR_ACCESSIBILITY_NO
            setOnClickListener { if (!busy) closeConfirm() }
        }, FrameLayout.LayoutParams(MATCH_PARENT, MATCH_PARENT))
        addView(LinearLayout(context).apply {
            orientation = LinearLayout.VERTICAL
            background = topRounded(SHEET, dp(30))
            setPadding(px(20), px(14), px(20), 0)
            insetBottom(px(26))
            // Taps on the sheet must not fall through to the scrim.
            isClickable = true
            addView(View(context).apply { background = round(FILL_DEEPER, dp(100)) },
                LinearLayout.LayoutParams(px(38), px(5)).apply { gravity = Gravity.CENTER_HORIZONTAL; bottomMargin = px(18) })
            addView(label(res.getQuantityString(R.plurals.block_confirm_title, f.cost, f.cost), 26f, INK, bold, -.02f).leading(1.15f), row())
            addView(label(res.getQuantityString(R.plurals.block_confirm_body, f.minutes, f.minutes, f.appName), 15.5f, TEXT_SECONDARY).leading(1.45f),
                row().apply { topMargin = px(8) })
            addView(exchange(f.balance, f.balance-f.cost), row().apply { topMargin = px(18) })
            addView(primary(res.getString(R.string.block_confirm_yes), busyTarget = true) { buy() }, row().apply { topMargin = px(16) })
            addView(secondary(res.getString(R.string.block_confirm_no)) { closeConfirm() }, row().apply { topMargin = px(10) })
        }, FrameLayout.LayoutParams(MATCH_PARENT, WRAP_CONTENT, Gravity.BOTTOM))
    }

    private fun openConfirm() {
        val root = root ?: return
        val f = facts ?: return
        step = Step.Confirm
        val layer = confirmLayer(f)
        confirm = layer
        root.addView(layer)
        if (!animations()) { page?.alpha = .35f; return }
        page?.animate()?.alpha(.35f)?.setDuration(260)?.setInterpolator(EASE)?.start()
        layer.getChildAt(0).apply { alpha = 0f; animate().alpha(1f).setDuration(260).setInterpolator(EASE).start() }
        slideUp(layer.getChildAt(1))
    }

    private fun closeConfirm() {
        val root = root ?: return
        val layer = confirm ?: return
        step = Step.Base
        confirm = null
        busyLabel = null
        if (!animations()) { page?.alpha = 1f; root.removeView(layer); return }
        page?.animate()?.alpha(1f)?.setDuration(240)?.setInterpolator(EASE)?.start()
        layer.getChildAt(0).animate().alpha(0f).setDuration(240).setInterpolator(EASE).start()
        val sheet = layer.getChildAt(1)
        sheet.animate().translationY(sheet.height.toFloat()).setDuration(240).setInterpolator(EASE)
            .withEndAction { root.removeView(layer) }.start()
    }

    private fun buy() {
        val root = root ?: return
        val pkg = pkg ?: return
        val f = facts ?: return
        if (busy) return
        busy = true
        busyLabel?.apply { text = res.getString(R.string.block_unlocking); alpha = .72f }
        host.buy(f) { error ->
            // Taken down or moved to another app meanwhile.
            if (this.root !== root) return@buy
            busy = false
            val fresh = host.facts(pkg) ?: f
            facts = fresh
            step = when {
                error == null -> Step.Unlocked(f.minutes, f.cost)
                // Paused, capped or short of coins by now: say that, not "failed".
                fresh.screen != BlockScreen.OUT_OF_TIME || !fresh.canUnlock -> Step.Base
                // A new price is confirmed again, never bought silently.
                fresh.cost != f.cost || fresh.minutes != f.minutes -> Step.Confirm
                else -> Step.Failed(offline = error is IOException)
            }
            if (error == null) root.performHapticFeedback(
                if (Build.VERSION.SDK_INT >= 30) HapticFeedbackConstants.CONFIRM else HapticFeedbackConstants.VIRTUAL_KEY)
            render(entrance = step != Step.Confirm, celebrate = error == null)
        }
    }

    private fun backToApp() {
        val root = root ?: return
        if (!animations()) return host.dismiss()
        root.animate().alpha(0f).setDuration(180).setInterpolator(EASE).withEndAction { if (this.root === root) host.dismiss() }.start()
    }

    private fun safini() = context.packageManager.getLaunchIntentForPackage(context.packageName)!!
    private fun home() = Intent(Intent.ACTION_MAIN).addCategory(Intent.CATEGORY_HOME)

    /** Opens Safini or the launcher. The takeover stays until that app is in front, so the blocked one never flashes. */
    private fun leave(intent: Intent) {
        runCatching { context.startActivity(intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)) }
        val root = root ?: return
        // The service drops the takeover when the foreground changes; this covers a launch that never lands.
        root.postDelayed({ if (this.root === root) host.dismiss() }, 1500)
    }

    // ── motion ──

    private fun animations() = ValueAnimator.areAnimatorsEnabled()

    /** Screen entrance from app_motion.dart: rows rise 8dp and fade in turn, the mascot pops, the sheet slides up. */
    private fun enter(rows: List<View>, halo: View, mascot: View, footer: View, celebrate: Boolean) {
        if (!animations()) return
        rows.forEachIndexed { i, view ->
            view.alpha = 0f
            view.translationY = dp(8)
            view.animate().alpha(1f).translationY(0f).setStartDelay(80L+45L*i).setDuration(320).setInterpolator(SPRING).start()
        }
        mascot.alpha = 0f
        mascot.scaleX = .86f
        mascot.scaleY = .86f
        if (celebrate) {
            // Lift-off: the rocket rises out of a halo that opens up behind it.
            mascot.translationY = dp(40)
            halo.scaleX = .7f
            halo.scaleY = .7f
            halo.animate().scaleX(1f).scaleY(1f).setDuration(520).setInterpolator(SPRING).start()
        }
        mascot.animate().alpha(1f).scaleX(1f).scaleY(1f).translationY(0f).setDuration(if (celebrate) 560 else 420)
            .setInterpolator(SPRING).withEndAction { breathe(mascot) }.start()
        meterFill?.apply {
            scaleX = 0f
            animate().scaleX(1f).setStartDelay(260).setDuration(560).setInterpolator(SPRING).start()
        }
        slideUp(footer)
    }

    /** Sheet presentation: from its own height, on the sheet curve. */
    private fun slideUp(view: View) {
        if (!animations()) return
        view.viewTreeObserver.addOnPreDrawListener(object : ViewTreeObserver.OnPreDrawListener {
            override fun onPreDraw(): Boolean {
                view.viewTreeObserver.removeOnPreDrawListener(this)
                view.translationY = view.height.toFloat()
                view.animate().translationY(0f).setDuration(400).setInterpolator(SHEET_IN).start()
                return true
            }
        })
    }

    /** A slow float so the mascot reads as alive while the child decides. */
    private fun breathe(mascot: View) {
        if (!animations() || !mascot.isAttachedToWindow || mascot.parent == null) return
        idle?.cancel()
        idle = ObjectAnimator.ofFloat(mascot, View.TRANSLATION_Y, 0f, -dp(3)).apply {
            duration = 1600
            repeatMode = ValueAnimator.REVERSE
            repeatCount = ValueAnimator.INFINITE
            interpolator = EASE
            start()
        }
    }

    // ── pieces ──

    private fun chip(f: BlockFacts, fill: Float, ink: Float) = LinearLayout(context).apply {
        orientation = LinearLayout.HORIZONTAL
        gravity = Gravity.CENTER_VERTICAL
        background = round(white(fill), dp(100))
        setPadding(px(6), px(6), px(14), px(6))
        // The real launcher icon: the overlay can see every catalog package.
        val icon = pkg?.let { runCatching { context.packageManager.getApplicationIcon(it) }.getOrNull() }
        addView(if (icon != null) ImageView(context).apply {
            setImageDrawable(icon)
            importantForAccessibility = View.IMPORTANT_FOR_ACCESSIBILITY_NO
        } else label(f.appName.take(1).uppercase(), 14f, INK, bold).apply { background = round(FILL, dp(8)) },
            LinearLayout.LayoutParams(px(26), px(26)))
        addView(label(f.appName, 13.5f, white(ink), medium), row(WRAP_CONTENT).apply { marginStart = px(9) })
    }

    private fun pill(value: String, dot: Int, fill: Int, ink: Int) = LinearLayout(context).apply {
        orientation = LinearLayout.HORIZONTAL
        gravity = Gravity.CENTER_VERTICAL
        background = round(fill, dp(100))
        setPadding(px(13), px(7), px(13), px(7))
        addView(View(context).apply { background = oval(dot) }, LinearLayout.LayoutParams(px(6), px(6)))
        addView(label(value, 13f, ink, medium).tabular(), row(WRAP_CONTENT).apply { marginStart = px(7) })
    }

    private fun backInPill(f: BlockFacts, night: Boolean) =
        pill(backInText(f), BAR, white(if (night) .08f else .141f), white(if (night) .85f else 1f)).also { backIn = it.getChildAt(1) as TextView }

    private fun backInText(f: BlockFacts): String {
        val hours = f.resetInMinutes/60
        val minutes = f.resetInMinutes%60
        val span = when {
            hours == 0L -> res.getString(R.string.block_minutes, minutes)
            minutes == 0L -> res.getString(R.string.block_hours, hours)
            else -> res.getString(R.string.block_hours_minutes, hours, minutes)
        }
        return res.getString(R.string.block_back_in, span)
    }

    private fun meter(title: String, value: String, fraction: Float, fill: Int) = LinearLayout(context).apply {
        orientation = LinearLayout.VERTICAL
        tag = WIDE
        addView(LinearLayout(context).apply {
            orientation = LinearLayout.HORIZONTAL
            addView(caption(title, white(.55f)), LinearLayout.LayoutParams(0, WRAP_CONTENT, 1f))
            addView(label(value, 13f, Color.WHITE, bold).tabular(), row(WRAP_CONTENT))
        }, row())
        val done = fraction.coerceIn(0f, 1f)
        addView(LinearLayout(context).apply {
            background = round(white(.161f), dp(100))
            addView(View(context).apply {
                background = round(fill, dp(100))
                pivotX = 0f
                meterFill = this
            }, LinearLayout.LayoutParams(0, MATCH_PARENT, done))
            addView(View(context), LinearLayout.LayoutParams(0, MATCH_PARENT, 1f-done))
        }, row(MATCH_PARENT, px(6)).apply { topMargin = px(9) })
    }

    private fun timer(seconds: Long) = LinearLayout(context).apply {
        orientation = LinearLayout.HORIZONTAL
        background = round(white(.16f), dp(100))
        setPadding(px(20), px(11), px(20), px(11))
        addView(label(String.format(Locale.ROOT, "%d:%02d", seconds/60, seconds%60), 26f, Color.WHITE, bold, -.02f).tabular())
        addView(label(res.getString(R.string.block_left), 13f, white(.7f), medium), row(WRAP_CONTENT).apply { marginStart = px(6) })
    }

    private fun exchange(now: Int, after: Int) = LinearLayout(context).apply {
        orientation = LinearLayout.HORIZONTAL
        gravity = Gravity.CENTER_VERTICAL
        background = round(FILL, dp(18))
        setPadding(px(18), px(16), px(18), px(16))
        addView(figure(res.getString(R.string.block_now), now, INK, Gravity.START), LinearLayout.LayoutParams(0, WRAP_CONTENT, 1f))
        addView(label("→", 20f, CHEVRON, bold).apply { importantForAccessibility = View.IMPORTANT_FOR_ACCESSIBILITY_NO },
            row(WRAP_CONTENT).apply { marginStart = px(14); marginEnd = px(14) })
        addView(figure(res.getString(R.string.block_after), after, PINE, Gravity.END), LinearLayout.LayoutParams(0, WRAP_CONTENT, 1f))
    }

    private fun figure(title: String, value: Int, color: Int, align: Int) = LinearLayout(context).apply {
        orientation = LinearLayout.VERTICAL
        gravity = align
        addView(caption(title, TEXT_TERTIARY, align))
        addView(label("$value", 20f, color, bold, -.016f, align).tabular(), row(WRAP_CONTENT).apply { topMargin = px(3) })
    }

    private fun unlockButton(f: BlockFacts) = LinearLayout(context).apply {
        orientation = LinearLayout.HORIZONTAL
        gravity = Gravity.CENTER
        background = round(PINE, dp(18))
        setPadding(px(17), px(17), px(17), px(17))
        lift()
        addView(label(res.getString(R.string.block_unlock, f.minutes), 17f, Color.WHITE, medium, -.01f))
        addView(LinearLayout(context).apply {
            orientation = LinearLayout.HORIZONTAL
            gravity = Gravity.CENTER_VERTICAL
            background = round(white(.16f), dp(100))
            setPadding(px(3), px(3), px(9), px(3))
            addView(coin(18))
            addView(label("${f.cost}", 14f, Color.WHITE, bold).tabular(), row(WRAP_CONTENT).apply { marginStart = px(5) })
        }, row(WRAP_CONTENT).apply { marginStart = px(10) })
        contentDescription = res.getString(R.string.block_unlock, f.minutes)+", "+res.getQuantityString(R.plurals.block_coins, f.cost, f.cost)
    }.tap { openConfirm() }

    /** One of today's tasks, the design's "Or earn it" row: category, title and what it pays. Opens Safini. */
    private fun taskRow(task: BlockTask, note: String?) = LinearLayout(context).apply {
        orientation = LinearLayout.HORIZONTAL
        gravity = Gravity.CENTER_VERTICAL
        background = round(FILL, dp(18))
        setPadding(px(14), px(13), px(14), px(13))
        addView(label(emoji(task.category), 19f, INK).apply {
            background = round(SHEET, dp(12))
            importantForAccessibility = View.IMPORTANT_FOR_ACCESSIBILITY_NO
        }, LinearLayout.LayoutParams(px(38), px(38)))
        addView(LinearLayout(context).apply {
            orientation = LinearLayout.VERTICAL
            addView(label(task.title, 15.5f, INK, medium, -.008f, Gravity.START).apply {
                maxLines = 2
                ellipsize = TextUtils.TruncateAt.END
            }, row())
            if (note != null) addView(label(note, 13f, TEXT_SECONDARY, align = Gravity.START), row().apply { topMargin = px(2) })
        }, LinearLayout.LayoutParams(0, WRAP_CONTENT, 1f).apply { marginStart = px(12); marginEnd = px(8) })
        addView(label("+${task.coins}", 14f, COIN_PILL_FG, bold).tabular().apply {
            background = round(COIN_PILL_BG, dp(100))
            setPadding(px(11), 0, px(11), 0)
        }, row(WRAP_CONTENT, px(26)))
        contentDescription = listOfNotNull(task.title, note, res.getQuantityString(R.plurals.block_coins, task.coins, task.coins)).joinToString(", ")
    }.tap { leave(safini()) }

    /** When the snapshot has no open tasks for today, the row points at Safini's task list instead. */
    private fun earnRow() = LinearLayout(context).apply {
        orientation = LinearLayout.HORIZONTAL
        gravity = Gravity.CENTER_VERTICAL
        background = round(FILL, dp(18))
        setPadding(px(14), px(13), px(14), px(13))
        addView(FrameLayout(context).apply {
            background = round(SHEET, dp(12))
            addView(coin(20), FrameLayout.LayoutParams(px(20), px(20), Gravity.CENTER))
        }, LinearLayout.LayoutParams(px(38), px(38)))
        addView(LinearLayout(context).apply {
            orientation = LinearLayout.VERTICAL
            addView(label(res.getString(R.string.block_earn_title), 15.5f, INK, medium, -.008f, Gravity.START), row())
            addView(label(res.getString(R.string.block_earn_subtitle), 13f, TEXT_SECONDARY, align = Gravity.START), row().apply { topMargin = px(2) })
        }, LinearLayout.LayoutParams(0, WRAP_CONTENT, 1f).apply { marginStart = px(12); marginEnd = px(8) })
        addView(label("›", 24f, CHEVRON, medium).apply { importantForAccessibility = View.IMPORTANT_FOR_ACCESSIBILITY_NO })
    }.tap { leave(safini()) }

    private fun primary(value: String, busyTarget: Boolean = false, action: () -> Unit) =
        label(value, 17f, Color.WHITE, medium, -.01f).apply {
            background = round(PINE, dp(18))
            setPadding(px(17), px(17), px(17), px(17))
            lift()
            if (busyTarget) busyLabel = this
        }.tap(action)

    private fun secondary(value: String, action: () -> Unit) =
        label(value, 17f, INK, medium, -.01f).apply {
            background = round(FILL, dp(18))
            setPadding(px(17), px(17), px(17), px(17))
        }.tap(action)

    private fun textButton(value: String, color: Int, action: () -> Unit) =
        label(value, 14.5f, color, medium, -.005f).apply {
            minHeight = px(44)
            setPadding(px(10), px(10), px(10), px(10))
        }.tap(action)

    /** The amber Time Coin from DsCoinToken: amber is reserved for coins. */
    private fun coin(size: Int) = label("c", 0f, COIN_INK, bold).apply {
        setTextSize(TypedValue.COMPLEX_UNIT_PX, dp(size)*.5f)
        background = oval(COIN)
        importantForAccessibility = View.IMPORTANT_FOR_ACCESSIBILITY_NO
        layoutParams = LinearLayout.LayoutParams(px(size), px(size))
    }

    private fun caption(value: String, color: Int, align: Int = Gravity.START) =
        label(value, 12f, color, medium, .06f, align).apply { isAllCaps = true }

    private fun label(value: CharSequence, sp: Float, color: Int, face: Typeface = regular, tracking: Float = 0f, align: Int = Gravity.CENTER) =
        TextView(context).apply {
            text = value
            typeface = face
            letterSpacing = tracking
            gravity = align
            includeFontPadding = false
            setTextSize(TypedValue.COMPLEX_UNIT_SP, sp)
            setTextColor(color)
        }

    @SuppressLint("ClickableViewAccessibility")
    private fun <T : View> T.tap(action: () -> Unit): T = apply {
        isClickable = true
        isFocusable = true
        setOnClickListener { if (!busy) action() }
        // Press feedback from app_motion.dart: 140ms down, 160ms back.
        setOnTouchListener { view, event ->
            when (event.actionMasked) {
                MotionEvent.ACTION_DOWN -> view.animate().scaleX(.97f).scaleY(.97f).setDuration(140).setInterpolator(SPRING).start()
                MotionEvent.ACTION_UP, MotionEvent.ACTION_CANCEL -> view.animate().scaleX(1f).scaleY(1f).setDuration(160).setInterpolator(SPRING).start()
            }
            false
        }
        accessibilityDelegate = ButtonRole
    }

    private fun View.lift() {
        elevation = dp(4)
        if (Build.VERSION.SDK_INT >= 28) {
            outlineAmbientShadowColor = PINE
            outlineSpotShadowColor = PINE
        }
    }

    private fun TextView.leading(multiple: Float) = apply {
        val height = (textSize*multiple).roundToInt()
        if (Build.VERSION.SDK_INT >= 28) lineHeight = height
        else setLineSpacing((height-paint.getFontMetricsInt(null)).toFloat(), 1f)
    }

    private fun TextView.tabular() = apply { fontFeatureSettings = "tnum" }

    private fun row(width: Int = MATCH_PARENT, height: Int = WRAP_CONTENT) = LinearLayout.LayoutParams(width, height)
    private fun dp(value: Number) = value.toFloat()*density
    private fun px(value: Number) = dp(value).roundToInt()
    private fun white(alpha: Float) = Color.argb((alpha*255).roundToInt(), 255, 255, 255)
    private fun oval(color: Int) = GradientDrawable().apply { shape = GradientDrawable.OVAL; setColor(color) }
    private fun round(color: Int, radius: Float) = GradientDrawable().apply { setColor(color); cornerRadius = radius }
    private fun topRounded(color: Int, radius: Float) = GradientDrawable().apply {
        setColor(color)
        cornerRadii = floatArrayOf(radius, radius, radius, radius, 0f, 0f, 0f, 0f)
    }
}
