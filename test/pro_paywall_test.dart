import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:safini/core/theme/app_theme.dart';
import 'package:safini/core/translation/generated/l10n.dart';
import 'package:safini/features/subscription/family_plan.dart';
import 'package:safini/features/subscription/paywall_screen.dart';
import 'package:safini/features/subscription/pro_cubit.dart';
import 'package:safini/features/subscription/pro_store.dart';

const _familyId = '5e1b8c1a-2c49-4bb3-9f62-6c3b2f1c0d11';

const _monthly = ProOffer(
  productId: ProProducts.monthly,
  price: r'$6.99',
  rawPrice: 6.99,
  currencyCode: 'USD',
);
const _yearly = ProOffer(
  productId: ProProducts.yearly,
  price: r'$66.99',
  rawPrice: 66.99,
  currencyCode: 'USD',
);

const _pro = FamilyPlan(
  isPro: true,
  status: 'active',
  source: 'apple',
  productId: ProProducts.yearly,
  willRenew: true,
);

class _FakeApi extends PlanApi {
  _FakeApi() : super(Dio());

  FamilyPlan plan = FamilyPlan.free;
  final posted = <String>[];

  /// Thrown by the next post instead of answering.
  Object? failWith;

  @override
  Future<FamilyPlan> current() async => plan;

  @override
  Future<String> familyId() async => _familyId;

  final promos = <String>[];

  /// Thrown by the next redeem instead of answering.
  Object? promoFails;

  @override
  Future<FamilyPlan> redeemPromo(String code) async {
    promos.add(code);
    final error = promoFails;
    if (error != null) throw error;
    return plan = const FamilyPlan(
      isPro: true,
      status: 'active',
      source: 'promo',
      productId: 'pro.promo',
      isTrial: true,
    );
  }

  @override
  Future<FamilyPlan> recordAppleTransaction(String signedTransaction) async {
    posted.add(signedTransaction);
    final error = failWith;
    if (error != null) throw error;
    return plan = _pro;
  }
}

class _FakeStore implements ProStore {
  final controller = StreamController<List<StoreUpdate>>.broadcast();
  final finished = <String>[];
  final bought = <(String, String)>[];
  List<StoreUpdate> leftovers = [];
  List<StoreUpdate> entitlements = [];
  List<ProOffer> catalog = const [_monthly, _yearly];

  @override
  Stream<List<StoreUpdate>> get updates => controller.stream;

  @override
  Future<List<ProOffer>> offers() async => catalog;

  @override
  Future<void> buy(ProOffer offer, {required String accountToken}) async {
    bought.add((offer.productId, accountToken));
    controller.add([_update(offer.productId, 'jws-${offer.productId}')]);
  }

  @override
  Future<void> restore() async => controller.add(entitlements);

  @override
  Future<List<StoreUpdate>> unfinished() async {
    final left = leftovers;
    leftovers = [];
    return left;
  }

  @override
  Future<void> finish(StoreUpdate update) async =>
      finished.add(update.signedTransaction);
}

StoreUpdate _update(
  String productId,
  String jws, {
  StoreUpdateKind kind = StoreUpdateKind.purchased,
}) => StoreUpdate(kind: kind, productId: productId, signedTransaction: jws);

DioException _status(int code, {String? detail}) => DioException(
  requestOptions: RequestOptions(path: '/v1/billing/apple/transactions'),
  response: Response(
    requestOptions: RequestOptions(path: '/v1/billing/apple/transactions'),
    statusCode: code,
    data: detail == null ? null : {'detail': detail},
  ),
);

Future<(ProCubit, _FakeApi, _FakeStore)> _started({
  List<ProOffer>? catalog,
}) async {
  final api = _FakeApi();
  final store = _FakeStore();
  if (catalog != null) store.catalog = catalog;
  final cubit = ProCubit(api: api, store: store);
  await cubit.start();
  await cubit.loadOffers();
  return (cubit, api, store);
}

Future<void> _settle() => Future<void>.delayed(Duration.zero);

Widget _host(Widget child) => MaterialApp(
  theme: AppTheme.light,
  locale: const Locale('en'),
  localizationsDelegates: const [
    S.delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
  ],
  supportedLocales: S.delegate.supportedLocales,
  home: child,
);

