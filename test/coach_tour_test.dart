import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:safini/core/translation/generated/l10n.dart';
import 'package:safini/features/onboarding/coach_tour.dart';
import 'package:safini/features/onboarding/onboarding_store.dart';
import 'package:safini/features/onboarding/parent_tour.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// The parent's dashboard tour: a hole over each widget in turn, Fini saying
/// one line, shown once per family.
final _a = GlobalKey();
final _b = GlobalKey();
final _missing = GlobalKey();

Widget _app({Widget? extra, bool withB = true}) => MaterialApp(
  localizationsDelegates: const [S.delegate],
  supportedLocales: S.delegate.supportedLocales,
  locale: const Locale('en'),
  builder: (context, page) => MediaQuery(
    data: MediaQuery.of(context).copyWith(disableAnimations: true),
    child: page!,
  ),
  home: Scaffold(
    body: Column(
      children: [
        SizedBox(key: _a, height: 120, width: 300),
        const Spacer(),
        if (withB) SizedBox(key: _b, height: 60, width: 300),
        ?extra,
      ],
    ),
  ),
);

List<CoachStep> get _steps => [
  CoachStep(target: _a, text: 'First thing'),
  CoachStep(target: _missing, text: 'Not on screen'),
  CoachStep(target: _b, text: 'Last thing'),
];

void main() {
  testWidgets('walks the steps on screen, skipping missing ones', (
    tester,
  ) async {
    await tester.pumpWidget(_app());
    final context = tester.element(find.byType(Scaffold));
    showCoachTour(context, _steps);
    await tester.pumpAndSettle();

    expect(find.text('First thing'), findsOneWidget);
    expect(find.text('Next'), findsOneWidget);

    await tester.tap(find.byKey(const ValueKey('coach-scrim')));
    await tester.pumpAndSettle();
    expect(find.text('Not on screen'), findsNothing);
    expect(find.text('Last thing'), findsOneWidget);
    expect(find.text('Got it'), findsOneWidget);
    expect(find.text('Skip'), findsNothing);

    await tester.tap(find.text('Got it'));
    await tester.pumpAndSettle();
    expect(find.byType(CoachTour), findsNothing);
  });

  testWidgets('Skip ends the tour at once', (tester) async {
    await tester.pumpWidget(_app());
    showCoachTour(tester.element(find.byType(Scaffold)), _steps);
    await tester.pumpAndSettle();

    await tester.tap(find.text('Skip'));
    await tester.pumpAndSettle();
    expect(find.byType(CoachTour), findsNothing);
  });

  group('ParentTourHost', () {
    Future<OnboardingStore> store() async {
      SharedPreferences.setMockInitialValues({});
      return OnboardingStore(await SharedPreferences.getInstance());
    }

    testWidgets('waits for a connected child and something to point at', (
      tester,
    ) async {
      final prefs = await store();
      Widget host(bool ready) => _app(
        extra: ParentTourHost(
          familyId: 'fam',
          ready: ready,
          store: prefs,
          delay: Duration.zero,
        ),
      );

      await tester.pumpWidget(host(false));
      await tester.pumpAndSettle();
      expect(find.byType(CoachTour), findsNothing);

      // Ready, but none of the tour's widgets are on screen: not shown, and
      // not spent either.
      await tester.pumpWidget(host(true));
      await tester.pumpAndSettle();
      expect(find.byType(CoachTour), findsNothing);
      expect(prefs.tourSeen('fam'), isFalse);
    });

    testWidgets('points at the screen-time card, once per family', (
      tester,
    ) async {
      final prefs = await store();
      Widget page() => _app(
        extra: Column(
          children: [
            SizedBox(key: ParentTour.screenTime, height: 40, width: 200),
            ParentTourHost(
              familyId: 'fam',
              ready: true,
              store: prefs,
              delay: Duration.zero,
            ),
          ],
        ),
      );
      await tester.pumpWidget(page());
      await tester.pumpAndSettle();

      expect(find.byType(CoachTour), findsOneWidget);
      expect(
        find.text("Today's screen time. It fills up as apps get used."),
        findsOneWidget,
      );
      expect(prefs.tourSeen('fam'), isTrue);

      await tester.tap(find.text('Got it'));
      await tester.pumpAndSettle();
      await tester.pumpWidget(const SizedBox());
      await tester.pumpWidget(page());
      await tester.pumpAndSettle();
      expect(find.byType(CoachTour), findsNothing);
    });
  });
}
