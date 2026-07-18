/// One app's usage + redemption rule for a child, as returned by
/// `GET /v1/children/{child_id}/app-usage`.
class ChildAppUsageModel {
  final String appSlug;
  final String displayName;
  final bool isEnabled;
  final int dailyLimitMinutes;
  final int usedMinutes;
  final int remainingMinutesToday;
  final int redeemCoinCost;
  final int redeemRewardMinutes;

  const ChildAppUsageModel({
    required this.appSlug,
    required this.displayName,
    required this.isEnabled,
    required this.dailyLimitMinutes,
    required this.usedMinutes,
    required this.remainingMinutesToday,
    required this.redeemCoinCost,
    required this.redeemRewardMinutes,
  });

  factory ChildAppUsageModel.fromJson(Map<String, dynamic> json) {
    int asInt(dynamic v) => v is num ? v.toInt() : 0;
    return ChildAppUsageModel(
      appSlug: (json['app_slug'] ?? '').toString(),
      displayName: (json['display_name'] ?? '').toString(),
      isEnabled: json['is_enabled'] == true,
      dailyLimitMinutes: asInt(json['daily_limit_minutes']),
      usedMinutes: asInt(json['used_minutes']),
      remainingMinutesToday: asInt(json['remaining_minutes_today']),
      redeemCoinCost: asInt(json['redeem_coin_cost']),
      redeemRewardMinutes: asInt(json['redeem_reward_minutes']),
    );
  }

  /// Body for `PUT /v1/children/{child_id}/app-rules/{app_slug}`.
  /// The endpoint requires all four fields, so we send the full rule.
  Map<String, dynamic> toRuleJson() {
    return {
      'is_enabled': isEnabled,
      'daily_limit_minutes': dailyLimitMinutes,
      'redeem_coin_cost': redeemCoinCost,
      'redeem_reward_minutes': redeemRewardMinutes,
    };
  }

  ChildAppUsageModel copyWith({bool? isEnabled, int? dailyLimitMinutes}) {
    return ChildAppUsageModel(
      appSlug: appSlug,
      displayName: displayName,
      isEnabled: isEnabled ?? this.isEnabled,
      dailyLimitMinutes: dailyLimitMinutes ?? this.dailyLimitMinutes,
      usedMinutes: usedMinutes,
      remainingMinutesToday: remainingMinutesToday,
      redeemCoinCost: redeemCoinCost,
      redeemRewardMinutes: redeemRewardMinutes,
    );
  }
}
