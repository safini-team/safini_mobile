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

  test('every app names the slug a parent can limit it under', () {
    final snapshot = InstalledAppsSnapshot.fromJson({
      'apps': [
        {
          'package_name': 'com.google.android.youtube',
          'app_name': 'YouTube',
          'app_slug': 'youtube',
        },
        // Not in the catalog: the API still names a slug for it.
        {
          'package_name': 'com.whatsapp',
          'app_name': 'WhatsApp',
          'app_slug': 'com.whatsapp',
        },
      ],
      'updated_at': '2026-09-13T12:00:00Z',
    });

    expect(snapshot.apps.map((app) => app.ruleSlug), [
      'youtube',
      'com.whatsapp',
    ]);
  });

  test('an API without app_slug still maps the catalog apps by package', () {
    final snapshot = InstalledAppsSnapshot.fromJson({
      'apps': [
        {'package_name': 'com.roblox.client', 'app_name': 'Roblox'},
        {'package_name': 'com.whatsapp', 'app_name': 'WhatsApp'},
        {'package_name': 'com.blank', 'app_name': 'Blank', 'app_slug': ''},
      ],
      'updated_at': '2026-09-13T12:00:00Z',
    });

    expect(snapshot.apps.map((app) => app.appSlug), [null, null, null]);
    expect(snapshot.apps.map((app) => app.ruleSlug), ['roblox', null, null]);
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
