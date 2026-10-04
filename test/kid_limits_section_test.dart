import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:safini/core/theme/app_theme.dart';
import 'package:safini/core/translation/generated/l10n.dart';
import 'package:safini/features/child/presentation/screens/home/child_today_view.dart';
import 'package:safini/features/child/presentation/widgets/kid_limits_section.dart';
import 'package:safini/features/parent/domain/models/child_app_usage_model.dart';

/// The kid's Today used to show only minutes spent, so the first a child heard
/// of a limit was the block screen ending the game. "My limits" shows what the
/// parent allows and what is left of it.
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
  home: Scaffold(body: SingleChildScrollView(child: child)),
);

const _youtube = KidAppLimit(
  name: 'YouTube',
  usedMinutes: 20,
  limitMinutes: 45,
  remainingMinutes: 25,
  canRedeem: true,
);

const _roblox = KidAppLimit(
  name: 'Roblox',
  usedMinutes: 30,
  limitMinutes: 30,
  remainingMinutes: 0,
  canRedeem: true,
);

const _tiktok = KidAppLimit(
  name: 'TikTok',
  usedMinutes: 0,
  limitMinutes: 0,
  remainingMinutes: 0,
  isBlocked: true,
);

const _duolingo = KidAppLimit(
  name: 'Duolingo',
  usedMinutes: 12,
  limitMinutes: 0,
  remainingMinutes: null,
  isLimited: false,
);

void main() {
  test('most urgent first: out of time, least left, no limit, blocked', () {
    const lowOnTime = KidAppLimit(
      name: 'Minecraft',
      usedMinutes: 52,
      limitMinutes: 60,
      remainingMinutes: 8,
    );
    final sorted = [_tiktok, _duolingo, _youtube, lowOnTime, _roblox]
      ..sort(KidAppLimit.compare);
    expect(sorted.map((app) => app.name), [
      'Roblox',
      'Minecraft',
      'YouTube',
      'Duolingo',
      'TikTok',
    ]);
  });

  test('an app with no limit is out of time once the budget is', () {
    const app = KidAppLimit(
      name: 'Duolingo',
      usedMinutes: 12,
      limitMinutes: 0,
      remainingMinutes: 0,
      isLimited: false,
    );
    expect(app.state, KidAppLimitState.timesUp);
  });

  testWidgets('each app says what is left and how much was used', (
    tester,
  ) async {
    var openedStore = 0;
    await tester.pumpWidget(
      _host(
        KidLimitsSection(
          apps: [_roblox, _youtube, _duolingo, _tiktok],
          onOpenStore: () => openedStore++,
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('25 m left'), findsOneWidget);
    expect(find.text('20 m of 45 m'), findsOneWidget);
    expect(find.text("Time's up"), findsOneWidget);
    expect(find.text('Get more time in the Store'), findsOneWidget);
    expect(find.text('No limit'), findsOneWidget);
    expect(find.text('12 m today'), findsOneWidget);
    expect(find.text('Blocked'), findsOneWidget);
    expect(find.text('Your parent turned this app off'), findsOneWidget);

    await tester.tap(find.text('Roblox'));
    await tester.tap(find.text('TikTok'));
    expect(openedStore, 1);
  });

  testWidgets('minutes bought with coins count towards the allowance', (
    tester,
  ) async {
    await tester.pumpWidget(
      _host(
        const KidLimitsSection(
          apps: [
            KidAppLimit(
              name: 'YouTube',
              usedMinutes: 40,
              limitMinutes: 45,
              bonusMinutes: 15,
              remainingMinutes: 20,
            ),
          ],
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('40 m of 1 h · +15 m from coins'), findsOneWidget);
    expect(find.text('20 m left'), findsOneWidget);
  });

  testWidgets('the daily budget reads as time left, then as time up', (
    tester,
  ) async {
    await tester.pumpWidget(
      _host(
        const KidLimitsSection(
          budget: KidBudget(
            limitMinutes: 120,
            usedMinutes: 50,
            remainingMinutes: 70,
          ),
          apps: [],
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('1 h 10 m left today'), findsOneWidget);
    expect(find.text('Shared by the apps below'), findsOneWidget);

    await tester.pumpWidget(
      _host(
        KidLimitsSection(
          budget: KidBudget(
            limitMinutes: 120,
            usedMinutes: 120,
            remainingMinutes: 0,
            nextResetAt: DateTime(2026, 10, 5),
          ),
          apps: const [],
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('No free time left today'), findsOneWidget);
    expect(find.text('Back at 00:00'), findsOneWidget);
  });

  testWidgets('an iPhone shows the limits without inventing minutes', (
    tester,
  ) async {
    await tester.pumpWidget(
      _host(
        const KidLimitsSection(
          usageAvailable: false,
          budget: KidBudget(
            limitMinutes: 120,
            usedMinutes: 0,
            remainingMinutes: 120,
            usageAvailable: false,
          ),
          apps: [
            KidAppLimit(
              name: 'YouTube',
              usedMinutes: 0,
              limitMinutes: 45,
              remainingMinutes: 45,
            ),
          ],
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('2 h a day'), findsOneWidget);
    expect(find.text('Daily limit · 45 m'), findsOneWidget);
    expect(find.textContaining('left'), findsNothing);
  });

  testWidgets('Today shows "My limits" only when there is something in it', (
    tester,
  ) async {
    ChildTodayData data({List<KidAppLimit> apps = const []}) => ChildTodayData(
      greeting: 'Good evening',
      name: 'Amir',
      coins: 25,
      questsDone: 0,
      questsTotal: 0,
      openCoins: 0,
      next: null,
      holdToComplete: true,
      limitApps: apps,
    );
    Widget today(ChildTodayData data) => ChildTodayView(
      data: data,
      onOpenStore: () {},
      onOpenTasks: () {},
      onOpenQuest: (_) {},
      onSendQuest: (_) {},
    );

    await tester.pumpWidget(
      _host(SizedBox(height: 2000, child: today(data()))),
    );
    await tester.pumpAndSettle();
    expect(find.text('My limits'), findsNothing);

    await tester.pumpWidget(
      _host(SizedBox(height: 2000, child: today(data(apps: [_youtube])))),
    );
    await tester.pumpAndSettle();
    expect(find.text('My limits'), findsOneWidget);
    expect(find.text('25 m left'), findsOneWidget);
  });

  test('bonus minutes are read from app-usage', () {
    final app = ChildAppUsageModel.fromJson({
      'app_slug': 'youtube',
      'display_name': 'YouTube',
      'is_limited': true,
      'daily_limit_minutes': 45,
      'used_minutes': 40,
      'bonus_minutes_remaining': 15,
      'remaining_minutes_today': 20,
    });
    expect(app.bonusMinutesRemaining, 15);
  });
}
