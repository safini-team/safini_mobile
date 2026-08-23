import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// App language, per PRD v4 §9.3: Uzbek (Latin), Russian, English. Kazakh is
/// retired.
///
/// State is the *override*: `null` means "follow the phone", and a non-null
/// value is a choice the user made. Resolution order on launch, highest first:
///
///  1. What the user picked in the in-app picker (F-15). Once they choose, that
///     choice wins forever and nothing below is consulted again.
///  2. The phone's own language, when it is one of the three. A device already
///     set to English or Uzbek should open in that language rather than be
///     overridden by a market default. This is resolved by [resolve] against
///     the device's full preferred-locale list, not a single snapshot: reading
///     `PlatformDispatcher.locale` once at startup can catch it before the
///     engine has reported anything, and it never sees a later change.
///  3. [parentDefault] (Russian). The PRD names Russian as the parent-app
///     default because it over-indexes among the converting Tashkent segment;
///     it applies as the fallback, not as an override of rule 2.
///
/// The child app defaults to Uzbek instead, applied by [applyChildDefault] when
/// a child claims their profile. iOS does not offer Uzbek as a system language
/// at all, so for Uzbek the picker is the only route in.
class LocaleCubit extends Cubit<Locale?> {
  LocaleCubit(this._prefs) : super(_saved(_prefs));

  static const List<String> supported = ['uz', 'ru', 'en'];

  /// Parent-side default. First launch is always a parent doing setup.
  static const Locale parentDefault = Locale('ru');

  /// Child-side default, applied when a child profile is claimed.
  static const Locale childDefault = Locale('uz');

  static const String _key = 'app_locale';
  static const String _chosenKey = 'app_locale_chosen';

  final SharedPreferences? _prefs;

  static Locale? _saved(SharedPreferences? prefs) {
    final saved = prefs?.getString(_key);
    if (saved != null && supported.contains(saved)) return Locale(saved);
    return null;
  }

  /// Picks the language for a device that reports [deviceLocales], in its own
  /// order of preference. Falls back to [parentDefault] when none match.
  ///
  /// Wired into `MaterialApp.localeListResolutionCallback`, so it re-runs
  /// whenever the system language changes rather than only at startup.
  static Locale resolve(List<Locale>? deviceLocales) {
    for (final locale in deviceLocales ?? const <Locale>[]) {
      if (supported.contains(locale.languageCode)) {
        return Locale(locale.languageCode);
      }
    }
    return parentDefault;
  }

  /// Whether the user has picked a language for themselves. Once true, neither
  /// the system language nor a side default can move it again.
  bool get hasExplicitChoice => _prefs?.getBool(_chosenKey) ?? false;

  /// The user picked a language themselves; remember it and stop inferring.
  Future<void> setLocale(Locale locale) async {
    emit(locale);
    await _prefs?.setString(_key, locale.languageCode);
    await _prefs?.setBool(_chosenKey, true);
  }

  /// Switch to the child-side default, unless the user has already chosen.
  Future<void> applyChildDefault() async {
    if (hasExplicitChoice) return;
    emit(childDefault);
    await _prefs?.setString(_key, childDefault.languageCode);
  }
}
