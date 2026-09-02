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

  /// When the child device last uploaded its list. `null` → never synced.
  final DateTime? updatedAt;

  /// The `GET` came back 404 (endpoint not deployed, or no such child) rather
  /// than an empty-but-valid snapshot. Same empty UI, but the dev hint differs.
  final bool endpointMissing;

  const ParentInstalledAppsLoaded(
    this.apps, {
    this.updatedAt,
    this.endpointMissing = false,
  });

  bool get isEmpty => apps.isEmpty;

  /// The child's phone has never uploaded a snapshot.
  bool get neverSynced => updatedAt == null;
}

class ParentInstalledAppsError extends ParentInstalledAppsState {
  final String message;

  const ParentInstalledAppsError(this.message);
}
