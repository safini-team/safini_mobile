import 'dart:io' show Platform;

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

/// iOS Screen Time authorization state, mirrored from
/// `AuthorizationCenter.authorizationStatus`.
enum ScreenTimeAuthStatus {
  /// The user has not been asked yet.
  notDetermined,

  /// The user declined (or a parent declined on a child device).
  denied,

  /// Authorized — the shield can be applied.
  approved,

  /// Not on iOS, or the native status was unrecognized.
  unavailable;

  static ScreenTimeAuthStatus fromNative(String? raw) {
    switch (raw) {
      case 'notDetermined':
        return ScreenTimeAuthStatus.notDetermined;
      case 'denied':
        return ScreenTimeAuthStatus.denied;
      case 'approved':
        return ScreenTimeAuthStatus.approved;
      default:
        return ScreenTimeAuthStatus.unavailable;
    }
  }
}

/// Which Family Sharing role authorizes Screen Time.
enum ScreenTimeMember {
  /// Self-control on this device — no Family Sharing required. Best for dev.
  individual,

  /// A child device enrolled in Family Sharing (parent approves).
  child;

  String get nativeValue => this == ScreenTimeMember.child ? 'child' : 'individual';
}

/// Result of a Screen Time selection or shield state — opaque token *counts*
/// only. iOS never exposes the underlying app identities (see
/// `observation/screenzen_research.md`), so there are no names to surface.
class ScreenTimeSelection {
  final int applications;
  final int categories;

  const ScreenTimeSelection({
    this.applications = 0,
    this.categories = 0,
  });

  bool get isEmpty => applications == 0 && categories == 0;
  int get total => applications + categories;

  static ScreenTimeSelection fromMap(Map<dynamic, dynamic>? map) {
    if (map == null) return const ScreenTimeSelection();
    return ScreenTimeSelection(
      applications: (map['applications'] as num?)?.toInt() ?? 0,
      categories: (map['categories'] as num?)?.toInt() ?? 0,
    );
  }
}

/// Raised when a native Screen Time call fails — most commonly because the
/// `com.apple.developer.family-controls` entitlement is missing/unapproved, or
/// the user denied authorization. [code] is the native `FlutterError` code.
class ScreenTimeException implements Exception {
  final String code;
  final String message;

  const ScreenTimeException(this.code, this.message);

  @override
  String toString() => 'ScreenTimeException($code): $message';
}

/// Dart bridge to the native iOS Screen Time / FamilyControls engine
/// (`ScreenTimeManager` on the Swift side, channel `com.safini.app/screen_time`).
///
/// This is the **iOS** counterpart to [AppBlockService] (which is Android-only).
/// The two are intentionally separate: the platforms share no primitives — iOS
/// blocks via Apple's system shield over opaque tokens, with no app list, no
/// overlay we draw, and no per-app usage we can read.
///
/// Until the family-controls entitlement is approved by Apple, every mutating
/// call throws a [ScreenTimeException]; the app is expected to surface that
/// state rather than treat it as a crash.
class ScreenTimeService {
  const ScreenTimeService();

  static const MethodChannel _channel =
      MethodChannel('com.safini.app/screen_time');

  /// Whether this platform can use Screen Time at all (iOS only).
  bool get isSupported => !kIsWeb && Platform.isIOS;

  /// Current authorization status. Returns [ScreenTimeAuthStatus.unavailable]
  /// off-iOS or if the native handler is missing.
  Future<ScreenTimeAuthStatus> authorizationStatus() async {
    if (!isSupported) return ScreenTimeAuthStatus.unavailable;
    try {
      final raw = await _channel.invokeMethod<String>('authorizationStatus');
      return ScreenTimeAuthStatus.fromNative(raw);
    } on MissingPluginException {
      return ScreenTimeAuthStatus.unavailable;
    } on PlatformException catch (e) {
      debugPrint('[ScreenTimeService] authorizationStatus failed: ${e.message}');
      return ScreenTimeAuthStatus.unavailable;
    }
  }

  /// Prompts for Screen Time authorization and returns the resulting status.
  ///
  /// Throws [ScreenTimeException] if the request fails (e.g. missing entitlement
  /// or the user/parent declined).
  Future<ScreenTimeAuthStatus> requestAuthorization({
    ScreenTimeMember member = ScreenTimeMember.individual,
  }) async {
    if (!isSupported) return ScreenTimeAuthStatus.unavailable;
    try {
      final raw = await _channel.invokeMethod<String>('requestAuthorization', {
        'member': member.nativeValue,
      });
      return ScreenTimeAuthStatus.fromNative(raw);
    } on MissingPluginException {
      throw const ScreenTimeException(
        'missing_plugin',
        'Native Screen Time handler is not available in this build.',
      );
    } on PlatformException catch (e) {
      throw ScreenTimeException(e.code, e.message ?? 'Authorization failed.');
    }
  }

  /// Presents Apple's `FamilyActivityPicker` and returns the chosen token counts.
  ///
  /// Throws [ScreenTimeException] on failure.
  Future<ScreenTimeSelection> presentPicker() async {
    if (!isSupported) return const ScreenTimeSelection();
    try {
      final raw = await _channel.invokeMapMethod<String, dynamic>('presentPicker');
      return ScreenTimeSelection.fromMap(raw);
    } on MissingPluginException {
      throw const ScreenTimeException(
        'missing_plugin',
        'Native Screen Time handler is not available in this build.',
      );
    } on PlatformException catch (e) {
      throw ScreenTimeException(e.code, e.message ?? 'Picker failed.');
    }
  }

  /// Applies the system shield to the current selection. Returns `false` if
  /// nothing is selected (nothing to block).
  Future<bool> applyShield() async {
    if (!isSupported) return false;
    try {
      return await _channel.invokeMethod<bool>('applyShield') ?? false;
    } on MissingPluginException {
      return false;
    } on PlatformException catch (e) {
      throw ScreenTimeException(e.code, e.message ?? 'Apply shield failed.');
    }
  }

  /// Lifts the shield from every previously blocked app/category.
  Future<void> clearShield() async {
    if (!isSupported) return;
    try {
      await _channel.invokeMethod<void>('clearShield');
    } on MissingPluginException {
      // Native handler not present yet — safe to ignore.
    } on PlatformException catch (e) {
      debugPrint('[ScreenTimeService] clearShield failed: ${e.message}');
    }
  }

  /// Token counts of the currently persisted selection.
  Future<ScreenTimeSelection> selectionCounts() async {
    if (!isSupported) return const ScreenTimeSelection();
    try {
      final raw = await _channel.invokeMapMethod<String, dynamic>('selectionCounts');
      return ScreenTimeSelection.fromMap(raw);
    } on MissingPluginException {
      return const ScreenTimeSelection();
    } on PlatformException catch (e) {
      debugPrint('[ScreenTimeService] selectionCounts failed: ${e.message}');
      return const ScreenTimeSelection();
    }
  }
}
