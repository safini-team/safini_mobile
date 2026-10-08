import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:in_app_update/in_app_update.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:safini/core/version_gate/version_gate_tier.dart';

/// Play In-App Updates (Android) plus store-URL fallback.
///
/// Immediate for hard when Play allows it; Flexible for soft. iOS and any
/// Play failure open [storeUrl] (Play listing by default on Android).
class VersionUpdateLauncher {
  VersionUpdateLauncher({
    Future<bool> Function()? startImmediate,
    Future<bool> Function()? startFlexible,
    Future<bool> Function(Uri uri)? openUrl,
  }) : _startImmediate = startImmediate ?? _playImmediate,
       _startFlexible = startFlexible ?? _playFlexible,
       _openUrl = openUrl ?? _launchExternal;

  final Future<bool> Function() _startImmediate;
  final Future<bool> Function() _startFlexible;
  final Future<bool> Function(Uri uri) _openUrl;

  Future<bool> open({
    required VersionGateTier tier,
    required String storeUrl,
  }) async {
    if (tier == VersionGateTier.hard) {
      if (await _startImmediate()) return true;
    } else if (tier == VersionGateTier.soft) {
      if (await _startFlexible()) return true;
    }
    return openStoreUrl(storeUrl);
  }

  Future<bool> openStoreUrl(String storeUrl) async {
    final uri = Uri.tryParse(storeUrl.trim());
    if (uri == null || !uri.hasScheme) return false;
    try {
      return await _openUrl(uri);
    } catch (error) {
      debugPrint('Store URL launch failed: $error');
      return false;
    }
  }

  static Future<bool> _launchExternal(Uri uri) {
    return launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  static bool get _isAndroid =>
      !kIsWeb && defaultTargetPlatform == TargetPlatform.android;

  static Future<bool> _playImmediate() async {
    if (!_isAndroid) return false;
    try {
      final info = await InAppUpdate.checkForUpdate();
      if (info.updateAvailability != UpdateAvailability.updateAvailable) {
        return false;
      }
      if (!info.immediateUpdateAllowed) return false;
      final result = await InAppUpdate.performImmediateUpdate();
      return result == AppUpdateResult.success;
    } catch (error) {
      debugPrint('Play immediate update unavailable: $error');
      return false;
    }
  }

  static Future<bool> _playFlexible() async {
    if (!_isAndroid) return false;
    try {
      final info = await InAppUpdate.checkForUpdate();
      if (info.installStatus == InstallStatus.downloaded) {
        _installDownloaded();
        return true;
      }
      if (info.updateAvailability != UpdateAvailability.updateAvailable) {
        return false;
      }
      if (!info.flexibleUpdateAllowed) return false;
      // Resolves only once Play reports DOWNLOADED, and that status event is
      // emitted before it resolves, so a listener attached afterwards misses it.
      final result = await InAppUpdate.startFlexibleUpdate();
      if (result != AppUpdateResult.success) return false;
      _installDownloaded();
      return true;
    } catch (error) {
      debugPrint('Play flexible update unavailable: $error');
      return false;
    }
  }

  static void _installDownloaded() {
    // The plugin never answers this call; Play restarts the app instead.
    unawaited(
      InAppUpdate.completeFlexibleUpdate().catchError((Object error) {
        debugPrint('Play flexible install failed: $error');
      }),
    );
  }
}
