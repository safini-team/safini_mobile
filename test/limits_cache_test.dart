import 'dart:async';

import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:safini/core/utils/error/failures.dart';
import 'package:safini/features/models/domain/models/family_model.dart';
import 'package:safini/features/parent/domain/models/child_app_usage_model.dart';
import 'package:safini/features/parent/domain/repositories/i_parent_app_usage_repository.dart';
import 'package:safini/features/parent/presentation/cubit/parent_apps_cubit.dart';
import 'package:safini/features/parent/presentation/cubit/parent_apps_state.dart';
import 'package:safini/features/parent/presentation/cubit/parent_family_cubit.dart';
import 'package:safini/features/parent/presentation/cubit/parent_family_state.dart';

/// The Limits screen keeps each child it has shown for a quick switch back.
/// A saved rule has to land in that copy too: the limit sheet opens on the
/// row on screen and saves the whole rule, so a stale row puts an old value
/// back on the server.
class _Family extends Fake implements ParentFamilyCubit {
  final _family = FamilyModel.fromJson({
    'id': 'family',
    'children': [
      for (final id in ['amir', 'zilola'])
        {'id': id, 'nickname': id, 'coins_balance': 10},
    ],
  });

  @override
  ParentFamilyState get state => ParentFamilyState.initial(family: _family);

  @override
  Stream<ParentFamilyState> get stream => const Stream.empty();

  @override
  Future<void> loadCurrentFamily({bool refresh = false}) async {}
}

class _Rules extends Fake implements IParentAppUsageRepository {
  final saved = <String, ChildAppUsageModel>{};
  Completer<Either<Failure, Unit>>? pendingSave;

  @override
  Future<Either<Failure, ChildAppUsageSnapshot>> fetchAppUsage(
    String childId,
  ) async => Right(
    ChildAppUsageSnapshot(
      apps: [
        saved[childId] ??
            ChildAppUsageModel(
              appSlug: childId == 'amir' ? 'youtube' : 'tiktok',
              displayName: childId == 'amir' ? 'YouTube' : 'TikTok',
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
  Future<Either<Failure, Unit>> updateAppRule(
    String childId,
    ChildAppUsageModel rule,
  ) {
    final pending = pendingSave;
    if (pending != null) return pending.future;
    saved[childId] = rule;
    return Future.value(const Right(unit));
  }
}

Map<String, dynamic> _row(ParentAppsCubit cubit) =>
    (cubit.state as ParentAppsLoaded).appLimits.single;

void main() {
  test(
    'a saved rule is still there after a switch to another child and back',
    () async {
      final rules = _Rules();
      final cubit = ParentAppsCubit(_Family(), rules);
      addTearDown(cubit.close);
      await cubit.loadAppLimits(childId: 'amir');

      expect(await cubit.updateRule('youtube', isBlocked: true), isNull);
      await cubit.selectChild('zilola');
      await cubit.selectChild('amir');

      expect(_row(cubit)['slug'], 'youtube');
      expect(_row(cubit)['isBlocked'], isTrue);
      expect(cubit.ruleForSlug('youtube')?.isBlocked, isTrue);
    },
  );

  test(
    'a save that fails after a switch leaves the other child on screen',
    () async {
      final rules = _Rules();
      final cubit = ParentAppsCubit(_Family(), rules);
      addTearDown(cubit.close);
      await cubit.loadAppLimits(childId: 'amir');

      rules.pendingSave = Completer();
      final saving = cubit.updateRule('youtube', dailyLimitMinutes: 45);
      await cubit.selectChild('zilola');
      rules.pendingSave!.complete(const Left(ServerFailure('down')));
      await saving;

      expect(_row(cubit)['slug'], 'tiktok');
      expect(cubit.ruleForSlug('youtube'), isNull);

      rules.pendingSave = null;
      await cubit.selectChild('amir');
      expect(_row(cubit)['limit'], 30);
    },
  );
}
