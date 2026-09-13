import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:safini/features/models/domain/models/installed_app.dart';

void main() {
  test('parses the app list and the upload timestamp', () {
    final snapshot = InstalledAppsSnapshot.fromJson({
      'apps': [
        {'package_name': 'com.roblox.client', 'app_name': 'Roblox'},
        {'package_name': 'com.mojang.minecraftpe', 'app_name': 'Minecraft'},
      ],
      'updated_at': '2026-08-24T12:00:00Z',
    });

    expect(snapshot.apps, hasLength(2));
    expect(snapshot.apps.first.packageName, 'com.roblox.client');
    expect(snapshot.updatedAt, DateTime.utc(2026, 8, 24, 12));
    expect(snapshot.neverSynced, isFalse);
  });

  test('updated_at: null means the phone has never synced', () {
    final snapshot = InstalledAppsSnapshot.fromJson({
      'apps': <dynamic>[],
      'updated_at': null,
    });

    expect(snapshot.apps, isEmpty);
    expect(snapshot.updatedAt, isNull);
    expect(snapshot.neverSynced, isTrue);
  });

  test('tolerates a missing apps key and a blank timestamp', () {
    final snapshot = InstalledAppsSnapshot.fromJson({'updated_at': ''});

    expect(snapshot.apps, isEmpty);
    expect(snapshot.neverSynced, isTrue);
  });

  test('an app links the icon its phone uploaded, or none yet', () {
    final snapshot = InstalledAppsSnapshot.fromJson({
      'apps': [
        {
          'package_name': 'com.google.android.youtube',
          'app_name': 'YouTube',
          'icon_url': '/v1/children/c1/installed-apps/com.google.android.youtube/icon?v=ab',
        },
        {'package_name': 'com.no.icon', 'app_name': 'No Icon', 'icon_url': null},
      ],
      'updated_at': '2026-09-13T12:00:00Z',
    });

    expect(
      snapshot.apps.first.iconUrl,
      '/v1/children/c1/installed-apps/com.google.android.youtube/icon?v=ab',
    );
    expect(snapshot.apps.last.iconUrl, isNull);
  });

  test('the upload names every icon but only attaches bytes on request', () {
    final app = InstalledApp(
      packageName: 'com.google.android.youtube',
      appName: 'YouTube',
      iconSha256: 'ab' * 32,
      iconPng: Uint8List.fromList([1, 2, 3]),
    );

    expect(app.toJson(), {
      'package_name': 'com.google.android.youtube',
      'app_name': 'YouTube',
      'icon_sha256': 'ab' * 32,
    });
    expect(app.toJson(withIcon: true)['icon_png'], 'AQID');
    expect(
      const InstalledApp(packageName: 'com.a', appName: 'A').toJson(),
      {'package_name': 'com.a', 'app_name': 'A'},
    );
  });
}
