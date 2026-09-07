import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:safini/features/child/data/services/app_block_service.dart';

/// The Dart half of the enforcement bridge. Nothing else checks that these
/// method names and argument shapes still match `MainActivity.kt`, and a
/// silent mismatch means the child's phone simply stops enforcing.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const android = AppBlockService(supported: true);
  const elsewhere = AppBlockService(supported: false);
  final calls = <MethodCall>[];
  Object? reply;

  setUp(() {
    calls.clear();
    reply = null;
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(AppBlockService.channel, (call) async {
      calls.add(call);
      return reply;
    });
  });

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(AppBlockService.channel, null);
  });

  test('permission checks report what the native side reported', () async {
    reply = false;
    expect(await android.hasUsageAccess(), isFalse);
    expect(await android.hasOverlayPermission(), isFalse);
    reply = true;
    expect(await android.hasUsageAccess(), isTrue);
    expect(
      calls.map((c) => c.method),
      ['hasUsageAccess', 'hasOverlayPermission', 'hasUsageAccess'],
    );
  });

  test('a null answer from native counts as "not granted"', () async {
    reply = null;
    expect(await android.hasUsageAccess(), isFalse);
    expect(await android.isRunning(), isFalse);
  });

  test('configure and purchase carry the arguments native expects', () async {
    await android.configure({
      'baseUrl': 'https://api.safini.fun',
      'childId': 'child-1',
      'deviceToken': 'secret',
    });
    expect(calls.single.method, 'configure');
    expect((calls.single.arguments as Map)['childId'], 'child-1');

    calls.clear();
    reply = jsonEncode({
      'balance': 150,
      'apps': [
        {'app_slug': 'roblox', 'remaining_minutes_today': 20},
      ],
    });
    final result = await android.purchaseTime('roblox', 150, 20);
    expect(calls.single.method, 'purchaseTime');
    expect(calls.single.arguments, {
      'slug': 'roblox',
      'cost': 150,
      'minutes': 20,
    });
    expect(result['balance'], 150);
  });

  test('installed apps survive a malformed entry', () async {
    reply = [
      {'packageName': 'com.roblox.client', 'appName': 'Roblox'},
      'not a map',
    ];
    final apps = await android.installedApps();
    expect(apps.length, 1);
    expect(apps.single.packageName, 'com.roblox.client');
  });

  test('a platform without the native side is never called', () async {
    await elsewhere.startService();
    await elsewhere.syncNow();
    await elsewhere.stopService();
    await elsewhere.configure({'childId': 'child-1'});
    expect(await elsewhere.installedApps(), isEmpty);
    expect(calls, isEmpty);

    // Permission checks answer "granted" off Android on purpose: the child
    // shell gates on isSupported first, and a false here would strand iOS on a
    // setup screen it can never satisfy.
    expect(await elsewhere.hasUsageAccess(), isTrue);
  });
}
