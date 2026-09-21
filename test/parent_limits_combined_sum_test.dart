import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:safini/core/translation/generated/l10n.dart';
import 'package:safini/features/parent/presentation/screens/apps/parent_limits_view.dart';

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
  testWidgets('no cap never uses the sum of app limits as a budget', (
    tester,
  ) async {
    await _pumpLimits(
      tester,
      _data(apps: [_app('Chrome', limit: 60), _app('Gmail', limit: 45)]),
    );
    expect(find.text('4 h'), findsOneWidget);
    expect(find.text('1 h 45 m'), findsNothing);
  });

  testWidgets('the selected child name appears only in the selector', (
    tester,
  ) async {
    await _pumpLimits(tester, _data(apps: [_app('Chrome', limit: 60)]));

    expect(find.text('Amir'), findsOneWidget);
    expect(find.text("Amir's phone · today"), findsNothing);
    expect(find.text('Amir · daily allowance'), findsNothing);
    expect(find.text("Amir's apps"), findsNothing);
    expect(find.text('Today'), findsOneWidget);
    expect(find.text('OVERALL DAILY BUDGET'), findsOneWidget);
    expect(find.text('APPS'), findsOneWidget);
  });

  testWidgets('rows show the daily allowance when usage stays on the child', (
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
    expect(find.text('Daily limit · 1 h'), findsOneWidget);
    // The overall card still explains where actual usage can be viewed.
    expect(find.textContaining('Usage is shown'), findsOneWidget);
    expect(
      find.textContaining('View actual usage in Screen Time'),
      findsNothing,
    );
  });
}
