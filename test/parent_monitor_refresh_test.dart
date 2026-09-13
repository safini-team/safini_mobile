import 'dart:async';

import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:safini/core/utils/error/failures.dart';
import 'package:safini/features/models/domain/models/family_model.dart';
import 'package:safini/features/parent/domain/models/child_app_usage_model.dart';
import 'package:safini/features/parent/domain/repositories/i_parent_app_usage_repository.dart';
import 'package:safini/features/parent/presentation/cubit/parent_family_cubit.dart';
import 'package:safini/features/parent/presentation/cubit/parent_family_state.dart';
import 'package:safini/features/parent/presentation/cubit/parent_monitor_cubit.dart';
import 'package:safini/features/parent/presentation/cubit/parent_monitor_state.dart';

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

void main() {
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
}
