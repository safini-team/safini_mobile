/// Where a child's time went on one day: every app they opened, whether or not
/// a parent has a rule on it, most used first.
///
/// Wire format matches `GET /v1/children/{child_id}/device-usage`. Unlike
/// `app-usage`, minutes here are what the child really spent, so a limited app
/// can read past its limit.
class DeviceUsage {
  const DeviceUsage({
    required this.usageAvailable,
    required this.totalMinutes,
    required this.apps,
  });

  /// False for an iPhone, whose usage stays on the device.
  final bool usageAvailable;
  final int totalMinutes;
  final List<DeviceUsageApp> apps;

  static const empty = DeviceUsage(
    usageAvailable: true,
    totalMinutes: 0,
    apps: [],
  );

  factory DeviceUsage.fromJson(Map<String, dynamic> json) {
    final apps = json['apps'];
    return DeviceUsage(
      usageAvailable: json['usage_available'] as bool? ?? true,
      totalMinutes: (json['total_minutes'] as num?)?.toInt() ?? 0,
      apps: apps is List
          ? apps
                .whereType<Map>()
                .map(
                  (e) => DeviceUsageApp.fromJson(
                    e.map((k, v) => MapEntry(k.toString(), v)),
                  ),
                )
                .toList()
          : const [],
    );
  }
}

class DeviceUsageApp {
  const DeviceUsageApp({
    required this.displayName,
    required this.usedMinutes,
    this.packageName,
    this.appSlug,
    this.iconUrl,
    this.hasRule = false,
    this.isBlocked = false,
    this.isLimited = false,
    this.dailyLimitMinutes,
  });

  final String? packageName;
  final String? appSlug;
  final String displayName;

  /// A path on the API, or null until the child's phone uploads the icon.
  final String? iconUrl;
  final int usedMinutes;
  final bool hasRule;
  final bool isBlocked;
  final bool isLimited;
  final int? dailyLimitMinutes;

  /// Past a real limit. A limit of zero is "no free time", so any use is over.
  bool get isOver =>
      hasRule &&
      isLimited &&
      !isBlocked &&
      dailyLimitMinutes != null &&
      usedMinutes > dailyLimitMinutes!;

  factory DeviceUsageApp.fromJson(Map<String, dynamic> json) {
    final package = json['package_name'] as String?;
    final name = (json['display_name'] as String?)?.trim();
    return DeviceUsageApp(
      packageName: package,
      appSlug: json['app_slug'] as String?,
      displayName: name == null || name.isEmpty ? (package ?? '') : name,
      iconUrl: json['icon_url'] as String?,
      usedMinutes: (json['used_minutes'] as num?)?.toInt() ?? 0,
      hasRule: json['has_rule'] as bool? ?? false,
      isBlocked: json['is_blocked'] as bool? ?? false,
      isLimited: json['is_limited'] as bool? ?? false,
      dailyLimitMinutes: (json['daily_limit_minutes'] as num?)?.toInt(),
    );
  }
}
