import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:safini/core/di/injection.dart';
import 'package:safini/features/common/auth/presentation/cubit/child_claim_cubit.dart';
import 'package:safini/features/common/profile/domain/controllers/profile_controller.dart';
import 'package:safini/features/models/data/services/device_usage_service.dart';
import 'package:safini/features/models/domain/models/device_usage.dart';

/// Where the child's own time went today, for the "My time today" section.
///
/// Null until the first load lands, and kept on a failed reload so a flaky
/// network does not blank a list the child was just reading.
class ChildTimeCubit extends Cubit<DeviceUsage?> {
  ChildTimeCubit(this._service, this._profileController) : super(null);

  final DeviceUsageService _service;
  final ProfileController _profileController;

  Future<void> load() async {
    final childId = await _resolveChildId();
    if (isClosed || childId == null) return;
    final result = await _service.fetch(childId);
    if (isClosed) return;
    result.fold((_) {}, emit);
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
