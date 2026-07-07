import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:safini/features/parent/domain/controllers/parent_controller.dart';
import 'package:safini/features/parent/domain/models/parent_monitor_model.dart';
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
            current.monitorModel.copyWith(
              childName: child.nickname.isNotEmpty ? child.nickname : 'Child',
              level: child.level,
              timeCoins: child.coinsBalance,
            ),
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
        ParentMonitorModel(
          childName: child.nickname.isNotEmpty ? child.nickname : 'Child',
          level: child.level,
          timeCoins: child.coinsBalance,
          stepsToday: 0,
          stepsChange: '',
          lessonsToday: '—',
          lessonsChange: '',
          weeklyUsage: const [0, 0, 0, 0, 0, 0, 0],
          appLimits: const [],
        ),
      ),
    );
  }

  void toggleAppLimit(String appName, bool isEnabled) {
    final current = state;
    if (current is! ParentMonitorLoaded) return;

    final updatedLimits = current.monitorModel.appLimits.map((app) {
      if (app['name'] == appName) {
        return {...app, 'isEnabled': isEnabled};
      }
      return app;
    }).toList();

    emit(
      ParentMonitorLoaded(
        current.monitorModel.copyWith(appLimits: updatedLimits),
      ),
    );
  }
}
