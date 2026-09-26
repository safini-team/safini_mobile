package com.safini.app

/** The persisted front app: EnforcementStore in the service, a plain object in tests. */
interface FrontApp {
    var foreground: String?
    /** Class of the resumed activity of [foreground]. Null for state saved before it was tracked. */
    var foregroundActivity: String?
    var covered: Boolean
}

/**
 * Which app is in front, and which apps are on screen, from UsageStats activity
 * events. Events are per activity, so everything here is keyed by activity and
 * not by package: an app that opens through a splash or launcher activity reports
 * that activity STOPPED a few seconds after its real activity RESUMED, and the
 * same happens whenever an app moves from one of its screens to the next.
 * Keying by package let that stale stop clear the front app, and a limited app
 * opened from its icon was never charged or blocked (SAF-191).
 *
 * Pure so those event orders can be unit tested.
 */
class ForegroundTracker(private val front: FrontApp) {
    // Every activity that is resumed, or paused for a PiP/split window and not
    // yet stopped. UsageStats reports one foreground app, so this is how a video
    // floating in picture-in-picture or a limited app in a split pane still gets
    // charged and covered. Cleared when the screen goes off.
    private val shown = LinkedHashSet<Pair<String, String?>>()

    /** Packages with an activity on screen, most recently resumed last. */
    val visible: List<String> get() = shown.map { it.first }.asReversed().distinct().asReversed()

    fun resumed(pkg: String, activity: String?) {
        front.foreground = pkg
        front.foregroundActivity = activity
        val key = pkg to activity
        shown.remove(key)
        shown.add(key)
    }

    /** A paused activity may still be on screen (PiP/split), so it stays visible until stopped. */
    fun paused(pkg: String, activity: String?) = leave(pkg, activity)

    fun stopped(pkg: String, activity: String?) {
        shown.remove(pkg to activity)
        // A null class cannot be matched to one entry; drop the package rather than keep a ghost.
        if (activity == null) shown.removeAll { it.first == pkg }
        leave(pkg, activity)
    }

    fun screenOff() {
        front.foreground = null
        front.foregroundActivity = null
        front.covered = false
        shown.clear()
    }

    private fun leave(pkg: String, activity: String?) {
        // The block screen keeps its app as the front app until the child really leaves it.
        if (front.covered || front.foreground != pkg) return
        val current = front.foregroundActivity
        // Only the activity that is in front can take the app out of front. A
        // missing class on either side falls back to the old package match.
        if (current != null && activity != null && current != activity) return
        front.foreground = null
        front.foregroundActivity = null
    }
}
