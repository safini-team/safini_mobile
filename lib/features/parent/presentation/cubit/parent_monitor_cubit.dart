import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:safini/features/models/domain/models/family_model.dart';
import 'package:safini/features/parent/domain/models/child_app_usage_model.dart';
import 'package:safini/features/parent/domain/repositories/i_parent_app_usage_repository.dart';
import 'package:safini/features/parent/presentation/cubit/parent_family_cubit.dart';
import 'package:safini/features/parent/presentation/cubit/parent_monitor_state.dart';

class ParentMonitorCubit extends Cubit<ParentMonitorState> {
  final ParentFamilyCubit _familyCubit;
  final IParentAppUsageRepository _appUsageRepo;
  StreamSubscription? _familySub;

  List<ChildSummaryModel> _children = const [];
  int _selectedIndex = 0;
  List<ChildAppUsageModel> _appUsage = const [];

  ParentMonitorCubit(this._familyCubit, this._appUsageRepo)
    : super(const ParentMonitorInitial()) {
    _familySub = _familyCubit.stream.listen((familyState) {
      if (familyState.family == null) return;
      _children = _childrenFromFamily(familyState.family);
      if (_children.isEmpty) {
        emit(const ParentMonitorNoChild());
        return;
      }
      if (state is ParentMonitorLoaded) {
        if (_selectedIndex >= _children.length) _selectedIndex = 0;
        emit(
          (state as ParentMonitorLoaded).copyWith(
            children: _children,
            selectedIndex: _selectedIndex,
          ),
        );
      }
    });
  }

  @override
  Future<void> close() {
    _familySub?.cancel();
    return super.close();
  }

  List<ChildSummaryModel> _childrenFromFamily(FamilyModel? family) {
    if (family == null) return const [];
    return family.children.where((c) => c.id.isNotEmpty).toList();
  }

  Future<void> loadMonitorData() async {
    emit(const ParentMonitorLoading());

    if (_familyCubit.state.family == null) {
      await _familyCubit.loadCurrentFamily(refresh: true);
    }

    _children = _childrenFromFamily(_familyCubit.state.family);
    _selectedIndex = 0;

    if (_children.isEmpty) {
      emit(const ParentMonitorNoChild());
      return;
    }

    _appUsage = const [];
    final result = await _appUsageRepo.fetchAppUsage(_children.first.id);
    result.fold((_) => _appUsage = const [], (apps) => _appUsage = apps);
    final faceEmoji = await _appUsageRepo.fetchChildFaceEmoji(
      _children.first.id,
    );

    emit(
      ParentMonitorLoaded(
        children: _children,
        selectedIndex: _selectedIndex,
        faceEmoji: faceEmoji,
        // TODO(backend): no GET endpoint for steps yet (only POST /steps).
        stepsToday: 0,
        stepsChange: '',
        // TODO(backend): no "lessons" concept exposed by the API yet.
        lessonsToday: '0/0',
        lessonsChange: '',
        // TODO(backend): app-usage only returns today; no weekly aggregation.
        weeklyUsage: const [0, 0, 0, 0, 0, 0, 0],
        appLimits: _appUsage.map(_toLimitMap).toList(),
      ),
    );
  }

  /// Called when the parent swipes the progress card to another child.
  Future<void> selectChild(int index) async {
    final current = state;
    if (current is! ParentMonitorLoaded) return;
    if (index < 0 || index >= _children.length || index == _selectedIndex) {
      return;
    }

    _selectedIndex = index;
    _appUsage = const [];
    // Update the selection immediately; clear limits/face while the child loads.
    emit(
      current.copyWith(
        selectedIndex: index,
        appLimits: const [],
        clearFaceEmoji: true,
      ),
    );

    final result = await _appUsageRepo.fetchAppUsage(_children[index].id);
    result.fold((_) => _appUsage = const [], (apps) => _appUsage = apps);
    final faceEmoji = await _appUsageRepo.fetchChildFaceEmoji(
      _children[index].id,
    );

    if (state is ParentMonitorLoaded && _selectedIndex == index) {
      emit(
        (state as ParentMonitorLoaded).copyWith(
          appLimits: _appUsage.map(_toLimitMap).toList(),
          faceEmoji: faceEmoji,
        ),
      );
    }
  }

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

  /// Toggles whether the daily limit applies for the selected child and
  /// persists it via PUT /children/{id}/app-rules/{slug}. Optimistic with
  /// revert on failure.
  Future<void> toggleAppLimit(String appSlug, bool isLimited) async {
    final current = state;
    if (current is! ParentMonitorLoaded) return;
    final child = current.selectedChild;
    if (child == null) return;

    final index = _appUsage.indexWhere((a) => a.appSlug == appSlug);
    if (index == -1) return;

    final previous = _appUsage;
    _appUsage = List.of(_appUsage)
      ..[index] = _appUsage[index].copyWith(isLimited: isLimited);
    emit(current.copyWith(appLimits: _appUsage.map(_toLimitMap).toList()));

    final result = await _appUsageRepo.updateAppRule(child.id, _appUsage[index]);

    result.fold(
      (_) {
        // Revert on failure.
        _appUsage = previous;
        if (state is ParentMonitorLoaded) {
          emit(
            (state as ParentMonitorLoaded).copyWith(
              appLimits: _appUsage.map(_toLimitMap).toList(),
            ),
          );
        }
      },
      (_) {},
    );
  }
}
