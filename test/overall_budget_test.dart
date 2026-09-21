import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:safini/core/translation/generated/l10n.dart';
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

  testWidgets('off shows usage without any remaining allowance', (
    tester,
  ) async {
    await pumpBudget(tester);
    expect(find.text('Off'), findsOneWidget);
    expect(find.text('43 m'), findsOneWidget);
    expect(find.text('Remaining'), findsNothing);
  });
  testWidgets('server remaining is used even when not limit minus usage', (
    tester,
  ) async {
    await pumpBudget(tester, limit: 90, remaining: 21);
    expect(find.text('1 h 30 m'), findsOneWidget);
    expect(find.text('21 m'), findsOneWidget);
    expect(find.text('47 m'), findsNothing);
  });
  testWidgets('zero is an exhausted budget, including with private usage', (
    tester,
  ) async {
    await pumpBudget(tester, limit: 0, remaining: 0, available: false);
    expect(find.text('No free time'), findsOneWidget);
    expect(
      find.text('Managed apps are paused until the daily reset.'),
      findsOneWidget,
    );
    expect(find.text('43 m'), findsNothing);
  });
  testWidgets('private usage still displays the configured budget', (
    tester,
  ) async {
    await pumpBudget(tester, limit: 90, available: false);
    expect(find.text('1 h 30 m'), findsOneWidget);
    expect(find.text('Usage is shown on your child’s device.'), findsOneWidget);
    expect(find.text('Remaining'), findsNothing);
  });
  testWidgets(
    'switch requires save; cancel makes no write; zero can be saved',
    (tester) async {
      final saved = <int?>[];
      await pumpBudget(
        tester,
        save: (value) async {
          saved.add(value);
          return null;
        },
      );
      await tester.tap(find.byType(Switch));
      await tester.pumpAndSettle();
      expect(saved, isEmpty);
      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();
      expect(saved, isEmpty);
      await tester.tap(find.byType(Switch));
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextFormField), '0');
      await tester.tap(find.text('Save'));
      await tester.pumpAndSettle();
      expect(saved, [0]);
    },
  );
  testWidgets('removing a budget sends null and failures keep editor open', (
    tester,
  ) async {
    final saved = <int?>[];
    await pumpBudget(
      tester,
      limit: 90,
      save: (value) async {
        saved.add(value);
        return 'Could not save';
      },
    );
    await tester.tap(find.byType(Switch));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();
    expect(saved, [null]);
    expect(find.text('Could not save'), findsOneWidget);
    expect(find.byType(AlertDialog), findsOneWidget);
  });
  testWidgets('invalid duration never saves', (tester) async {
    final saved = <int?>[];
    await pumpBudget(
      tester,
      save: (value) async {
        saved.add(value);
        return null;
      },
    );
    await tester.tap(find.byType(Switch));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextFormField), '1441');
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();
    expect(saved, isEmpty);
    expect(find.text('Enter a whole number from 0 to 1440.'), findsOneWidget);
  });
  for (final language in ['ru', 'uz']) {
    testWidgets('budget is localized in $language', (tester) async {
      await pumpBudget(
        tester,
        limit: 15,
        remaining: 5,
        used: 10,
        language: language,
      );
      expect(find.text('Overall daily budget'), findsNothing);
      expect(
        find.text(
          language == 'ru' ? 'Общий дневной лимит' : 'Umumiy kunlik limit',
        ),
        findsOneWidget,
      );
    });
  }
}