void main() {
  group('the family plan', () {
    test('reads the server payload', () {
      final plan = FamilyPlan.fromJson({
        'plan': 'pro',
        'status': 'active',
        'source': 'apple',
        'product_id': 'pro.yearly',
        'is_trial': true,
        'expires_at': '2027-10-08T12:00:00Z',
        'will_renew': true,
        'manage_url': 'https://apps.apple.com/account/subscriptions',
      });

      expect(plan.isPro, isTrue);
      expect(plan.isTrial, isTrue);
      expect(plan.expiresAt, DateTime.utc(2027, 10, 8, 12));
      expect(plan.manageUrl, 'https://apps.apple.com/account/subscriptions');
    });

    test('a failed card is not Pro but says how to fix it', () {
      final plan = FamilyPlan.fromJson({
        'plan': 'free',
        'status': 'in_billing_retry',
      });

      expect(plan.isPro, isFalse);
      expect(plan.needsPaymentFix, isTrue);
    });

    test(r'the year at $66.99 saves 20% against $6.99 a month', () async {
      final (cubit, _, _) = await _started();

      expect(cubit.state.yearlySavingPercent, 20);
    });
  });

  group('buying Pro', () {
    test(
      'buys for the family, has the server verify it, then finishes',
      () async {
        final (cubit, api, store) = await _started();

        await cubit.buy(ProPeriod.year);
        await _settle();

        expect(store.bought, [(ProProducts.yearly, _familyId)]);
        expect(api.posted, ['jws-pro.yearly']);
        expect(store.finished, ['jws-pro.yearly']);
        expect(cubit.state.isPro, isTrue);
        expect(cubit.state.busy, isFalse);
        expect(cubit.state.notice, ProNotice.welcome);
      },
    );

    test('keeps the transaction when the server cannot be reached', () async {
      final (cubit, api, store) = await _started();
      api.failWith = _status(503);

      await cubit.buy(ProPeriod.month);
      await _settle();

      // Unfinished, StoreKit hands it back next launch.
      expect(api.posted, ['jws-pro.monthly']);
      expect(store.finished, isEmpty);
      expect(cubit.state.isPro, isFalse);
      expect(cubit.state.notice, ProNotice.failed);
    });

    test('finishes a purchase that belongs to another family', () async {
      final (cubit, api, store) = await _started();
      api.failWith = _status(409);

      await cubit.buy(ProPeriod.year);
      await _settle();

      expect(store.finished, ['jws-pro.yearly']);
      expect(cubit.state.notice, ProNotice.otherFamily);
    });

    test('delivers leftovers before the next purchase', () async {
      final (cubit, api, store) = await _started();
      store.leftovers = [_update(ProProducts.monthly, 'jws-left-over')];

      await cubit.buy(ProPeriod.year);
      await _settle();

      expect(api.posted.first, 'jws-left-over');
      expect(store.finished, contains('jws-left-over'));
    });

    test('a renewal while the app is open updates the plan quietly', () async {
      final (cubit, _, store) = await _started();

      store.controller.add([_update(ProProducts.yearly, 'jws-renewal')]);
      await _settle();

      expect(cubit.state.isPro, isTrue);
      expect(cubit.state.notice, ProNotice.none);
    });
  });

  group('restoring', () {
    test('sends what the Apple ID owns to the server', () async {
      final (cubit, api, store) = await _started();
      store.entitlements = [
        _update(
          ProProducts.yearly,
          'jws-restored',
          kind: StoreUpdateKind.restored,
        ),
      ];

      await cubit.restore();
      await _settle();

      expect(api.posted, ['jws-restored']);
      expect(cubit.state.isPro, isTrue);
      expect(cubit.state.notice, ProNotice.restored);
    });

    test('says so when there is nothing to restore', () async {
      final (cubit, api, _) = await _started();

      await cubit.restore();
      await _settle();

      expect(api.posted, isEmpty);
      expect(cubit.state.notice, ProNotice.nothingToRestore);
      expect(cubit.state.busy, isFalse);
    });
  });

  group('the paywall', () {
    testWidgets('shows everything App Review asks for', (tester) async {
      // A tall phone, so the whole list is built at once.
      tester.view.physicalSize = const Size(1170, 3600);
      tester.view.devicePixelRatio = 3;
      addTearDown(tester.view.reset);
      final (cubit, _, _) = await _started();

      await tester.pumpWidget(_host(PaywallScreen(cubit: cubit)));
      await tester.pumpAndSettle();

      expect(find.text(r'$66.99 per year'), findsOneWidget);
      expect(find.text(r'$6.99 per month'), findsOneWidget);
      expect(find.text('Save 20%'), findsOneWidget);
      expect(find.text('Subscribe'), findsOneWidget);
      expect(find.textContaining('renews automatically'), findsOneWidget);
      expect(find.text('Restore purchases'), findsOneWidget);
      expect(find.text('Terms of Use'), findsOneWidget);
      expect(find.text('Privacy Policy'), findsOneWidget);
    });

    testWidgets('offers the free trial while the Apple ID can have it', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(1170, 3600);
      tester.view.devicePixelRatio = 3;
      addTearDown(tester.view.reset);
      final (cubit, _, _) = await _started(
        catalog: const [
          ProOffer(
            productId: ProProducts.monthly,
            price: r'$6.99',
            rawPrice: 6.99,
            currencyCode: 'USD',
            trial: ProTrial(1, ProTrialUnit.week),
          ),
          ProOffer(
            productId: ProProducts.yearly,
            price: r'$66.99',
            rawPrice: 66.99,
            currencyCode: 'USD',
            trial: ProTrial(1, ProTrialUnit.month),
          ),
        ],
      );

      await tester.pumpWidget(_host(PaywallScreen(cubit: cubit)));
      await tester.pumpAndSettle();

      expect(find.text(r'1 month free, then $66.99 per year'), findsOneWidget);
      expect(find.text(r'1 week free, then $6.99 per month'), findsOneWidget);
      expect(find.text('Start free trial'), findsOneWidget);
      expect(find.text('Subscribe'), findsNothing);
      expect(find.textContaining('Nothing is charged during'), findsOneWidget);
    });

    testWidgets('a family on its trial sees when it ends', (tester) async {
      final (cubit, api, _) = await _started();
      api.plan = FamilyPlan(
        isPro: true,
        status: 'active',
        source: 'apple',
        productId: ProProducts.yearly,
        isTrial: true,
        willRenew: true,
        expiresAt: DateTime.utc(2026, 11, 9, 12),
      );
      await cubit.refresh();

      await tester.pumpWidget(_host(PaywallScreen(cubit: cubit)));
      await tester.pumpAndSettle();

      expect(find.text('Free trial until Nov 9, 2026'), findsOneWidget);
    });

    testWidgets('a Pro family sees its plan and Manage subscription', (
      tester,
    ) async {
      final (cubit, api, _) = await _started();
      api.plan = _pro;
      await cubit.refresh();

      await tester.pumpWidget(_host(PaywallScreen(cubit: cubit)));
      await tester.pumpAndSettle();

      expect(find.text('Your family has Safini Pro'), findsOneWidget);
      expect(find.text('Manage subscription'), findsOneWidget);
      expect(find.text('Subscribe'), findsNothing);
    });
  });

  group('promo codes', () {
    test('a code makes the family Pro', () async {
      final (cubit, api, _) = await _started();

      final error = await cubit.redeemPromo('  friends30 ');

      expect(error, isNull);
      expect(api.promos, ['friends30']);
      expect(cubit.state.isPro, isTrue);
      expect(cubit.state.notice, ProNotice.promoApplied);
      expect(cubit.state.busy, isFalse);
    });

    test('says why a code did not work', () async {
      final (cubit, api, _) = await _started();
      final cases = {
        _status(404): PromoError.invalid,
        _status(409, detail: 'This promo code has been used up.'):
            PromoError.usedUp,
        _status(409, detail: 'Your family already used this promo code.'):
            PromoError.alreadyUsed,
        _status(409, detail: 'Your family already has Safini Pro.'):
            PromoError.alreadyPro,
        _status(429): PromoError.tooMany,
        _status(503): PromoError.failed,
      };
      for (final MapEntry(key: failure, value: expected) in cases.entries) {
        api.promoFails = failure;
        expect(await cubit.redeemPromo('NOPE'), expected);
        expect(cubit.state.busy, isFalse);
      }
      expect(await cubit.redeemPromo('   '), PromoError.invalid);
      expect(cubit.state.isPro, isFalse);
    });

    testWidgets('Android has no plans to buy but takes a code', (tester) async {
      tester.view.physicalSize = const Size(1170, 4800);
      tester.view.devicePixelRatio = 3;
      addTearDown(tester.view.reset);
      final api = _FakeApi();
      final cubit = ProCubit(api: api);
      await cubit.start();

      await tester.pumpWidget(_host(PaywallScreen(cubit: cubit)));
      await tester.pumpAndSettle();

      expect(find.text('Subscribe'), findsNothing);
      expect(find.text('Restore purchases'), findsNothing);
      expect(find.textContaining('coming soon'), findsOneWidget);
      await tester.enterText(find.byType(TextField), 'friends30');
      await tester.tap(find.text('Apply'));
      await tester.pumpAndSettle();

      expect(api.promos, ['friends30']);
      expect(find.text('Your family has Safini Pro'), findsOneWidget);
      // Let the success snack bar run out.
      await tester.pump(const Duration(seconds: 5));
    });

    testWidgets('a bad code says so under the box', (tester) async {
      tester.view.physicalSize = const Size(1170, 4800);
      tester.view.devicePixelRatio = 3;
      addTearDown(tester.view.reset);
      final (cubit, api, _) = await _started();
      api.promoFails = _status(404);

      await tester.pumpWidget(_host(PaywallScreen(cubit: cubit)));
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextField), 'nope');
      await tester.tap(find.text('Apply'));
      await tester.pumpAndSettle();

      expect(find.text("This promo code isn't valid."), findsOneWidget);
      expect(cubit.state.isPro, isFalse);
    });
  });
}
