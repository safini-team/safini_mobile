import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:safini/core/translation/generated/l10n.dart';
import 'package:safini/core/utils/widgets/ds/ds.dart';
import 'package:safini/features/parent/presentation/screens/monitor/parent_today_view.dart';

void main() {
  testWidgets('Today relies on the selector for identity and brands coins', (
    tester,
  ) async {
    const data = ParentTodayData(
      kids: [TodayKid(id: 'c1', name: 'Amir', color: Color(0xFF1A5C4A))],
      selectedIndex: 0,
      kidName: 'Amir',
      usedMinutes: 10,
      limitMinutes: 240,
      remainingMinutes: 230,
      topApp: 'Roblox',
      tasksDone: 0,
      tasksTotal: 2,
      coins: 100,
      streakDays: 2,
      reviews: [],
      apps: [],
    );

    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: const [
          S.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: S.delegate.supportedLocales,
        home: ParentTodayView(
          data: data,
          onSelectKid: (_) {},
          onOpenSettings: () {},
          onOpenReview: (_) {},
          onApproveReview: (_) {},
          onOpenLimits: () {},
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Amir'), findsOneWidget);
    expect(find.text('3 h 50 m left'), findsOneWidget);
    expect(find.textContaining('Amir has'), findsNothing);
    expect(find.byType(DsCoinToken), findsOneWidget);
  });
}
