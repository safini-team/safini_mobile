package com.safini.app

import android.content.Context
import android.content.Intent
import android.graphics.Bitmap
import android.graphics.Canvas
import android.graphics.drawable.Drawable
import java.io.ByteArrayOutputStream
import java.security.MessageDigest

/**
 * The apps on this phone, with their launcher icons rendered to PNG.
 *
 * A parent's phone cannot read this launcher, so the installed-apps upload
 * carries each icon (the server only asks for the ones it lacks), and the
 * child's own screens draw them from here. Rendering a whole phone takes a
 * second or two, so callers keep it off the main thread.
 */
object AppIcons {
    /** Tiles are 36-52pt, so 108-156px at 3x; 128px is 5-20 KiB as a PNG. */
    private const val SIZE_PX = 128

    /** The API refuses an icon over 64 KiB; a busy one is redrawn smaller. */
    private const val MAX_BYTES = 60 * 1024
    private const val MIN_SIZE_PX = 48

    fun installedApps(context: Context): List<Map<String, Any?>> {
        val pm = context.packageManager
        val launcher = Intent(Intent.ACTION_MAIN).addCategory(Intent.CATEGORY_LAUNCHER)
        val alwaysAllowed = AlwaysAllowed.packages(context)
        return pm.queryIntentActivities(launcher, 0)
            .filter { it.activityInfo != null && it.activityInfo.packageName != context.packageName }
            .distinctBy { it.activityInfo.packageName }
            .map { info ->
                val png = runCatching { png(info.loadIcon(pm)) }.getOrNull()
                mapOf(
                    "packageName" to info.activityInfo.packageName,
                    "appName" to info.loadLabel(pm).toString(),
                    "alwaysAllowed" to (info.activityInfo.packageName in alwaysAllowed),
                    "iconPng" to png,
                    "iconSha256" to png?.let(::sha256),
                )
            }
    }

    /** What the launcher shows for [packageName], or null when it is not installed. */
    fun icon(context: Context, packageName: String): ByteArray? {
        val pm = context.packageManager
        val drawable = runCatching {
            pm.getLaunchIntentForPackage(packageName)?.let { pm.resolveActivity(it, 0)?.loadIcon(pm) }
                ?: pm.getApplicationIcon(packageName)
        }.getOrNull() ?: return null
        return runCatching { png(drawable) }.getOrNull()
    }

    private fun png(drawable: Drawable): ByteArray {
        var size = SIZE_PX
        while (true) {
            val bytes = render(drawable, size)
            if (bytes.size <= MAX_BYTES || size <= MIN_SIZE_PX) return bytes
            size = size * 3 / 4
        }
    }

    private fun render(drawable: Drawable, size: Int): ByteArray {
        val bitmap = Bitmap.createBitmap(size, size, Bitmap.Config.ARGB_8888)
        // An adaptive icon draws through the system's mask, so it comes out the
        // same shape the child sees on the home screen.
        drawable.setBounds(0, 0, size, size)
        drawable.draw(Canvas(bitmap))
        return ByteArrayOutputStream().use { out ->
            bitmap.compress(Bitmap.CompressFormat.PNG, 100, out)
            bitmap.recycle()
            out.toByteArray()
        }
    }

    private fun sha256(bytes: ByteArray): String =
        MessageDigest.getInstance("SHA-256").digest(bytes).joinToString("") { "%02x".format(it) }
}
