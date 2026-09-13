import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:safini/core/app_icons/app_icon_cache.dart';
import 'package:safini/core/app_icons/app_icon_tile.dart';
import 'package:safini/core/utils/widgets/ds/ds_avatar.dart';
import 'package:safini/features/parent/domain/models/child_app_usage_model.dart';

/// A 1x1 transparent PNG, so Image.memory has something real to decode.
final _png = base64Decode(
  'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mNkYPhfDwAChwGA'
  '60e6kgAAAABJRU5ErkJggg==',
);

/// Answers icon GETs with a status per path and records what was asked.
class _IconApi implements HttpClientAdapter {
  final Map<String, int> statusByPath = {};
  final List<String> requested = [];

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    requested.add(options.path);
    final status = statusByPath[options.path] ?? 200;
    if (status != 200) {
      return ResponseBody.fromString('{"detail":"nope"}', status);
    }
    return ResponseBody.fromBytes(
      _png,
      200,
      headers: {
        Headers.contentTypeHeader: ['image/png'],
      },
    );
  }

  @override
  void close({bool force = false}) {}
}

void main() {
  group('AppIconCache', () {
    late _IconApi api;
    late AppIconCache cache;

    setUp(() {
      api = _IconApi();
      cache = AppIconCache.api(Dio()..httpClientAdapter = api);
    });

    test('fetches an uploaded icon once, however often it is asked', () async {
      final results = await Future.wait([
        cache.remote('/icon?v=1'),
        cache.remote('/icon?v=1'),
      ]);
      await cache.remote('/icon?v=1');

      expect(results.first, _png);
      expect(identical(results.first, results.last), isTrue);
      expect(api.requested, ['/icon?v=1']);
      expect(cache.peekRemote('/icon?v=1'), _png);
    });

    test('a 404 is remembered as "no icon"', () async {
      api.statusByPath['/icon?v=404'] = 404;

      expect(await cache.remote('/icon?v=404'), isNull);
      expect(await cache.remote('/icon?v=404'), isNull);
      expect(cache.hasRemote('/icon?v=404'), isTrue);
      expect(api.requested, ['/icon?v=404']);
    });

    test('any other failure is forgotten, so the next ask retries', () async {
      api.statusByPath['/icon?v=500'] = 500;
      expect(await cache.remote('/icon?v=500'), isNull);
      expect(cache.hasRemote('/icon?v=500'), isFalse);

      api.statusByPath.remove('/icon?v=500');
      expect(await cache.remote('/icon?v=500'), _png);
      expect(api.requested, ['/icon?v=500', '/icon?v=500']);
    });

    test('without a launcher (anything but Android) local is null', () async {
      expect(await cache.local('com.google.android.youtube'), isNull);
      expect(cache.hasLocal('com.google.android.youtube'), isTrue);
    });
  });

  group('AppIconTile', () {
    late List<String> askedLauncher;
    late List<String> askedApi;
    Uint8List? launcherIcon;
    Uint8List? uploadedIcon;

    AppIconCache cache() => AppIconCache(
      loadLocal: (package) async {
        askedLauncher.add(package);
        return launcherIcon;
      },
      loadRemote: (url) async {
        askedApi.add(url);
        return uploadedIcon;
      },
    );

    Future<void> pumpTile(WidgetTester tester, Widget tile) async {
      await tester.pumpWidget(MaterialApp(home: Scaffold(body: tile)));
      await tester.pump();
    }

    setUp(() {
      askedLauncher = [];
      askedApi = [];
      launcherIcon = null;
      uploadedIcon = _png;
    });

    testWidgets('with nothing to load it is the emoji tile', (tester) async {
      await pumpTile(tester, const AppIconTile(emoji: '📺'));

      expect(find.byType(DsEmojiTile), findsOneWidget);
      expect(find.byType(Image), findsNothing);
    });

    testWidgets('the parent sees the icon the child phone uploaded', (
      tester,
    ) async {
      await pumpTile(
        tester,
        AppIconTile(emoji: '📺', iconUrl: '/icon?v=1', cache: cache()),
      );

      expect(find.byType(Image), findsOneWidget);
      expect(find.byType(DsEmojiTile), findsNothing);
      expect(askedApi, ['/icon?v=1']);
      expect(askedLauncher, isEmpty);
    });

    testWidgets('the child phone uses its own launcher before the network', (
      tester,
    ) async {
      launcherIcon = _png;
      await pumpTile(
        tester,
        AppIconTile(
          emoji: '📺',
          packageName: 'com.google.android.youtube',
          iconUrl: '/icon?v=1',
          cache: cache(),
        ),
      );

      expect(find.byType(Image), findsOneWidget);
      expect(askedLauncher, ['com.google.android.youtube']);
      expect(askedApi, isEmpty);
    });

    testWidgets('an app not on this phone falls back to the upload', (
      tester,
    ) async {
      await pumpTile(
        tester,
        AppIconTile(
          emoji: '📺',
          packageName: 'com.google.android.youtube',
          iconUrl: '/icon?v=1',
          cache: cache(),
        ),
      );

      expect(find.byType(Image), findsOneWidget);
      expect(askedApi, ['/icon?v=1']);
    });

    testWidgets('no icon anywhere keeps the placeholder it was given', (
      tester,
    ) async {
      uploadedIcon = null;
      await pumpTile(
        tester,
        AppIconTile(
          emoji: '⏱️',
          iconUrl: '/icon?v=1',
          placeholder: const Text('⏱️'),
          cache: cache(),
        ),
      );

      expect(find.text('⏱️'), findsOneWidget);
      expect(find.byType(DsEmojiTile), findsNothing);
      expect(find.byType(Image), findsNothing);
    });

    testWidgets('an icon already loaded draws in the first frame', (
      tester,
    ) async {
      final shared = cache();
      await shared.remote('/icon?v=1');

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AppIconTile(emoji: '📺', iconUrl: '/icon?v=1', cache: shared),
          ),
        ),
      );

      expect(find.byType(Image), findsOneWidget);
      expect(askedApi, ['/icon?v=1']);
    });

    testWidgets('a tile handed another app shows that app', (tester) async {
      final shared = cache();
      await pumpTile(
        tester,
        AppIconTile(emoji: '📺', iconUrl: '/icon?v=1', cache: shared),
      );
      uploadedIcon = null;
      await pumpTile(
        tester,
        AppIconTile(emoji: '🎮', iconUrl: '/icon?v=2', cache: shared),
      );

      expect(find.byType(Image), findsNothing);
      expect(find.byType(DsEmojiTile), findsOneWidget);
      expect(askedApi, ['/icon?v=1', '/icon?v=2']);
    });
  });

  test('app rows read the icon the server attached', () {
    final withIcon = ChildAppUsageModel.fromJson({
      'app_slug': 'youtube',
      'display_name': 'YouTube',
      'icon_url':
          '/v1/children/c1/installed-apps/com.google.android.youtube/icon?v=ab',
    });
    final withoutIcon = ChildAppUsageModel.fromJson({
      'app_slug': 'roblox',
      'icon_url': null,
    });

    expect(withIcon.iconUrl, endsWith('/icon?v=ab'));
    expect(withIcon.copyWith(dailyLimitMinutes: 5).iconUrl, withIcon.iconUrl);
    expect(withoutIcon.iconUrl, isNull);
  });
}
