import 'package:flutter_test/flutter_test.dart';
import 'package:safini/features/parent/presentation/cubit/parent_monitor_cubit.dart';
import 'package:safini/features/parent/presentation/cubit/parent_tasks_cubit.dart';
import 'package:safini/features/parent/presentation/screens/monitor/parent_monitor_screen.dart';
import 'package:safini/features/prizes/prize_asks_cubit.dart';

/// SAF-191: pulling Today refetched usage, the family and wishes but never the
/// tasks, so a child's submission did not show under "Needs your review".
class _Monitor extends Fake implements ParentMonitorCubit {
  int loads = 0;

  @override
  Future<void> loadMonitorData({String? childId}) async => loads++;
}

class _Asks extends Fake implements PrizeAsksCubit {
  int loads = 0;

  @override
  Future<void> load() async => loads++;
}

class _Tasks extends Fake implements ParentTasksCubit {
  final calls = <String>[];

  @override
  Future<void> loadAllTasks() async => calls.add('all');

  @override
  Future<void> loadTasks({String? childId}) async => calls.add('one');
}

void main() {
  test('pull to refresh on Today refetches every child\'s tasks', () async {
    final monitor = _Monitor();
    final asks = _Asks();
    final tasks = _Tasks();

    await refreshParentToday(monitor: monitor, asks: asks, tasks: tasks);

    expect(monitor.loads, 1);
    expect(asks.loads, 1);
    // All children: the cubit is shared with the Tasks tab and the Today
    // picker badges count every child's pending reviews.
    expect(tasks.calls, ['all']);
  });
}
