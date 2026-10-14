import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:safini/core/notifications/push_event.dart';
import 'package:safini/core/translation/generated/l10n.dart';
import 'package:safini/features/fini/data/fini_repository.dart';
import 'package:safini/features/fini/demo/fini_demo.dart';
import 'package:safini/features/fini/demo/fini_demo_repository.dart';
import 'package:safini/features/fini/domain/fini_models.dart';
import 'package:safini/features/fini/onboarding/fini_onboarding.dart';
import 'package:safini/features/fini/onboarding/fini_onboarding_cubit.dart';
import 'package:safini/features/fini/presentation/cubit/fini_cubit.dart';
import 'package:safini/features/parent/presentation/cubit/home/home_state.dart';
import 'package:safini/features/parent/presentation/screens/main/parent_main_screen.dart';

class _Repo extends FiniDemoRepository {
  _Repo(super.state);

  int starts = 0;
  bool trialFails = false;

  @override
  Future<FiniTrial> trial() {
    if (trialFails) throw Exception('offline');
    return super.trial();
  }

  @override
  Future<FiniTrial> startTrial() {
    starts++;
    return super.startTrial();
  }
}

void main() {
  group('FiniTrial.fromJson', () {
    test('reads every state the API sends', () {
      FiniTrial read(String state, [int? left]) =>
          FiniTrial.fromJson({'state': state, 'days_left': left});
      expect(read('trial', 11).inTrial, isTrue);
      expect(read('trial', 11).daysLeft, 11);
      expect(read('expired', 0).paused, isTrue);
      expect(read('pro').paused, isFalse);
      expect(read('pro').inTrial, isFalse);
      expect(read('not_started').state, FiniTrialState.notStarted);
      expect(read('something new').state, FiniTrialState.notStarted);
    });
  });

  group('FiniCubit', () {
    test('loads the trial with the rest', () async {
      final cubit = FiniCubit(_Repo(FiniDemoState.runningPlan));
      await cubit.load('amir');
      expect(cubit.state.trial.daysLeft, 11);
      expect(cubit.state.trial.paused, isFalse);
    });

    test('an expired trial pauses Fini and keeps the goals', () async {
      final cubit = FiniCubit(_Repo(FiniDemoState.trialExpired));
      await cubit.load('amir');
      expect(cubit.state.trial.paused, isTrue);
      expect(cubit.state.goals, isNotEmpty);
    });

    test('a trial the server cannot say does not break the tab', () async {
      final repo = _Repo(FiniDemoState.runningPlan)..trialFails = true;
      final cubit = FiniCubit(repo);
      await cubit.load('amir');
      expect(cubit.state.status, FiniStatus.loaded);
      expect(cubit.state.trial.state, FiniTrialState.notStarted);
    });
  });

  test('"Start 14 days free" on board E starts the trial', () async {
    final repo = _Repo(FiniDemoState.androidChildWithUsage);
    final cubit = FiniOnboardingCubit(
      repo: repo,
      createChild: ({required name, required age, gender}) async => 'c1',
      resume: const FiniOnboarding(
        step: OnboardingStep.trial,
        childId: 'c1',
        name: 'Amir',
      ),
    );
    expect(await cubit.next(), isTrue);
    expect(repo.starts, 1);
  });

  test('the day-12 push opens the Fini tab', () {
    final event = PushEvent.fromData({'type': 'fini_trial_ending'});
    expect(event?.type, PushType.finiTrialEnding);
    expect(event!.target.destination, PushDestination.parentFini);
    expect(event.target.destination.isParent, isTrue);
    expect(ParentMainScreen.tabFor(PushDestination.parentFini), ParentTab.fini);
  });

  testWidgets('the pill says how many days are left, in Russian too', (
    tester,
  ) async {
    late S s;
    await tester.pumpWidget(
      MaterialApp(
        locale: const Locale('ru'),
        localizationsDelegates: const [
          S.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: S.delegate.supportedLocales,
        home: Builder(
          builder: (context) {
            s = S.of(context);
            return const SizedBox();
          },
        ),
      ),
    );
    expect(s.finiTrialPill(1), 'Пробный период · остался 1 день');
    expect(s.finiTrialPill(2), 'Пробный период · осталось 2 дня');
    expect(s.finiTrialPill(11), 'Пробный период · осталось 11 дней');
  });

  test('the demo repository serves both trial states', () async {
    final FiniRepository running = FiniDemoRepository(
      FiniDemoState.runningPlan,
    );
    expect((await running.trial()).inTrial, isTrue);
    expect(
      (await FiniDemoRepository(FiniDemoState.trialExpired).trial()).paused,
      isTrue,
    );
  });
}
