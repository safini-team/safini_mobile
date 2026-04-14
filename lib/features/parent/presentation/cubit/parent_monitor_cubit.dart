import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:safini/features/parent/domain/controllers/parent_controller.dart';
import 'package:safini/features/parent/presentation/cubit/parent_monitor_state.dart';

class ParentMonitorCubit extends Cubit<ParentMonitorState> {
  ParentMonitorCubit(ParentController controller)
      : super(const ParentMonitorInitial());

  Future<void> loadMonitorData() async {
    emit(const ParentMonitorLoading());

    // Simulate API call via controller
    await Future.delayed(const Duration(seconds: 1));

    // Placeholder data based on UI reference
    emit(
      ParentMonitorLoaded(
        childName: 'Alex',
        level: 5,
        timeCoins: 150,
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
          },
          {
            "name": "Roblox",
            "used": 15,
            "limit": 60,
            "icon": "assets/icons/roblox.png",
          },
        ],
      ),
    );
  }
}
