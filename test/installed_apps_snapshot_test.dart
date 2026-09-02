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
}
