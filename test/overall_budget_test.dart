import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:safini/core/translation/generated/l10n.dart';
import 'package:safini/core/utils/widgets/ds/ds.dart';
import 'package:safini/features/parent/presentation/cubit/home/home_cubit.dart';
import 'package:safini/features/parent/presentation/widgets/apps/overall_budget_card.dart';

Future<void> pumpBudget(
  WidgetTester tester, {
  int? limit,
  int used = 43,
  int? remaining,
  bool available = true,
  String language = 'en',
  Future<String?> Function(int?)? save,
}) async {
  await tester.pumpWidget(
    MaterialApp(
      locale: Locale(language),
      localizationsDelegates: const [
        S.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: S.delegate.supportedLocales,
      home: Scaffold(
        body: SingleChildScrollView(
          child: OverallBudgetCard(
            limitMinutes: limit,
            usedMinutes: used,
            remainingMinutes: remaining,
            usageAvailable: available,
            kidName: 'Amir',
            onSave: save,
          ),
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  test(
    'child selection survives all parent tabs; Everyone clears task scope',
    () async {
      final home = ParentHomeCubit();
      home.selectTab(2);
      home.selectChild('second-child');
      for (final tab in [1, 0, 2]) {
        home.selectTab(tab);
        expect(home.state.selectedChildId, 'second-child');
      }
      home.selectChild(null);
      expect(home.state.selectedChildId, isNull);
      await home.close();
    },
  );

  testWidgets('legacy no-cap state starts from a four-hour allowance', (
    tester,
  ) async {
    await pumpBudget(tester);
    expect(find.text('4 h'), findsOneWidget);
    expect(find.text('43 m used'), findsOneWidget);
    expect(find.text('3 h 17 m left'), findsOneWidget);
    expect(find.byType(Switch), findsNothing);
    expect(find.byType(DsStepper), findsOneWidget);
  });

  testWidgets('server remaining is shown without recomputing it', (
    tester,
  ) async {
    await pumpBudget(tester, limit: 90, remaining: 21);
    expect(find.text('1 h 30 m'), findsOneWidget);
    expect(find.text('21 m left'), findsOneWidget);
    expect(find.text('47 m left'), findsNothing);
  });

  testWidgets('plus and minus persist thirty-minute steps', (tester) async {
    final saved = <int?>[];
    await pumpBudget(
      tester,
      save: (value) async {
        saved.add(value);
        return null;
      },
    );

    await tester.tap(find.text('+'));
    await tester.pumpAndSettle();
    expect(saved, [270]);

    await tester.tap(find.text('−'));
    await tester.pumpAndSettle();
    expect(saved, [270, 240]);
  });

  testWidgets('zero can only increase and remains formatted as minutes', (
    tester,
  ) async {
    final saved = <int?>[];
    await pumpBudget(
      tester,
      limit: 0,
      remaining: 0,
      save: (value) async {
        saved.add(value);
        return null;
      },
    );
    expect(find.text('0 m'), findsWidgets);
    await tester.tap(find.text('−'));
    await tester.pumpAndSettle();
    expect(saved, isEmpty);
    await tester.tap(find.text('+'));
    await tester.pumpAndSettle();
    expect(saved, [30]);
  });

  testWidgets('private usage keeps the allowance and hides false totals', (
    tester,
  ) async {
    await pumpBudget(tester, limit: 90, available: false);
    expect(find.text('1 h 30 m'), findsOneWidget);
    expect(find.text('Usage is shown on your child’s device.'), findsOneWidget);
    expect(find.text('43 m used'), findsNothing);
  });

  testWidgets('save failure stays visible below the allowance card', (
    tester,
  ) async {
    await pumpBudget(
      tester,
      limit: 90,
      remaining: 47,
      save: (_) async => 'Could not save',
    );
    await tester.tap(find.text('+'));
    await tester.pumpAndSettle();
    expect(find.text('Could not save'), findsOneWidget);
  });

  for (final language in ['ru', 'uz']) {
    testWidgets('allowance is localized in $language', (tester) async {
      await pumpBudget(
        tester,
        limit: 90,
        remaining: 80,
        used: 10,
        language: language,
      );
      expect(find.text('Overall daily budget'), findsNothing);
      expect(
        find.text(language == 'ru' ? '1 ч 30 м' : '1 s 30 d'),
        findsOneWidget,
      );
    });
  }
}
