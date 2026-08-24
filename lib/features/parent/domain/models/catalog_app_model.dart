/// One app the parent can put limits on, as returned by `GET /v1/apps`.
///
/// The app used to carry its own hard-coded list of four slugs, with a comment
/// admitting there was no catalog endpoint to ask. That list then went stale
/// the moment the catalog grew, and it is why "Add an app" could only answer
/// "Every app is already set up".
class CatalogAppModel {
  const CatalogAppModel({
    required this.appSlug,
    required this.displayName,
    this.iconUrl,
    this.defaultDailyLimitMinutes = 60,
    this.defaultRedeemCoinCost = 100,
    this.defaultRedeemRewardMinutes = 30,
    this.defaultIsLimited = true,
    this.defaultCanRedeem = true,
    this.isDefaultForNewChild = false,
  });

  final String appSlug;
  final String displayName;
  final String? iconUrl;
  final int defaultDailyLimitMinutes;
  final int defaultRedeemCoinCost;
  final int defaultRedeemRewardMinutes;
  final bool defaultIsLimited;
  final bool defaultCanRedeem;
  final bool isDefaultForNewChild;

  factory CatalogAppModel.fromJson(Map<String, dynamic> json) {
    int asInt(dynamic value, int fallback) =>
        value is num ? value.toInt() : fallback;
    return CatalogAppModel(
      appSlug: (json['app_slug'] ?? json['slug'] ?? '').toString(),
      displayName: (json['display_name'] ?? '').toString(),
      iconUrl: json['icon_url'] as String?,
      defaultDailyLimitMinutes: asInt(json['default_daily_limit_minutes'], 60),
      defaultRedeemCoinCost: asInt(json['default_redeem_coin_cost'], 100),
      defaultRedeemRewardMinutes: asInt(
        json['default_redeem_reward_minutes'],
        30,
      ),
      defaultIsLimited: json['default_is_limited'] as bool? ?? true,
      defaultCanRedeem: json['default_can_redeem'] as bool? ?? true,
      isDefaultForNewChild: json['is_default_for_new_child'] as bool? ?? false,
    );
  }
}
