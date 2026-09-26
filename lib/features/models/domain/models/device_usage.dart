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
    this.usageDate,
  });

  /// The family-local day these minutes are for, `YYYY-MM-DD`.
  final String? usageDate;

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
      usageDate: json['usage_date'] as String?,
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

/// The seven days before today, for "Last 7 days" on the parent's Today.
///
/// A phone paired today already has this: Android kept the week before Safini
/// was installed, and the child's phone sends it once after pairing.
class WeekUsage {
  const WeekUsage({required this.days, required this.apps});

  /// Oldest first, one per day, including days with no use.
  final List<DayUsage> days;

  /// Each app's minutes summed over the week, most used first.
  final List<DeviceUsageApp> apps;

  int get totalMinutes => days.fold(0, (sum, day) => sum + day.minutes);

  /// Over the days that had any use, so a week that started mid-way on a
  /// phone that kept only a few days is not averaged down by empty ones.
  int get averageMinutes {
    final used = days.where((day) => day.minutes > 0).length;
    return used == 0 ? 0 : (totalMinutes / used).round();
  }

  /// [days] must be oldest first and each one's `usageDate` set.
  factory WeekUsage.fromDays(List<DeviceUsage> days) {
    final apps = <String, DeviceUsageApp>{};
    for (final day in days) {
      for (final app in day.apps) {
        final key = app.packageName ?? app.appSlug ?? app.displayName;
        final seen = apps[key];
        apps[key] = DeviceUsageApp(
          packageName: app.packageName,
          appSlug: app.appSlug,
          displayName: seen?.displayName ?? app.displayName,
          iconUrl: seen?.iconUrl ?? app.iconUrl,
          usedMinutes: (seen?.usedMinutes ?? 0) + app.usedMinutes,
        );
      }
    }
    return WeekUsage(
      days: [
        for (final day in days)
          DayUsage(
            date: DateTime.parse(day.usageDate!),
            minutes: day.totalMinutes,
          ),
      ],
      apps: apps.values.toList()
        ..sort((a, b) => b.usedMinutes.compareTo(a.usedMinutes)),
    );
  }
}

class DayUsage {
  const DayUsage({required this.date, required this.minutes});

  final DateTime date;
  final int minutes;
}
