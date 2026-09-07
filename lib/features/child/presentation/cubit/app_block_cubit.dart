import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:safini/core/config/supabase_config.dart';
import 'package:safini/features/child/data/services/app_block_service.dart';
import 'package:safini/features/child/data/services/child_app_rules_service.dart';
import 'package:safini/features/child/presentation/cubit/app_block_state.dart';
import 'package:safini/features/common/profile/domain/controllers/profile_controller.dart';

class ChildAppBlockCubit extends Cubit<AppBlockState> {
  final AppBlockService _blockService;
  final ChildAppRulesService _rulesService;
  final ProfileController _profileController;
  bool _busy = false;
  bool _uploaded = false;
  ChildAppBlockCubit(
    this._blockService,
    this._rulesService,
    this._profileController,
  ) : super(const AppBlockState.initial());
  Future<void> start() => refreshPermissions();
  Future<void> onResumed() => refreshPermissions();
  Future<void> requestUsageAccess() => _blockService.requestUsageAccess();
  Future<void> requestOverlayPermission() =>
      _blockService.requestOverlayPermission();
  Future<void> requestBatterySettings() =>
      _blockService.requestBatterySettings();
  Future<void> syncNow() => _blockService.syncNow();

  Future<void> refreshPermissions() async {
    if (_busy || isClosed) return;
    if (!_blockService.isSupported) {
      emit(state.copyWith(status: AppBlockStatus.unsupported));
      return;
    }
    _busy = true;
    emit(state.copyWith(isChecking: true));
    try {
      final usage = await _blockService.hasUsageAccess();
      final overlay = await _blockService.hasOverlayPermission();
      if (isClosed) return;
      emit(
        state.copyWith(hasUsageAccess: usage, hasOverlayPermission: overlay),
      );
      if (!usage || !overlay) {
        emit(
          state.copyWith(
            status: AppBlockStatus.needsPermissions,
            isChecking: false,
          ),
        );
        return;
      }
      final profile = await _profileController.fetchMe();
      final id = profile.fold(
        (f) => throw StateError(f.message),
        (p) => p.childId,
      );
      if (id == null || id.isEmpty) throw StateError('Child account required.');
      if (!await _blockService.isConfigured(id)) {
        final pairing = await _rulesService.pairDevice(id);
        await _blockService.configure({
          'baseUrl': SupabaseConfig.apiBaseUrl,
          'childId': id,
          'token': pairing['device_token'],
          'expiresAt': pairing['expires_at'],
        });
      }
      await _blockService.startService();
      if (!isClosed) {
        emit(state.copyWith(status: AppBlockStatus.active, isChecking: false));
      }
      if (!_uploaded) {
        final apps = await _blockService.installedApps();
        final result = await _rulesService.reportInstalledApps(id, apps);
        _uploaded = result.isRight();
      }
    } catch (e) {
      // A network failure retains the native service's cached budgets.
      final cached = await _blockService.hasSnapshot();
      if (cached) {
        // Start the cached native policy even when the profile API is offline.
        // A sync error does not stop the foreground service.
        try {
          await _blockService.startService();
        } catch (_) {}
      }
      final running = cached && await _blockService.isRunning();
      if (!isClosed) {
        emit(
          state.copyWith(
            status: running ? AppBlockStatus.active : AppBlockStatus.error,
            isChecking: false,
            errorMessage: e.toString(),
          ),
        );
      }
    } finally {
      _busy = false;
    }
  }
}
