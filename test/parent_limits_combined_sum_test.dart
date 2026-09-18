import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:safini/core/translation/generated/l10n.dart';
import 'package:safini/core/utils/screen_time_cap.dart';
import 'package:safini/features/parent/domain/models/child_app_usage_model.dart';
import 'package:safini/features/parent/domain/models/screen_time_model.dart';
import 'package:safini/features/parent/presentation/screens/apps/parent_limits_view.dart';

/// With no whole-device cap, the Limits headline is the per-app limits added
/// up. A blocked app keeps its `daily_limit_minutes` on the rule but the child
/// gets none of it, and an app with no limit has nothing to add. On 2026-09-13
/// Chrome blocked at 60 plus Gmail at 45 read "1 ч 45 м" and "1 ч 45 м
/// осталось" for a child who could only ever use 45 minutes.
ParentLimitsData _data({int? cap, required List<LimitsApp> apps}) {
  return ParentLimitsData(
    kids: const [LimitsKid(id: 'c1', name: 'Amir', color: Color(0xFF1A5C4A))],
    selectedKidId: 'c1',
    kidName: 'Amir',
    apps: apps,
    capMinutes: cap,
  );
}

LimitsApp _app(
  String name, {
  required int limit,
  int used = 0,
  bool isLimited = true,
  bool isBlocked = false,
}) {
  return LimitsApp(
    slug: name.toLowerCase(),
    name: name,
    emoji: '📱',
    usedMinutes: used,
    limitMinutes: limit,
    isBlocked: isBlocked,
    isLimited: isLimited,
    canRedeem: true,
  );
}

/// A row as `GET /v1/children/{child_id}/app-usage` sends it.
ChildAppUsageModel _row(
  String slug, {
  required int limit,
  bool isLimited = true,
  bool isBlocked = false,
}) {
  return ChildAppUsageModel.fromJson({
    'app_slug': slug,
    'display_name': slug,
    'is_blocked': isBlocked,
    'is_limited': isLimited,
    'can_redeem': true,
    'daily_limit_minutes': limit,
    'used_minutes': 0,
    'remaining_minutes_today': isBlocked ? 0 : limit,
    'redeem_coin_cost': 100,
    'redeem_reward_minutes': 30,
  });
}

