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

  /// The child's whole-device budget. Null cap means the parent has not set
  /// one and the panel falls back to the sum of the per-app limits, labelled
  /// as the sum it is.
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