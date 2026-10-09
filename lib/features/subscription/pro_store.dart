import 'dart:async';

import 'package:in_app_purchase_platform_interface/in_app_purchase_platform_interface.dart';
import 'package:in_app_purchase_storekit/in_app_purchase_storekit.dart';
import 'package:in_app_purchase_storekit/store_kit_2_wrappers.dart';

/// The two Safini Pro products in App Store Connect (SAF-212).
class ProProducts {
  static const String monthly = 'pro.monthly';
  static const String yearly = 'pro.yearly';
  static const Set<String> all = {monthly, yearly};

  const ProProducts._();
}

enum ProPeriod { month, year }

enum ProTrialUnit { day, week, month, year }

/// A free trial Apple will give this Apple ID on a plan: one per
/// subscription group, so after any trial or subscription there is none.
class ProTrial {
  const ProTrial(this.count, this.unit);

  final int count;
  final ProTrialUnit unit;
}

/// One product as the App Store prices it for this Apple ID's storefront.
class ProOffer {
  const ProOffer({
    required this.productId,
    required this.price,
    required this.rawPrice,
    required this.currencyCode,
    this.trial,
  });

  final String productId;

  /// Localized by the App Store, currency included: `$66.99`, `39 990,00 ₸`.
  final String price;
  final double rawPrice;
  final String currencyCode;

  /// Null when the plan has no free trial or this Apple ID already used one.
  final ProTrial? trial;

  ProPeriod get period =>
      productId == ProProducts.yearly ? ProPeriod.year : ProPeriod.month;
}

enum StoreUpdateKind { purchased, restored, pending, canceled, failed }

/// A transaction StoreKit reported: a purchase, a restore, a renewal while
/// the app was closed, or one left unfinished last time.
class StoreUpdate {
  const StoreUpdate({
    required this.kind,
    required this.productId,
    this.signedTransaction = '',
    this.handle,
  });

  final StoreUpdateKind kind;
  final String productId;

  /// StoreKit 2 `jwsRepresentation`, what the server verifies.
  final String signedTransaction;

  /// The plugin's own object, needed to finish the transaction.
  final Object? handle;
}

/// What the paywall needs from the App Store. iOS only: the Android parent
/// app sells nothing (Google Play has no Kyrgyz merchants, SAF-216).
abstract class ProStore {
  Stream<List<StoreUpdate>> get updates;

  Future<List<ProOffer>> offers();

  /// Opens Apple's purchase sheet. The result arrives on [updates].
  Future<void> buy(ProOffer offer, {required String accountToken});

  /// Asks StoreKit to resend this Apple ID's current subscriptions.
  Future<void> restore();

  /// Transactions bought but never finished, for example because the server
  /// could not be reached. StoreKit refuses a new purchase of the same product
  /// while one is waiting, so they are delivered before every purchase.
  Future<List<StoreUpdate>> unfinished();

  /// Tells StoreKit the purchase was delivered. Until then it keeps
  /// resending the transaction on every launch.
  Future<void> finish(StoreUpdate update);
}

class AppStoreProStore implements ProStore {
  AppStoreProStore() {
    InAppPurchaseStoreKitPlatform.registerPlatform();
  }

  InAppPurchasePlatform get _store => InAppPurchasePlatform.instance;
  final Map<String, ProductDetails> _products = {};

  @override
  Stream<List<StoreUpdate>> get updates =>
      _store.purchaseStream.map((purchases) => purchases.map(_update).toList());

  StoreUpdate _update(PurchaseDetails purchase) => StoreUpdate(
    kind: switch (purchase.status) {
      PurchaseStatus.purchased => StoreUpdateKind.purchased,
      PurchaseStatus.restored => StoreUpdateKind.restored,
      PurchaseStatus.pending => StoreUpdateKind.pending,
      PurchaseStatus.canceled => StoreUpdateKind.canceled,
      PurchaseStatus.error => StoreUpdateKind.failed,
    },
    productId: purchase.productID,
    signedTransaction: purchase.verificationData.serverVerificationData,
    handle: purchase,
  );

  @override
  Future<List<ProOffer>> offers() async {
    if (!await _store.isAvailable()) return const [];
    final response = await _store.queryProductDetails(ProProducts.all);
    for (final product in response.productDetails) {
      _products[product.id] = product;
    }
    return [
      for (final product in response.productDetails)
        ProOffer(
          productId: product.id,
          price: product.price,
          rawPrice: product.rawPrice,
          currencyCode: product.currencyCode,
          trial: await _trial(product),
        ),
    ];
  }

  /// Monthly has a week free and yearly a month (App Store Connect). The
  /// plugin lists the introductory offer among the promotional ones.
  Future<ProTrial?> _trial(ProductDetails product) async {
    if (product is! AppStoreProduct2Details) return null;
    final offers = product.sk2Product.subscription?.promotionalOffers ?? [];
    final free = offers
        .where(
          (offer) =>
              offer.type == SK2SubscriptionOfferType.introductory &&
              offer.paymentMode == SK2SubscriptionOfferPaymentMode.freeTrial,
        )
        .firstOrNull;
    if (free == null) return null;
    try {
      if (!await SK2Product.isIntroductoryOfferEligible(product.id)) {
        return null;
      }
    } catch (_) {
      // Unknown eligibility: promise nothing rather than a trial Apple
      // then refuses.
      return null;
    }
    return ProTrial(
      free.period.value * free.periodCount,
      switch (free.period.unit) {
        SK2SubscriptionPeriodUnit.day => ProTrialUnit.day,
        SK2SubscriptionPeriodUnit.week => ProTrialUnit.week,
        SK2SubscriptionPeriodUnit.month => ProTrialUnit.month,
        SK2SubscriptionPeriodUnit.year => ProTrialUnit.year,
      },
    );
  }

  @override
  Future<void> buy(ProOffer offer, {required String accountToken}) async {
    final product = _products[offer.productId];
    if (product == null) throw StateError('Unknown product ${offer.productId}');
    await _store.buyNonConsumable(
      purchaseParam: PurchaseParam(
        productDetails: product,
        applicationUserName: accountToken,
      ),
    );
  }

  @override
  Future<void> restore() => _store.restorePurchases();

  @override
  Future<List<StoreUpdate>> unfinished() async {
    final transactions = await SK2Transaction.unfinishedTransactions();
    return [
      for (final transaction in transactions)
        if (ProProducts.all.contains(transaction.productId))
          StoreUpdate(
            kind: StoreUpdateKind.purchased,
            productId: transaction.productId,
            signedTransaction: transaction.receiptData ?? '',
            handle: transaction,
          ),
    ];
  }

  @override
  Future<void> finish(StoreUpdate update) async {
    final handle = update.handle;
    if (handle is SK2Transaction) {
      await SK2Transaction.finish(int.parse(handle.id));
    } else if (handle is PurchaseDetails && handle.purchaseID != null) {
      await _store.completePurchase(handle);
    }
  }
}
