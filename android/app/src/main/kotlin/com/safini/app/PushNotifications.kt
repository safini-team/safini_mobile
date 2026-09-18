package com.safini.app

import android.app.Activity
import android.app.Notification
import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.PendingIntent
import android.content.Context
import android.content.Intent
import android.provider.Settings

/**
 * Notification channels for every push the API sends, and the posting of a push
 * that arrives while the app is open.
 *
 * FCM posts a notification itself only while the app is in the background; in
 * the foreground it hands the message to Dart and nothing appears. [show] posts
 * it the way FCM would have: the same channel, the same tag (so a newer push
 * about the same thing replaces the older one), and `google.message_id` in the
 * tap intent, which firebase_messaging already resolves into
 * `onMessageOpenedApp`, so a tap routes exactly like a background one.
 */
object PushNotifications {
    const val PROTECTION = "safini_protection"
    private const val TASKS = "safini_tasks"
    private const val SCREEN_TIME = "safini_screen_time"
    private const val FAMILY = "safini_family"
    private const val REMINDERS = "safini_reminders"

    /**
     * Ids match `app/services/notifications.py` in safini-api. Importance cannot
     * be raised once a channel exists, so it is decided here for good: a child's
     * phone losing protection and a task waiting on someone interrupt, the rest
     * arrive quietly. Names follow the phone's language each time this runs.
     */
    fun createChannels(context: Context) {
        val manager = context.getSystemService(NotificationManager::class.java) ?: return
        listOf(
            Triple(PROTECTION, R.string.protection_channel_name, NotificationManager.IMPORTANCE_HIGH),
            Triple(TASKS, R.string.notification_channel_tasks, NotificationManager.IMPORTANCE_HIGH),
            Triple(SCREEN_TIME, R.string.notification_channel_screen_time, NotificationManager.IMPORTANCE_DEFAULT),
            Triple(FAMILY, R.string.notification_channel_family, NotificationManager.IMPORTANCE_DEFAULT),
            Triple(REMINDERS, R.string.notification_channel_reminders, NotificationManager.IMPORTANCE_DEFAULT),
        ).forEach { (id, name, importance) ->
            manager.createNotificationChannel(NotificationChannel(id, context.getString(name), importance))
        }
    }

    fun show(activity: Activity, messageId: String, title: String, body: String, channelId: String?, tag: String?) {
        val manager = activity.getSystemService(NotificationManager::class.java) ?: return
        val channel = channelId?.takeIf { manager.getNotificationChannel(it) != null } ?: PROTECTION
        val tap = Intent(activity, MainActivity::class.java)
            .addFlags(Intent.FLAG_ACTIVITY_SINGLE_TOP or Intent.FLAG_ACTIVITY_CLEAR_TOP)
            .putExtra("google.message_id", messageId)
        val pending = PendingIntent.getActivity(
            activity, messageId.hashCode(), tap,
            PendingIntent.FLAG_IMMUTABLE or PendingIntent.FLAG_UPDATE_CURRENT,
        )
        val notification = Notification.Builder(activity, channel)
            .setSmallIcon(R.drawable.ic_stat_safini)
            .setColor(activity.getColor(R.color.safini_pine))
            .setContentTitle(title)
            .setContentText(body)
            .setStyle(Notification.BigTextStyle().bigText(body))
            .setAutoCancel(true)
            .setContentIntent(pending)
            .build()
        // Same tag and id FCM uses, so the next push about this thing replaces it.
        manager.notify(tag ?: "safini:$messageId", 0, notification)
    }

    fun enabled(context: Context): Boolean =
        context.getSystemService(NotificationManager::class.java)?.areNotificationsEnabled() ?: false

    fun openSettings(activity: Activity) {
        activity.startActivity(
            Intent(Settings.ACTION_APP_NOTIFICATION_SETTINGS)
                .putExtra(Settings.EXTRA_APP_PACKAGE, activity.packageName)
        )
    }
}
