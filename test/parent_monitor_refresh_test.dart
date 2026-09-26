import 'dart:async';

import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:safini/core/utils/error/failures.dart';
import 'package:safini/features/models/data/services/device_usage_service.dart';
import 'package:safini/features/models/domain/models/device_usage.dart';
import 'package:safini/features/models/domain/models/family_model.dart';
import 'package:safini/features/parent/domain/models/child_app_usage_model.dart';
import 'package:safini/features/parent/domain/repositories/i_parent_app_usage_repository.dart';
import 'package:safini/features/parent/presentation/cubit/parent_family_cubit.dart';
import 'package:safini/features/parent/presentation/cubit/parent_family_state.dart';
import 'package:safini/features/parent/presentation/cubit/parent_monitor_cubit.dart';
import 'package:safini/features/parent/presentation/cubit/parent_monitor_state.dart';
import 'package:safini/features/parent/presentation/cubit/parent_apps_cubit.dart';
import 'package:safini/features/parent/presentation/cubit/parent_apps_state.dart';
import 'package:safini/features/parent/domain/models/screen_time_model.dart';

/// Coins and the streak on the Today card come from the child rows in the
/// family, and the monitor only fetched the family when it had none. Approving
/// a task or the child spending on the block screen left the card showing the
/// balance from app start, while the usage under it updated.
FamilyModel _family(Map<String, int> coinsByChild) => FamilyModel.fromJson({
  'id': 'family',
  'children': [
    for (final entry in coinsByChild.entries)
      {'id': entry.key, 'nickname': entry.key, 'coins_balance': entry.value},
  ],
});

class _Family extends Fake implements ParentFamilyCubit {
  _Family(this._family);

  FamilyModel _family;
  int loads = 0;
  final _controller = StreamController<ParentFamilyState>.broadcast();

  void serve(FamilyModel family) => _family = family;

  @override
  ParentFamilyState get state => ParentFamilyState.initial(family: _family);

  @override
  Stream<ParentFamilyState> get stream => _controller.stream;

  @override
  Future<void> loadCurrentFamily({bool refresh = false}) async {
    if (refresh) loads++;
  }
}

class _Usage extends Fake implements IParentAppUsageRepository {
  final requested = <String>[];

  @override
  Future<Either<Failure, ChildAppUsageSnapshot>> fetchAppUsage(
    String childId,
  ) async {
    requested.add(childId);
    return const Right(ChildAppUsageSnapshot.empty);
  }

  @override
  Future<String?> fetchChildFaceEmoji(String childId) async => null;
}

class _DeviceUsage extends Fake implements DeviceUsageService {
  _DeviceUsage({this.today});

  /// The family-local day the API answers with; null like an older fake.
  final String? today;
  final requested = <String>[];
  final weeks = <(String, String)>[];

  @override
  Future<Either<Failure, WeekUsage>> fetchWeek(
    String childId,
    String today,
  ) async {
    weeks.add((childId, today));
    return Right(
      WeekUsage(
        days: [DayUsage(date: DateTime(2026, 9, 25), minutes: 90)],
        apps: [DeviceUsageApp(displayName: childId, usedMinutes: 90)],
      ),
    );
  }

  @override
  Future<Either<Failure, DeviceUsage>> fetch(String childId) async {
    requested.add(childId);
    return Right(
      DeviceUsage(
        usageDate: today,
        usageAvailable: true,
        totalMinutes: 40,
        apps: [DeviceUsageApp(displayName: childId, usedMinutes: 40)],
      ),
    );
  }
}

class _DelayedUsage extends _Usage {
  final replies = <String, Completer<Either<Failure, ChildAppUsageSnapshot>>>{};
  @override
  Future<Either<Failure, ChildAppUsageSnapshot>> fetchAppUsage(String childId) {
    requested.add(childId);
    return (replies[childId] = Completer()).future;
  }

  void finish(String id, int minutes) => replies[id]!.complete(
    Right(
      ChildAppUsageSnapshot(
        apps: const [],
        screenTime: ScreenTimeModel(
          limitMinutes: minutes,
          usedMinutes: 0,
          remainingMinutes: minutes,
        ),
      ),
    ),
  );
}

