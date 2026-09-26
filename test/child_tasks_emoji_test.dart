import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:safini/core/translation/generated/l10n.dart';
import 'package:safini/features/child/presentation/screens/tasks/child_tasks_view.dart';

/// The kid's Tasks list dropped the icon the parent picked for each task, so
/// every row started with the same empty circle (SAF-191).
void main() {
  testWidgets('each task row shows its icon', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: const [S.delegate],
        supportedLocales: S.delegate.supportedLocales,
        locale: const Locale('en'),
        home: ChildTasksView(
          data: const ChildTasksData(
            done: 0,
            total: 2,
            pendingCoins: 0,
            categories: [],
            rows: [
              ChildTaskRow(
                id: 'bed',
                title: 'Make the bed',
                meta: '',
                coins: 10,
                state: ChildTaskState.open,
                emoji: '🛏️',
              ),
              ChildTaskRow(
                id: 'plain',
                title: 'Water the plants',
                meta: '',
                coins: 5,
                state: ChildTaskState.sent,
              ),
            ],
            emptyMessage: '',
          ),
          onSelectCategory: (_) {},
          onOpenTask: (_) {},
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('🛏️'), findsOneWidget);
    expect(find.text(defaultTaskEmoji), findsOneWidget);
  });
}
