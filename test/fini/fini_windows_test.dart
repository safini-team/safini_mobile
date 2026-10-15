import 'package:flutter_test/flutter_test.dart';
import 'package:safini/features/fini/domain/fini_goal_specs.dart';
import 'package:safini/features/fini/domain/fini_models.dart';
import 'package:safini/features/fini/kid/kid_fini.dart';

void main() {
  test('school hours start Monday to Friday, bedtime every day', () {
    expect(specFor(GoalIntent.school).createBody()['window_days'], 31);
    expect(specFor(GoalIntent.bedtime).createBody()['window_days'], 127);
  });

  test('a goal from an older API runs every day', () {
    final goal = FiniGoal.fromJson({
      'id': 'g',
      'child_id': 'c',
      'kind': 'schedule_window',
      'target': {'intent': 'bedtime'},
      'window_start': '22:00:00',
      'window_end': '07:00:00',
    });
    expect(goal.windowDays, allWeekdays);
  });

  test('the kid view carries the window on now', () {
    final fini = KidFini.fromJson({
      'pools': [],
      'window': {'intent': 'bedtime', 'until': '07:00'},
    });
    expect(fini.window!.until, '07:00');
    expect(KidFini.fromJson({'window': null}).window, isNull);
  });
}
