import 'dart:async';

import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:safini/core/utils/error/failures.dart';
import 'package:safini/features/models/data/services/device_usage_service.dart';
import 'package:safini/features/models/domain/controllers/task_controller.dart';
import 'package:safini/features/models/domain/models/device_usage.dart';
import 'package:safini/features/models/domain/models/family_model.dart';
import 'package:safini/features/parent/domain/models/child_app_usage_model.dart';
import 'package:safini/features/parent/domain/models/parent_tasks_response_model.dart';
import 'package:safini/features/parent/domain/repositories/i_parent_app_usage_repository.dart';
import 'package:safini/features/parent/domain/repositories/i_parent_task_repository.dart';
import 'package:safini/features/parent/presentation/cubit/parent_apps_cubit.dart';
import 'package:safini/features/parent/presentation/cubit/parent_apps_state.dart';
import 'package:safini/features/parent/presentation/cubit/parent_family_cubit.dart';
import 'package:safini/features/parent/presentation/cubit/parent_family_state.dart';
import 'package:safini/features/parent/presentation/cubit/parent_monitor_cubit.dart';
import 'package:safini/features/parent/presentation/cubit/parent_monitor_state.dart';
import 'package:safini/features/parent/presentation/cubit/parent_tasks_cubit.dart';
import 'package:safini/features/parent/presentation/cubit/parent_tasks_state.dart';

/// Every tab refetched on every switch and swapped itself for its skeleton
/// while it did, so moving between Today, Tasks and Limits flashed loading
/// blocks each time. A refresh now keeps what is on screen.
FamilyModel _family(List<String> ids) => FamilyModel.fromJson({
  'id': 'family',
  'children': [
    for (final id in ids) {'id': id, 'nickname': id, 'coins_balance': 10},
  ],
});

class _Family extends Fake implements ParentFamilyCubit {
  _Family(this._family);

  final FamilyModel _family;
  final _controller = StreamController<ParentFamilyState>.broadcast();

  @override
  ParentFamilyState get state => ParentFamilyState.initial(family: _family);

  @override
  Stream<ParentFamilyState> get stream => _controller.stream;

  @override
  Future<void> loadCurrentFamily({bool refresh = false}) async {}
}

class _Usage extends Fake implements IParentAppUsageRepository {
  bool fail = false;

  @override
  Future<Either<Failure, ChildAppUsageSnapshot>> fetchAppUsage(
    String childId,
  ) async => fail
      ? const Left(ServerFailure('down'))
      : Right(
          ChildAppUsageSnapshot(
            apps: [
              ChildAppUsageModel(
                appSlug: 'youtube',
                displayName: 'YouTube',
                isBlocked: false,
                isLimited: true,
                canRedeem: true,
                dailyLimitMinutes: 30,
                usedMinutes: 5,
                remainingMinutesToday: 25,
                redeemCoinCost: 1,
                redeemRewardMinutes: 5,
              ),
            ],
            screenTime: ChildAppUsageSnapshot.empty.screenTime,
          ),
        );

  @override
  Future<String?> fetchChildFaceEmoji(String childId) async => null;
}

class _DeviceUsage extends Fake implements DeviceUsageService {
  Completer<Either<Failure, WeekUsage>>? week;

  @override
  Future<Either<Failure, DeviceUsage>> fetch(String childId) async => Right(
    DeviceUsage(
      usageDate: '2026-09-26',
      usageAvailable: true,
      totalMinutes: 40,
      apps: const [],
    ),
  );

  @override
  Future<Either<Failure, WeekUsage>> fetchWeek(String childId, String today) {
    week = Completer();
    return week!.future;
  }
}

class _TaskRepo extends Fake implements IParentTaskRepository {
  final pending =
      <String, Completer<Either<Failure, ParentTasksResponseModel>>>{};

  @override
  Future<Either<Failure, ParentTasksResponseModel>> fetchTasks(
    String childId,
  ) => (pending[childId] = Completer()).future;

  void answer(String childId, {bool fail = false}) =>
      pending[childId]!.complete(
        fail
            ? const Left(ServerFailure('down'))
            : Right(
                ParentTasksResponseModel(
                  tasks: [
                    ParentTaskInstanceModel.fromJson({
                      'id': 'task-$childId',
                      'status': 'pending',
                      'child_id': childId,
                    }),
                  ],
                ),
              ),
      );
}

class _NoTasks extends Fake implements TaskController {}

