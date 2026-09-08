import 'dart:async';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';

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
  String? _lastToken;
  bool _started = false;
  int _generation = 0;
  Future<void>? _starting;
  Future<void> _registrations = Future<void>.value();
  Timer? _retry;

  @visibleForTesting
  String? get registeredToken => _registeredToken;

  bool _active(int generation) => _started && generation == _generation;

  /// Retry an incomplete setup on resume; a successful start is idempotent.
  Future<void> start() {
    if (_starting != null) return _starting!;
    if (_started && _registeredToken != null) return Future<void>.value();
    if (!_started) {
      _started = true;
      _generation++;
      final generation = _generation;
      _refreshSubscription = _messaging.onTokenRefresh.listen(
        (token) => unawaited(_register(token, generation)),
        onError: (Object _) => _scheduleRetry(generation),
      );
      _openedSubscription = _openedMessages.listen((message) {
        if (_active(generation)) handleMessage(message);
      });
    }
    final generation = _generation;
    return _starting = _initialize(
      generation,
    ).whenComplete(() => _starting = null);
  }

  Future<void> _initialize(int generation) async {
    try {
      await _messaging.requestPermission();
      if (!_active(generation)) return;
      await _registerCurrentToken(generation);
      if (!_active(generation)) return;
      final initial = await _messaging.getInitialMessage();
      if (_active(generation) && initial != null) handleMessage(initial);
    } catch (error) {
      debugPrint('Parent push setup failed (${error.runtimeType}).');
      _scheduleRetry(generation);
    }
  }

  void _scheduleRetry(int generation) {
    if (!_active(generation) || _retry != null) return;
    _retry = Timer(const Duration(minutes: 1), () {
      _retry = null;
      unawaited(_registerCurrentToken(generation));
    });
  }

  Future<void> _registerCurrentToken(int generation) async {
    if (!_active(generation)) return;
    try {
      final token = await _messaging.getToken();
      if (token == null) {
        _scheduleRetry(generation);
      } else {
        await _register(token, generation);
      }
    } catch (error) {
      debugPrint('Parent push token unavailable (${error.runtimeType}).');
      _scheduleRetry(generation);
    }
  }

  Future<void> _register(String token, int generation) {
    // A sign-out drains this queue before revocation, so an in-flight PUT
    // cannot recreate the registration after DELETE or after the account changes.
    return _registrations = _registrations.then((_) async {
      if (!_active(generation)) return;
      _lastToken = token;
      try {
        await _dio.put<Map<String, dynamic>>(
          ApiConst.pushDevices,
          data: {
            'token': token,
            'platform': Platform.isIOS ? 'ios' : 'android',
            'locale': Intl.getCurrentLocale().split('_').first,
          },
        );
        if (_active(generation)) {
          _registeredToken = token;
          _retry?.cancel();
          _retry = null;
        }
      } catch (error) {
        debugPrint('Parent push registration failed (${error.runtimeType}).');
        _scheduleRetry(generation);
      }
    });
  }

  Future<void> _stop() async {
    _started = false;
    _generation++;
    _retry?.cancel();
    _retry = null;
    await _refreshSubscription?.cancel();
    await _openedSubscription?.cancel();
    _refreshSubscription = null;
    _openedSubscription = null;
    await _starting;
    await _registrations;
  }

  /// Called before auth is cleared. Provider failures never trap the user here.
  Future<void> revoke() async {
    await _stop();
    var token = _lastToken ?? _registeredToken;
    _registeredToken = null;
    _lastToken = null;
    _links.takeChildId();
    try {
      token ??= await _messaging.getToken();
      if (token != null) {
        await _dio.delete<Map<String, dynamic>>(
          ApiConst.pushDevices,
          data: {'token': token},
        );
      }
    } catch (error) {
      debugPrint('Parent push revoke failed (${error.runtimeType}).');
    }
    try {
      await _messaging.deleteToken();
    } catch (error) {
      debugPrint('Parent push token deletion failed (${error.runtimeType}).');
    }
  }

  @visibleForTesting
  void handleMessage(RemoteMessage message) {
    final data = message.data;
    if (data['type'] != 'protection_alert') return;
    final link = data['deep_link'];
    final uri = link is String ? Uri.tryParse(link) : null;
    final childId = uri == null ? null : PushDeepLinks.parseChildId(uri);
    final fallback = data['child_id'];
    final target = childId ?? (fallback is String ? fallback : null);
    if (target != null && target.isNotEmpty) _links.open(target);
  }

  Future<void> dispose() => _stop();
}
