import 'package:safini/features/models/domain/models/installed_app.dart';

/// State for the parent's read-only view of the apps installed on a child's
/// device (uploaded by the child device — see `ChildAppRulesService`).
abstract class ParentInstalledAppsState {
  const ParentInstalledAppsState();
}

class ParentInstalledAppsLoading extends ParentInstalledAppsState {
  const ParentInstalledAppsLoading();
}

class ParentInstalledAppsLoaded extends ParentInstalledAppsState {
  final List<InstalledApp> apps;

  const ParentInstalledAppsLoaded(this.apps);

  bool get isEmpty => apps.isEmpty;
}

class ParentInstalledAppsError extends ParentInstalledAppsState {
  final String message;

  const ParentInstalledAppsError(this.message);
}
