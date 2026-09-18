import 'dart:io';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

/// The Android half of "a push shows up even while the app is open".
///
/// FCM posts a notification itself only while the app is in the background.
/// In the foreground it hands the message to Dart instead and nothing appears,
/// so this posts it the way FCM would have: same channel, same tag, and the
/// message id in the tap intent, which makes firebase_messaging report the tap
/// through `onMessageOpenedApp` exactly like a background one. iOS needs none
/// of this; `setForegroundNotificationPresentationOptions` shows the banner.
class ForegroundNotifications {
  const ForegroundNotifications([
    this._channel = const MethodChannel('com.safini.app/notifications'),
    this._isAndroid,
  ]);

  final MethodChannel _channel;
  final bool? _isAndroid;

  bool get _android => _isAndroid ?? (!kIsWeb && Platform.isAndroid);

  Future<void> show(RemoteMessage message) async {
    final notification = message.notification;
    final id = message.messageId;
    if (!_android || notification == null || id == null) return;
    try {
      await _channel.invokeMethod<void>('show', {
        'messageId': id,
        'title': notification.title ?? '',
        'body': notification.body ?? '',
        'channelId': notification.android?.channelId,
        'tag': notification.android?.tag,
      });
    } catch (error) {
      debugPrint('Foreground notification failed (${error.runtimeType}).');
    }
  }

  /// Whether the system lets Safini post notifications at all. Null where the
  /// platform cannot say, which the caller treats as "do not warn".
  Future<bool?> enabled() async {
    if (!_android) return null;
    try {
      return await _channel.invokeMethod<bool>('enabled');
    } catch (_) {
      return null;
    }
  }

  /// Opens Safini's page in the system notification settings.
  Future<void> openSettings() async {
    if (!_android) return;
    try {
      await _channel.invokeMethod<void>('openSettings');
    } catch (error) {
      debugPrint('Notification settings unavailable (${error.runtimeType}).');
    }
  }
}
