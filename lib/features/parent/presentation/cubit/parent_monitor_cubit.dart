import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:safini/features/parent/domain/controllers/parent_controller.dart';
import 'package:safini/features/parent/presentation/cubit/parent_family_cubit.dart';
import 'package:safini/features/parent/presentation/cubit/parent_monitor_state.dart';

class ParentMonitorCubit extends Cubit<ParentMonitorState> {
  final ParentController _controller;
  final ParentFamilyCubit _familyCubit;
  StreamSubscription? _familySub;

  ParentMonitorCubit(this._controller, this._familyCubit)
      : super(const ParentMonitorInitial()) {
    _familySub = _familyCubit.stream.listen((familyState) {
      if (familyState.family == null) return;
      final child = familyState.family!.children
          .where((c) => c.id.isNotEmpty)
          .firstOrNull;
      if (child == null) {
        emit(const ParentMonitorNoChild());
        return;
      }
      if (state is ParentMonitorLoaded) {
        final current = state as ParentMonitorLoaded;
        emit(
          ParentMonitorLoaded(
            childName: child.nickname.isNotEmpty ? child.nickname : 'Child',
            level: child.level,
            timeCoins: child.coinsBalance,
            stepsToday: current.stepsToday,
            stepsChange: current.stepsChange,
            lessonsToday: current.lessonsToday,
            lessonsChange: current.lessonsChange,
            weeklyUsage: current.weeklyUsage,
            appLimits: current.appLimits,
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

  Future<void> loadMonitorData() async {
    emit(const ParentMonitorLoading());

    if (_familyCubit.state.family == null) {
      await _familyCubit.loadCurrentFamily(refresh: true);
    }

    final child = _familyCubit.state.family?.children
        .where((c) => c.id.isNotEmpty)
        .firstOrNull;

    if (child == null) {
      emit(const ParentMonitorNoChild());
      return;
    }

    emit(
      ParentMonitorLoaded(
        childName: child.nickname.isNotEmpty ? child.nickname : 'Child',
        level: child.level,
        timeCoins: child.coinsBalance,
        stepsToday: 0,
        stepsChange: '',
        lessonsToday: '—',
        lessonsChange: '',
        weeklyUsage: [0, 0, 0, 0, 0, 0, 0],
        appLimits: [],
      ),
    );
  }

  void toggleAppLimit(String appName, bool isEnabled) {
    final current = state;
    if (current is! ParentMonitorLoaded) return;

    final updatedLimits = current.appLimits.map((app) {
      if (app['name'] == appName) {
        return {...app, 'isEnabled': isEnabled};
      }
      return app;
    }).toList();

    emit(
      ParentMonitorLoaded(
        childName: current.childName,
        level: current.level,
        timeCoins: current.timeCoins,
        stepsToday: current.stepsToday,
        stepsChange: current.stepsChange,
        lessonsToday: current.lessonsToday,
        lessonsChange: current.lessonsChange,
        weeklyUsage: current.weeklyUsage,
        appLimits: updatedLimits,
      ),
    );
  }
}
