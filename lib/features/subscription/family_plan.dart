import 'package:dio/dio.dart';
import 'package:safini/core/utils/constants/api_const.dart';

/// The family's Safini Pro plan as the server sees it (SAF-208). Pro belongs
/// to the family, so both parents read the same plan whoever paid.
class FamilyPlan {
  const FamilyPlan({
    required this.isPro,
    this.status,
    this.source,
    this.productId,
    this.isTrial = false,
    this.expiresAt,
    this.willRenew = false,
    this.manageUrl,
  });

  static const FamilyPlan free = FamilyPlan(isPro: false);

  final bool isPro;

  /// `active`, `in_grace_period`, `in_billing_retry`, `expired`, `revoked`.
  final String? status;

  /// `apple`, `paddle`, `finik` or `manual`.
  final String? source;
  final String? productId;
  final bool isTrial;
  final DateTime? expiresAt;
  final bool willRenew;

  /// Set only for App Store purchases: Apple's own subscriptions page.
  final String? manageUrl;

  /// The card failed and Apple is retrying: Pro is off until it is fixed.
  bool get needsPaymentFix => status == 'in_billing_retry';

  factory FamilyPlan.fromJson(Map<String, dynamic> json) {
    final expires = json['expires_at'];
    return FamilyPlan(
      isPro: json['plan'] == 'pro',
      status: json['status'] as String?,
      source: json['source'] as String?,
      productId: json['product_id'] as String?,
      isTrial: json['is_trial'] == true,
      expiresAt: expires is String ? DateTime.tryParse(expires) : null,
      willRenew: json['will_renew'] == true,
      manageUrl: json['manage_url'] as String?,
    );
  }
}

/// The server's word on whether a purchase happened. The app never decides
/// that a family is Pro on its own.
class PlanApi {
  PlanApi(this._dio);

  final Dio _dio;

  Future<FamilyPlan> current() async {
    final response = await _dio.get(ApiConst.familySubscription);
    return FamilyPlan.fromJson(_map(response.data));
  }

  /// StoreKit buys with this id as `appAccountToken`, which ties the purchase
  /// to the family on the server.
  Future<String> familyId() async {
    final response = await _dio.get(ApiConst.currentFamily);
    return _map(response.data)['id'] as String;
  }

  /// Hands Apple's signed transaction to the server, which checks Apple's
  /// signature and answers with the family's plan.
  Future<FamilyPlan> recordAppleTransaction(String signedTransaction) async {
    final response = await _dio.post(
      ApiConst.appleTransactions,
      data: {'signed_transaction': signedTransaction},
    );
    return FamilyPlan.fromJson(_map(response.data));
  }

  /// Redeems a promo code for the family. The plan comes back with
  /// `source: promo` and `isTrial`, ending at `expiresAt`.
  Future<FamilyPlan> redeemPromo(String code) async {
    final response = await _dio.post(
      ApiConst.promoRedeem,
      data: {'code': code},
    );
    return FamilyPlan.fromJson(_map(response.data));
  }

  static Map<String, dynamic> _map(dynamic raw) =>
      raw is Map ? Map<String, dynamic>.from(raw) : <String, dynamic>{};
}
