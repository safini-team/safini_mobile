import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:safini/core/utils/widgets/ds/ds_kid_picker.dart';

const _amir = DsPickerOption(
  key: 'amir',
  label: 'Amir',
  color: Color(0xFF1A5C4A),
);
const _layla = DsPickerOption(
  key: 'layla',
  label: 'Layla',
  color: Color(0xFF2E6F8E),
);
const _frka = DsPickerOption(
  key: 'frka',
  label: 'Frka',
  color: Color(0xFF9C4F6B),
);

Future<void> _pumpPicker(
  WidgetTester tester, {
  required String selectedKey,
  required List<DsPickerOption> options,
}) async {
  await tester.pumpWidget(
    MaterialApp(
      home: Scaffold(
        body: DsKidPicker(
          selectedKey: selectedKey,
          options: options,
          onSelect: (_) {},
        ),
      ),
    ),
  );
  await tester.pump();
}

Finder _chipBadge() => find.byKey(const ValueKey('kid-picker-chip-badge'));
Finder _rowBadge(String childId) =>
    find.byKey(ValueKey('kid-picker-row-badge-$childId'));

void main() {
  testWidgets('chip badge is hidden when other children have 0 pending', (
    tester,
  ) async {
    await _pumpPicker(
      tester,
      selectedKey: 'amir',
      options: [
        DsPickerOption(
          key: _amir.key,
          label: _amir.label,
          color: _amir.color,
          badge: 4,
        ),
        DsPickerOption(
          key: _layla.key,
          label: _layla.label,
          color: _layla.color,
        ),
      ],
    );

    expect(_chipBadge(), findsNothing);
    expect(find.text('4'), findsNothing);
    expect(find.text('0'), findsNothing);

    await tester.tap(find.text('Amir'));
    await tester.pumpAndSettle();

    expect(_rowBadge('layla'), findsNothing);
    expect(_rowBadge('amir'), findsNothing);
  });

  testWidgets('chip count excludes the selected child', (tester) async {
    await _pumpPicker(
      tester,
      selectedKey: 'amir',
      options: [
        DsPickerOption(
          key: _amir.key,
          label: _amir.label,
          color: _amir.color,
          badge: 5,
        ),
        DsPickerOption(
          key: _layla.key,
          label: _layla.label,
          color: _layla.color,
          badge: 2,
        ),
        DsPickerOption(
          key: _frka.key,
          label: _frka.label,
          color: _frka.color,
          badge: 1,
        ),
      ],
    );

    expect(tester.widget<DsAttentionBadge>(_chipBadge()).count, 3);
    expect(find.text('3'), findsOneWidget);
    expect(find.text('5'), findsNothing);
    expect(find.text('8'), findsNothing);

    await tester.tap(find.text('Amir'));
    await tester.pumpAndSettle();

    expect(_rowBadge('amir'), findsNothing);
    expect(tester.widget<DsAttentionBadge>(_rowBadge('layla')).count, 2);
    expect(tester.widget<DsAttentionBadge>(_rowBadge('frka')).count, 1);
  });

  testWidgets('chip and rows cap the label at 9+', (tester) async {
    await _pumpPicker(
      tester,
      selectedKey: 'amir',
      options: [
        DsPickerOption(
          key: _amir.key,
          label: _amir.label,
          color: _amir.color,
          badge: 2,
        ),
        DsPickerOption(
          key: _layla.key,
          label: _layla.label,
          color: _layla.color,
          badge: 12,
        ),
      ],
    );

    expect(tester.widget<DsAttentionBadge>(_chipBadge()).count, 12);
    expect(find.text('9+'), findsOneWidget);
    expect(find.text('12'), findsNothing);

    await tester.tap(find.text('Amir'));
    await tester.pumpAndSettle();

    expect(find.text('9+'), findsNWidgets(2));
    expect(_rowBadge('layla'), findsOneWidget);
  });
}
