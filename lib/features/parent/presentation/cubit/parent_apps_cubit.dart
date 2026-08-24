import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:safini/features/parent/domain/models/child_app_usage_model.dart';
import 'package:safini/features/parent/domain/repositories/i_parent_app_usage_repository.dart';
import 'package:safini/features/parent/presentation/cubit/parent_apps_state.dart';
import 'package:safini/features/parent/presentation/cubit/parent_family_cubit.dart';
import 'package:dartz/dartz.dart';
import 'package:safini/core/utils/error/failures.dart';
import 'package:safini/features/parent/domain/models/catalog_app_model.dart';

class ParentAppsCubit extends Cubit<ParentAppsState> {
  final ParentFamilyCubit _familyCubit;
  final IParentAppUsageRepository _appUsageRepo;

  String? _childId;
  List<ChildAppUsageModel> _appUsage = const [];

  ParentAppsCubit(this._familyCubit, this._appUsageRepo)
    : super(const ParentAppsInitial());

  /// Child the Limits screen is scoped to; the chip strip switches it.
  String? get childId => _childId;

  Future<void> loadAppLimits({String? childId}) async {
    emit(const ParentAppsLoading());

    if (_familyCubit.state.family == null) {
      await _familyCubit.loadCurrentFamily(refresh: true);
    }

    final children =
        _familyCubit.state.family?.children.where((c) => c.id.isNotEmpty) ??
        const [];
    final child = childId != null
        ? children.where((c) => c.id == childId).firstOrNull
        : children.where((c) => c.id == _childId).firstOrNull ??
              children.firstOrNull;
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
  /// The controlled-app catalog from `GET /v1/apps`.
  Future<Either<Failure, List<CatalogAppModel>>> loadCatalog() =>
      _appUsageRepo.fetchCatalog();

  Future<String?> addApp({
    required String slug,
    required String name,
    required int dailyLimitMinutes,
    required int redeemCoinCost,
    required int redeemRewardMinutes,
    bool isLimited = true,
    bool canRedeem = true,
  }) async {
    if (_childId == null) return 'No child selected.';
    if (slug.isEmpty) return 'Please choose an app.';

    final rule = ChildAppUsageModel(
      appSlug: slug,
      displayName: name.trim(),
      isLimited: isLimited,
      canRedeem: canRedeem,
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

  /// Switches which child's limits are shown.
  Future<void> selectChild(String childId) {
    if (childId == _childId) return Future.value();
    _appUsage = const [];
    return loadAppLimits(childId: childId);
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
      'isLimited': app.isLimited,
      'canRedeem': app.canRedeem,
      'cost': app.redeemCoinCost,
      'reward': app.redeemRewardMinutes,
    };
  }

  /// Persists a new daily limit via PUT /children/{id}/app-rules/{slug}.
  Future<void> updateLimit(String appSlug, int newLimit) async {
    await _persist(appSlug, (app) => app.copyWith(dailyLimitMinutes: newLimit));
  }

  /// Persists the whole rule: both flags and the coin price, which the parent
  /// could not reach at all before - the steppers only existed in the add
  /// sheet, and the add sheet was never reachable.
  Future<void> updateRule(
    String appSlug, {
    int? dailyLimitMinutes,
    bool? isLimited,
    bool? canRedeem,
    int? redeemCoinCost,
    int? redeemRewardMinutes,
  }) async {
    await _persist(
      appSlug,
      (app) => app.copyWith(
        dailyLimitMinutes: dailyLimitMinutes,
        isLimited: isLimited,
        canRedeem: canRedeem,
        redeemCoinCost: redeemCoinCost,
        redeemRewardMinutes: redeemRewardMinutes,
      ),
    );
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
