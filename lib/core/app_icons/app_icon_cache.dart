import 'dart:typed_data';

import 'package:dio/dio.dart';

/// App icons, loaded once and kept for the life of the app.
///
/// Two sources, both keyed so a rebuilding list or the same app on two screens
/// costs one load: the launcher of the phone the app is on, by package name,
/// and the copy the child's phone uploaded, by `icon_url`. "No icon" is
/// remembered like an icon; a failed load is not, so a later screen retries.
class AppIconCache {
  AppIconCache({
    required Future<Uint8List?> Function(String iconUrl) loadRemote,
    Future<Uint8List?> Function(String packageName)? loadLocal,
  }) : _loadRemote = loadRemote,
       _loadLocal = loadLocal;

  /// Uploaded icons come from the API through [dio], with the user's token.
  factory AppIconCache.api(
    Dio dio, {
    Future<Uint8List?> Function(String packageName)? loadLocal,
  }) => AppIconCache(
    loadRemote: (iconUrl) => fetchIcon(dio, iconUrl),
    loadLocal: loadLocal,
  );

  final Future<Uint8List?> Function(String iconUrl) _loadRemote;
  final Future<Uint8List?> Function(String packageName)? _loadLocal;

  final Map<String, Uint8List?> _icons = {};
  final Map<String, Future<Uint8List?>> _loading = {};

  static String _localKey(String packageName) => 'package:$packageName';
  static String _remoteKey(String iconUrl) => 'url:$iconUrl';

  /// Whether this phone's launcher has answered for [packageName] yet.
  bool hasLocal(String packageName) =>
      _icons.containsKey(_localKey(packageName));
  Uint8List? peekLocal(String packageName) => _icons[_localKey(packageName)];

  bool hasRemote(String iconUrl) => _icons.containsKey(_remoteKey(iconUrl));
  Uint8List? peekRemote(String iconUrl) => _icons[_remoteKey(iconUrl)];

  /// The icon this phone's launcher shows for [packageName]. `null` when the
  /// app is not installed here, or this phone cannot say (anything but
  /// Android).
  Future<Uint8List?> local(String packageName) {
    final load = _loadLocal;
    return _load(
      _localKey(packageName),
      () async => load == null ? null : await load(packageName),
    );
  }

  /// The icon the child's phone uploaded, from [iconUrl].
  Future<Uint8List?> remote(String iconUrl) =>
      _load(_remoteKey(iconUrl), () => _loadRemote(iconUrl));

  Future<Uint8List?> _load(String key, Future<Uint8List?> Function() fetch) {
    if (_icons.containsKey(key)) return Future.value(_icons[key]);
    return _loading[key] ??= fetch()
        .then<Uint8List?>((bytes) => _icons[key] = bytes, onError: (_) => null)
        // A block, not an arrow: `remove` returns this very future, and
        // whenComplete would wait on it - forever.
        .whenComplete(() {
          _loading.remove(key);
        });
  }

  /// GETs an `icon_url` (a path on the API). A 404 is an answer - this app
  /// has no icon - so it comes back as `null`; any other failure throws and
  /// is not remembered.
  static Future<Uint8List?> fetchIcon(Dio dio, String iconUrl) async {
    try {
      final response = await dio.get<List<int>>(
        iconUrl,
        options: Options(responseType: ResponseType.bytes),
      );
      final bytes = response.data;
      return bytes == null || bytes.isEmpty ? null : Uint8List.fromList(bytes);
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) return null;
      rethrow;
    }
  }
}
