import 'dart:async';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';

import 'package:safini/core/notifications/foreground_notifications.dart';
import 'package:safini/core/notifications/push_deep_links.dart';
import 'package:safini/core/notifications/push_event.dart';
import 'package:safini/core/utils/constants/api_const.dart';

/// Registers this handset with the API so pushes reach whoever is signed in,
/// parent or child, and turns each push into the screen it is about.
///
/// A push reaches the user in every app state: closed or in the background the
/// system shows it; open, iOS shows it through the presentation options and
/// Android through [ForegroundNotifications]. An open app also gets [events],
/// so the screen that a push is about can refresh itself.
///
/// The token belongs to the handset, so signing out revokes it here as well as
/// on the server: the next account to sign in on this phone should not inherit
/// the previous one's notifications.
class PushService {
  PushService(
    this._dio,
    this._messaging,
    this._links, {
    Stream<RemoteMessage>? openedMessages,
    Stream<RemoteMessage>? foregroundMessages,
    ForegroundNotifications foreground = const ForegroundNotifications(),
    bool? isIOS,
  }) : _openedMessages = openedMessages ?? FirebaseMessaging.onMessageOpenedApp,
       _foregroundMessages = foregroundMessages ?? FirebaseMessaging.onMessage,
       _foreground = foreground,
       _isIOS = isIOS ?? (!kIsWeb && Platform.isIOS);

  final Dio _dio;
  final FirebaseMessaging _messaging;
  final PushDeepLinks _links;
  final Stream<RemoteMessage> _openedMessages;
  final Stream<RemoteMessage> _foregroundMessages;
  final ForegroundNotifications _foreground;
  final bool _isIOS;

  final StreamController<PushEvent> _events =
      StreamController<PushEvent>.broadcast();

  StreamSubscription<String>? _refreshSubscription;
  StreamSubscription<RemoteMessage>? _openedSubscription;
  StreamSubscription<RemoteMessage>? _foregroundSubscription;
  String? _registeredToken;
  String? _registeredLocale;
  String? _lastToken;
  String? _locale;
  bool _started = false;
  int _generation = 0;
  Future<void>? _starting;
  Future<void> _registrations = Future<void>.value();
  Timer? _retry;

  /// Pushes that arrived while the app was open. Screens listen to refetch
  /// whatever the push says changed.
  Stream<PushEvent> get events => _events.stream;

  ForegroundNotifications get foreground => _foreground;

  @visibleForTesting
  String? get registeredToken => _registeredToken;

  bool _active(int generation) => _started && generation == _generation;

  /// Retry an incomplete setup on resume; a successful start is idempotent.
  ///
  /// [locale] is the app's language, which is what the server writes the
  /// next push in. It is not always the phone's.
  Future<void> start({String? locale}) {
    if (locale != null) _locale = locale;
    if (_starting != null) return _starting!;
    if (_started && _registeredToken != null) return updateLocale(_locale);
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
      _foregroundSubscription = _foregroundMessages.listen((message) {
        if (_active(generation)) unawaited(handleForeground(message));
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
      if (_isIOS) {
        // Without this iOS drops a push that arrives while Safini is open.
        await _messaging.setForegroundNotificationPresentationOptions(
          alert: true,
          badge: true,
          sound: true,
        );
      }
      await _registerCurrentToken(generation);
      if (!_active(generation)) return;
      final initial = await _messaging.getInitialMessage();
      if (_active(generation) && initial != null) handleMessage(initial);
    } catch (error) {
      debugPrint('Push setup failed (${error.runtimeType}).');
      _scheduleRetry(generation);
    }
  }

  /// The app language changed: re-register so the next push is written in it.
  Future<void> updateLocale(String? locale) {
    if (locale == null || locale.isEmpty) return Future<void>.value();
    _locale = locale;
    final token = _registeredToken;
    if (!_started || token == null || _registeredLocale == locale) {
      return Future<void>.value();
    }
    return _register(token, _generation);
  }

  String get _languageCode =>
      (_locale ?? Intl.getCurrentLocale()).split(RegExp('[_-]')).first;

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
      debugPrint('Push token unavailable (${error.runtimeType}).');
      _scheduleRetry(generation);
    }
  }

  Future<void> _register(String token, int generation) {
    // A sign-out drains this queue before revocation, so an in-flight PUT
    // cannot recreate the registration after DELETE or after the account changes.
    return _registrations = _registrations.then((_) async {
      if (!_active(generation)) return;
      _lastToken = token;
      final locale = _languageCode;
      try {
        await _dio.put<Map<String, dynamic>>(
          ApiConst.pushDevices,
          data: {
            'token': token,
            'platform': _isIOS ? 'ios' : 'android',
            'locale': locale,
          },
        );
        if (_active(generation)) {
          _registeredToken = token;
          _registeredLocale = locale;
          _retry?.cancel();
          _retry = null;
        }
      } catch (error) {
        debugPrint('Push registration failed (${error.runtimeType}).');
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
    await _foregroundSubscription?.cancel();
    _refreshSubscription = null;
    _openedSubscription = null;
    _foregroundSubscription = null;
    await _starting;
    await _registrations;
  }

  /// Called before auth is cleared. Provider failures never trap the user here.
  Future<void> revoke() async {
    await _stop();
    var token = _lastToken ?? _registeredToken;
    _registeredToken = null;
    _registeredLocale = null;
    _lastToken = null;
    _links.clear();
    try {
      token ??= await _messaging.getToken();
      if (token != null) {
        await _dio.delete<Map<String, dynamic>>(
          ApiConst.pushDevices,
          data: {'token': token},
        );
      }
    } catch (error) {
      debugPrint('Push revoke failed (${error.runtimeType}).');
    }
    try {
      await _messaging.deleteToken();
    } catch (error) {
      debugPrint('Push token deletion failed (${error.runtimeType}).');
    }
  }

  /// A tapped notification: park where it goes for the shell to open.
  @visibleForTesting
  void handleMessage(RemoteMessage message) {
    final event = PushEvent.fromData(message.data);
    if (event != null) _links.open(event.target);
  }

  /// A push that arrived with the app open: show it, then tell the screens.
  @visibleForTesting
  Future<void> handleForeground(RemoteMessage message) async {
    final event = PushEvent.fromData(message.data);
    if (event == null) return;
    await _foreground.show(message);
    if (!_events.isClosed) _events.add(event);
  }

  Future<void> dispose() async {
    await _stop();
    await _events.close();
  }
}
