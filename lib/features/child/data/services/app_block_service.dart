import 'dart:io' show Platform;

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'package:safini/core/utils/constants/controlled_apps.dart';
import 'package:safini/features/models/domain/models/installed_app.dart';
import 'package:safini/features/parent/domain/models/child_app_usage_model.dart';

/// One app's enforcement rule as understood by the native engine.
///
/// - [blocked] `true`  → block the app outright ("App Blocked" overlay).
/// - [limitMs] set     → allow until this much foreground time is consumed,
///   then show the "Time Limit Reached" overlay.
///
/// A manual block takes priority over a time limit (matches the native spike).
class AppBlockRule {
  final String packageName;
  final int? limitMs;
  final bool blocked;

  const AppBlockRule({
    required this.packageName,
    this.limitMs,
    this.blocked = false,
  });

  Map<String, dynamic> toMap() => {
    'packageName': packageName,
    'limitMs': limitMs,
    'blocked': blocked,
  };
}

/// Dart bridge to the native Android app-blocking engine.
///
/// This is the **child device** side of the feature: it drives the
/// `UsageStatsManager` polling service + `WindowManager` overlay that actually
/// prevent app use once a limit is hit. All calls go over a [MethodChannel]
/// (`com.safini.app/app_block`) handled by `MainActivity` in Kotlin.
///
/// The native layer is not implemented yet (see `observation/app_blocking.md`,
/// Steps 1-3). Until it lands, calls are safe no-ops:
///  - On iOS / web the platform is unsupported, so mutating calls do nothing and
///    permission checks return `true` (nothing to enforce, so the gate passes).
///  - On Android before the native handler exists, [MissingPluginException] is
///    swallowed and logged so the app keeps working.
class AppBlockService {
  const AppBlockService();

  static const MethodChannel _channel = MethodChannel('com.safini.app/app_block');

  bool get isSupported => !kIsWeb && Platform.isAndroid;

  // ── Permissions ───────────────────────────────────────────────────────────

  /// Whether Usage Access (`PACKAGE_USAGE_STATS`) is granted.
  Future<bool> hasUsageAccess() =>
      _invokeBool('hasUsageAccess', unsupportedValue: true);

  /// Whether "Display over other apps" (`SYSTEM_ALERT_WINDOW`) is granted.
  Future<bool> hasOverlayPermission() =>
      _invokeBool('hasOverlayPermission', unsupportedValue: true);

  /// Whether both special permissions required for enforcement are granted.
  Future<bool> hasAllPermissions() async {
    if (!isSupported) return true;
    final results = await Future.wait([
      hasUsageAccess(),
      hasOverlayPermission(),
    ]);
    return results.every((granted) => granted);
  }

  /// Deep-links to the system Usage Access settings screen.
  Future<void> requestUsageAccess() => _invokeVoid('requestUsageAccess');

  /// Deep-links to the system "Display over other apps" settings screen.
  Future<void> requestOverlayPermission() =>
      _invokeVoid('requestOverlayPermission');

  // ── Service lifecycle ──────────────────────────────────────────────────────

  /// Starts the foreground enforcement service (idempotent natively).
  Future<void> startService() => _invokeVoid('startService');

  /// Stops the foreground enforcement service.
  Future<void> stopService() => _invokeVoid('stopService');

  // ── Rule mutation ──────────────────────────────────────────────────────────

  /// Sets a time limit for a single package (in milliseconds).
  Future<void> setAppLimit(String packageName, int limitMs) => _invokeVoid(
    'setAppLimit',
    {'packageName': packageName, 'limitMs': limitMs},
  );

  /// Removes a time limit for a single package.
  Future<void> removeAppLimit(String packageName) =>
      _invokeVoid('removeAppLimit', {'packageName': packageName});

  /// Adds/removes a package from the manual block set.
  Future<void> setManualBlock(String packageName, bool blocked) => _invokeVoid(
    'setManualBlock',
    {'packageName': packageName, 'blocked': blocked},
  );

  /// Replaces the entire native rule set in one atomic call. This is the primary
  /// path: fetch rules from the backend, map them, and push them here.
  Future<void> syncRules(List<AppBlockRule> rules) => _invokeVoid('syncRules', {
    'rules': rules.map((r) => r.toMap()).toList(),
  });

