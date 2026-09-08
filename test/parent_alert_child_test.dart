import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:safini/core/utils/error/failures.dart';
import 'package:safini/features/models/domain/models/family_model.dart';
import 'package:safini/features/parent/domain/models/child_app_usage_model.dart';
import 'package:safini/features/parent/domain/repositories/i_parent_app_usage_repository.dart';
import 'package:safini/features/parent/presentation/cubit/parent_apps_cubit.dart';
import 'package:safini/features/parent/presentation/cubit/parent_family_cubit.dart';
import 'package:safini/features/parent/presentation/cubit/parent_family_state.dart';

FamilyModel family(List<String> children) => FamilyModel.fromJson({
  'id': 'family',
  'children': [
    for (final id in children) {'id': id, 'nickname': id},
  ],
});

class _Family extends Fake implements ParentFamilyCubit {
  @override
  ParentFamilyState state = ParentFamilyState.initial(
    family: family(['first']),
  );
  int refreshes = 0;
  List<String> latest = ['first', 'second'];
  @override
  Future<void> loadCurrentFamily({bool refresh = false}) async {
    refreshes++;
    state = ParentFamilyState.initial(family: family(latest));
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
}

void main() {
  test(
    'an alert for a newly added child refreshes the family and selects that child',
    () async {
      final source = _Family();
      final usage = _Usage();
      final cubit = ParentAppsCubit(source, usage);
      addTearDown(cubit.close);
      await cubit.loadAppLimits();
      await cubit.selectChild('second');
      expect(source.refreshes, 1);
      expect(cubit.childId, 'second');
      expect(usage.requested, ['first', 'second']);
    },
  );

  test(
    'an unknown alert never loads another family child or falls back to the first',
    () async {
      final source = _Family()..latest = ['first'];
      final usage = _Usage();
      final cubit = ParentAppsCubit(source, usage);
      addTearDown(cubit.close);
      await cubit.loadAppLimits(childId: 'not-in-family');
      expect(source.refreshes, 1);
      expect(cubit.childId, isNull);
      expect(usage.requested, isEmpty);
    },
  );
}
