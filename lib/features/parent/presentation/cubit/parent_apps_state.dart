import 'package:safini/features/parent/domain/models/screen_time_model.dart';

abstract class ParentAppsState {
  const ParentAppsState();
}

class ParentAppsInitial extends ParentAppsState {
  const ParentAppsInitial();
}

class ParentAppsLoading extends ParentAppsState {
  const ParentAppsLoading();
}

class ParentAppsLoaded extends ParentAppsState {
  final List<Map<String, dynamic>> appLimits;

  /// Canonical shared budget. Null cap means off; app limits remain independent.
  final ScreenTimeModel screenTime;

  const ParentAppsLoaded({
    required this.appLimits,
    this.screenTime = ScreenTimeModel.none,
  });
}

class ParentAppsError extends ParentAppsState {
  final String message;
  const ParentAppsError(this.message);
}