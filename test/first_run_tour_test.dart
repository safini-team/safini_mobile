import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:safini/core/di/injection.dart';
import 'package:safini/core/translation/generated/l10n.dart';
import 'package:safini/features/onboarding/first_run_tour.dart';
import 'package:safini/features/onboarding/onboarding_store.dart';
import 'package:shared_preferences/shared_preferences.dart';

class _TourHarness extends StatefulWidget {
  const _TourHarness({required this.role, required this.userId});

  final TourRole role;
  final String userId;

  @override
  State<_TourHarness> createState() => _TourHarnessState();
}

class _TourHarnessState extends State<_TourHarness> {
  final tabKey = GlobalKey();
  int tab = 0;
  bool gifts = false;
  bool tappedBehind = false;

  void select(int index) => setState(() => tab = index);

  @override
  Widget build(BuildContext context) => FirstRunTour(
    role: widget.role,
    userId: widget.userId,
    selectedTab: tab,
    onSelectTab: select,
    onOpenGifts: () => setState(() {
      tab = 2;
      gifts = true;
    }),
    tabBarKey: tabKey,
    // Mirrors the real bars: four parent tabs, five child tabs.
    tabCount: widget.role == TourRole.parent ? 4 : 5,
    child: Scaffold(
      body: Stack(
        children: [
          Align(
            alignment: Alignment.topCenter,
            child: TextButton(
              onPressed: () => setState(() => tappedBehind = true),
              child: const Text('behind the tour'),
            ),
          ),
          Center(child: Text('tab $tab${gifts ? ' gifts' : ''}')),
        ],
      ),
      bottomNavigationBar: SizedBox(
        key: tabKey,
        height: 76,
        child: const Center(child: Text('navigation')),
      ),
    ),
  );
}

Future<void> _pumpTour(
  WidgetTester tester,
  TourRole role,
  String userId,
) async {
  await tester.pumpWidget(
    MaterialApp(
      localizationsDelegates: const [S.delegate],
      supportedLocales: S.delegate.supportedLocales,
      home: _TourHarness(role: role, userId: userId),
    ),
  );
  await tester.pump();
  await tester.pump();
}

void main() {
  late OnboardingStore store;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    store = OnboardingStore(await SharedPreferences.getInstance());
    getIt.registerSingleton<OnboardingStore>(store);
  });

  tearDown(() async => getIt.reset());

  testWidgets('parent sees every tab and the Gifts view, then finishes once', (
    tester,
  ) async {
    await _pumpTour(tester, TourRole.parent, 'new-parent');
    expect(find.text('Your dashboard'), findsOneWidget);
    await tester.tap(find.text('behind the tour'), warnIfMissed: false);
    await tester.pump();
    final harness = tester.state<_TourHarnessState>(find.byType(_TourHarness));
    expect(harness.tappedBehind, isFalse);
    expect(harness.tab, 0);

    for (final title in [
      'Needs your review',
      'Tasks',
      'Limits',
      'Gifts',
      'Family',
    ]) {
      await tester.tap(find.byKey(const ValueKey('tour-next')));
      await tester.pump();
      expect(find.text(title), findsOneWidget);
      if (title == 'Gifts') {
        expect(find.text('tab 2 gifts'), findsOneWidget);
      }
    }
    await tester.tap(find.byKey(const ValueKey('tour-next')));
    await tester.pump();
    expect(find.text('Skip tour'), findsNothing);
    expect(store.tourStep('parent', 'new-parent'), 6);

    await tester.pumpWidget(const SizedBox.shrink());
    await _pumpTour(tester, TourRole.parent, 'new-parent');
    expect(find.text('Your dashboard'), findsNothing);
  });

  testWidgets('child can skip without affecting another account', (
    tester,
  ) async {
    await _pumpTour(tester, TourRole.child, 'child-one');
    expect(find.text('Your Today page'), findsOneWidget);
    await tester.tap(find.text('Skip tour'));
    await tester.pump();
    expect(store.tourStep('child', 'child-one'), 5);

    await tester.pumpWidget(const SizedBox.shrink());
    await _pumpTour(tester, TourRole.child, 'child-two');
    expect(find.text('Your Today page'), findsOneWidget);
  });

  testWidgets('child walks through all five tabs, ending on Me', (
    tester,
  ) async {
    await _pumpTour(tester, TourRole.child, 'five-tabs-child');
    final harness = tester.state<_TourHarnessState>(find.byType(_TourHarness));
    expect(find.text('Your Today page'), findsOneWidget);
    expect(find.text('1 of 5'), findsOneWidget);
    expect(harness.tab, 0);

    const titles = [
      'Your tasks',
      'Spend your coins',
      'Your friends',
      'Your space',
    ];
    for (var i = 0; i < titles.length; i++) {
      await tester.tap(find.byKey(const ValueKey('tour-next')));
      await tester.pump();
      expect(find.text(titles[i]), findsOneWidget);
      expect(find.text('${i + 2} of 5'), findsOneWidget);
      expect(harness.tab, i + 1);
    }

    await tester.tap(find.byKey(const ValueKey('tour-next')));
    await tester.pump();
    expect(find.text('Skip tour'), findsNothing);
    expect(store.tourStep('child', 'five-tabs-child'), 5);
  });

  testWidgets('an interrupted tour resumes at Gifts inside Limits', (
    tester,
  ) async {
    await store.saveTourStep('parent', 'paused-parent', 4);
    await _pumpTour(tester, TourRole.parent, 'paused-parent');
    expect(find.text('Gifts'), findsOneWidget);
    expect(find.text('tab 2 gifts'), findsOneWidget);
    expect(find.text('5 of 6'), findsOneWidget);
  });
}
