/// Canonical daily budget across Safini-managed apps, returned by the API.
/// A null limit is off; zero is a real cap. Usage availability is independent
/// of configuration and device enforcement status.
class ScreenTimeModel {
  /// Null when there is no global cap, which is the default.
  final int? limitMinutes;
  final DateTime? nextResetAt;
  final String? budgetScope;
  final bool? configurationAvailable;
  final bool? enforcementAvailable;
  final bool usageAvailable;

  /// Minutes used today across managed apps; only display when usageAvailable.
  final int usedMinutes;

  /// Null exactly when [limitMinutes] is.
  final int? remainingMinutes;

  const ScreenTimeModel({
    this.usageAvailable = true,
    this.nextResetAt,
    this.budgetScope,
    this.configurationAvailable,
    this.enforcementAvailable,
    required this.limitMinutes,
    required this.usedMinutes,
    required this.remainingMinutes,
  });

  /// What an older API - or a failed request - amounts to: usage we do not
  /// know, and no cap.
  static const ScreenTimeModel none = ScreenTimeModel(
    usageAvailable: false,
    configurationAvailable: false,
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
      usageAvailable: json["usage_available"] != false,
      nextResetAt: DateTime.tryParse(json['next_reset_at']?.toString() ?? ''),
      budgetScope: json['budget_scope'] as String?,
      configurationAvailable: json['configuration_available'] as bool?,
      enforcementAvailable: json['enforcement_available'] as bool?,
      limitMinutes: asNullableInt(json['global_limit_minutes']),
      usedMinutes: asNullableInt(json['global_used_minutes']) ?? 0,
      remainingMinutes: asNullableInt(json['global_remaining_minutes']),
    );
  }
}
