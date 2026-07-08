import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:safini/features/parent/domain/models/child_app_usage_model.dart';
import 'package:safini/features/parent/domain/repositories/i_parent_app_usage_repository.dart';
import 'package:safini/features/parent/presentation/cubit/parent_apps_state.dart';
import 'package:safini/features/parent/presentation/cubit/parent_family_cubit.dart';

class ParentAppsCubit extends Cubit<ParentAppsState> {
  final ParentFamilyCubit _familyCubit;
  final IParentAppUsageRepository _appUsageRepo;

  String? _childId;
  List<ChildAppUsageModel> _appUsage = const [];

  ParentAppsCubit(this._familyCubit, this._appUsageRepo)
    : super(const ParentAppsInitial());

  Future<void> loadAppLimits() async {
    emit(const ParentAppsLoading());

    if (_familyCubit.state.family == null) {
      await _familyCubit.loadCurrentFamily(refresh: true);
    }

    final child = _familyCubit.state.family?.children
        .where((c) => c.id.isNotEmpty)
        .firstOrNull;
    _childId = child?.id;

    if (_childId == null) {
      emit(const ParentAppsLoaded(appLimits: []));
      return;
    }

    final result = await _appUsageRepo.fetchAppUsage(_childId!);
    result.fold(
      // Degrade to an empty list so the screen still renders (tip + add button).
      (_) => emit(const ParentAppsLoaded(appLimits: [])),
      (apps) {
        _appUsage = apps;
        emit(ParentAppsLoaded(appLimits: _appUsage.map(_toLimitMap).toList()));
      },
    );
  }

  /// Creates (upserts) an app rule for the selected child via
  /// PUT /children/{id}/app-rules/{slug}, then refreshes the list.
  /// Returns an error message on failure, or null on success.
  Future<String?> addApp({
    required String slug,
    required String name,
    required int dailyLimitMinutes,
    required int redeemCoinCost,
    required int redeemRewardMinutes,
  }) async {
    if (_childId == null) return 'No child selected.';
    if (slug.isEmpty) return 'Please choose an app.';

    final rule = ChildAppUsageModel(
      appSlug: slug,
      displayName: name.trim(),
      isEnabled: true,
      dailyLimitMinutes: dailyLimitMinutes,
      usedMinutes: 0,
      remainingMinutesToday: 0,
      redeemCoinCost: redeemCoinCost,
      redeemRewardMinutes: redeemRewardMinutes,
    );

    final result = await _appUsageRepo.updateAppRule(_childId!, rule);
    return result.fold(
      (failure) async => failure.message,
      (_) async {
        await loadAppLimits();
        return null;
      },
    );
  }

  /// Slugs already configured for the selected child (to exclude from the
  /// "add app" picker).
  Set<String> get addedSlugs => _appUsage.map((a) => a.appSlug).toSet();

  Map<String, dynamic> _toLimitMap(ChildAppUsageModel app) {
    return {
      'slug': app.appSlug,
      'name': app.displayName,
      'used': app.usedMinutes,
      'limit': app.dailyLimitMinutes,
      'icon': null,
      'isEnabled': app.isEnabled,
    };
  }

  /// Persists a new daily limit via PUT /children/{id}/app-rules/{slug}.
  Future<void> updateLimit(String appSlug, int newLimit) async {
    await _persist(appSlug, (app) => app.copyWith(dailyLimitMinutes: newLimit));
  }

  /// Enables/disables an app's redemption rule and persists it.
  Future<void> toggleApp(String appSlug, bool isEnabled) async {
    await _persist(appSlug, (app) => app.copyWith(isEnabled: isEnabled));
  }

  Future<void> _persist(
    String appSlug,
    ChildAppUsageModel Function(ChildAppUsageModel) update,
  ) async {
    if (_childId == null) return;
    final index = _appUsage.indexWhere((a) => a.appSlug == appSlug);
    if (index == -1) return;

    final previous = _appUsage;
    _appUsage = List.of(_appUsage)..[index] = update(_appUsage[index]);
    emit(ParentAppsLoaded(appLimits: _appUsage.map(_toLimitMap).toList()));

    final result = await _appUsageRepo.updateAppRule(_childId!, _appUsage[index]);
    result.fold(
      (_) {
        // Revert on failure.
        _appUsage = previous;
        emit(ParentAppsLoaded(appLimits: _appUsage.map(_toLimitMap).toList()));
      },
      (_) {},
    );
  }
}
