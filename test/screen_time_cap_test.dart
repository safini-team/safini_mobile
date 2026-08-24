import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:safini/core/utils/screen_time_cap.dart';
import 'package:safini/features/parent/domain/models/screen_time_model.dart';
import 'package:safini/features/parent/presentation/screens/apps/parent_limits_view.dart';

/// The whole-device cap is the first figure in the parent app that a child can
/// actually spend down. Everything here guards the two ways it has already
/// been got wrong once: reading zero as "unlimited" (F25 did exactly that with
/// `daily_limit_minutes`), and presenting the sum of the per-app limits as if
/// it were a budget.
ParentLimitsData _data({int? cap, List<LimitsApp> apps = const []}) {
  return ParentLimitsData(
    kids: const [LimitsKid(id: 'c1', name: 'Amir', color: Color(0xFF8100D1))],
    selectedKidId: 'c1',
    kidName: 'Amir',
    apps: apps,
    capMinutes: cap,
  );
}

LimitsApp _app({required int used, required int limit, bool isLimited = true}) {
  return LimitsApp(
    slug: 'roblox',
    name: 'Roblox',
    emoji: '🎮',
    usedMinutes: used,
    limitMinutes: limit,
    isLimited: isLimited,
    canRedeem: true,
  );
}

void main() {
  group('ScreenTimeModel.fromJson', () {
    test('reads the budget the server computed', () {
      final model = ScreenTimeModel.fromJson(const {
        'global_limit_minutes': 180,
        'global_used_minutes': 130,
        'global_remaining_minutes': 50,
      });
      expect(model.limitMinutes, 180);
      expect(model.usedMinutes, 130);
      expect(model.remainingMinutes, 50);
      expect(model.hasCap, isTrue);
    });

    test('an uncapped child still reports usage', () {
      final model = ScreenTimeModel.fromJson(const {
        'global_limit_minutes': null,
        'global_used_minutes': 130,
        'global_remaining_minutes': null,
      });
      expect(model.hasCap, isFalse);
      expect(model.usedMinutes, 130);
    });

    test('a cap of zero is a cap, not the absence of one', () {
      // `daily_screen_time_minutes = 0` means no free time at all. Reading it
      // as "unlimited" is the inversion that shipped in F25.
      final model = ScreenTimeModel.fromJson(const {
        'global_limit_minutes': 0,
        'global_used_minutes': 40,
        'global_remaining_minutes': 0,
      });
      expect(model.hasCap, isTrue);
      expect(model.limitMinutes, 0);
    });

    test('survives a response with no screen_time keys at all', () {
      final model = ScreenTimeModel.fromJson(const {});
      expect(model.hasCap, isFalse);
      expect(model.usedMinutes, 0);
    });
  });

  group('the stepper ladder', () {
    test('climbs in quarter hours', () {
      expect(screenTimeCapUp(60), 75);
      expect(screenTimeCapUp(75), 90);
      expect(screenTimeCapDown(90), 75);
    });

    test('the first press seeds from the per-app limits', () {
      // A child with four hours of apps should not have their first cap land
      // at fifteen minutes.
      expect(screenTimeCapUp(null, combinedMinutes: 255), 255);
      expect(screenTimeCapUp(null, combinedMinutes: 250), 255);
      expect(screenTimeCapUp(null, combinedMinutes: 0), screenTimeCapSeed);
    });

    test('lands on a rung when the server value is off-step', () {
      // Nothing stops a cap of 100 arriving - the API takes any 0..1440.
      expect(screenTimeCapUp(100), 105);
      expect(screenTimeCapDown(100), 90);
    });

    test('the bottom rung removes the cap', () {
      expect(screenTimeCapDown(15), isNull);
      expect(screenTimeCapDown(0), isNull);
      expect(screenTimeCapDown(null), isNull);
    });

    test('stops at a full day', () {
      expect(screenTimeCapUp(screenTimeCapMax), screenTimeCapMax);
      expect(screenTimeCapUp(1435), screenTimeCapMax);
    });

    test('a cap of zero climbs back onto the ladder', () {
      expect(screenTimeCapUp(0), 15);
    });
  });

  group('ParentLimitsData', () {
    test('counts down the cap when one is set', () {
      final data = _data(cap: 120, apps: [_app(used: 45, limit: 60)]);
      expect(data.allowanceMinutes, 120);
      expect(data.leftMinutes, 75);
      expect(data.progress, closeTo(0.375, 0.001));
    });

    test('falls back to the sum of the per-app limits with no cap', () {
      // Not a budget - nothing spends from it - which is why the panel labels
      // it "all apps combined" rather than as an allowance.
      final data = _data(
        apps: [_app(used: 45, limit: 60), _app(used: 20, limit: 45)],
      );
      expect(data.hasCap, isFalse);
      expect(data.allowanceMinutes, 105);
      expect(data.combinedLimitMinutes, 105);
    });

    test('a cap of zero leaves no time, rather than unlimited time', () {
      final data = _data(cap: 0, apps: [_app(used: 45, limit: 60)]);
      expect(data.hasCap, isTrue);
      expect(data.allowanceMinutes, 0);
      expect(data.leftMinutes, 0);
      expect(data.progress, 0);
    });

    test('the cap wins over a larger combined sum', () {
      // The whole point: four apps at an hour each do not add up to four hours
      // of screen time once the parent sets a two-hour cap.
      final data = _data(
        cap: 120,
        apps: [_app(used: 30, limit: 60), _app(used: 30, limit: 60)],
      );
      expect(data.combinedLimitMinutes, 120);
      expect(data.allowanceMinutes, 120);
      expect(_data(cap: 60, apps: data.apps).leftMinutes, 0);
    });
  });
}
