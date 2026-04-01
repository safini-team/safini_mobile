import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:safini/features/parent/domain/controllers/parent_controller.dart';
import 'package:safini/features/parent/presentation/cubit/parent_apps_state.dart';

class ParentAppsCubit extends Cubit<ParentAppsState> {
  final ParentController _controller;

  ParentAppsCubit(this._controller) : super(const ParentAppsInitial());

  Future<void> loadAppLimits() async {
    emit(const ParentAppsLoading());
    
    await Future.delayed(const Duration(milliseconds: 600));
    
    emit(const ParentAppsLoaded(
      appLimits: [
        {"name": "YouTube Kids", "used": 48, "limit": 60, "icon": "assets/icons/youtube_kids.png", "isEnabled": true},
        {"name": "Roblox", "used": 15, "limit": 60, "icon": "assets/icons/roblox.png", "isEnabled": true},
        {"name": "Brawl Stars", "used": 5, "limit": 45, "icon": "assets/icons/brawl_stars.png", "isEnabled": true},
        {"name": "Minecraft", "used": 30, "limit": 90, "icon": "assets/icons/minecraft.png", "isEnabled": true},
      ],
    ));
  }

  void updateLimit(String appName, int newLimit) {
    // Update limit via controller
  }

  void toggleApp(String appName, bool isEnabled) {
    // Toggle app restriction via controller
  }
}
