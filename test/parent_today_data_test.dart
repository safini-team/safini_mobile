import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:safini/features/parent/presentation/screens/monitor/parent_today_view.dart';

/// The screen-time ring and the "X left today" line are both derived, and both
/// have to survive two states the backend really produces: no allowance set at
/// all (`limitMinutes == 0`), and a child who has already blown through it.
/// Neither is reachable from the artboard, which only ever draws 130 of 180.
ParentTodayData _data({
  required int used,
  required int limit,
  List<TodayApp> apps = const [],
}) {
  return ParentTodayData(
    kids: const [TodayKid(id: 'c1', name: 'Amir', color: Color(0xFF8100D1))],
    selectedIndex: 0,
    kidName: 'Amir',
    usedMinutes: used,
    limitMinutes: limit,
    topApp: 'Roblox',
    tasksDone: 2,
    tasksTotal: 5,
    coins: 240,
    reviews: const [],
    apps: apps,
  );
}

void main() {
  group('leftMinutes', () {
    test('is the remainder of the allowance', () {
      expect(_data(used: 130, limit: 180).leftMinutes, 50);
      expect(_data(used: 0, limit: 180).leftMinutes, 180);
    });

    test('floors at zero once the child is over', () {
      expect(_data(used: 200, limit: 180).leftMinutes, 0);
      expect(_data(used: 999, limit: 180).leftMinutes, 0);
    });

    test('is zero when no allowance is set', () {
      // A child with no limit has no "time left" to report - the card falls
      // back to showing usage only.
      expect(_data(used: 130, limit: 0).leftMinutes, 0);
    });

    test('does not go negative on a negative limit', () {
      expect(_data(used: 10, limit: -30).leftMinutes, 0);
    });
  });

  group('ringProgress', () {
    test('is the used fraction', () {
      expect(_data(used: 90, limit: 180).ringProgress, 0.5);
      expect(_data(used: 0, limit: 180).ringProgress, 0.0);
    });

    test('caps at a full ring rather than overdrawing the arc', () {
      expect(_data(used: 180, limit: 180).ringProgress, 1.0);
      expect(_data(used: 400, limit: 180).ringProgress, 1.0);
    });

    test('is zero rather than NaN when no allowance is set', () {
      // `used / 0` is infinity in Dart, not a throw - it would reach the arc
      // painter and blow up there instead of here.
      final progress = _data(used: 130, limit: 0).ringProgress;
      expect(progress, 0.0);
      expect(progress.isFinite, isTrue);
    });
  });

  group('TodayApp.isOver', () {
    const roblox = TodayApp(
      name: 'Roblox',
      emoji: '🎮',
      usedMinutes: 62,
      limitMinutes: 45,
    );
    const youtube = TodayApp(
      name: 'YouTube',
      emoji: '📺',
      usedMinutes: 38,
      limitMinutes: 60,
    );
    const telegram = TodayApp(
      name: 'Telegram',
      emoji: '💬',
      usedMinutes: 21,
      limitMinutes: 0,
    );

    test('flags an app past its own limit', () {
      // The artboard's Roblox row: 62 min against a 45 min cap, drawn red.
      expect(roblox.isOver, isTrue);
      expect(youtube.isOver, isFalse);
    });

    test('an uncapped app is never over', () {
      // Limit 0 means "not limited", not "limited to nothing" - Telegram and
      // Spotify sit in the list with usage but no cap.
      expect(telegram.isOver, isFalse);
    });

    test('exactly at the limit is not yet over', () {
      const atCap = TodayApp(
        name: 'Roblox',
        emoji: '🎮',
        usedMinutes: 45,
        limitMinutes: 45,
      );
      expect(atCap.isOver, isFalse);
    });
  });
}
