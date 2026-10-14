import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:safini/core/translation/generated/l10n.dart';
import 'package:safini/features/fini/demo/fini_demo.dart';
import 'package:safini/features/fini/demo/fini_demo_repository.dart';
import 'package:safini/features/fini/domain/fini_models.dart';
import 'package:safini/features/fini/presentation/cubit/fini_cubit.dart';
import 'package:safini/features/fini/presentation/screens/fini_add_goal_sheet.dart';

Future<FiniCubit> _pump(WidgetTester tester, FiniDemoState state) async {
  final cubit = FiniCubit(FiniDemoRepository(state));
  await cubit.load('amir');
  await tester.pumpWidget(
    MaterialApp(
      localizationsDelegates: const [
        S.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: S.delegate.supportedLocales,
      home: BlocProvider.value(
        value: cubit,
        child: Scaffold(
          body: Builder(
            builder: (context) => TextButton(
              onPressed: () => showAddGoalSheet(context, childName: 'Amir'),
              child: const Text('open'),
            ),
          ),
        ),
      ),
    ),
  );
  await tester.tap(find.text('open'));
  await tester.pumpAndSettle();
  return cubit;
}

void main() {
  testWidgets('goals already set read "Added" and do nothing on tap', (
    tester,
  ) async {
    final cubit = await _pump(tester, FiniDemoState.runningPlan);
    final s = S.current;
    expect(find.text(s.goalAdded), findsNWidgets(4));

    await tester.tap(find.byKey(const ValueKey('goal-tile-games')));
    await tester.pumpAndSettle();
    expect(cubit.state.goals, hasLength(4));
    expect(find.text(s.finiAddGoalFor('Amir')), findsOneWidget);
  });

  testWidgets('one tap adds a goal and closes the sheet', (tester) async {
    final cubit = await _pump(tester, FiniDemoState.androidChildWithUsage);
    expect(find.text(S.current.goalAdded), findsNothing);

    await tester.tap(find.byKey(const ValueKey('goal-tile-games')));
    await tester.pumpAndSettle();
    expect(cubit.state.addedIntents, {GoalIntent.games});
    expect(find.text(S.current.finiAddGoalFor('Amir')), findsNothing);
  });

  testWidgets('video is coming soon and cannot be added', (tester) async {
    final cubit = await _pump(tester, FiniDemoState.androidChildWithUsage);
    await tester.ensureVisible(find.byKey(const ValueKey('goal-tile-video')));
    await tester.tap(find.byKey(const ValueKey('goal-tile-video')));
    await tester.pumpAndSettle();
    expect(cubit.state.goals, isEmpty);
  });
}
