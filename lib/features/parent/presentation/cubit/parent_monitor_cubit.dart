import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:safini/features/parent/domain/controllers/parent_controller.dart';
import 'package:safini/features/parent/presentation/cubit/parent_family_cubit.dart';
import 'package:safini/features/parent/presentation/cubit/parent_monitor_state.dart';

class ParentMonitorCubit extends Cubit<ParentMonitorState> {
  final ParentController _controller;
  final ParentFamilyCubit _familyCubit;

  ParentMonitorCubit(this._controller, this._familyCubit)
      : super(const ParentMonitorInitial());

  Future<void> loadMonitorData() async {
    emit(const ParentMonitorLoading());

    if (_familyCubit.state.family == null) {
      await _familyCubit.loadCurrentFamily(refresh: true);
    }

    final child = _familyCubit.state.family?.children
        .where((c) => c.id.isNotEmpty)
        .firstOrNull;

    emit(
      ParentMonitorLoaded(
        childName: child?.nickname ?? 'Child',
        level: child?.level ?? 0,
        timeCoins: child?.coinsBalance ?? 0,
        stepsToday: 4230,
        stepsChange: '+12% vs yesterday',
        lessonsToday: '1/8',
        lessonsChange: '+1 today',
        weeklyUsage: [0.4, 0.5, 0.3, 0.7, 1.0, 0.8, 0.6],
        appLimits: [
          {
            "name": "YouTube Kids",
            "used": 48,
            "limit": 60,
            "icon": "assets/icons/youtube_kids.png",
            "isEnabled": true,
          },
          {
            "name": "Roblox",
            "used": 15,
            "limit": 60,
            "icon": "assets/icons/roblox.png",
            "isEnabled": true,
          },
        ],
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
