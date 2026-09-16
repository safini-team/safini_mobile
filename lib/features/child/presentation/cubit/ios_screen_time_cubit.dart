import 'package:dio/dio.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:safini/features/child/data/services/screen_time_service.dart';

class IosScreenTimeState {
  final bool busy;
  final Map<String, dynamic> status;
  final List<Map<String, dynamic>> rules;
  final String? error;

  /// The native `FamilyControlsError` code behind [error], so the UI can show
  /// localized copy instead of Apple's English `errorDescription`.
  final String? errorCode;
  final bool syncFailed;
  const IosScreenTimeState({
    this.busy = false,
    this.status = const {},
    this.rules = const [],
    this.error,
    this.errorCode,
    this.syncFailed = false,
  });
  bool get authorized => status['authorization'] == 'approved';
  bool get monitoring => status['monitoring_active'] == true;
  Set<String> get mapped =>
      (status['mapped_slugs'] as List? ?? []).cast<String>().toSet();
  bool get ready =>
      status["policy_loaded"] == true &&
      status["all_mapped"] == true &&
      authorized &&
      (rules.isEmpty || monitoring) &&
      rules.every((r) => mapped.contains(r['app_slug']));
}

/// Only policy and operational state cross this bridge. Reports stay native.
class IosScreenTimeCubit extends Cubit<IosScreenTimeState> {
  final ScreenTimeService native;
  final Dio dio;
  String? _childId;
  int _generation = 0;
  bool _acting = false;
  Future<void>? _refreshing;
  IosScreenTimeCubit(this.native, this.dio) : super(const IosScreenTimeState());

  Future<void> start(String childId) async {
    if (_childId != childId) {
      _generation++;
      _childId = childId;
      _refreshing = null;
      emit(const IosScreenTimeState());
    }
    await refresh();
  }

  void endSession() {
    _generation++;
    _childId = null;
    _refreshing = null;
    emit(const IosScreenTimeState());
    // Signing out must not lift parental restrictions. Revocation is managed
    // by the parent in Apple's Screen Time settings.
  }

  Future<void> refresh() {
    if (_acting || _childId == null || !native.isSupported) {
      return Future.value();
    }
    if (_refreshing != null) return _refreshing!;
    final generation = _generation;
    final future = _sync(generation, _childId!);
    _refreshing = future;
    return future.whenComplete(() {
      if (generation == _generation) _refreshing = null;
    });
  }

  Future<void> _sync(int generation, String childId) async {
    final previous = state;
    emit(
      IosScreenTimeState(
        busy: true,
        status: previous.status,
        rules: previous.rules,
      ),
    );
    Map<String, dynamic> status = previous.status;
    List<Map<String, dynamic>> rules = previous.rules;
    try {
      status = await native.releaseStatus();
      if (status["child_id"] != childId) status = {};
      if (generation != _generation) return;
      final response = await dio.get<Map<String, dynamic>>(
        '/v1/children/$childId/screen-time-policy',
      );
      if (generation != _generation) return;
      final policy = response.data!;
      if (policy['child_id'] != childId) {
        throw StateError('Policy child mismatch');
      }
      rules = (policy['apps'] as List)
          .map((r) => Map<String, dynamic>.from(r as Map))
          .toList();
      status = await native.configurePolicy(policy);
      if (generation != _generation) return;
      // Explicit allowlist: never forward mapped slugs, Apple tokens or report data.
      await dio.put(
        '/v1/children/$childId/screen-time-status',
        data: {
          'platform': 'ios',
          for (final key in [
            'authorization',
            'selected_applications',
            'selected_categories',
            'shield_active',
            'monitoring_active',
          ])
            key: status[key],
        },
      );
      if (generation == _generation) {
        emit(IosScreenTimeState(status: status, rules: rules));
      }
    } catch (e) {
      if (generation == _generation) {
        emit(
          IosScreenTimeState(
            status: status,
            rules: rules,
            syncFailed: true,
            error: e is ScreenTimeException ? e.message : null,
            errorCode: e is ScreenTimeException ? e.code : null,
          ),
        );
      }
    }
  }

  Future<void> authorize() async {
    await _action(() async {
      try {
        await native.requestAuthorization(member: ScreenTimeMember.child);
      } on ScreenTimeException catch (e) {
        // `.child` needs this device's Apple Account to be a child inside the
        // parent's Family Sharing group. Anywhere else Apple rejects it with
        // `invalidAccountType` and never shows a prompt, which dead-ends setup
        // on a phone the family has not enrolled yet (App Review 2026-09-15).
        // Individual authorization prompts for the same Screen Time powers on
        // the device itself, so fall back to it rather than stopping.
        if (e.code != 'invalid_account') rethrow;
        await native.requestAuthorization(member: ScreenTimeMember.individual);
      }
    });
  }

  Future<void> select(String slug) => _action(() async {
    await native.selectRule(slug);
  });
  Future<void> _action(Future<void> Function() action) async {
    if (state.busy) return;
    final generation = _generation;
    emit(
      IosScreenTimeState(busy: true, status: state.status, rules: state.rules),
    );
    try {
      _acting = true;
      await action();
      _acting = false;
      if (generation == _generation) await refresh();
    } catch (e) {
      _acting = false;
      if (generation == _generation) {
        emit(
          IosScreenTimeState(
            status: state.status,
            rules: state.rules,
            error: e is ScreenTimeException ? e.message : null,
            errorCode: e is ScreenTimeException ? e.code : null,
            syncFailed: e is! ScreenTimeException,
          ),
        );
      }
    }
  }

  bool canPurchase(String childId, String slug) =>
      _childId == childId &&
      state.authorized &&
      state.monitoring &&
      state.mapped.contains(slug) &&
      state.status["global_blocked"] != true &&
      state.rules.any((r) => r["app_slug"] == slug && r["is_blocked"] != true);
}