void main() {
  test(
    'Today discards a slow response for the previously selected child',
    () async {
      final family = _Family(_family({'amir': 25, 'zilola': 40}));
      final usage = _DelayedUsage();
      final cubit = ParentMonitorCubit(family, usage);
      addTearDown(cubit.close);
      final first = cubit.loadMonitorData(childId: 'amir');
      await Future<void>.delayed(Duration.zero);
      final second = cubit.loadMonitorData(childId: 'zilola');
      await Future<void>.delayed(Duration.zero);
      usage.finish('zilola', 15);
      await second;
      usage.finish('amir', 90);
      await first;
      expect((cubit.state as ParentMonitorLoaded).selectedChild?.id, 'zilola');
      expect((cubit.state as ParentMonitorLoaded).screenTime.limitMinutes, 15);
    },
  );

  test(
    'Limits discards a slow response for the previously selected child',
    () async {
      final family = _Family(_family({'amir': 25, 'zilola': 40}));
      final usage = _DelayedUsage();
      final cubit = ParentAppsCubit(family, usage);
      addTearDown(cubit.close);
      final first = cubit.loadAppLimits(childId: 'amir');
      final second = cubit.loadAppLimits(childId: 'zilola');
      usage.finish('zilola', 15);
      await second;
      usage.finish('amir', 90);
      await first;
      expect(cubit.childId, 'zilola');
      expect((cubit.state as ParentAppsLoaded).screenTime.limitMinutes, 15);
    },
  );

  test('a reload refetches the family, so the coin balance is current', () async {
    final family = _Family(_family({'amir': 25}));
    final cubit = ParentMonitorCubit(family, _Usage());
    addTearDown(cubit.close);

    await cubit.loadMonitorData();
    expect(
      (cubit.state as ParentMonitorLoaded).selectedChild?.coinsBalance,
      25,
    );

    // The parent approves a task on this device and the child spends on theirs.
    family.serve(_family({'amir': 15}));
    await cubit.loadMonitorData();

    expect(family.loads, 2);
    expect(
      (cubit.state as ParentMonitorLoaded).selectedChild?.coinsBalance,
      15,
    );
  });

  test('a reload keeps the child the parent was looking at', () async {
    final family = _Family(_family({'amir': 25, 'zilola': 40}));
    final usage = _Usage();
    final cubit = ParentMonitorCubit(family, usage);
    addTearDown(cubit.close);

    await cubit.loadMonitorData();
    await cubit.selectChild(1);
    expect((cubit.state as ParentMonitorLoaded).selectedChild?.id, 'zilola');

    await cubit.loadMonitorData();

    expect((cubit.state as ParentMonitorLoaded).selectedChild?.id, 'zilola');
    expect(usage.requested.last, 'zilola');
  });

  test('it falls back to the first child when that one is gone', () async {
    final family = _Family(_family({'amir': 25, 'zilola': 40}));
    final cubit = ParentMonitorCubit(family, _Usage());
    addTearDown(cubit.close);

    await cubit.loadMonitorData();
    await cubit.selectChild(1);
    family.serve(_family({'amir': 25}));
    await cubit.loadMonitorData();

    expect((cubit.state as ParentMonitorLoaded).selectedChild?.id, 'amir');
  });

  test('every app the child used loads with the day, per child', () async {
    final family = _Family(_family({'amir': 25, 'zilola': 40}));
    final device = _DeviceUsage();
    final cubit = ParentMonitorCubit(family, _Usage(), deviceUsage: device);
    addTearDown(cubit.close);

    await cubit.loadMonitorData();
    expect(
      (cubit.state as ParentMonitorLoaded).deviceUsage?.apps.single.displayName,
      'amir',
    );

    await cubit.selectChild(1);
    expect(device.requested, ['amir', 'zilola']);
    expect(
      (cubit.state as ParentMonitorLoaded).deviceUsage?.apps.single.displayName,
      'zilola',
    );
  });

  test('last week loads after the day, for the day the API is on', () async {
    final family = _Family(_family({'amir': 25}));
    final device = _DeviceUsage(today: '2026-09-26');
    final cubit = ParentMonitorCubit(family, _Usage(), deviceUsage: device);
    addTearDown(cubit.close);

    await cubit.loadMonitorData();

    expect(device.weeks, [('amir', '2026-09-26')]);
    final week = (cubit.state as ParentMonitorLoaded).weekUsage;
    expect(week?.apps.single.displayName, 'amir');
    expect(week?.totalMinutes, 90);
  });
}
