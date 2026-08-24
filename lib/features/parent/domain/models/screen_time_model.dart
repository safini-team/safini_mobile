/// The child's whole-device daily budget, returned as `screen_time` by
/// `/app-usage`, `/dashboard`, `/home` and `/today`.
///
/// The parent app has always shown a headline allowance figure, but until the
/// server grew this object the figure was the sum of the per-app limits - a
/// number the child cannot spend, because no app draws from it. This is the
/// real budget, or nulls when the parent has not set one.
class ScreenTimeModel {
  /// Null when there is no global cap, which is the default.
  final int? limitMinutes;

  /// Minutes used today across every controlled app. Always a real number.
  final int usedMinutes;

  /// Null exactly when [limitMinutes] is.
  final int? remainingMinutes;

  const ScreenTimeModel({
    required this.limitMinutes,
    required this.usedMinutes,
    required this.remainingMinutes,
  });

  /// What an older API - or a failed request - amounts to: usage we do not
  /// know, and no cap.
  static const ScreenTimeModel none = ScreenTimeModel(
    limitMinutes: null,
    usedMinutes: 0,
    remainingMinutes: null,
  );

  /// A cap of zero is a cap: the server reads it as "no free time at all", not
  /// as "unlimited". Only null means uncapped. This is the same inversion that
  /// made `daily_limit_minutes = 0` render as "no limit" in F25.
  bool get hasCap => limitMinutes != null;

  factory ScreenTimeModel.fromJson(Map<String, dynamic> json) {
    int? asNullableInt(dynamic v) => v is num ? v.toInt() : null;
    return ScreenTimeModel(
      limitMinutes: asNullableInt(json['global_limit_minutes']),
      usedMinutes: asNullableInt(json['global_used_minutes']) ?? 0,
      remainingMinutes: asNullableInt(json['global_remaining_minutes']),
    );
  }
}
