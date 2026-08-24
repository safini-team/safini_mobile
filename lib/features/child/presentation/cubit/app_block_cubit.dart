import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:safini/features/child/data/services/app_block_service.dart';
import 'package:safini/features/child/data/services/child_app_rules_service.dart';
import 'package:safini/features/child/presentation/cubit/app_block_state.dart';
import 'package:safini/features/common/profile/domain/controllers/profile_controller.dart';

/// Orchestrates on-device app blocking for the **child**:
///  1. checks the two special permissions (Usage Access + overlay),
///  2. resolves the signed-in child's id,
///  3. pulls the rules from the backend and programs the native engine,
///  4. keeps the native engine in sync on a timer and on app resume.
///
/// Enforcement itself lives natively (see `AppBlockForegroundService`); this
/// cubit only drives it. On unsupported platforms every step is a safe no-op.
class ChildAppBlockCubit extends Cubit<AppBlockState> {
  final AppBlockService _blockService;
  final ChildAppRulesService _rulesService;
  final ProfileController _profileController;

  /// How often to re-pull rules from the backend while the app is foregrounded.
  static const Duration _syncInterval = Duration(minutes: 5);

  String? _childId;
  Timer? _syncTimer;
  bool _installedAppsUploaded = false;

  /// Controlled-app slugs from the last successful fetch; the set of apps whose
  /// measured usage we report back to the backend.
  List<String> _knownSlugs = const [];

  ChildAppBlockCubit(
    this._blockService,
    this._rulesService,
    this._profileController,
  ) : super(const AppBlockState.initial());

  /// Entry point — call once when the child shell mounts.
  Future<void> start() async {
    if (!_blockService.isSupported) {
      emit(state.copyWith(status: AppBlockStatus.unsupported));
      return;
    }
    // Upload the installed-app list so the parent can see it. This is
    // independent of the blocking permissions, so it runs regardless.
    await _uploadInstalledApps();
    await refreshPermissions();
  }

  /// Enumerates the device's installed apps and uploads them once per session.
  Future<void> _uploadInstalledApps() async {
    if (_installedAppsUploaded) return;
    final childId = await _resolveChildId();
    if (childId == null || isClosed) return;

    final apps = await _blockService.installedApps();
    if (apps.isEmpty || isClosed) return;

    final result = await _rulesService.reportInstalledApps(childId, apps);
    result.fold(
      (failure) => debugPrint(
        '[ChildAppBlockCubit] reportInstalledApps failed: ${failure.message}',
      ),
      (_) => _installedAppsUploaded = true,
    );
  }

  /// Re-reads permission state (e.g. after returning from system Settings) and
  /// activates enforcement once both permissions are granted.
  Future<void> refreshPermissions() async {
    if (!_blockService.isSupported) return;
    emit(state.copyWith(isChecking: true, errorMessage: null));

    final usage = await _blockService.hasUsageAccess();
    final overlay = await _blockService.hasOverlayPermission();
    if (isClosed) return;

    if (usage && overlay) {
      emit(state.copyWith(hasUsageAccess: usage, hasOverlayPermission: overlay));
      await _activate();
    } else {
      emit(
        state.copyWith(
          hasUsageAccess: usage,
          hasOverlayPermission: overlay,
          status: AppBlockStatus.needsPermissions,
          isChecking: false,
        ),
      );
    }
  }

  /// Opens the system Usage Access settings screen.
  Future<void> requestUsageAccess() => _blockService.requestUsageAccess();

  /// Opens the system "Display over other apps" settings screen.
  Future<void> requestOverlayPermission() =>
      _blockService.requestOverlayPermission();

  /// Called when the app returns to the foreground: re-check permissions and,
  /// when already active, refresh the rule set immediately.
  Future<void> onResumed() async {
    if (!_blockService.isSupported) return;
    if (state.status == AppBlockStatus.active) {
      await syncNow();
    } else {
      await refreshPermissions();
    }
  }

  /// One full cycle: report measured usage → fetch fresh rules → program the
  /// native engine. Reporting first lets the backend recompute
  /// `remaining_minutes_today` before we read it back.
  Future<void> syncNow() async {
    final childId = await _resolveChildId();
    if (childId == null || isClosed) return;

    await _reportUsage(childId);
    if (isClosed) return;

    final result = await _rulesService.fetchAppRules(childId);
    if (isClosed) return;
    await result.fold(
      (failure) async =>
          debugPrint('[ChildAppBlockCubit] fetchAppRules failed: '
              '${failure.message}'),
      (apps) async {
        _knownSlugs = apps.map((a) => a.appSlug).toList(growable: false);
        await _blockService.syncFromUsage(apps);
      },
    );
  }

  /// Reports today's measured usage (minutes since midnight) for the controlled
  /// apps we know about. No-op on the first cycle (no known slugs yet).
  Future<void> _reportUsage(String childId) async {
    if (_knownSlugs.isEmpty) return;
    final minutesBySlug = await _blockService.usageMinutesBySlug(_knownSlugs);
    final nonZero = <String, int>{
      for (final entry in minutesBySlug.entries)
        if (entry.value > 0) entry.key: entry.value,
    };
    if (nonZero.isEmpty || isClosed) return;

    final result = await _rulesService.reportUsageBatch(childId, nonZero);
    result.fold(
      (failure) => debugPrint(
        '[ChildAppBlockCubit] reportUsage failed: ${failure.message}',
      ),
      (_) {},
    );
  }

  Future<void> _activate() async {
    try {
      await syncNow();
      await _blockService.startService();
      _startSyncTimer();
      if (!isClosed) {
        emit(state.copyWith(status: AppBlockStatus.active, isChecking: false));
      }
    } catch (e) {
      debugPrint('[ChildAppBlockCubit] activation failed: $e');
      if (!isClosed) {
        emit(
          state.copyWith(
            status: AppBlockStatus.error,
            errorMessage: e.toString(),
            isChecking: false,
          ),
        );
      }
    }
  }

  void _startSyncTimer() {
    _syncTimer?.cancel();
    _syncTimer = Timer.periodic(_syncInterval, (_) => syncNow());
  }

  Future<String?> _resolveChildId() async {
    final cached = _childId;
    if (cached != null && cached.isNotEmpty) return cached;

    final result = await _profileController.fetchMe();
    _childId = result.fold((_) => null, (profile) {
      final id = profile.childId?.trim();
      return (id == null || id.isEmpty) ? null : id;
    });
    return _childId;
  }

  @override
  Future<void> close() {
    _syncTimer?.cancel();
    return super.close();
  }
}
