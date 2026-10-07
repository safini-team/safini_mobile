import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:safini/core/theme/app_theme.dart';
import 'package:safini/core/translation/generated/l10n.dart';
import 'package:safini/features/child/presentation/screens/home/child_today_view.dart';
import 'package:safini/features/child/presentation/widgets/kid_usage_section.dart';
import 'package:safini/features/models/domain/models/device_usage.dart';
import 'package:safini/features/parent/domain/models/child_app_usage_model.dart';

/// The kid's Today used to show only minutes spent, so the first a child heard
/// of a limit was the block screen ending the game. "My usage today" puts what
/// the parent allows beside where the time went, in one list.
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

const _youtube = KidAppUsage(
  name: 'YouTube',
  usedMinutes: 20,
  limitMinutes: 45,
  remainingMinutes: 25,
  canRedeem: true,
);

const _roblox = KidAppUsage(
  name: 'Roblox',
  usedMinutes: 30,
  limitMinutes: 30,
  remainingMinutes: 0,
  canRedeem: true,
);

const _tiktok = KidAppUsage(
  name: 'TikTok',
  usedMinutes: 0,
  limitMinutes: 0,
  remainingMinutes: 0,
  isBlocked: true,
);

const _chrome = KidAppUsage(name: 'Chrome', usedMinutes: 9);

ChildAppUsageModel _rule(
  String slug,
  String name, {
  bool limited = true,
  bool blocked = false,
  int limit = 30,
  int used = 10,
  int? remaining = 20,
}) => ChildAppUsageModel(
  appSlug: slug,
  displayName: name,
  isBlocked: blocked,
  isLimited: limited,
  canRedeem: false,
  dailyLimitMinutes: limit,
  usedMinutes: used,
  remainingMinutesToday: remaining,
  redeemCoinCost: 0,
  redeemRewardMinutes: 0,
);

void main() {
  test('limits first, most urgent on top, then the rest by minutes', () {
    const lowOnTime = KidAppUsage(
      name: 'Minecraft',
      usedMinutes: 52,
      limitMinutes: 60,
      remainingMinutes: 8,
    );
    const telegram = KidAppUsage(name: 'Telegram', usedMinutes: 12);
    final sorted = [_chrome, _tiktok, telegram, _youtube, lowOnTime, _roblox]
      ..sort(KidAppUsage.compare);
    expect(sorted.map((app) => app.name), [
      'Roblox',
      'Minecraft',
      'YouTube',
      'TikTok',
      'Telegram',
      'Chrome',
    ]);
  });

  test('one row per app: used apps joined to their rule by slug', () {
    final rows = kidAppUsage(
      usage: const DeviceUsage(
        usageAvailable: true,
        totalMinutes: 60,
        apps: [
          DeviceUsageApp(
            displayName: 'YouTube',
            appSlug: 'youtube',
            usedMinutes: 22,
          ),
          DeviceUsageApp(
            displayName: 'Telegram',
            appSlug: 'telegram',
            usedMinutes: 12,
          ),
          DeviceUsageApp(
            displayName: 'Chrome',
            appSlug: 'com.android.chrome',
            usedMinutes: 9,
          ),
        ],
      ),
      rules: [
        _rule('youtube', 'YouTube', used: 20, remaining: 10),
        _rule('telegram', 'Telegram', limited: false, remaining: null),
        _rule('tiktok', 'TikTok', blocked: true, used: 0, remaining: 0),
        _rule('discord', 'Discord', limited: false, remaining: null),
        _rule('minecraft', 'Minecraft', used: 0, remaining: 30),
      ],
    );

    expect(rows.map((app) => app.name), [
      'YouTube',
      'Minecraft',
      'TikTok',
      'Telegram',
      'Chrome',
    ]);
    // A capped app reads the rule's minutes so "x of y" and "left" agree.
    expect(rows.first.usedMinutes, 20);
    expect(rows.first.state, KidAppState.limited);
    // A rule with no cap is just minutes; unused, it is not listed at all.
    expect(rows[3].state, KidAppState.free);
    expect(rows.any((app) => app.name == 'Discord'), isFalse);
  });

  test('an iPhone lists only what the parent capped or blocked', () {
    final rows = kidAppUsage(
      usage: const DeviceUsage(
        usageAvailable: false,
        totalMinutes: 0,
        apps: [],
      ),
      rules: [
        _rule('youtube', 'YouTube'),
        _rule('telegram', 'Telegram', limited: false, remaining: null),
      ],
    );
    expect(rows.map((app) => app.name), ['YouTube']);
  });

  testWidgets('each row says what is left, or just the minutes', (
    tester,
  ) async {
    var openedStore = 0;
    await tester.pumpWidget(
      _host(
        KidUsageSection(
          apps: const [_roblox, _youtube, _tiktok, _chrome],
          onOpenStore: () => openedStore++,
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('25 m left'), findsOneWidget);
    expect(find.text('20 m of 45 m'), findsOneWidget);
    expect(find.text("Time's up"), findsOneWidget);
    expect(find.text('Get more time in the Store'), findsOneWidget);
    expect(find.text('Blocked'), findsOneWidget);
    expect(find.text('Your parent turned this app off'), findsOneWidget);
    expect(find.text('9 m'), findsOneWidget);
    expect(find.text('No limit'), findsNothing);

    await tester.tap(find.text('Roblox'));
    await tester.tap(find.text('TikTok'));
    await tester.tap(find.text('Chrome'));
    expect(openedStore, 1);
  });

  testWidgets('a long day folds behind "Show all N apps"', (tester) async {
    await tester.pumpWidget(
      _host(
        KidUsageSection(
          collapsed: 2,
          apps: const [
            _youtube,
            KidAppUsage(name: 'Telegram', usedMinutes: 12),
            _chrome,
          ],
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('Chrome'), findsNothing);

    await tester.tap(find.text('Show all 3 apps'));
    await tester.pumpAndSettle();
    expect(find.text('Chrome'), findsOneWidget);
  });

  testWidgets('minutes bought with coins count towards the allowance', (
    tester,
  ) async {
    await tester.pumpWidget(
      _host(
        const KidUsageSection(
          apps: [
            KidAppUsage(
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
        const KidUsageSection(
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
    expect(find.text('Shared by the apps your parent manages'), findsOneWidget);

    await tester.pumpWidget(
      _host(
        KidUsageSection(
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
        const KidUsageSection(
          usageAvailable: false,
          budget: KidBudget(
            limitMinutes: 120,
            usedMinutes: 0,
            remainingMinutes: 120,
            usageAvailable: false,
          ),
          apps: [
            KidAppUsage(
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

  testWidgets('Today shows one "My usage today" section, and only with data', (
    tester,
  ) async {
    ChildTodayData data({List<KidAppUsage> apps = const []}) => ChildTodayData(
      greeting: 'Good evening',
      name: 'Amir',
      coins: 25,
      questsDone: 0,
      questsTotal: 0,
      openCoins: 0,
      next: null,
      holdToComplete: true,
      usageApps: apps,
      usageMinutes: 29,
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
    expect(find.text('My usage today'), findsNothing);

    await tester.pumpWidget(
      _host(
        SizedBox(height: 2000, child: today(data(apps: [_youtube, _chrome]))),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('My usage today'), findsOneWidget);
    expect(find.text('29 m'), findsOneWidget);
    expect(find.text('25 m left'), findsOneWidget);
    expect(find.text('My time today'), findsNothing);
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
