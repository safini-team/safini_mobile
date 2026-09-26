import 'dart:io';

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart' show MaterialApp;
import 'package:safini/core/translation/generated/l10n.dart';
import 'package:safini/features/onboarding/fini.dart';
import 'package:safini/features/onboarding/pairing_connected.dart';
import 'package:safini/features/onboarding/pairing_watch.dart';

/// The add-child screen flips to "connected" by itself once the kid's phone
/// uses the code.
void main() {
  testWidgets('polls until the phone connects, then stops', (tester) async {
    var checks = 0;
    var connected = 0;
    final watch = PairingWatch(
      isConnected: () async => ++checks >= 3,
      onConnected: () => connected++,
    )..start();

    await tester.pump(const Duration(seconds: 3));
    await tester.pump(const Duration(seconds: 3));
    expect(connected, 0);
    await tester.pump(const Duration(seconds: 3));
    expect(connected, 1);
    expect(watch.isWatching, isFalse);

    await tester.pump(const Duration(seconds: 30));
    expect(checks, 3);
  });

  testWidgets('the child_connected push checks at once', (tester) async {
    var connected = false;
    final watch = PairingWatch(
      isConnected: () async => true,
      onConnected: () => connected = true,
    )..start();

    await watch.checkNow();
    expect(connected, isTrue);
    expect(watch.isWatching, isFalse);
  });

  testWidgets('a failed check is retried on the next tick', (tester) async {
    var checks = 0;
    var connected = false;
    PairingWatch(
      isConnected: () async {
        if (++checks == 1) throw Exception('offline');
        return true;
      },
      onConnected: () => connected = true,
    ).start();

    await tester.pump(const Duration(seconds: 3));
    expect(connected, isFalse);
    await tester.pump(const Duration(seconds: 3));
    expect(connected, isTrue);
  });

  testWidgets('gives up after the deadline', (tester) async {
    var checks = 0;
    final watch = PairingWatch(
      isConnected: () async {
        checks++;
        return false;
      },
      onConnected: () {},
      giveUpAfter: const Duration(seconds: 10),
    )..start();

    await tester.pump(const Duration(seconds: 10));
    final atDeadline = checks;
    expect(watch.isWatching, isFalse);
    await tester.pump(const Duration(minutes: 1));
    expect(checks, atDeadline);
  });

  test('every Fini pose has its art', () {
    for (final pose in FiniPose.values) {
      expect(File(pose.asset).existsSync(), isTrue, reason: pose.asset);
    }
  });

  testWidgets('switching pose swaps the art', (tester) async {
    Widget fini(FiniPose pose) => MediaQuery(
      data: const MediaQueryData(disableAnimations: true),
      child: Directionality(
        textDirection: TextDirection.ltr,
        child: Fini(pose: pose),
      ),
    );
    await tester.pumpWidget(fini(FiniPose.wait));
    expect(
      find.image(const AssetImage('assets/mascot/fini-wait.png')),
      findsOneWidget,
    );
    await tester.pumpWidget(fini(FiniPose.cheer));
    await tester.pump(const Duration(milliseconds: 300));
    expect(
      find.image(const AssetImage('assets/mascot/fini-cheer.png')),
      findsOneWidget,
    );
  });

  testWidgets('connected says whose phone and goes back to the family', (
    tester,
  ) async {
    var done = false;
    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: const [S.delegate],
        supportedLocales: S.delegate.supportedLocales,
        locale: const Locale('en'),
        builder: (context, page) => MediaQuery(
          data: MediaQuery.of(context).copyWith(disableAnimations: true),
          child: page!,
        ),
        home: PairingConnected(name: 'Amir', onDone: () => done = true),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text("Amir's phone is connected!"), findsOneWidget);
    await tester.tap(find.text('Go to my family'));
    expect(done, isTrue);
  });
}
