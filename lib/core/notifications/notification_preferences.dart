import 'dart:io';

import 'package:dio/dio.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:safini/core/notifications/foreground_notifications.dart';
import 'package:safini/core/utils/constants/api_const.dart';

/// The three Alerts switches on parent Settings, stored per account on the
/// server so they apply to every phone the parent is signed in on.
///
/// Protection alerts, task reviews sent to a child and family changes have no
/// switch: they are always sent.
enum AlertSwitch {
  taskSubmissions('task_submissions'),
  limitReached('limit_reached'),
  weeklyDigest('weekly_digest');

  const AlertSwitch(this.wire);

  final String wire;
}

class NotificationPreferences {
  const NotificationPreferences(this.values);

  /// What an account that never opened Settings gets; matches the API.
  static const NotificationPreferences defaults = NotificationPreferences({
    AlertSwitch.taskSubmissions: true,
    AlertSwitch.limitReached: true,
    AlertSwitch.weeklyDigest: false,
  });

  final Map<AlertSwitch, bool> values;

  bool operator [](AlertSwitch key) => values[key] ?? defaults.values[key]!;

  factory NotificationPreferences.fromJson(Map<String, dynamic> json) =>
      NotificationPreferences({
        for (final key in AlertSwitch.values)
          key: json[key.wire] is bool
              ? json[key.wire] as bool
              : defaults.values[key]!,
      });

  NotificationPreferences withValue(AlertSwitch key, bool value) =>
      NotificationPreferences({...values, key: value});
}

class NotificationPreferencesService {
  const NotificationPreferencesService(this._dio);

  final Dio _dio;

  Future<NotificationPreferences> fetch() async {
    final response = await _dio.get<Map<String, dynamic>>(
      ApiConst.notificationPreferences,
    );
    return NotificationPreferences.fromJson(response.data ?? const {});
  }

  Future<NotificationPreferences> update(AlertSwitch key, bool value) async {
    final response = await _dio.patch<Map<String, dynamic>>(
      ApiConst.notificationPreferences,
      data: {key.wire: value},
    );
    return NotificationPreferences.fromJson(response.data ?? const {});
  }
}

/// Whether the phone itself lets Safini post notifications. The switches mean
/// nothing while it does not, so Settings says so and links to the fix.
typedef SystemNotificationsCheck = Future<bool?> Function();

Future<bool?> systemNotificationsEnabled() async {
  if (kIsWeb) return null;
  if (Platform.isAndroid) return const ForegroundNotifications().enabled();
  try {
    final settings = await FirebaseMessaging.instance.getNotificationSettings();
    return settings.authorizationStatus != AuthorizationStatus.denied;
  } catch (_) {
    return null;
  }
}

class AlertsState {
  const AlertsState({
    this.preferences = NotificationPreferences.defaults,
    this.loaded = false,
    this.systemEnabled,
    this.saveFailed = false,
  });

  final NotificationPreferences preferences;
  final bool loaded;

  /// False when the phone blocks Safini's notifications; null when unknown.
  final bool? systemEnabled;

  /// Set for one emission when a switch could not be saved and went back.
  final bool saveFailed;

  AlertsState copyWith({
    NotificationPreferences? preferences,
    bool? loaded,
    bool? systemEnabled,
    bool saveFailed = false,
  }) => AlertsState(
    preferences: preferences ?? this.preferences,
    loaded: loaded ?? this.loaded,
    systemEnabled: systemEnabled ?? this.systemEnabled,
    saveFailed: saveFailed,
  );
}

class AlertsCubit extends Cubit<AlertsState> {
  AlertsCubit(
    this._service, {
    SystemNotificationsCheck systemCheck = systemNotificationsEnabled,
  }) : _systemCheck = systemCheck,
       super(const AlertsState());

  final NotificationPreferencesService _service;
  final SystemNotificationsCheck _systemCheck;

  Future<void> load() async {
    await checkSystem();
    try {
      final preferences = await _service.fetch();
      if (!isClosed) {
        emit(state.copyWith(preferences: preferences, loaded: true));
      }
    } catch (error) {
      debugPrint('Alert switches unavailable (${error.runtimeType}).');
      // Show the defaults rather than an empty section; a toggle still saves.
      if (!isClosed) emit(state.copyWith(loaded: true));
    }
  }

  /// Re-read after the user comes back from system settings.
  Future<void> checkSystem() async {
    final enabled = await _systemCheck();
    if (!isClosed && enabled != null) {
      emit(state.copyWith(systemEnabled: enabled));
    }
  }

  /// Flips at once, and back if the server says no.
  Future<void> toggle(AlertSwitch key, bool value) async {
    final before = state.preferences;
    emit(state.copyWith(preferences: before.withValue(key, value)));
    try {
      final saved = await _service.update(key, value);
      if (!isClosed) emit(state.copyWith(preferences: saved));
    } catch (error) {
      debugPrint('Alert switch not saved (${error.runtimeType}).');
      if (!isClosed) {
        emit(state.copyWith(preferences: before, saveFailed: true));
      }
    }
  }
}
