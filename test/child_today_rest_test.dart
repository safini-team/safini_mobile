import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:safini/core/theme/app_theme.dart';
import 'package:safini/core/translation/generated/l10n.dart';
import 'package:safini/features/child/presentation/screens/home/child_today_view.dart';

/// Today used to call every empty day "Everything is with your parent", so a
/// child whose tasks had already been approved and paid was still told the
/// parent had them. And the card's hold-to-send skipped the photo the parent
/// asked for, which the sheet refuses to do.
ChildTodayData _data({
  int questsDone = 0,
  int questsTotal = 2,
  int awaiting = 0,
  TodayQuest? next,
  bool loadFailed = false,
}) {
  return ChildTodayData(
    greeting: 'Good evening',
    name: 'Amir',
    coins: 25,
    questsDone: questsDone,
    questsTotal: questsTotal,
    questsAwaitingReview: awaiting,
    openCoins: 50,
    next: next,
    holdToComplete: true,
    loadFailed: loadFailed,
  );
}

const _photoQuest = TodayQuest(
  id: 't1',
  title: 'Read for 20 mins',
  meta: '35 coins reward',
  emoji: '📚',
  coins: 35,
  needsPhoto: true,
);

const _plainQuest = TodayQuest(
  id: 't2',
  title: 'Tidy the room',
  meta: '15 coins reward',
  emoji: '🧹',
  coins: 15,
);

Widget _host(Widget child) => MaterialApp(
  theme: AppTheme.light,
  locale: const Locale('en'),
  localizationsDelegates: const [
    S.delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
  ],
  supportedLocales: S.delegate.supportedLocales,
  home: child,
);

void main() {
  group('rest', () {
    test('is "with your parent" only while something waits for review', () {
      expect(_data(awaiting: 2).rest, TodayRest.withParent);
    });

    test('is "all done" once every task is approved', () {
      expect(_data(questsDone: 2).rest, TodayRest.allDone);
    });

    test('is empty when the day has no tasks at all', () {
      expect(_data(questsTotal: 0).rest, TodayRest.empty);
    });

    test('is offline, not empty, when the tasks could not load', () {
      expect(_data(questsTotal: 0, loadFailed: true).rest, TodayRest.offline);
      expect(_data(questsDone: 2, loadFailed: true).rest, TodayRest.allDone);
    });
  });

  testWidgets('a failed load never tells the child the day is empty', (
    tester,
  ) async {
    await tester.pumpWidget(
      _host(
        ChildTodayView(
          data: _data(questsTotal: 0, loadFailed: true),
          onOpenStore: () {},
          onOpenTasks: () {},
          onOpenQuest: (_) {},
          onSendQuest: (_) {},
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('No connection'), findsWidgets);
    expect(find.text('Nothing for today'), findsNothing);
    expect(find.text('Nothing left'), findsNothing);
  });

  testWidgets('an approved day says so instead of blaming the parent', (
    tester,
  ) async {
    await tester.pumpWidget(
      _host(
        ChildTodayView(
          data: _data(questsDone: 2),
          onOpenStore: () {},
          onOpenTasks: () {},
          onOpenQuest: (_) {},
          onSendQuest: (_) {},
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('All done today'), findsWidgets);
    expect(find.text('Everything is with your parent'), findsNothing);
  });

  testWidgets('a day still under review keeps the parent copy', (tester) async {
    await tester.pumpWidget(
      _host(
        ChildTodayView(
          data: _data(awaiting: 2),
          onOpenStore: () {},
          onOpenTasks: () {},
          onOpenQuest: (_) {},
          onSendQuest: (_) {},
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Everything is with your parent'), findsOneWidget);
    expect(find.text("Everything's sent"), findsOneWidget);
  });

  testWidgets('an open task keeps the hero on what is left to earn', (
    tester,
  ) async {
    await tester.pumpWidget(
      _host(
        ChildTodayView(
          data: _data(next: _plainQuest, awaiting: 1),
          onOpenStore: () {},
          onOpenTasks: () {},
          onOpenQuest: (_) {},
          onSendQuest: (_) {},
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.textContaining('50 coins'), findsWidgets);
    expect(find.text('Everything is with your parent'), findsNothing);
  });

  testWidgets('a photo task opens the sheet instead of sending itself', (
    tester,
  ) async {
    var sent = 0;
    var opened = 0;
    await tester.pumpWidget(
      _host(
        ChildTodayView(
          data: _data(next: _photoQuest),
          onOpenStore: () {},
          onOpenTasks: () {},
          onOpenQuest: (_) => opened++,
          onSendQuest: (_) => sent++,
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Add a photo'), findsOneWidget);
    await tester.tap(find.text('Add a photo'));
    await tester.pumpAndSettle();

    expect(opened, 1);
    expect(sent, 0);
  });

  testWidgets('a task without proof still sends on a hold', (tester) async {
    var sent = 0;
    await tester.pumpWidget(
      _host(
        ChildTodayView(
          data: _data(next: _plainQuest),
          onOpenStore: () {},
          onOpenTasks: () {},
          onOpenQuest: (_) {},
          onSendQuest: (_) => sent++,
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Hold to mark it done'), findsOneWidget);
    final gesture = await tester.startGesture(
      tester.getCenter(find.text('Hold to mark it done')),
    );
    // The fill runs on a controller, so let the frames tick while held.
    for (var i = 0; i < 16; i++) {
      await tester.pump(const Duration(milliseconds: 100));
    }
    await gesture.up();
    await tester.pumpAndSettle();

    expect(sent, 1);
  });
}
