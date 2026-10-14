import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:safini/core/theme/app_theme.dart';
import 'package:safini/core/utils/qa_ids.dart';
import 'package:safini/core/utils/widgets/ds/ds_tab_bar.dart';
import 'package:safini/core/utils/widgets/language_sheet.dart';

/// The screenshot scripts in `tool/screenshots/` find elements by these ids,
/// so a renamed id has to fail here rather than in a half-captured run.
void main() {
  testWidgets('a tab is found and tapped by its id', (tester) async {
    int? tapped;
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: Scaffold(
          bottomNavigationBar: DsTabBar(
            currentIndex: 0,
            onTap: (i) => tapped = i,
            items: [
              for (final id in [
                QaIds.navToday,
                QaIds.navTasks,
                QaIds.navLimits,
                QaIds.navFamily,
              ])
                DsTabItem(
                  label: id,
                  semanticsId: id,
                  builder: (color) => Icon(Icons.circle, color: color),
                ),
            ],
          ),
        ),
      ),
    );

    expect(find.bySemanticsIdentifier(QaIds.navToday), findsOneWidget);
    await tester.tap(find.bySemanticsIdentifier(QaIds.navLimits));
    expect(tapped, 2);
  });

  test('ids are unique', () {
    final all = [
      ...QaIds.fixed,
      for (final l in appLanguages) QaIds.language(l.code),
    ];
    expect(all.toSet().length, all.length);
  });

  test('every id the Maestro flows use exists', () {
    final known = {
      ...QaIds.fixed,
      for (final l in appLanguages) QaIds.language(l.code),
    };
    final flows = Directory('tool/screenshots/maestro')
        .listSync(recursive: true)
        .whereType<File>()
        .where((f) => f.path.endsWith('.yaml'));
    expect(flows, isNotEmpty);
    final idPattern = RegExp(r'''id:\s*["']?([a-z][\w.]*)["']?''');
    for (final flow in flows) {
      for (final m in idPattern.allMatches(flow.readAsStringSync())) {
        final id = m.group(1)!;
        // `lang.${LANG}` style ids are filled in by the runner.
        if (id.endsWith('.')) continue;
        expect(known, contains(id), reason: '${flow.path} uses "$id"');
      }
    }
  });

  test('every id the screen paths in shoot.py tap exists', () {
    final script = File('tool/screenshots/shoot.py').readAsStringSync();
    final table = RegExp(
      r'SCREENS = \{([^}]*)\}',
    ).firstMatch(script)!.group(1)!;
    final paths = RegExp(r'"[\w-]+":\s*"([^"]+)"').allMatches(table).toList();
    expect(paths, isNotEmpty);
    for (final m in paths) {
      for (final id in m.group(1)!.split(' ')) {
        expect(QaIds.fixed, contains(id), reason: 'shoot.py taps "$id"');
      }
    }
  });
}
