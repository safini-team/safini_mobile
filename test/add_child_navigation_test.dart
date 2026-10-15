import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:safini/core/di/injection.dart';
import 'package:safini/core/translation/generated/l10n.dart';
import 'package:safini/features/fini/data/fini_repository.dart';
import 'package:safini/features/fini/demo/fini_demo.dart';
import 'package:safini/features/fini/demo/fini_demo_repository.dart';
import 'package:safini/features/fini/domain/fini_models.dart';
import 'package:safini/features/fini/onboarding/fini_onboarding.dart';
import 'package:safini/features/fini/onboarding/fini_onboarding_cubit.dart';
import 'package:safini/features/fini/onboarding/fini_onboarding_page.dart';
import 'package:safini/features/parent/presentation/screens/family/add_child_page.dart';

void main() {
  late FiniRepository repo;

  setUp(() {
    repo = FiniDemoRepository(FiniDemoState.androidChildWithUsage);
    getIt.registerSingleton<FiniRepository>(repo);
  });

  tearDown(() => getIt.reset());

  Future<RootStackRouter> openFlow(WidgetTester tester, Widget flow) async {
    tester.view.physicalSize = const Size(1170, 2532);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);
    final router = RootStackRouter.build(
      routes: [
        NamedRouteDef(
          name: 'home',
          path: '/',
          builder: (_, _) => const Scaffold(body: Text('Family home')),
        ),
        NamedRouteDef(
          name: 'addChild',
          path: '/add-child',
          builder: (_, _) => TickerMode(enabled: false, child: flow),
        ),
      ],
    );
    addTearDown(router.dispose);
    await tester.pumpWidget(
      MaterialApp.router(
        routerConfig: router.config(),
        localizationsDelegates: const [
          S.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: S.delegate.supportedLocales,
      ),
    );
    await tester.pumpAndSettle();
    // Push without awaiting: the future completes when the screen exits.
    router.push<bool>(const NamedRoute('addChild'));
    await tester.pumpAndSettle();
    return router;
  }

  for (final systemBack in [false, true]) {
    testWidgets(
      '${systemBack ? 'system' : 'header'} Back exits Add Child before creation',
      (tester) async {
        final router = await openFlow(tester, const AddChildPage());
        expect(find.byKey(const ValueKey('ob-name')), findsOneWidget);
        final result = router.topRoute.popped;

        if (systemBack) {
          await tester.binding.handlePopRoute();
        } else {
          await tester.tap(find.bySemanticsLabel('Back'));
        }
        await tester.pump(const Duration(milliseconds: 500));

        expect(router.stack.length, 1);
        expect(find.text('Family home'), findsOneWidget);
        expect(await result, isFalse);
        expect(tester.takeException(), isNull);
      },
    );
  }

  testWidgets('Back moves between boards before leaving with a result', (
    tester,
  ) async {
    final cubit = FiniOnboardingCubit(
      repo: repo,
      createChild: ({required name, required age, gender}) async => 'c1',
      resume: const FiniOnboarding(
        step: OnboardingStep.plan,
        childId: 'c1',
        name: 'Amir',
        picked: [GoalIntent.games],
      ),
    );
    addTearDown(cubit.close);
    late RootStackRouter router;
    router = await openFlow(
      tester,
      BlocProvider.value(
        value: cubit,
        child: FiniOnboardingFlow(
          onDone: () {},
          onLeave: () => router.pop(true),
        ),
      ),
    );
    final result = router.topRoute.popped;

    await tester.tap(find.bySemanticsLabel('Back'));
    await tester.pump(const Duration(milliseconds: 500));
    expect(cubit.state.data.step, OnboardingStep.tune);
    expect(router.stack.length, 2);

    await tester.binding.handlePopRoute();
    await tester.pump(const Duration(milliseconds: 500));
    expect(cubit.state.data.step, OnboardingStep.goals);
    expect(router.stack.length, 2);

    await tester.binding.handlePopRoute();
    await tester.pump(const Duration(milliseconds: 500));
    expect(router.stack.length, 1);
    expect(await result, isTrue);
    expect(tester.takeException(), isNull);
  });
}
