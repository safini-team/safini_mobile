import 'dart:io' show Platform;

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:package_info_plus/package_info_plus.dart';

/// SAF-253: every Safini API request names the binary that sent it.
class AppClientHeaders {
  AppClientHeaders({
    Future<({String version, String build})> Function()? readInfo,
    String Function()? detectPlatform,
  }) : _readInfo = readInfo ?? _readInstalledInfo,
       _platform = detectPlatform ?? detectAppPlatform;

  static const version = 'X-App-Version';
  static const build = 'X-App-Build';
  static const platform = 'X-App-Platform';

  static final AppClientHeaders shared = AppClientHeaders();

  final Future<({String version, String build})> Function() _readInfo;
  final String Function() _platform;

  Future<Map<String, String>>? _pending;
  Map<String, String> cached = const {};

  Future<Map<String, String>> resolve() => _pending ??= _load();

  Future<Map<String, String>> _load() async {
    var versionName = '';
    var buildNumber = '';
    try {
      final info = await _readInfo();
      versionName = info.version.trim();
      buildNumber = info.build.trim();
    } catch (_) {
      // A missing plugin in tests, or a failed PackageInfo read, must not
      // drop the platform header or block the request.
    }
    final headers = <String, String>{
      version: versionName,
      build: buildNumber,
      platform: _platform(),
    };
    cached = headers;
    return headers;
  }

  static Future<({String version, String build})> _readInstalledInfo() async {
    final info = await PackageInfo.fromPlatform();
    return (version: info.version, build: info.buildNumber);
  }
}

/// Store binaries are Android or iOS. Tests on a desktop host still send one
/// of those two so the API contract stays closed.
String detectAppPlatform() {
  if (!kIsWeb && Platform.isIOS) return 'ios';
  if (!kIsWeb && Platform.isAndroid) return 'android';
  return defaultTargetPlatform == TargetPlatform.iOS ? 'ios' : 'android';
}

class AppClientHeadersInterceptor extends Interceptor {
  AppClientHeadersInterceptor([AppClientHeaders? headers])
    : _headers = headers ?? AppClientHeaders.shared;

  final AppClientHeaders _headers;

  @override
  void onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    options.headers.addAll(await _headers.resolve());
    handler.next(options);
  }
}
