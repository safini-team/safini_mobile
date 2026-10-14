import 'package:safini/features/fini/domain/fini_models.dart';

/// The biggest step down one week may take, as a share of the current limit.
/// Mirrors `PACE_MAX_WEEKLY_STEP` in safini-api's `services/fini/policy.py`.
const paceWeeklyStep = {
  FiniPace.gentle: 0.15,
  FiniPace.steady: 0.25,
  FiniPace.now: 1.0,
};

/// Minutes a day for each week of the plan: today's [start] first, then one
/// step every Monday at [pace] until [target]. Never below [target] and never
/// above [start]; a start already at or under the target is just `[start]`.
///
/// The same arithmetic as the API's plan (SAF-274 shares a fixture).
List<int> formatPlanSteps(int start, int target, FiniPace pace) {
  if (start <= target) return [start];
  final step = paceWeeklyStep[pace]!;
  final steps = [start];
  var current = start;
  while (current > target && steps.length < 53) {
    final next = (current * (1 - step)).round();
    // A share of a small number can round to no step at all.
    current = next >= current ? current - 1 : next;
    if (current < target) current = target;
    steps.add(current);
  }
  return steps;
}

/// Weeks until the plan reaches its target.
int planWeeks(int start, int target, FiniPace pace) =>
    formatPlanSteps(start, target, pace).length - 1;
