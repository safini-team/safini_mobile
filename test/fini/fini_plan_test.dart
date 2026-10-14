import 'package:flutter_test/flutter_test.dart';
import 'package:safini/features/fini/domain/fini_models.dart';
import 'package:safini/features/fini/domain/fini_plan.dart';

void main() {
  group('formatPlanSteps', () {
    test('steady from 2h10m to 45m: 25% a week, clamped at the goal', () {
      expect(formatPlanSteps(130, 45, FiniPace.steady), [130, 98, 74, 56, 45]);
    });

    test('gentle takes 15% a week', () {
      final steps = formatPlanSteps(120, 60, FiniPace.gentle);
      expect(steps.first, 120);
      expect(steps[1], 102);
      expect(steps.last, 60);
      for (var i = 1; i < steps.length; i++) {
        expect(steps[i], lessThan(steps[i - 1]));
        expect(
          steps[i - 1] - steps[i],
          lessThanOrEqualTo(steps[i - 1] * 0.15 + 0.5),
        );
      }
    });

    test('now goes straight to the goal', () {
      expect(formatPlanSteps(130, 45, FiniPace.now), [130, 45]);
    });

    test('already at or under the goal is no plan', () {
      expect(formatPlanSteps(45, 45, FiniPace.steady), [45]);
      expect(formatPlanSteps(30, 45, FiniPace.gentle), [30]);
    });

    test('small numbers still step at least a minute', () {
      expect(formatPlanSteps(3, 1, FiniPace.gentle), [3, 2, 1]);
    });

    test('a zero goal ends, capped at a year', () {
      final steps = formatPlanSteps(600, 0, FiniPace.gentle);
      expect(steps.last, 0);
      expect(steps.length, lessThanOrEqualTo(53));
    });

    test('planWeeks counts the steps after today', () {
      expect(planWeeks(130, 45, FiniPace.steady), 4);
      expect(planWeeks(45, 45, FiniPace.steady), 0);
    });
  });
}
