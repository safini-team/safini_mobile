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

  @override
  Stream<List<StoreUpdate>> get updates => controller.stream;

  @override
  Future<List<ProOffer>> offers() async => const [_monthly, _yearly];

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

DioException _status(int code) => DioException(
  requestOptions: RequestOptions(path: '/v1/billing/apple/transactions'),
  response: Response(
    requestOptions: RequestOptions(path: '/v1/billing/apple/transactions'),
    statusCode: code,
  ),
);

Future<(ProCubit, _FakeApi, _FakeStore)> _started() async {
  final api = _FakeApi();
  final store = _FakeStore();
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
}
