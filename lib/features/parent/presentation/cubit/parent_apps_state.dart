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

  const ParentAppsLoaded({required this.appLimits});
}

class ParentAppsError extends ParentAppsState {
  final String message;
  const ParentAppsError(this.message);
}
