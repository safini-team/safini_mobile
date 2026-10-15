import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:safini/core/translation/generated/l10n.dart';
import 'package:safini/features/fini/demo/fini_demo.dart';
import 'package:safini/features/fini/demo/fini_demo_repository.dart';
import 'package:safini/features/fini/domain/fini_models.dart';
import 'package:safini/features/fini/presentation/cubit/fini_cubit.dart';
import 'package:safini/features/fini/presentation/fini_copy.dart';
import 'package:safini/features/fini/presentation/screens/fini_goal_screen.dart';
import 'package:safini/features/parent/presentation/screens/monitor/parent_today_view.dart'
    show formatHm;

/// The demo's running plan, with the games goal on an iPhone instead.
class _IphoneRepo extends FiniDemoRepository {
  _IphoneRepo() : super(FiniDemoState.runningPlan);

  @override
  Future<List<FiniGoal>> goals(String childId) async => [
    for (final goal in await super.goals(childId))
      if (goal.intent == GoalIntent.games)
        FiniGoal(
          id: goal.id,
          childId: goal.childId,
          kind: goal.kind,
          intent: goal.intent,
          minutesPerDay: 45,
          currentMinutes: 45,
          plan: const FiniPlan(
            phase: FiniPlanPhase.atTarget,
            platform: 'ios',
            currentMinutes: 45,
          ),
        )
      else
        goal,
  ];
}

Future<FiniCubit> _pump(
  WidgetTester tester,
  String goalId, {
  FiniDemoRepository? repo,
}) async {
  final cubit = FiniCubit(
    repo ?? FiniDemoRepository(FiniDemoState.runningPlan),
  );
  await cubit.load('amir');
  tester.view.physicalSize = const Size(1170, 2532);
  tester.view.devicePixelRatio = 3;
  addTearDown(tester.view.reset);
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
        child: FiniGoalScreen(goalId: goalId, childName: 'Amir'),
      ),
    ),
  );
  await tester.pumpAndSettle();
  return cubit;
}

String _planText(WidgetTester tester) =>
    tester.widget<Text>(find.byKey(const ValueKey('goal-plan-text'))).data!;

void main() {
  testWidgets('a stepping plan shows the weeks ahead and can jump', (
    tester,
  ) async {
    final cubit = await _pump(tester, 'amir-games');
    final s = S.current;
    expect(
      _planText(tester),
      s.goalPlanStepping(formatHm(s, 98), formatHm(s, 74), 3),
    );
    expect(find.text('98'), findsOneWidget);
    expect(find.text('45'), findsOneWidget);

    await tester.ensureVisible(find.byKey(const ValueKey('goal-jump')));
    await tester.tap(find.byKey(const ValueKey('goal-jump')));
    await tester.pumpAndSettle();
    final games = cubit.state.goals.firstWhere((g) => g.id == 'amir-games');
    expect(games.currentMinutes, 45);
    expect(_planText(tester), s.goalPlanAtTarget(formatHm(s, 45)));
    expect(find.byKey(const ValueKey('goal-jump')), findsNothing);
  });

  testWidgets('watching counts the days', (tester) async {
    await _pump(tester, 'amir-scrolling');
    expect(_planText(tester), S.current.goalPlanWatchingDays(3, 3, 'Amir'));
    expect(find.byKey(const ValueKey('goal-jump')), findsNothing);
  });

  testWidgets('an iPhone says why there are no steps and hides the pace', (
    tester,
  ) async {
    await _pump(tester, 'amir-games', repo: _IphoneRepo());
    final s = S.current;
    expect(_planText(tester), s.goalPlanIphone(formatHm(s, 45)));
    expect(find.text(s.paceSteady), findsNothing);
    expect(find.byKey(const ValueKey('goal-jump')), findsNothing);
  });

  group('plan lines in the parent language', () {
    late S s;
    setUp(() async => s = await S.load(const Locale('ru')));

    FiniProposal change(Map<String, dynamic> plan, {String reason = 'en'}) =>
        FiniProposal(
          id: 'p',
          childId: 'amir',
          kind: 'rule_change',
          status: FiniProposalStatus.pending,
          reason: reason,
          createdAt: DateTime(2026, 10, 19),
          payload: {'goal_id': 'g', 'daily_limit_minutes': plan['to']},
          evidence: {'plan': plan},
        );

    test('a step, a start, a jump and an ease are said from the numbers', () {
      final step = change({
        'action': 'step',
        'intent': 'games',
        'from': 120,
        'to': 90,
        'target': 45,
      });
      expect(
        finiReasonLine(s, step),
        s.planLineStep(formatHm(s, 120), formatHm(s, 90), formatHm(s, 45)),
      );
      expect(
        finiActivityTitle(s, step, childName: 'Amir'),
        s.finiDidLimit(s.goalGames, formatHm(s, 90)),
      );
      expect(
        finiReasonLine(
          s,
          change({'action': 'start', 'why': 'watched', 'to': 118}),
        ),
        s.planLineStart(formatHm(s, 118)),
      );
      expect(
        finiReasonLine(
          s,
          change({'action': 'jump', 'why': 'parent', 'to': 45}),
        ),
        s.planLineJumped(formatHm(s, 45)),
      );
      final ease = change({
        'action': 'ease',
        'intent': 'games',
        'from': 90,
        'to': 120,
      });
      expect(
        finiReasonLine(s, ease),
        s.planLineEase(formatHm(s, 90), formatHm(s, 120)),
      );
      // Easing off is a raise, and the card says so.
      expect(
        finiCardTitle(s, ease, childName: 'Amir'),
        s.finiAskRaiseLimit(s.goalGames, formatHm(s, 120)),
      );
    });

    test('anything without plan numbers shows the reason as sent', () {
      final other = FiniProposal(
        id: 'p',
        childId: 'amir',
        kind: 'task_review',
        status: FiniProposalStatus.pending,
        reason: '12 min in Duolingo',
        createdAt: DateTime(2026, 10, 19),
      );
      expect(finiReasonLine(s, other), '12 min in Duolingo');
    });
  });
}
