/// One app installed on a child's device, as enumerated natively on the child
/// device and synced to the backend so the parent can see the child's apps.
///
/// Wire format (snake_case) matches the
/// `PUT/GET /v1/children/{child_id}/installed-apps` endpoints
/// (see `BACKEND_TODO.md` #4).
class InstalledApp {
  final String packageName;
  final String appName;

  const InstalledApp({required this.packageName, required this.appName});

  factory InstalledApp.fromJson(Map<String, dynamic> json) => InstalledApp(
    packageName: (json['package_name'] ?? json['packageName'] ?? '').toString(),
    appName: (json['app_name'] ?? json['appName'] ?? '').toString(),
  );

  Map<String, dynamic> toJson() => {
    'package_name': packageName,
    'app_name': appName,
  };
}

/// The parent-facing snapshot returned by
/// `GET /v1/children/{child_id}/installed-apps`: the app list plus the moment
/// the child device last uploaded it.
///
/// `updatedAt == null` means the child's phone has **never** synced — distinct
/// from "synced, and the list happens to be empty".
class InstalledAppsSnapshot {
  final List<InstalledApp> apps;
  final DateTime? updatedAt;

  const InstalledAppsSnapshot({required this.apps, this.updatedAt});

  /// True when the device has never uploaded a snapshot.
  bool get neverSynced => updatedAt == null;

  factory InstalledAppsSnapshot.fromJson(Map<String, dynamic> json) {
    final rawApps = json['apps'];
    final apps = rawApps is List
        ? rawApps
              .whereType<Map>()
              .map(
                (e) => InstalledApp.fromJson(
                  e.map((k, v) => MapEntry(k.toString(), v)),
                ),
              )
              .toList()
        : <InstalledApp>[];
    final rawUpdatedAt = json['updated_at'] ?? json['updatedAt'];
    return InstalledAppsSnapshot(
      apps: apps,
      updatedAt: rawUpdatedAt is String && rawUpdatedAt.isNotEmpty
          ? DateTime.tryParse(rawUpdatedAt)
          : null,
    );
  }
}