void main() {
  group('Today', () {
    test('a refresh of the same child never shows the skeleton', () async {
      final cubit = ParentMonitorCubit(_Family(_family(['amir'])), _Usage());
      addTearDown(cubit.close);
      await cubit.loadMonitorData();
      expect(cubit.state, isA<ParentMonitorLoaded>());
      expect(cubit.isFreshFor('amir'), isTrue);

      final seen = <ParentMonitorState>[];
      final sub = cubit.stream.listen(seen.add);
      await cubit.loadMonitorData();
      await sub.cancel();

      expect(seen, isNotEmpty);
      expect(seen.whereType<ParentMonitorLoading>(), isEmpty);
    });

    test('switching to another child still shows the skeleton', () async {
      final cubit = ParentMonitorCubit(
        _Family(_family(['amir', 'zilola'])),
        _Usage(),
      );
      addTearDown(cubit.close);
      await cubit.loadMonitorData(childId: 'amir');
      expect(cubit.isFreshFor('zilola'), isFalse);

      final seen = <ParentMonitorState>[];
      final sub = cubit.stream.listen(seen.add);
      await cubit.loadMonitorData(childId: 'zilola');
      await sub.cancel();

      expect(seen.first, isA<ParentMonitorLoading>());
      expect((cubit.state as ParentMonitorLoaded).selectedChild?.id, 'zilola');
    });

    test('the week chart stays up while a refresh fetches it again', () async {
      final device = _DeviceUsage();
      final cubit = ParentMonitorCubit(
        _Family(_family(['amir'])),
        _Usage(),
        deviceUsage: device,
      );
      addTearDown(cubit.close);
      final first = cubit.loadMonitorData();
      await pumpEventQueue();
      final week = WeekUsage(
        days: [DayUsage(date: DateTime(2026, 9, 25), minutes: 90)],
        apps: const [],
      );
      device.week!.complete(Right(week));
      await first;
      expect((cubit.state as ParentMonitorLoaded).weekUsage, week);

      final refresh = cubit.loadMonitorData();
      await pumpEventQueue();
      // Today is back with fresh numbers; the new week has not answered yet.
      expect((cubit.state as ParentMonitorLoaded).weekUsage, week);
      device.week!.complete(Right(week));
      await refresh;
    });
  });

  group('Limits', () {
    test('a refresh keeps the rows up, even when it fails', () async {
      final usage = _Usage();
      final cubit = ParentAppsCubit(_Family(_family(['amir'])), usage);
      addTearDown(cubit.close);
      await cubit.loadAppLimits();
      expect((cubit.state as ParentAppsLoaded).appLimits, hasLength(1));
      expect(cubit.isFreshFor('amir'), isTrue);

      final seen = <ParentAppsState>[];
      final sub = cubit.stream.listen(seen.add);
      usage.fail = true;
      await cubit.loadAppLimits();
      await sub.cancel();

      expect(seen.whereType<ParentAppsLoading>(), isEmpty);
      expect((cubit.state as ParentAppsLoaded).appLimits, hasLength(1));
    });
  });

  group('Tasks', () {
    test('every child is fetched at once, not one after another', () async {
      final repo = _TaskRepo();
      final cubit = ParentTasksCubit(
        repo,
        _Family(_family(['amir', 'zilola'])),
        _NoTasks(),
      );
      addTearDown(cubit.close);
      final load = cubit.loadAllTasks();
      await pumpEventQueue();
      expect(repo.pending.keys, ['amir', 'zilola']);
      repo.answer('amir');
      repo.answer('zilola');
      await load;
      expect((cubit.state as ParentTasksLoaded).tasks, hasLength(2));
      expect(cubit.isFresh, isTrue);
    });

    test('a refresh keeps the list up, even when it fails', () async {
      final repo = _TaskRepo();
      final cubit = ParentTasksCubit(
        repo,
        _Family(_family(['amir'])),
        _NoTasks(),
      );
      addTearDown(cubit.close);
      final first = cubit.loadAllTasks();
      await pumpEventQueue();
      repo.answer('amir');
      await first;

      final seen = <ParentTasksState>[];
      final sub = cubit.stream.listen(seen.add);
      final refresh = cubit.loadAllTasks();
      await pumpEventQueue();
      repo.answer('amir', fail: true);
      await refresh;
      await sub.cancel();

      expect(seen, isEmpty);
      expect((cubit.state as ParentTasksLoaded).tasks, hasLength(1));
    });

    test(
      'an older load that lands late does not overwrite a newer one',
      () async {
        final repo = _TaskRepo();
        final cubit = ParentTasksCubit(
          repo,
          _Family(_family(['amir'])),
          _NoTasks(),
        );
        addTearDown(cubit.close);
        final older = cubit.loadAllTasks();
        await pumpEventQueue();
        final olderReply = repo.pending['amir']!;
        final newer = cubit.loadAllTasks();
        await pumpEventQueue();
        repo.answer('amir');
        await newer;
        olderReply.complete(const Left(ServerFailure('down')));
        await older;
        expect(cubit.state, isA<ParentTasksLoaded>());
      },
    );
  });
}
