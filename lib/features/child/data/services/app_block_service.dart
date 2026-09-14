import 'dart:convert';
import 'dart:io' show Platform;
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:safini/features/models/domain/models/installed_app.dart';

/// Android native enforcement owns accounting, offline rules and background sync.
class AppBlockService {
  /// [supported] exists so the channel contract can be exercised on the test
  /// host, where `Platform.isAndroid` is false and every call would otherwise
  /// short-circuit. Production always uses the real check.
  const AppBlockService({bool? supported}) : _supported = supported;

  final bool? _supported;

  static const channel = MethodChannel('com.safini.app/app_block');
  bool get isSupported => _supported ?? (!kIsWeb && Platform.isAndroid);
  Future<bool> _bool(String method, [Map<String, dynamic>? args]) async =>
      !isSupported || (await channel.invokeMethod<bool>(method, args) ?? false);
  Future<void> _call(String method, [Map<String, dynamic>? args]) async {
    if (isSupported) await channel.invokeMethod<void>(method, args);
  }

  Future<bool> hasUsageAccess() => _bool('hasUsageAccess');
  Future<bool> hasOverlayPermission() => _bool('hasOverlayPermission');
  Future<void> requestUsageAccess() => _call('requestUsageAccess');
  Future<void> requestOverlayPermission() => _call('requestOverlayPermission');
  Future<void> requestBatterySettings() => _call('requestBatterySettings');

  /// Uninstall guard. An active device admin cannot be uninstalled,
  /// clear-data'd or force-stopped, and its removal alerts the parent.
  Future<bool> hasDeviceAdmin() => _bool('hasDeviceAdmin');
  Future<void> requestDeviceAdmin() => _call('requestDeviceAdmin');
  Future<bool> isConfigured(String childId) =>
      _bool('isConfigured', {'childId': childId});
  Future<bool> isRunning() => _bool('isRunning');
  Future<bool> hasSnapshot() => _bool('hasSnapshot');
  Future<void> configure(Map<String, dynamic> config) =>
      _call('configure', config);
  Future<void> setLanguage(String language) =>
      _call('setLanguage', {'language': language});
  Future<Map<String, dynamic>> purchaseTime(
    String slug,
    int cost,
    int minutes,
  ) async {
    final raw = await channel.invokeMethod<String>('purchaseTime', {
      'slug': slug,
      'cost': cost,
      'minutes': minutes,
    });
    return jsonDecode(raw!) as Map<String, dynamic>;
  }

  Future<void> startService() => _call('startService');
  Future<void> syncNow() => _call('syncNow');
  Future<void> stopService() => _call('stopService');

  /// Every launchable app on this phone, with its launcher icon. Rendering
  /// the icons takes native a second or two; it happens off the UI thread.
  Future<List<InstalledApp>> installedApps() async {
    if (!isSupported) return [];
    final raw = await channel.invokeListMethod<dynamic>('installedApps') ?? [];
    return raw
        .whereType<Map>()
        .map(
          (a) => InstalledApp(
            packageName: a['packageName'].toString(),
            appName: a['appName'].toString(),
            alwaysAllowed: a['alwaysAllowed'] == true,
            iconPng: a['iconPng'] is Uint8List
                ? a['iconPng'] as Uint8List
                : null,
            iconSha256: a['iconSha256'] is String
                ? a['iconSha256'] as String
                : null,
          ),
        )
        .toList();
  }

  /// The launcher icon of one app on this phone as a PNG, or `null` when the
  /// app is not installed (or this is not Android).
  Future<Uint8List?> appIcon(String packageName) async {
    if (!isSupported) return null;
    return channel.invokeMethod<Uint8List>('appIcon', {
      'packageName': packageName,
    });
  }
}
