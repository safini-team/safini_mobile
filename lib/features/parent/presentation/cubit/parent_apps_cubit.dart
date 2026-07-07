import 'dart:convert';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:safini/features/parent/domain/controllers/parent_controller.dart';
import 'package:safini/features/parent/presentation/cubit/parent_apps_state.dart';

class ParentAppsCubit extends Cubit<ParentAppsState> {
  static const _prefsKey = 'parent_app_limits';

  final ParentController _controller;
  final SharedPreferences _prefs;

  ParentAppsCubit(this._controller, this._prefs) : super(const ParentAppsInitial());

  Future<void> loadAppLimits() async {
    emit(const ParentAppsLoading());
    final saved = _prefs.getString(_prefsKey);
    if (saved != null) {
      try {
        final decoded = jsonDecode(saved);
        if (decoded is List) {
          final limits = decoded.cast<Map<String, dynamic>>();
          emit(ParentAppsLoaded(appLimits: limits));
          return;
        }
      } catch (_) {}
    }
    emit(const ParentAppsLoaded(appLimits: []));
  }

  void addApp(String appName, int limitMinutes) {
    final current = state;
    if (current is! ParentAppsLoaded) return;
    final updated = [
      ...current.appLimits,
      {
        'name': appName,
        'used': 0,
        'limit': limitMinutes,
        'icon': null,
        'isEnabled': true,
      },
    ];
    emit(ParentAppsLoaded(appLimits: updated));
    _persist(updated);
  }

  void removeApp(String appName) {
    final current = state;
    if (current is! ParentAppsLoaded) return;
    final updated = current.appLimits
        .where((app) => app['name'] != appName)
        .toList();
    emit(ParentAppsLoaded(appLimits: updated));
    _persist(updated);
  }

  void toggleApp(String appName, bool isEnabled) {
    final current = state;
    if (current is! ParentAppsLoaded) return;
    final updated = current.appLimits.map((app) {
      if (app['name'] == appName) return {...app, 'isEnabled': isEnabled};
      return app;
    }).toList();
    emit(ParentAppsLoaded(appLimits: updated));
    _persist(updated);
  }

  void _persist(List<Map<String, dynamic>> limits) {
    _prefs.setString(_prefsKey, jsonEncode(limits));
  }
}
