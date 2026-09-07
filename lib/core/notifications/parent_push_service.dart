import 'dart:async';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';

import 'package:safini/core/notifications/push_deep_links.dart';
import 'package:safini/core/utils/constants/api_const.dart';

/// Registers this parent device with the API so protection alerts can reach it
/// while the app is closed (SAF-164).
///
/// The token belongs to the handset, so signing out revokes it here as well as
/// on the server: the next parent to sign in on this phone should not inherit
/// the previous one's alerts.
class ParentPushService {
  ParentPushService(
    this._dio,
    this._messaging,
    this._links, {
    Stream<RemoteMessage>? openedMessages,
  }) : _openedMessages = openedMessages ?? FirebaseMessaging.onMessageOpenedApp;

  final Dio _dio;
  final FirebaseMessaging _messaging;
  final PushDeepLinks _links;
  final Stream<RemoteMessage> _openedMessages;

  StreamSubscription<String>? _refreshSubscription;
  StreamSubscription<RemoteMessage>? _openedSubscription;
  String? _registeredToken;
  bool _started = false;

  @visibleForTesting
  String? get registeredToken => _registeredToken;

  /// Safe to call more than once; only the first call does the work.
  Future<void> start() async {
    if (_started) return;
    _started = true;
    try {
      await _messaging.requestPermission();
      await _registerCurrentToken();
      _refreshSubscription = _messaging.onTokenRefresh.listen(_register);
      _openedSubscription = _openedMessages.listen(handleMessage);
      final initial = await _messaging.getInitialMessage();
      if (initial != null) handleMessage(initial);
    } catch (error, stack) {
      // Never block the parent home on push setup.
      debugPrint('Parent push registration failed: $error\n$stack');
    }
  }

  Future<void> _registerCurrentToken() async {
    final token = await _messaging.getToken();
    if (token != null) await _register(token);
  }

  Future<void> _register(String token) async {
    await _dio.put<Map<String, dynamic>>(
      ApiConst.pushDevices,
      data: {
        'token': token,
        'platform': Platform.isIOS ? 'ios' : 'android',
        'locale': PlatformDispatcher.instance.locale.languageCode,
      },
    );
    _registeredToken = token;
  }

  /// Called on sign-out, while the session still has a usable bearer token.
  Future<void> revoke() async {
    final token = _registeredToken ?? await _messaging.getToken();
    _registeredToken = null;
    if (token == null) return;
    try {
      await _dio.delete<Map<String, dynamic>>(
        ApiConst.pushDevices,
        data: {'token': token},
      );
    } catch (error) {
      // The server also drops tokens FCM rejects, so a failure here is not
      // worth blocking sign-out over.
      debugPrint('Parent push revoke failed: $error');
    }
    await _messaging.deleteToken();
  }

  @visibleForTesting
  void handleMessage(RemoteMessage message) {
    final data = message.data;
    if (data['type'] != 'protection_alert') return;
    final link = data['deep_link'];
    final childId = link is String
        ? PushDeepLinks.parseChildId(Uri.parse(link))
        : null;
    final fallback = data['child_id'];
    final target = childId ?? (fallback is String ? fallback : null);
    if (target != null && target.isNotEmpty) _links.open(target);
  }

  Future<void> dispose() async {
    await _refreshSubscription?.cancel();
    await _openedSubscription?.cancel();
  }
}
