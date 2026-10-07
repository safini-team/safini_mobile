import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:safini/core/di/injection.dart';
import 'package:safini/features/child/data/services/child_app_rules_service.dart';
import 'package:safini/features/common/auth/presentation/cubit/child_claim_cubit.dart';
import 'package:safini/features/common/profile/domain/controllers/profile_controller.dart';
import 'package:safini/features/models/data/services/device_usage_service.dart';
import 'package:safini/features/models/domain/models/device_usage.dart';
import 'package:safini/features/parent/domain/models/child_app_usage_model.dart';

/// The child's own day on the device: where the time went ("My time today")
/// and what the parent allows ("My limits").
class ChildTimeState {
  const ChildTimeState({this.usage, this.limits});

  /// Every app opened today, real minutes. Null until the first load lands.
  final DeviceUsage? usage;

  /// The parent's rules with what is left of each, and the daily budget.
  /// Null until the first load lands.
  final ChildAppUsageSnapshot? limits;
}

/// Both halves are kept on a failed reload so a flaky network does not blank
/// a list the child was just reading.
class ChildTimeCubit extends Cubit<ChildTimeState> {
  ChildTimeCubit(this._service, this._rules, this._profileController)
    : super(const ChildTimeState());

  final DeviceUsageService _service;
  final ChildAppRulesService _rules;
  final ProfileController _profileController;

  Future<void> load() async {
    final childId = await _resolveChildId();
    if (isClosed || childId == null) return;
    final (usage, limits) = await (
      _service.fetch(childId),
      _rules.fetchUsageSnapshot(childId),
    ).wait;
    if (isClosed) return;
    emit(
      ChildTimeState(
        usage: usage.fold((_) => state.usage, (value) => value),
        limits: limits.fold((_) => state.limits, (value) => value),
      ),
    );
  }

  Future<String?> _resolveChildId() async {
    final claimChild = getIt<ChildClaimCubit>().state.child;
    if (claimChild != null) return claimChild.id;

    final profileResult = await _profileController.fetchMe();
    return profileResult.fold((_) => null, (profile) {
      final childId = profile.childId?.trim();
      return childId == null || childId.isEmpty ? null : childId;
    });
  }
}
