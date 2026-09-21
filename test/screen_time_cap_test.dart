import 'package:flutter_test/flutter_test.dart';
import 'package:safini/features/parent/domain/models/screen_time_model.dart';

void main() {
  test(
    'metadata preserves reset instant and independent capability states',
    () {
      final model = ScreenTimeModel.fromJson({
        'global_limit_minutes': 90,
        'global_used_minutes': 0,
        'global_remaining_minutes': 90,
        'usage_available': false,
        'configuration_available': true,
        'enforcement_available': null,
        'budget_scope': 'safini_managed_apps',
        'next_reset_at': '2026-09-21T18:00:00Z',
      });
      expect(model.nextResetAt, DateTime.utc(2026, 9, 21, 18));
      expect(model.budgetScope, 'safini_managed_apps');
      expect(model.configurationAvailable, isTrue);
      expect(model.usageAvailable, isFalse);
      expect(model.enforcementAvailable, isNull);
      expect(ScreenTimeModel.none.configurationAvailable, isFalse);
    },
  );

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
}
