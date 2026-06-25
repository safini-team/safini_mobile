import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:safini/features/parent/domain/controllers/parent_controller.dart';
import 'package:safini/features/parent/presentation/cubit/parent_apps_state.dart';

class ParentAppsCubit extends Cubit<ParentAppsState> {
  final ParentController _controller;

  ParentAppsCubit(this._controller) : super(const ParentAppsInitial());

  Future<void> loadAppLimits() async {
    emit(const ParentAppsLoading());
    emit(const ParentAppsLoaded(appLimits: []));
  }

  void addApp(String appName, int limitMinutes) {
    final current = state;
    if (current is! ParentAppsLoaded) return;
    emit(
      ParentAppsLoaded(
        appLimits: [
          ...current.appLimits,
          {
            'name': appName,
            'used': 0,
            'limit': limitMinutes,
            'icon': null,
            'isEnabled': true,
          },
        ],
      ),
    );
  }

  void updateLimit(String appName, int newLimit) {
    // Update limit via controller
  }

  void toggleApp(String appName, bool isEnabled) {
    final current = state;
    if (current is! ParentAppsLoaded) return;

    final updatedLimits = current.appLimits.map((app) {
      if (app['name'] == appName) {
        return {...app, 'isEnabled': isEnabled};
      }
      return app;
    }).toList();

    emit(ParentAppsLoaded(appLimits: updatedLimits));
  }
}