Future<void> _pumpLimits(
  WidgetTester tester,
  ParentLimitsData data, {
  String locale = 'en',
}) async {
  await tester.pumpWidget(
    MaterialApp(
      locale: Locale(locale),
      localizationsDelegates: const [
        S.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: S.delegate.supportedLocales,
      home: ParentLimitsView(
        data: data,
        onSelectKid: (_) {},
        onOpenApp: (_) {},
        onAddApp: () {},
      ),
    ),
  );
  await tester.pump(const Duration(milliseconds: 400));
}

void main() {
  group('ParentLimitsData.combinedLimitMinutes', () {
    test('a blocked app adds nothing, whatever its rule still says', () {
      final data = _data(
        apps: [
          _app('Chrome', limit: 60, isBlocked: true),
          _app('Gmail', limit: 45),
        ],
      );
      expect(data.combinedLimitMinutes, 45);
      expect(data.allowanceMinutes, 45);
      expect(data.leftMinutes, 45);
    });

    test('an app with no limit adds nothing', () {
      // Turning the limit off keeps the old minutes on the rule.
      final data = _data(
        apps: [
          _app('YouTube', limit: 90, isLimited: false),
          _app('Gmail', limit: 45),
        ],
      );
      expect(data.combinedLimitMinutes, 45);
    });

    test('a limit of zero is still a limit', () {
      final data = _data(apps: [_app('Roblox', limit: 0)]);
      expect(data.combinedLimitMinutes, 0);
      expect(data.hasAppLimits, isTrue);
    });

    test('a blocked app is a limit set, an unlimited one is not', () {
      expect(
        _data(apps: [_app('Chrome', limit: 60, isBlocked: true)]).hasAppLimits,
        isTrue,
      );
      expect(
        _data(
          apps: [_app('Chrome', limit: 60, isLimited: false, isBlocked: true)],
        ).hasAppLimits,
        isTrue,
      );
      expect(
        _data(
          apps: [_app('YouTube', limit: 90, isLimited: false)],
        ).hasAppLimits,
        isFalse,
      );
      expect(_data(apps: const []).hasAppLimits, isFalse);
    });

    test('the first stepper press seeds from what the child can use', () {
      final data = _data(
        apps: [
          _app('Chrome', limit: 60, isBlocked: true),
          _app('Gmail', limit: 45),
        ],
      );
      expect(
        screenTimeCapUp(null, combinedMinutes: data.combinedLimitMinutes),
        45,
      );
    });

    test('a cap still wins, blocked apps or not', () {
      final data = _data(
        cap: 120,
        apps: [_app('Chrome', limit: 60, isBlocked: true)],
      );
      expect(data.allowanceMinutes, 120);
    });
  });

  group('ChildAppUsageSnapshot.combinedLimitMinutes', () {
    test('skips blocked apps as well as unlimited ones', () {
      final snapshot = ChildAppUsageSnapshot(
        apps: [
          _row('chrome', limit: 60, isBlocked: true),
          _row('gmail', limit: 45),
          _row('youtube', limit: 90, isLimited: false),
          _row('roblox', limit: 0),
        ],
        screenTime: ScreenTimeModel.none,
      );
      expect(snapshot.combinedLimitMinutes, 45);
    });
  });

  group('the Limits headline with no cap', () {
    testWidgets('shows what the child can actually use', (tester) async {
      // The 2026-09-13 child, in the language it was seen in.
      await _pumpLimits(
        tester,
        _data(
          apps: [
            _app('Chrome', limit: 60, isBlocked: true),
            _app('Gmail', limit: 45),
          ],
        ),
        locale: 'ru',
      );
      expect(find.text('45 м'), findsOneWidget);
      expect(find.text('45 м осталось'), findsOneWidget);
      expect(find.text('1 ч 45 м'), findsNothing);
    });

    testWidgets('every app blocked reads 0 m, not "No limits set"', (
      tester,
    ) async {
      await _pumpLimits(
        tester,
        _data(
          apps: [
            _app('Chrome', limit: 60, used: 20, isBlocked: true),
            _app('Gmail', limit: 45, isBlocked: true),
          ],
        ),
      );
      expect(find.text('0 m'), findsOneWidget);
      expect(find.text('No limits set'), findsNothing);
    });

    testWidgets('blocked plus unlimited apps still read 0 m', (tester) async {
      // Consistent with Gmail at 45 next to an unlimited app reading 45 m:
      // the unlimited app never adds to the figure.
      await _pumpLimits(
        tester,
        _data(
          apps: [
            _app('Chrome', limit: 60, isBlocked: true),
            _app('YouTube', limit: 90, isLimited: false),
          ],
        ),
      );
      expect(find.text('0 m'), findsOneWidget);
      expect(find.text('No limits set'), findsNothing);
    });

    testWidgets('apps limited to zero read 0 m', (tester) async {
      // Zero is no free time, not no limit.
      await _pumpLimits(tester, _data(apps: [_app('Roblox', limit: 0)]));
      expect(find.text('0 m'), findsOneWidget);
      expect(find.text('No limits set'), findsNothing);
    });

    testWidgets('only unlimited apps really is "No limits set"', (
      tester,
    ) async {
      await _pumpLimits(
        tester,
        _data(
          apps: [
            _app('YouTube', limit: 90, isLimited: false),
            _app('Telegram', limit: 0, isLimited: false),
          ],
        ),
      );
      expect(find.text('No limits set'), findsOneWidget);
    });

    testWidgets('no apps at all is "No limits set"', (tester) async {
      await _pumpLimits(tester, _data(apps: const []));
      expect(find.text('No limits set'), findsOneWidget);
    });
  });

  testWidgets('iOS without usage minutes uses a one-line caption', (
    tester,
  ) async {
    await _pumpLimits(
      tester,
      ParentLimitsData(
        usageAvailable: false,
        kids: const [
          LimitsKid(id: 'c1', name: 'Amir', color: Color(0xFF1A5C4A)),
        ],
        selectedKidId: 'c1',
        kidName: 'Amir',
        apps: [
          LimitsApp(
            usageAvailable: false,
            slug: 'youtube-kids',
            name: 'YouTube',
            emoji: '📺',
            usedMinutes: 38,
            limitMinutes: 60,
            isLimited: true,
            canRedeem: true,
          ),
        ],
      ),
    );
    expect(find.textContaining('Usage on the'), findsWidgets);
    expect(
      find.textContaining('View actual usage in Screen Time'),
      findsNothing,
    );
  });
}
