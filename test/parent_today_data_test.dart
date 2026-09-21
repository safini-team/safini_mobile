import 'package:flutter_test/flutter_test.dart';
import 'package:safini/features/parent/presentation/screens/monitor/parent_today_view.dart';

void main() {
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
