import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:safini/core/di/injection.dart';
import 'package:safini/features/child/data/services/child_app_rules_service.dart';
import 'package:safini/features/common/auth/presentation/cubit/child_claim_cubit.dart';
import 'package:safini/features/common/profile/domain/controllers/profile_controller.dart';
import 'package:safini/features/models/data/services/device_usage_service.dart';
import 'package:safini/features/models/domain/models/device_usage.dart';
import 'package:safini/features/parent/domain/models/child_app_usage_model.dart';
import 'package:safini/features/fini/kid/kid_fini.dart';

/// The child's own day on the device: where the time went ("My time today")
/// and what the parent allows ("My limits").
class ChildTimeState {
  const ChildTimeState({
    this.usage,
    this.limits,
    this.fini = const KidFini(),
    this.asking = false,
  });

  /// Every app opened today, real minutes. Null until the first load lands.
  final DeviceUsage? usage;

  /// The parent's rules with what is left of each, and the daily budget.
  /// Null until the first load lands.
  final ChildAppUsageSnapshot? limits;

  /// Fini's budgets and today's ask for more time (SAF-275).
  final KidFini fini;
  final bool asking;

  ChildTimeState copyWith({KidFini? fini, bool? asking}) => ChildTimeState(
    usage: usage,
    limits: limits,
    fini: fini ?? this.fini,
    asking: asking ?? this.asking,
  );
}

/// Both halves are kept on a failed reload so a flaky network does not blank
/// a list the child was just reading.
class ChildTimeCubit extends Cubit<ChildTimeState> {
  ChildTimeCubit(
    this._service,
    this._rules,
    this._profileController, {
    KidFiniService? fini,
    Future<String?> Function()? childId,
  }) : _fini = fini,
       _childIdOverride = childId,
       super(const ChildTimeState());

  /// Tests name the child directly instead of the signed-in claim.
  final Future<String?> Function()? _childIdOverride;

  final DeviceUsageService _service;
  final ChildAppRulesService _rules;
  final ProfileController _profileController;
  final KidFiniService? _fini;
  String? _childId;

  Future<void> load() async {
    final childId = await _resolveChildId();
    if (isClosed || childId == null) return;
    _childId = childId;
    final (usage, limits, fini) = await (
      _service.fetch(childId),
      _rules.fetchUsageSnapshot(childId),
      _loadFini(childId),
    ).wait;
    if (isClosed) return;
    emit(
      ChildTimeState(
        usage: usage.fold((_) => state.usage, (value) => value),
        limits: limits.fold((_) => state.limits, (value) => value),
        fini: fini,
      ),
    );
  }

  /// A failed read keeps what the child was looking at.
  Future<KidFini> _loadFini(String childId) async {
    final fini = _fini;
    if (fini == null) return state.fini;
    try {
      return await fini.load(childId);
    } catch (_) {
      return state.fini;
    }
  }

  /// "Ask a parent for 15 min". Returns an error to show, or null. The
  /// button is off from the tap on: the server allows one ask a day.
  Future<String?> askForTime(String goalId) async {
    final fini = _fini;
    final childId = _childId;
    if (fini == null || childId == null || state.asking) return '';
    emit(state.copyWith(asking: true));
    try {
      final ask = await fini.ask(childId, goalId);
      if (isClosed) return null;
      emit(state.copyWith(fini: state.fini.asked(ask), asking: false));
      return null;
    } catch (_) {
      if (isClosed) return null;
      // Already asked today on another device, or offline: read what is true.
      final fresh = await _loadFini(childId);
      if (isClosed) return null;
      emit(state.copyWith(fini: fresh, asking: false));
      return fresh.canAsk ? '' : null;
    }
  }

  Future<String?> _resolveChildId() async {
    final override = _childIdOverride;
    if (override != null) return override();
    final claimChild = getIt<ChildClaimCubit>().state.child;
    if (claimChild != null) return claimChild.id;

    final profileResult = await _profileController.fetchMe();
    return profileResult.fold((_) => null, (profile) {
      final childId = profile.childId?.trim();
      return childId == null || childId.isEmpty ? null : childId;
    });
  }
}
