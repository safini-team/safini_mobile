import 'dart:ui' show PlatformDispatcher;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// App language: Uzbek (Latin), Russian, English.
///
/// State is the *override*: `null` means "follow the phone" via [resolve].
/// Auto-mapping from the device is Russian or English only. Uzbek is never
/// inferred from the OS; it is available only from the in-app picker.
///
/// Once a language is picked or assigned to a signed-in account, it is stored
/// under that user id so logout then login restores it instead of following
/// the current device language. SharedPreferences is local (same as
/// UserDefaults on iOS); the profile API has no language field.
class LocaleCubit extends Cubit<Locale?> {
  LocaleCubit(this._prefs) : super(_saved(_prefs));

  static const List<String> supported = ['uz', 'ru', 'en'];

  /// Device languages that may become the app default without a picker tap.
  static const List<String> autoFromDevice = ['ru', 'en'];

  /// Fallback when the device is neither Russian nor English (including Uzbek).
  static const Locale parentDefault = Locale('ru');

  static const String _key = 'app_locale';
  static const String _chosenKey = 'app_locale_chosen';
  static const String _accountKey = 'app_locale_account';
  static const String _userPrefix = 'app_locale_for_';

  final SharedPreferences? _prefs;

  static String _userKey(String userId) => '$_userPrefix$userId';

  static Locale? _localeIfSupported(String? code) {
    if (code != null && supported.contains(code)) return Locale(code);
    return null;
  }

  static Locale? _saved(SharedPreferences? prefs) {
    if (prefs == null) return null;
    final accountId = prefs.getString(_accountKey);
    if (accountId != null && accountId.isNotEmpty) {
      final pinned = _localeIfSupported(prefs.getString(_userKey(accountId)));
      if (pinned != null) return pinned;
    }
    final chosen = prefs.getBool(_chosenKey) ?? false;
    if (!chosen) return null;
    return _localeIfSupported(prefs.getString(_key));
  }

  /// Picks the language for a device that reports [deviceLocales], in its own
  /// order of preference. Uzbek entries are skipped. Falls back to
  /// [parentDefault] when neither Russian nor English appears.
  ///
  /// Wired into `MaterialApp.localeListResolutionCallback`, so it re-runs
  /// whenever the system language changes rather than only at startup, and
  /// only while the cubit override is null.
  static Locale resolve(List<Locale>? deviceLocales) {
    for (final locale in deviceLocales ?? const <Locale>[]) {
      if (autoFromDevice.contains(locale.languageCode)) {
        return Locale(locale.languageCode);
      }
    }
    return parentDefault;
  }

  /// [override] is a picker or account pin, including Uzbek. Flutter still
  /// calls [localeListResolutionCallback] with that override as the only
  /// preferred locale, so it must not go through the device mapper.
  static Locale resolvePreferred(List<Locale>? preferred, Locale? override) {
    if (override != null) return override;
    return resolve(preferred);
  }

  /// Whether the user has picked a language in the in-app picker this session
  /// (or a leftover explicit pick from before the first account bind).
  bool get hasExplicitChoice => _prefs?.getBool(_chosenKey) ?? false;

  /// The user picked a language themselves; remember it and stop inferring.
  Future<void> setLocale(Locale locale) async {
    emit(locale);
    await _prefs?.setString(_key, locale.languageCode);
    await _prefs?.setBool(_chosenKey, true);
    final accountId = _prefs?.getString(_accountKey);
    if (accountId != null && accountId.isNotEmpty) {
      await _prefs?.setString(_userKey(accountId), locale.languageCode);
    }
  }

  /// Attach the current (or newly assigned) language to [userId].
  ///
  /// Used after sign-in and on a restored session. [deviceLocales] is the
  /// phone's preferred list when assigning a first-login default; tests pass
  /// it explicitly so the mapping does not depend on the host OS.
  Future<void> bindAccount(String userId, {List<Locale>? deviceLocales}) async {
    if (userId.isEmpty) return;
    await _prefs?.setString(_accountKey, userId);

    final pinned = _localeIfSupported(_prefs?.getString(_userKey(userId)));
    if (pinned != null) {
      emit(pinned);
      return;
    }

    if (hasExplicitChoice) {
      final picked = state ?? _localeIfSupported(_prefs?.getString(_key));
      if (picked != null) {
        emit(picked);
        await _prefs?.setString(_userKey(userId), picked.languageCode);
        return;
      }
    }

    final assigned = resolve(
      deviceLocales ?? PlatformDispatcher.instance.locales,
    );
    emit(assigned);
    await _prefs?.setString(_userKey(userId), assigned.languageCode);
  }

  /// Drop the in-memory override so the login screen follows the phone.
  /// Per-account pins stay in preferences.
  Future<void> unbindAccount() async {
    await _prefs?.remove(_accountKey);
    await _prefs?.remove(_key);
    await _prefs?.remove(_chosenKey);
    emit(null);
  }
}
