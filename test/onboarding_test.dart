import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:safini/core/translation/generated/l10n.dart';
import 'package:safini/features/child/presentation/cubit/app_block_state.dart';
import 'package:safini/features/onboarding/getting_started_card.dart';
import 'package:safini/features/onboarding/getting_started_cubit.dart';
import 'package:safini/features/onboarding/kid_hello.dart';
import 'package:safini/features/onboarding/kid_setup.dart';
import 'package:safini/features/onboarding/onboarding_store.dart';
import 'package:safini/features/prizes/prize.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Getting started on the parent's Today, and Fini on the kid's phone.
class _Prizes extends Fake implements PrizeApi {
  _Prizes({Set<String> withPrize = const {}}) : withPrize = {...withPrize};

  final Set<String> withPrize;
  final calls = <String>[];

  @override
  Future<PrizeList> list(String childId) async {
    calls.add(childId);
    return PrizeList(
      balance: 0,
      prizes: [
        if (withPrize.contains(childId))
          Prize(id: 'p', childId: childId, title: 'Bike', coinCost: 50),
      ],
      requests: const [],
    );
  }
}

Future<OnboardingStore> _store([Map<String, Object> values = const {}]) async {
  SharedPreferences.setMockInitialValues(values);
  return OnboardingStore(await SharedPreferences.getInstance());
}

Future<void> _observe(
  GettingStartedCubit cubit, {
  List<String> kids = const ['aziz'],
  bool phone = false,
  bool task = false,
  bool limit = false,
}) => cubit.observe(
  familyId: 'fam',
  childIds: kids,
  phoneConnected: phone,
  hasTask: task,
  hasLimit: limit,
);

Widget _app(Widget child) => MaterialApp(
  localizationsDelegates: const [S.delegate],
  supportedLocales: S.delegate.supportedLocales,
  locale: const Locale('en'),
  // Fini's float repeats forever, which pumpAndSettle would wait out. Set on
  // the app so sheets, which are their own routes, get it too.
  builder: (context, page) => MediaQuery(
    data: MediaQuery.of(context).copyWith(disableAnimations: true),
    child: page!,
  ),
  home: Scaffold(body: SingleChildScrollView(child: child)),
);

