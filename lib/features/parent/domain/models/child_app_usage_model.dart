import 'package:safini/features/parent/domain/models/screen_time_model.dart';

/// One `GET /v1/children/{child_id}/app-usage` response: the per-app rows and
/// the whole-device budget they sit under. They arrive together because the
/// remaining minutes on a row are already capped by the global budget - reading
/// one without the other gives a number the child cannot actually spend.
class ChildAppUsageSnapshot {
  final List<ChildAppUsageModel> apps;
  final ScreenTimeModel screenTime;

  const ChildAppUsageSnapshot({required this.apps, required this.screenTime});

  static const ChildAppUsageSnapshot empty = ChildAppUsageSnapshot(
    apps: [],
    screenTime: ScreenTimeModel.none,
  );

  /// The old headline figure: the per-app limits added up. Still shown when no
  /// global cap is set, labelled as the sum it is.
  int get combinedLimitMinutes => apps.fold(
    0,
    (sum, app) => sum + (app.isLimited ? app.dailyLimitMinutes : 0),
  );
}

/// One app's usage + redemption rule for a child, as returned by
/// `GET /v1/children/{child_id}/app-usage`.
class ChildAppUsageModel {
  final String appSlug;
  final String displayName;

  /// Does `dailyLimitMinutes` apply at all. False means the app is never
  /// capped, which is what a parent means by "no limit".
  final bool isLimited;

  /// May the child spend coins on extra minutes for this app.
  final bool canRedeem;

  final int dailyLimitMinutes;
  final int usedMinutes;

  /// Null when the app is uncapped and no global cap is set, so there is no
  /// finite number to show.
  final int? remainingMinutesToday;
  final int redeemCoinCost;
  final int redeemRewardMinutes;

  const ChildAppUsageModel({
    required this.appSlug,
    required this.displayName,
    required this.isLimited,
    required this.canRedeem,
    required this.dailyLimitMinutes,
    required this.usedMinutes,
    required this.remainingMinutesToday,
    required this.redeemCoinCost,
    required this.redeemRewardMinutes,
  });

  factory ChildAppUsageModel.fromJson(Map<String, dynamic> json) {
    int asInt(dynamic v) => v is num ? v.toInt() : 0;
    int? asNullableInt(dynamic v) => v is num ? v.toInt() : null;
    return ChildAppUsageModel(
      appSlug: (json['app_slug'] ?? '').toString(),
      displayName: (json['display_name'] ?? '').toString(),
      // `is_limited` is the newer field; fall back to the deprecated
      // `is_enabled` alias so a build talking to an older API still reads.
      isLimited: json['is_limited'] as bool? ?? true,
      canRedeem: (json['can_redeem'] ?? json['is_enabled']) == true,
      dailyLimitMinutes: asInt(json['daily_limit_minutes']),
      usedMinutes: asInt(json['used_minutes']),
      remainingMinutesToday: asNullableInt(json['remaining_minutes_today']),
      redeemCoinCost: asInt(json['redeem_coin_cost']),
      redeemRewardMinutes: asInt(json['redeem_reward_minutes']),
    );
  }

  /// Body for `PUT /v1/children/{child_id}/app-rules/{app_slug}`.
  /// The endpoint requires the whole rule, so we always send all of it.
  Map<String, dynamic> toRuleJson() {
    return {
      // `is_enabled` used to carry both meanings at once. The server split it
      // into these two and keeps the old key as an alias for one release.
      'is_limited': isLimited,
      'can_redeem': canRedeem,
      'daily_limit_minutes': dailyLimitMinutes,
      'redeem_coin_cost': redeemCoinCost,
      'redeem_reward_minutes': redeemRewardMinutes,
    };
  }

  ChildAppUsageModel copyWith({
    bool? isLimited,
    bool? canRedeem,
    int? dailyLimitMinutes,
    int? redeemCoinCost,
    int? redeemRewardMinutes,
  }) {
    return ChildAppUsageModel(
      appSlug: appSlug,
      displayName: displayName,
      isLimited: isLimited ?? this.isLimited,
      canRedeem: canRedeem ?? this.canRedeem,
      dailyLimitMinutes: dailyLimitMinutes ?? this.dailyLimitMinutes,
      usedMinutes: usedMinutes,
      remainingMinutesToday: remainingMinutesToday,
      redeemCoinCost: redeemCoinCost ?? this.redeemCoinCost,
      redeemRewardMinutes: redeemRewardMinutes ?? this.redeemRewardMinutes,
    );
  }
}
