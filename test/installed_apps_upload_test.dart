import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:safini/features/child/data/services/child_app_rules_service.dart';
import 'package:safini/features/models/domain/models/installed_app.dart';

/// Plays the server's side of the lazy icon upload: it remembers the icons it
/// was sent and lists the ones it still lacks after every PUT.
class _IconServer implements HttpClientAdapter {
  _IconServer({Set<String>? stored}) : stored = stored ?? {};

  final Set<String> stored;
  final List<List<Map<String, dynamic>>> uploads = [];

  /// Hashes the server keeps asking for even after it was sent them.
  Set<String> neverStores = {};

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    final apps = [
      for (final app in (options.data as Map)['apps'] as List)
        Map<String, dynamic>.from(app as Map),
    ];
    uploads.add(apps);
    for (final app in apps) {
      if (app['icon_png'] != null && !neverStores.contains(app['icon_sha256'])) {
        stored.add(app['icon_sha256'] as String);
      }
    }
    final missing = {
      for (final app in apps)
        if (app['icon_sha256'] != null && !stored.contains(app['icon_sha256']))
          app['icon_sha256'] as String,
    };
    return ResponseBody.fromString(
      jsonEncode({'apps': [], 'missing_icon_sha256': missing.toList()}),
      200,
      headers: {
        Headers.contentTypeHeader: [Headers.jsonContentType],
      },
    );
  }

  @override
  void close({bool force = false}) {}
}

InstalledApp _app(String package, {String? hash, int bytes = 4}) =>
    InstalledApp(
      packageName: package,
      appName: package,
      iconSha256: hash,
      iconPng: hash == null ? null : Uint8List(bytes),
    );

List<String> _attached(List<Map<String, dynamic>> upload) => [
  for (final app in upload)
    if (app['icon_png'] != null) app['package_name'] as String,
];

void main() {
  late _IconServer server;
  late ChildAppRulesService service;

  void serve(_IconServer next) {
    server = next;
    service = ChildAppRulesService(Dio()..httpClientAdapter = server);
  }

  test('a first sync names the icons, then sends the ones asked for', () async {
    serve(_IconServer(stored: {'b' * 64}));

    final result = await service.reportInstalledApps('child-1', [
      _app('com.google.android.youtube', hash: 'a' * 64),
      _app('com.roblox.client', hash: 'b' * 64),
      _app('com.no.icon'),
    ]);

    expect(result.isRight(), isTrue);
    expect(server.uploads, hasLength(2));
    // The first PUT carries hashes only.
    expect(_attached(server.uploads.first), isEmpty);
    expect(server.uploads.first[0]['icon_sha256'], 'a' * 64);
    expect(server.uploads.first[2].containsKey('icon_sha256'), isFalse);
    // The second carries exactly the icon the server lacked.
    expect(_attached(server.uploads.last), ['com.google.android.youtube']);
    expect(
      base64Decode(server.uploads.last[0]['icon_png'] as String),
      hasLength(4),
    );
  });

  test('once the server has every icon, a sync is one small request', () async {
    serve(_IconServer(stored: {'a' * 64}));

    await service.reportInstalledApps('child-1', [
      _app('com.google.android.youtube', hash: 'a' * 64),
    ]);

    expect(server.uploads, hasLength(1));
    expect(_attached(server.uploads.single), isEmpty);
  });

  test('icons go up in batches of about a megabyte', () async {
    serve(_IconServer());

    await service.reportInstalledApps('child-1', [
      for (var i = 0; i < 5; i++)
        _app('com.app$i', hash: '$i' * 64, bytes: 400 * 1024),
    ]);

    // Hashes, then 2 + 2 + 1 icons: never more than 1 MiB in one PUT.
    expect(server.uploads.map(_attached).map((a) => a.length), [0, 2, 2, 1]);
  });

  test('an icon bigger than a batch still goes, alone', () async {
    serve(_IconServer());

    await service.reportInstalledApps('child-1', [
      _app('com.big', hash: 'a' * 64, bytes: 2 * 1024 * 1024),
      _app('com.small', hash: 'b' * 64),
    ]);

    expect(server.uploads.map(_attached).toList(), [
      <String>[],
      ['com.big'],
      ['com.small'],
    ]);
  });

  test('two apps sharing an icon send its bytes once', () async {
    serve(_IconServer());

    await service.reportInstalledApps('child-1', [
      _app('com.one', hash: 'a' * 64),
      _app('com.two', hash: 'a' * 64),
    ]);

    expect(server.uploads, hasLength(2));
    expect(_attached(server.uploads.last), ['com.one']);
    expect(server.uploads.last[1]['icon_sha256'], 'a' * 64);
  });

  test('a hash the server keeps asking for does not loop forever', () async {
    serve(_IconServer()..neverStores = {'a' * 64});

    final result = await service.reportInstalledApps('child-1', [
      _app('com.google.android.youtube', hash: 'a' * 64),
    ]);

    expect(result.isRight(), isTrue);
    expect(server.uploads, hasLength(2));
  });

  test('a hash this phone has no bytes for is not chased', () async {
    serve(_IconServer());

    await service.reportInstalledApps('child-1', [
      const InstalledApp(
        packageName: 'com.lost.bytes',
        appName: 'Lost',
        iconSha256: 'cc',
      ),
    ]);

    expect(server.uploads, hasLength(1));
  });
}
