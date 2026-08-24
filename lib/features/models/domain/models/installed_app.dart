/// One app installed on a child's device, as enumerated natively on the child
/// device and synced to the backend so the parent can see the child's apps.
///
/// Wire format (snake_case) matches the proposed
/// `PUT/GET /v1/children/{child_id}/installed-apps` endpoints
/// (see `BACKEND_TODO.md`).
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