  /// Maps backend usage models → native [AppBlockRule]s and pushes them.
  ///
  /// Rule mapping (see `observation/app_blocking.md`, Step 6):
  ///  - unknown slug (no package mapping)      → skipped
  ///  - `is_enabled == false`                   → manual block
  ///  - `remaining_minutes_today <= 0`          → blocked (limit consumed)
  ///  - otherwise                               → limit = remaining × 60 000 ms
  Future<void> syncFromUsage(List<ChildAppUsageModel> apps) {
    final rules = <AppBlockRule>[];
    for (final app in apps) {
      final packageName = ControlledApps.packageFor(app.appSlug);
      if (packageName == null) continue;

      if (!app.isEnabled) {
        rules.add(AppBlockRule(packageName: packageName, blocked: true));
      } else if (app.remainingMinutesToday <= 0) {
        rules.add(AppBlockRule(packageName: packageName, blocked: true));
      } else {
        rules.add(
          AppBlockRule(
            packageName: packageName,
            limitMs: app.remainingMinutesToday * 60 * 1000,
          ),
        );
      }
    }
    return syncRules(rules);
  }

  /// Foreground time measured natively since the current limit window began,
  /// keyed by package name. (Enforcement window — not the day total.)
  Future<Map<String, int>> measuredUsageMs() async {
    if (!isSupported) return const {};
    try {
      final result = await _channel.invokeMapMethod<String, dynamic>(
        'measuredUsageMs',
      );
      if (result == null) return const {};
      return result.map(
        (key, value) => MapEntry(key, (value as num?)?.toInt() ?? 0),
      );
    } on MissingPluginException {
      return const {};
    } on PlatformException catch (e) {
      debugPrint('[AppBlockService] measuredUsageMs failed: ${e.message}');
      return const {};
    }
  }

  /// Usage in **ms since midnight** for the given package names — the day total
  /// the backend expects for `used_minutes` (independent of any limit window).
  Future<Map<String, int>> usageSinceMidnightMs(
    List<String> packageNames,
  ) async {
    if (!isSupported || packageNames.isEmpty) return const {};
    try {
      final result = await _channel.invokeMapMethod<String, dynamic>(
        'usageSinceMidnight',
        {'packages': packageNames},
      );
      if (result == null) return const {};
      return result.map(
        (key, value) => MapEntry(key, (value as num?)?.toInt() ?? 0),
      );
    } on MissingPluginException {
      return const {};
    } on PlatformException catch (e) {
      debugPrint('[AppBlockService] usageSinceMidnight failed: ${e.message}');
      return const {};
    }
  }

  /// Usage in **whole minutes since midnight** keyed by backend **slug** for the
  /// given controlled-app slugs. Unmapped slugs are skipped. Ready to feed into
  /// `POST /app-usage` (`ChildAppRulesService.reportUsageBatch`).
  Future<Map<String, int>> usageMinutesBySlug(Iterable<String> slugs) async {
    if (!isSupported) return const {};
    final slugByPackage = <String, String>{};
    final packages = <String>[];
    for (final slug in slugs) {
      final packageName = ControlledApps.packageFor(slug);
      if (packageName == null) continue;
      slugByPackage[packageName] = slug;
      packages.add(packageName);
    }
    if (packages.isEmpty) return const {};

    final usageMs = await usageSinceMidnightMs(packages);
    final out = <String, int>{};
    usageMs.forEach((packageName, ms) {
      final slug = slugByPackage[packageName];
      if (slug != null) out[slug] = ms ~/ (60 * 1000);
    });
    return out;
  }

  /// Every launchable app installed on this device. Android-only; returns an
  /// empty list on unsupported platforms or before the native handler exists.
  Future<List<InstalledApp>> installedApps() async {
    if (!isSupported) return const [];
    try {
      final raw = await _channel.invokeListMethod<dynamic>('installedApps');
      if (raw == null) return const [];
      return raw
          .whereType<Map>()
          .map(
            (e) => InstalledApp(
              packageName: (e['packageName'] ?? '').toString(),
              appName: (e['appName'] ?? '').toString(),
            ),
          )
          .where((app) => app.packageName.isNotEmpty)
          .toList();
    } on MissingPluginException {
      return const [];
    } on PlatformException catch (e) {
      debugPrint('[AppBlockService] installedApps failed: ${e.message}');
      return const [];
    }
  }

  // ── Channel plumbing ───────────────────────────────────────────────────────

  Future<bool> _invokeBool(
    String method, {
    required bool unsupportedValue,
  }) async {
    if (!isSupported) return unsupportedValue;
    try {
      return await _channel.invokeMethod<bool>(method) ?? false;
    } on MissingPluginException {
      return false;
    } on PlatformException catch (e) {
      debugPrint('[AppBlockService] $method failed: ${e.message}');
      return false;
    }
  }

  Future<void> _invokeVoid(String method, [Map<String, dynamic>? args]) async {
    if (!isSupported) return;
    try {
      await _channel.invokeMethod<void>(method, args);
    } on MissingPluginException {
      // Native handler not wired up yet — safe to ignore during rollout.
    } on PlatformException catch (e) {
      debugPrint('[AppBlockService] $method failed: ${e.message}');
    }
  }
}
