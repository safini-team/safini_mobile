import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:safini/core/translation/generated/l10n.dart';
import 'package:safini/features/models/domain/models/device_usage.dart';
import 'package:safini/features/models/presentation/widgets/app_time_list.dart';

/// "Where the time went" used to show the top three apps a parent had a rule
/// on. It now lists every app the child opened, so a long day has to stay
/// readable, and an app with no rule must parse without rule fields.
void main() {
  group('DeviceUsage.fromJson', () {
    test('reads apps with and without a rule', () {
      final usage = DeviceUsage.fromJson({
        'usage_available': true,
        'total_minutes': 95,
        'apps': [
          {
            'package_name': 'com.roblox.client',
            'app_slug': 'roblox',
            'display_name': 'Roblox',
            'icon_url': '/v1/children/c1/installed-apps/com.roblox.client/icon',
            'used_minutes': 70,
            'has_rule': true,
            'is_blocked': false,
            'is_limited': true,
            'daily_limit_minutes': 60,
          },
          {
            'package_name': 'com.whatsapp',
            'app_slug': 'com.whatsapp',
            'display_name': 'WhatsApp',
            'icon_url': null,
            'used_minutes': 25,
            'has_rule': false,
            'is_blocked': false,
            'is_limited': false,
            'daily_limit_minutes': null,
          },
        ],
      });

      expect(usage.totalMinutes, 95);
      expect(usage.apps.map((app) => app.displayName), ['Roblox', 'WhatsApp']);
      expect(usage.apps.first.isOver, isTrue);
      expect(usage.apps.last.isOver, isFalse);
      expect(usage.apps.last.dailyLimitMinutes, isNull);
    });

    test('an iPhone child has no apps to show', () {
      final usage = DeviceUsage.fromJson({
        'usage_available': false,
        'total_minutes': 0,
        'apps': [],
      });
      expect(usage.usageAvailable, isFalse);
      expect(usage.apps, isEmpty);
    });

    test('a blank name falls back to the package', () {
      final app = DeviceUsageApp.fromJson({
        'package_name': 'org.unlisted',
        'display_name': '  ',
        'used_minutes': 5,
      });
      expect(app.displayName, 'org.unlisted');
    });

    test('a blocked app is not "over" its stale limit', () {
      const app = DeviceUsageApp(
        displayName: 'Roblox',
        usedMinutes: 30,
        hasRule: true,
        isBlocked: true,
        isLimited: true,
        dailyLimitMinutes: 10,
      );
      expect(app.isOver, isFalse);
    });
  });

  test('bars share a 90-minute scale unless an app went further', () {
    expect(
      AppTimeList.scaleFor(const [AppTimeRow(name: 'a', usedMinutes: 30)]),
      90,
    );
    expect(
      AppTimeList.scaleFor(const [
        AppTimeRow(name: 'a', usedMinutes: 30),
        AppTimeRow(name: 'b', usedMinutes: 140),
      ]),
      140,
    );
  });

  testWidgets('a long day shows five apps and the rest behind a tap', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: const [S.delegate],
        supportedLocales: S.delegate.supportedLocales,
        locale: const Locale('en'),
        home: Scaffold(
          body: SingleChildScrollView(
            child: AppTimeList(
              apps: [
                for (var i = 1; i <= 7; i++)
                  AppTimeRow(name: 'App $i', usedMinutes: 80 - i * 10),
              ],
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('App 5'), findsOneWidget);
    expect(find.text('App 6'), findsNothing);
    expect(find.text('Show all 7 apps'), findsOneWidget);

    await tester.tap(find.text('Show all 7 apps'));
    await tester.pumpAndSettle();

    expect(find.text('App 7'), findsOneWidget);
    expect(find.text('Show fewer'), findsOneWidget);
  });

  testWidgets('five apps or fewer need no toggle', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: const [S.delegate],
        supportedLocales: S.delegate.supportedLocales,
        locale: const Locale('en'),
        home: Scaffold(
          body: AppTimeList(
            apps: [
              for (var i = 1; i <= 5; i++)
                AppTimeRow(name: 'App $i', usedMinutes: 10),
            ],
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('App 5'), findsOneWidget);
    expect(find.textContaining('Show'), findsNothing);
  });
}