void main() {
  group('GettingStartedCubit', () {
    test(
      'a new family starts with the child ticked and sees the card',
      () async {
        final cubit = GettingStartedCubit(await _store(), _Prizes());
        await _observe(cubit);

        expect(cubit.state.hidden, isFalse);
        expect(cubit.state.done, {SetupStep.child});
        expect(cubit.state.next, SetupStep.phone);
      },
    );

    test('steps tick from data and stay ticked when the data goes', () async {
      final store = await _store();
      final cubit = GettingStartedCubit(store, _Prizes());
      await _observe(cubit, phone: true, task: true);
      expect(cubit.state.doneCount, 3);

      // The parent deleted the only task; the step does not un-tick.
      await _observe(cubit, phone: true);
      expect(cubit.state.done, contains(SetupStep.task));

      // Nor on the next app start.
      final again = GettingStartedCubit(store, _Prizes());
      await _observe(again);
      expect(again.state.done, {
        SetupStep.child,
        SetupStep.phone,
        SetupStep.task,
      });
    });

    test('a prize on any child ticks the prize step', () async {
      final prizes = _Prizes(withPrize: {'layla'});
      final cubit = GettingStartedCubit(await _store(), prizes);
      await _observe(cubit, kids: ['aziz', 'layla']);

      expect(cubit.state.done, contains(SetupStep.prize));
      expect(prizes.calls, ['aziz', 'layla']);
    });

    test('prizes are not re-fetched on every rebuild', () async {
      final prizes = _Prizes();
      var now = DateTime(2026, 9, 26, 12);
      final cubit = GettingStartedCubit(await _store(), prizes, now: () => now);
      await _observe(cubit);
      await _observe(cubit, task: true);
      expect(prizes.calls, hasLength(1));

      now = now.add(const Duration(seconds: 16));
      await _observe(cubit, task: true);
      expect(prizes.calls, hasLength(2));
    });

    test('a family that already did everything never sees the card', () async {
      final store = await _store();
      final cubit = GettingStartedCubit(store, _Prizes(withPrize: {'aziz'}));
      await _observe(cubit, phone: true, task: true, limit: true);

      expect(cubit.state.hidden, isTrue);
      expect(store.isHidden('fam'), isTrue);
    });

    test('finishing the last step shows the cheer, Done hides it', () async {
      final store = await _store();
      final prizes = _Prizes();
      final cubit = GettingStartedCubit(store, prizes);
      await _observe(cubit, phone: true, task: true);
      expect(cubit.state.hidden, isFalse);

      prizes.withPrize.add('aziz');
      final done = GettingStartedCubit(store, prizes);
      await _observe(done, phone: true, task: true, limit: true);
      expect(done.state.complete, isTrue);
      expect(done.state.hidden, isFalse);

      await done.hide();
      expect(done.state.hidden, isTrue);
      expect(store.isHidden('fam'), isTrue);
    });
  });

  group('GettingStartedCard', () {
    testWidgets('shows the count, Fini on the next step, and opens it', (
      tester,
    ) async {
      final opened = <SetupStep>[];
      await tester.pumpWidget(
        _app(
          GettingStartedCard(
            state: const GettingStarted(
              familyId: 'fam',
              done: {SetupStep.child, SetupStep.task},
              hidden: false,
            ),
            kidName: 'Aziz',
            onOpen: opened.add,
            onHide: () {},
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Getting started'), findsOneWidget);
      expect(find.text('2 of 5'), findsOneWidget);
      expect(find.text("Now let's connect Aziz's phone."), findsOneWidget);

      await tester.tap(find.text('Add a gift'));
      expect(opened, [SetupStep.prize]);
      // A ticked row goes nowhere.
      await tester.tap(find.text('Create a task'));
      expect(opened, [SetupStep.prize]);
    });

    testWidgets('five of five swaps the list for Done', (tester) async {
      var hidden = false;
      await tester.pumpWidget(
        _app(
          GettingStartedCard(
            state: GettingStarted(
              familyId: 'fam',
              done: SetupStep.values.toSet(),
              hidden: false,
            ),
            kidName: 'Aziz',
            onOpen: (_) {},
            onHide: () => hidden = true,
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('All set! Great start.'), findsOneWidget);
      expect(find.text('Add a gift'), findsNothing);
      await tester.tap(find.text('Done'));
      expect(hidden, isTrue);
    });
  });

  group('KidSetup', () {
    Future<List<KidPermission>> pump(
      WidgetTester tester,
      AppBlockState state,
    ) async {
      final asked = <KidPermission>[];
      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: const [S.delegate],
          supportedLocales: S.delegate.supportedLocales,
          locale: const Locale('en'),
          home: MediaQuery(
            data: const MediaQueryData(disableAnimations: true),
            child: KidSetup(
              state: state,
              onRequest: asked.add,
              onCheck: () {},
              onBattery: () {},
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      return asked;
    }

    testWidgets('one permission at a time, in order', (tester) async {
      var asked = await pump(
        tester,
        const AppBlockState(status: AppBlockStatus.needsPermissions),
      );
      expect(find.text('1 of 3'), findsOneWidget);
      expect(find.text('Usage Access'), findsOneWidget);
      expect(find.text('Display over other apps'), findsNothing);
      await tester.tap(find.text('Take me there'));
      expect(asked, [KidPermission.usage]);

      asked = await pump(
        tester,
        const AppBlockState(
          status: AppBlockStatus.needsPermissions,
          hasUsageAccess: true,
          hasOverlayPermission: true,
        ),
      );
      expect(find.text('3 of 3'), findsOneWidget);
      expect(find.text('Prevent uninstall'), findsOneWidget);
      await tester.tap(find.text('Take me there'));
      expect(asked, [KidPermission.admin]);
    });

    testWidgets('all granted but not connected offers a retry only', (
      tester,
    ) async {
      await pump(
        tester,
        const AppBlockState(
          status: AppBlockStatus.error,
          hasUsageAccess: true,
          hasOverlayPermission: true,
          hasDeviceAdmin: true,
        ),
      );
      expect(find.text('Take me there'), findsNothing);
      expect(find.text('Check and connect'), findsOneWidget);
      expect(
        find.text(
          'Could not connect app limits. Check the connection and try again.',
        ),
        findsOneWidget,
      );
    });
  });

  group('KidHello', () {
    testWidgets('greets a kid once per account', (tester) async {
      final store = await _store();
      Future<void> open() async {
        await tester.pumpWidget(
          _app(
            KidHello(
              userId: 'kid-1',
              store: store,
              child: const SizedBox(height: 10),
            ),
          ),
        );
        await tester.pumpAndSettle();
      }

      await open();
      expect(find.text("Hi! I'm Fini."), findsOneWidget);
      expect(
        find.text('Your parent can see which apps you use'),
        findsOneWidget,
      );
      await tester.tap(find.text("Let's go"));
      await tester.pumpAndSettle();

      await tester.pumpWidget(const SizedBox());
      await open();
      expect(find.text("Hi! I'm Fini."), findsNothing);
    });
  });

  testWidgets('a sheet keeps its last button above the Android nav bar', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1080, 2424);
    tester.view.devicePixelRatio = 2.625;
    tester.view.padding = const FakeViewPadding(bottom: 48 * 2.625);
    tester.view.viewPadding = const FakeViewPadding(bottom: 48 * 2.625);
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      _app(
        Builder(
          builder: (context) => TextButton(
            onPressed: () => showKidHello(context),
            child: const Text('hi'),
          ),
        ),
      ),
    );
    await tester.tap(find.text('hi'));
    await tester.pumpAndSettle();

    final screen =
        tester.view.physicalSize.height / tester.view.devicePixelRatio;
    final button = tester.getRect(find.byKey(const ValueKey('kid-hello-go')));
    expect(button.bottom, lessThanOrEqualTo(screen - 48));
  });
}
