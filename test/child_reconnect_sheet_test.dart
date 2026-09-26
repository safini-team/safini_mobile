import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:safini/core/translation/generated/l10n.dart';
import 'package:safini/features/parent/presentation/screens/family/parent_family_view.dart';
import 'package:safini/features/parent/presentation/widgets/family/family_sheets.dart';

/// SAF-191: "Re-connect with a code" is offered for a paired child. The API
/// now issues that code and moves the profile to whichever phone claims it,
/// so the sheet has to say so before the parent hands the code over.
FamilyChildCard _card({required bool paired}) => FamilyChildCard(
  id: 'aziz',
  name: 'Aziz',
  age: 10,
  color: Colors.teal,
  level: 1,
  coins: 210,
  paired: paired,
);

Future<void> _openSheet(WidgetTester tester, FamilyChildCard card) async {
  await tester.pumpWidget(
    MaterialApp(
      localizationsDelegates: const [S.delegate],
      supportedLocales: S.delegate.supportedLocales,
      locale: const Locale('en'),
      home: Builder(
        builder: (context) => Scaffold(
          body: TextButton(
            onPressed: () => showChildSheet(
              context,
              child: card,
              onCreateCode: () async => (code: 'K7PQ', error: null),
            ),
            child: const Text('open'),
          ),
        ),
      ),
    ),
  );
  await tester.tap(find.text('open'));
  await tester.pumpAndSettle();
  await tester.tap(find.text('Re-connect with a code'));
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('a paired child\'s code says the profile moves over', (
    tester,
  ) async {
    await _openSheet(tester, _card(paired: true));
    expect(find.text('K7PQ'), findsOneWidget);
    expect(
      find.textContaining('Coins, tasks and history move'),
      findsOneWidget,
    );
  });

  testWidgets('a child not paired yet gets the plain instruction', (
    tester,
  ) async {
    await _openSheet(tester, _card(paired: false));
    expect(find.textContaining('Coins, tasks and history move'), findsNothing);
    expect(find.textContaining("Type it on Aziz's phone"), findsOneWidget);
  });
}
