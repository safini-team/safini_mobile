import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:safini/core/translation/generated/l10n.dart';
import 'package:safini/features/fini/demo/fini_demo.dart';
import 'package:safini/features/fini/demo/fini_demo_repository.dart';
import 'package:safini/features/fini/domain/fini_goal_specs.dart';
import 'package:safini/features/fini/domain/fini_models.dart';
import 'package:safini/features/fini/onboarding/fini_onboarding.dart';
import 'package:safini/features/fini/onboarding/fini_onboarding_cubit.dart';
import 'package:safini/features/fini/onboarding/fini_onboarding_page.dart';

final _order = [for (final spec in goalIntentSpecs) spec.intent];

FiniOnboarding _picked(List<GoalIntent> picked, {int age = 9}) =>
    FiniOnboarding(step: OnboardingStep.goals, picked: picked, age: age);

void main() {
  group('which boards show', () {
    test('A, B, C, D, E in order when a goal has numbers', () {
      var data = _picked([
        GoalIntent.games,
      ]).copyWith(step: OnboardingStep.child);
      final seen = <OnboardingStep>[data.step];
      while (data.next != null) {
        data = data.copyWith(step: data.next);
        seen.add(data.step);
      }
      expect(seen, OnboardingStep.values);
    });

    test('C is skipped when only learning apps were picked', () {
      final data = _picked([GoalIntent.learning]);
      expect(data.tuned, isEmpty);
      expect(data.next, OnboardingStep.plan);
      expect(
        data.copyWith(step: OnboardingStep.plan).previous,
        OnboardingStep.goals,
      );
    });

    test('C shows only what was picked', () {
      final data = _picked([
        GoalIntent.learning,
        GoalIntent.games,
        GoalIntent.bedtime,
        GoalIntent.homework,
      ]);
      expect(data.tuned, [
        GoalIntent.games,
        GoalIntent.bedtime,
        GoalIntent.homework,
      ]);
      expect(tuneKindFor(GoalIntent.games), TuneKind.minutes);
      expect(tuneKindFor(GoalIntent.bedtime), TuneKind.window);
      expect(tuneKindFor(GoalIntent.homework), TuneKind.homework);
    });

    test('Back never reopens A once the child exists', () {
      final data = _picked([GoalIntent.games]);
      expect(data.previous, OnboardingStep.child);
      expect(data.copyWith(childId: 'c1').previous, isNull);
    });
  });

  group('age-band defaults', () {
    test('younger children start lower and sleep earlier', () {
      expect(AgeDefaults.forAge(5).gamesMinutes, 30);
      expect(AgeDefaults.forAge(8).bedtime, const FiniTime(20, 30));
      expect(AgeDefaults.forAge(9).gamesMinutes, 45);
      expect(AgeDefaults.forAge(9).scrollingMinutes, 60);
      expect(AgeDefaults.forAge(12).bedtime, const FiniTime(21, 30));
      expect(AgeDefaults.forAge(13).gamesMinutes, 90);
      expect(AgeDefaults.forAge(16).bedtime, const FiniTime(22, 30));
    });

    test('board C starts from the band, and a value set wins', () {
      final data = _picked([GoalIntent.games, GoalIntent.bedtime], age: 7);
      expect(data.minutesFor(GoalIntent.games), 30);
      expect(data.windowFor(GoalIntent.bedtime).$1, const FiniTime(20, 30));
      final set = data.copyWith(minutes: {GoalIntent.games: 75});
      expect(set.minutesFor(GoalIntent.games), 75);
    });
  });

  group('what we POST', () {
    test('one body per picked goal, with the numbers from C', () {
      final bodies =
          _picked([
                GoalIntent.games,
                GoalIntent.scrolling,
                GoalIntent.homework,
                GoalIntent.bedtime,
                GoalIntent.learning,
              ])
              .copyWith(
                minutes: {GoalIntent.games: 60},
                windows: {
                  GoalIntent.bedtime: (
                    const FiniTime(21, 0),
                    const FiniTime(6, 30),
                  ),
                },
              )
              .goalBodies();

      expect(bodies, [
        {
          'kind': 'category_budget',
          'target': {
            'intent': 'games',
            'categories': ['games'],
          },
          'minutes_per_day': 60,
          'pace': 'steady',
        },
        {
          'kind': 'group_budget',
          'target': {
            'intent': 'scrolling',
            'categories': ['social', 'short_video'],
          },
          'minutes_per_day': 60,
          'pace': 'steady',
        },
        {
          'kind': 'task_gate',
          'target': {'intent': 'homework'},
          'pace': 'gentle',
        },
        {
          'kind': 'schedule_window',
          'target': {'intent': 'bedtime'},
          'window_start': '21:00:00',
          'window_end': '06:30:00',
          'pace': 'gentle',
        },
        {
          'kind': 'exempt',
          'target': {
            'intent': 'learning',
            'categories': ['education'],
          },
          'pace': 'gentle',
        },
      ]);
    });

    test('coming-soon goals are never sent', () {
      expect(_picked([GoalIntent.video]).goalBodies(), isEmpty);
    });
  });

  group('FiniOnboardingCubit', () {
    late FiniDemoRepository repo;
    final created = <Map<String, Object?>>[];

    FiniOnboardingCubit cubit({FiniOnboarding? resume, Object? fail}) =>
        FiniOnboardingCubit(
          repo: repo,
          resume: resume,
          createChild: ({required name, required age, gender}) async {
            if (fail != null) throw fail;
            created.add({'name': name, 'age': age, 'gender': gender});
            return 'new-child';
          },
        );

    setUp(() {
      repo = FiniDemoRepository(FiniDemoState.androidChildWithUsage);
      created.clear();
    });

    test('A creates the child once, D saves the goals', () async {
      final c = cubit()
        ..setName(' Amir ')
        ..setAge(16)
        ..setPhone(ChildPhone.iphone)
        ..setGender('boy');
      expect(await c.next(), isFalse);
      expect(created, [
        {'name': 'Amir', 'age': 16, 'gender': 'boy'},
      ]);
      expect(c.state.data.step, OnboardingStep.goals);

      c.toggleGoal(GoalIntent.bedtime, _order);
      c.toggleGoal(GoalIntent.games, _order);
      expect(c.state.data.picked, [GoalIntent.games, GoalIntent.bedtime]);
      await c.next();
      expect(c.state.data.step, OnboardingStep.tune);
      await c.next();
      expect(c.state.data.step, OnboardingStep.plan);
      await c.next();
      expect(c.state.data.step, OnboardingStep.trial);

      final goals = await repo.goals('new-child');
      expect(goals.map((g) => g.intent), [
        GoalIntent.games,
        GoalIntent.bedtime,
      ]);
      expect(goals.first.minutesPerDay, 90, reason: '16+ is the 13-16 band');
      expect(await c.next(), isTrue, reason: 'E ends the flow');
    });

    test('a resumed flow never doubles a goal the child has', () async {
      await repo.createGoal('c1', specFor(GoalIntent.games).createBody());
      final c = cubit(
        resume: const FiniOnboarding(
          step: OnboardingStep.goals,
          childId: 'c1',
          name: 'Amir',
        ),
      );
      c.toggleGoal(GoalIntent.games, _order);
      c.toggleGoal(GoalIntent.learning, _order);
      c.changeLimits();
      await c.next();
      await c.next();
      expect(c.state.data.step, OnboardingStep.trial);
      expect((await repo.goals('c1')).map((g) => g.intent), [
        GoalIntent.games,
        GoalIntent.learning,
      ]);
      expect(created, isEmpty);
    });

    test('a failed create stays on A and says why', () async {
      final c = cubit(fail: 'Name taken')
        ..setName('Amir')
        ..setPhone(ChildPhone.android);
      await c.next();
      expect(c.state.data.step, OnboardingStep.child);
      expect(c.state.error, 'Name taken');
    });

    test('a free-plan limit shows its own sheet, no message here', () async {
      final c = cubit(fail: const QuietFailure())
        ..setName('Amir')
        ..setPhone(ChildPhone.android);
      await c.next();
      expect(c.state.data.step, OnboardingStep.child);
      expect(c.state.error, isNull);
    });

    test('B needs at least one goal', () async {
      final c = cubit(
        resume: const FiniOnboarding(
          step: OnboardingStep.goals,
          childId: 'c1',
          name: 'Amir',
        ),
      );
      await c.next();
      expect(c.state.data.step, OnboardingStep.goals);
    });
  });

  group('board A', () {
    Future<FiniOnboardingCubit> pump(WidgetTester tester) async {
      tester.view.physicalSize = const Size(1170, 2532);
      tester.view.devicePixelRatio = 3;
      addTearDown(tester.view.reset);
      final c = FiniOnboardingCubit(
        repo: FiniDemoRepository(FiniDemoState.androidChildWithUsage),
        createChild: ({required name, required age, gender}) async => 'id',
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
          home: BlocProvider.value(
            value: c,
            child: FiniOnboardingFlow(onDone: () {}, onLeave: () {}),
          ),
        ),
      );
      await tester.pump(const Duration(milliseconds: 500));
      return c;
    }

    testWidgets('16+ is stored as 16', (tester) async {
      final c = await pump(tester);
      expect(find.text('16+'), findsOneWidget);
      await tester.tap(find.byKey(const ValueKey('ob-age-16')));
      await tester.pump();
      expect(c.state.data.age, 16);
    });

    testWidgets('gender can be skipped', (tester) async {
      final c = await pump(tester);
      expect(find.byKey(const ValueKey('ob-gender-skip')), findsNothing);
      await tester.ensureVisible(find.byKey(const ValueKey('ob-gender-girl')));
      await tester.tap(find.byKey(const ValueKey('ob-gender-girl')));
      await tester.pump();
      expect(c.state.data.gender, 'girl');

      await tester.tap(find.byKey(const ValueKey('ob-gender-skip')));
      await tester.pump();
      expect(c.state.data.gender, isNull);
    });

    testWidgets('Continue waits for a name and a phone, not a gender', (
      tester,
    ) async {
      final c = await pump(tester);
      await tester.enterText(find.byKey(const ValueKey('ob-name')), 'Amir');
      await tester.pump();
      await tester.tap(find.byKey(const ValueKey('ob-continue')));
      await tester.pump();
      expect(c.state.data.step, OnboardingStep.child, reason: 'no phone yet');

      await tester.tap(find.byKey(const ValueKey('ob-phone-android')));
      await tester.pump();
      await tester.tap(find.byKey(const ValueKey('ob-continue')));
      await tester.pump(const Duration(milliseconds: 500));
      expect(c.state.data.step, OnboardingStep.goals);
      expect(c.state.data.gender, isNull);
    });
  });
}
