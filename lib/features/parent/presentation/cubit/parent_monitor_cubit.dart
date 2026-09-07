import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:safini/features/models/domain/models/family_model.dart';
import 'package:safini/features/parent/domain/models/child_app_usage_model.dart';
import 'package:safini/features/parent/domain/models/screen_time_model.dart';
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
  ScreenTimeModel _screenTime = ScreenTimeModel.none;

  ParentMonitorCubit(this._familyCubit, this._appUsageRepo)
    : super(const ParentMonitorInitial()) {
    _familySub = _familyCubit.stream.listen((familyState) {
      if (familyState.family == null) return;
      _children = _childrenFromFamily(familyState.family);
      if (_children.isEmpty) {
        emit(const ParentMonitorNoChild());
        return;
      }
      final selectedId = familyState.selectedChildId;
      final targetIndex = selectedId != null
          ? _children.indexWhere((c) => c.id == selectedId)
          : -1;
      final newIndex = targetIndex != -1 ? targetIndex : 0;

      if (state is ParentMonitorLoaded) {
        if (newIndex != _selectedIndex) {
          selectChild(newIndex, syncFamily: false);
        } else {
          emit(
            (state as ParentMonitorLoaded).copyWith(
              children: _children,
              selectedIndex: _selectedIndex,
            ),
          );
        }
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

    if (_children.isEmpty) {
      emit(const ParentMonitorNoChild());
      return;
    }

    final selectedId = _familyCubit.state.selectedChildId;
    final targetIndex = selectedId != null
        ? _children.indexWhere((c) => c.id == selectedId)
        : -1;
    _selectedIndex = targetIndex != -1 ? targetIndex : 0;

    _appUsage = const [];
    _screenTime = ScreenTimeModel.none;
    final activeChildId = _children[_selectedIndex].id;
    final result = await _appUsageRepo.fetchAppUsage(activeChildId);
    result.fold(_clearUsage, _takeUsage);
    final faceEmoji = await _appUsageRepo.fetchChildFaceEmoji(activeChildId);

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
        screenTime: _screenTime,
      ),
    );
  }

  /// Called when the parent swipes the progress card to another child.
  Future<void> selectChild(int index, {bool syncFamily = true}) async {
    final current = state;
    if (current is! ParentMonitorLoaded) return;
    if (index < 0 || index >= _children.length) return;

    if (syncFamily) {
      _familyCubit.selectChildIndex(index);
    }

    if (index == _selectedIndex && current.children.isNotEmpty && current.faceEmoji != null) {
      return;
    }

    _selectedIndex = index;
    _appUsage = const [];
    _screenTime = ScreenTimeModel.none;
    // Update the selection immediately; clear limits/face while the child loads.
    emit(
      current.copyWith(
        children: _children,
        selectedIndex: index,
        appLimits: const [],
        screenTime: ScreenTimeModel.none,
        clearFaceEmoji: true,
      ),
    );

    final activeChildId = _children[index].id;
    final result = await _appUsageRepo.fetchAppUsage(activeChildId);
    result.fold(_clearUsage, _takeUsage);
    final faceEmoji = await _appUsageRepo.fetchChildFaceEmoji(activeChildId);

    if (state is ParentMonitorLoaded && _selectedIndex == index) {
      emit(
        (state as ParentMonitorLoaded).copyWith(
          children: _children,
          appLimits: _appUsage.map(_toLimitMap).toList(),
          screenTime: _screenTime,
          faceEmoji: faceEmoji,
        ),
      );
    }
  }

  void _clearUsage(Object _) {
    _appUsage = const [];
    _screenTime = ScreenTimeModel.none;
  }

  void _takeUsage(ChildAppUsageSnapshot snapshot) {
    _appUsage = snapshot.apps;
    _screenTime = snapshot.screenTime;
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
