import 'dart:ui' show SemanticsFlag;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:safini/core/utils/widgets/ds/ds_kid_stories.dart';
import 'package:safini/features/parent/presentation/cubit/home/home_cubit.dart';
import 'package:safini/features/models/domain/models/family_model.dart';
import 'package:safini/features/parent/presentation/widgets/family/oldest_first.dart';

const _kids = [
  DsStoryKid(id: 'amir', name: 'Amir', color: Color(0xFF1A5C4A)),
  DsStoryKid(
    id: 'laylo',
    name: 'Laylo',
    color: Color(0xFF2E6F8E),
    hasNews: true,
  ),
];

Future<void> _pump(
  WidgetTester tester, {
  String? selectedId,
  ValueChanged<String?>? onSelect,
  VoidCallback? onAdd,
}) async {
  await tester.pumpWidget(
    MaterialApp(
      home: Scaffold(
        body: DsKidStories(
          kids: _kids,
          selectedId: selectedId,
          everyoneLabel: 'Everyone',
          addLabel: 'Add',
          onSelect: onSelect ?? (_) {},
          onAdd: onAdd,
        ),
      ),
    ),
  );
}

void main() {
  testWidgets('Everyone comes first and Add last', (tester) async {
    await _pump(tester, onAdd: () {});

    final everyone = tester.getCenter(find.text('Everyone')).dx;
    final amir = tester.getCenter(find.text('Amir')).dx;
    final laylo = tester.getCenter(find.text('Laylo')).dx;
    final add = tester.getCenter(find.text('Add')).dx;
    expect(everyone < amir && amir < laylo && laylo < add, isTrue);
  });

  testWidgets('a tap selects that child, Everyone selects null', (
    tester,
  ) async {
    final picks = <String?>[];
    await _pump(tester, selectedId: 'amir', onSelect: picks.add);

    await tester.tap(find.text('Laylo'));
    await tester.tap(find.text('Everyone'));

    expect(picks, ['laylo', null]);
  });

  testWidgets('Add opens add-child, and is hidden without a handler', (
    tester,
  ) async {
    var opened = 0;
    await _pump(tester, onAdd: () => opened++);
    await tester.tap(find.text('Add'));
    expect(opened, 1);

    await _pump(tester);
    expect(find.text('Add'), findsNothing);
  });

  testWidgets('the selected child reads as selected to screen readers', (
    tester,
  ) async {
    final handle = tester.ensureSemantics();
    await _pump(tester, selectedId: 'amir');

    expect(
      tester.getSemantics(find.byKey(const ValueKey('kid-story-amir'))),
      matchesSemantics(
        label: 'Amir',
        isButton: true,
        hasSelectedState: true,
        isSelected: true,
        isInMutuallyExclusiveGroup: true,
        hasTapAction: true,
      ),
    );
    expect(
      tester.getSemantics(find.byKey(const ValueKey('kid-story-everyone'))),
      matchesSemantics(
        label: 'Everyone',
        isButton: true,
        hasSelectedState: true,
        isSelected: false,
        isInMutuallyExclusiveGroup: true,
        hasTapAction: true,
        identifier: 'kid.everyone',
      ),
    );
    handle.dispose();
  });

  testWidgets('touch targets are at least 44pt', (tester) async {
    await _pump(tester, onAdd: () {});

    for (final key in ['everyone', 'amir', 'laylo', 'add']) {
      final size = tester.getSize(find.byKey(ValueKey('kid-story-$key')));
      expect(size.width, greaterThanOrEqualTo(44), reason: key);
      expect(size.height, greaterThanOrEqualTo(44), reason: key);
    }
  });

  testWidgets('a child with something waiting gets a dot', (tester) async {
    await _pump(tester);

    expect(find.byKey(const ValueKey('kid-story-dot')), findsOneWidget);
    expect(
      find.descendant(
        of: find.byKey(const ValueKey('kid-story-laylo')),
        matching: find.byKey(const ValueKey('kid-story-dot')),
      ),
      findsOneWidget,
    );
  });

  testWidgets('an unknown id falls back to Everyone', (tester) async {
    final handle = tester.ensureSemantics();
    await _pump(tester, selectedId: 'gone');

    expect(
      tester
          .getSemantics(find.byKey(const ValueKey('kid-story-everyone')))
          .hasFlag(SemanticsFlag.isSelected),
      isTrue,
    );
    handle.dispose();
  });

  testWidgets('without Everyone, nobody picked selects the first child', (
    tester,
  ) async {
    final handle = tester.ensureSemantics();
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: DsKidStories(
            kids: _kids,
            selectedId: null,
            showEveryone: false,
            everyoneLabel: 'Everyone',
            addLabel: 'Add',
            onSelect: (_) {},
          ),
        ),
      ),
    );

    expect(find.text('Everyone'), findsNothing);
    expect(
      tester
          .getSemantics(find.byKey(const ValueKey('kid-story-amir')))
          .hasFlag(SemanticsFlag.isSelected),
      isTrue,
    );
    handle.dispose();
  });

  test('children are ordered oldest first, ties keep the family order', () {
    ChildSummaryModel kid(String id, int age) => ChildSummaryModel(
      id: id,
      nickname: id,
      age: age,
      coinsBalance: 0,
      level: 1,
    );

    final order = oldestFirst([
      kid('amir', 8),
      kid('laylo', 12),
      kid('timur', 8),
      kid('sara', 15),
    ]).map((kid) => kid.id);

    expect(order, ['sara', 'laylo', 'amir', 'timur']);
  });

  test('the selection survives a tab switch', () {
    final home = ParentHomeCubit()..selectChild('laylo');

    home.selectTab(2);
    home.selectTab(1);

    expect(home.state.selectedChildId, 'laylo');
    home.close();
  });
}
