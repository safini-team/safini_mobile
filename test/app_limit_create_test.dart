import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:safini/core/theme/app_theme.dart';
import 'package:safini/core/translation/generated/l10n.dart';
import 'package:safini/features/models/domain/models/device_usage.dart';
import 'package:safini/features/parent/presentation/cubit/parent_apps_cubit.dart';
import 'package:safini/features/parent/presentation/screens/apps/parent_limits_view.dart';
import 'package:safini/features/parent/presentation/widgets/apps/app_limit_sheet.dart';

class _AppsCubit extends Fake implements ParentAppsCubit {
  Map<String, Object?>? added;
  Map<String, Object?>? updated;

  @override
  Future<String?> updateRule(
    String appSlug, {
    int? dailyLimitMinutes,
    bool? isBlocked,
    bool? isLimited,
    bool? canRedeem,
    int? redeemCoinCost,
    int? redeemRewardMinutes,
  }) async {
    updated = {
      'slug': appSlug,
      'limit': dailyLimitMinutes,
      'blocked': isBlocked,
      'limited': isLimited,
      'redeem': canRedeem,
      'cost': redeemCoinCost,
      'reward': redeemRewardMinutes,
    };
    return null;
  }

  @override
  Future<String?> addApp({
    required String slug,
    required String name,
    required int dailyLimitMinutes,
    required int redeemCoinCost,
    required int redeemRewardMinutes,
    bool isBlocked = false,
    bool isLimited = true,
    bool canRedeem = true,
  }) async {
    added = {
      'slug': slug,
      'name': name,
      'limit': dailyLimitMinutes,
      'cost': redeemCoinCost,
      'reward': redeemRewardMinutes,
      'blocked': isBlocked,
      'limited': isLimited,
      'redeem': canRedeem,
    };
    return null;
  }
}

Future<void> _open(
  WidgetTester tester,
  _AppsCubit cubit,
  LimitsApp app, {
  bool isNew = false,
  bool startEditing = true,
  List<DayUsage>? week,
}) async {
  tester.view
    ..physicalSize = const Size(402, 1000) * 3
    ..devicePixelRatio = 3;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(
    MaterialApp(
      theme: AppTheme.light,
      locale: const Locale('en'),
      localizationsDelegates: const [
        S.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: S.delegate.supportedLocales,
      home: Builder(
        builder: (context) => Scaffold(
          body: TextButton(
            onPressed: () => showAppLimitSheet(
              context,
              cubit: cubit,
              childName: 'Amir',
              app: app,
              isNew: isNew,
              startEditing: startEditing,
              week: week,
            ),
            child: const Text('Open'),
          ),
        ),
      ),
    ),
  );
  await tester.tap(find.text('Open'));
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('new installed app is saved only from the configuration sheet', (
    tester,
  ) async {
    tester.view
      ..physicalSize = const Size(402, 1000) * 3
      ..devicePixelRatio = 3;
    addTearDown(tester.view.reset);
    final cubit = _AppsCubit();

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        locale: const Locale('en'),
        localizationsDelegates: const [
          S.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: S.delegate.supportedLocales,
        home: Builder(
          builder: (context) => Scaffold(
            body: TextButton(
              onPressed: () => showAppLimitSheet(
                context,
                cubit: cubit,
                childName: 'Amir',
                isNew: true,
                app: const LimitsApp(
                  slug: 'com.example.video',
                  name: 'Video',
                  emoji: '📺',
                  usedMinutes: 0,
                  limitMinutes: 60,
                  isLimited: true,
                  canRedeem: true,
                ),
              ),
              child: const Text('Open'),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Open'));
    await tester.pumpAndSettle();
    expect(cubit.added, isNull);

    await tester.tap(find.text('Save for Amir'));
    await tester.pumpAndSettle();
    await tester.pump(const Duration(seconds: 3));

    expect(cubit.added, {
      'slug': 'com.example.video',
      'name': 'Video',
      'limit': 60,
      'cost': 100,
      'reward': 30,
      'blocked': false,
      'limited': true,
      'redeem': true,
    });
  });

  final week = [
    for (var i = 0; i < 7; i++)
      DayUsage(date: DateTime(2026, 10, 2 + i), minutes: i == 3 ? 90 : 0),
  ];

  testWidgets('an app with no limit opens on its week, button first', (
    tester,
  ) async {
    final cubit = _AppsCubit();
    await _open(
      tester,
      cubit,
      const LimitsApp(
        slug: 'youtube',
        name: 'YouTube',
        emoji: '📺',
        usedMinutes: 20,
        limitMinutes: 60,
        isLimited: false,
        canRedeem: true,
      ),
      isNew: true,
      startEditing: false,
      week: week,
    );

    expect(find.text('Add a limit'), findsOneWidget);
    expect(find.text('Last 7 days'.toUpperCase()), findsOneWidget);
    expect(find.textContaining('Remove limit'), findsNothing);
    expect(find.text('Save for Amir'), findsNothing);
    // The button sits above the week.
    expect(
      tester.getTopLeft(find.text('Add a limit')).dy,
      lessThan(tester.getTopLeft(find.text('Last 7 days'.toUpperCase())).dy),
    );

    await tester.tap(find.text('Add a limit'));
    await tester.pumpAndSettle();
    expect(find.text('Save for Amir'), findsOneWidget);
    // A fresh limit has nothing to remove.
    expect(find.text('Remove limit'), findsNothing);

    await tester.tap(find.text('Save for Amir'));
    await tester.pumpAndSettle();
    await tester.pump(const Duration(seconds: 3));
    expect(cubit.added, containsPair('limited', true));
    expect(cubit.added, containsPair('limit', 60));
  });

  testWidgets(
    'an app with a limit opens its settings, with a way to remove it',
    (tester) async {
      final cubit = _AppsCubit();
      await _open(
        tester,
        cubit,
        const LimitsApp(
          slug: 'youtube',
          name: 'YouTube',
          emoji: '📺',
          usedMinutes: 20,
          limitMinutes: 45,
          isLimited: true,
          canRedeem: false,
        ),
        week: week,
      );

      expect(find.text('Add a limit'), findsNothing);
      expect(find.text('Save for Amir'), findsOneWidget);
      // Buying is off, so its price rows are not shown.
      expect(find.text('Minutes per purchase'), findsNothing);

      await tester.tap(find.text('Remove limit'));
      await tester.pumpAndSettle();
      await tester.pump(const Duration(seconds: 3));
      expect(cubit.updated, containsPair('limited', false));
      expect(cubit.updated, containsPair('blocked', false));
    },
  );
}
