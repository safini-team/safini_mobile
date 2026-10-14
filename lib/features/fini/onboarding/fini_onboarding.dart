import 'package:safini/features/fini/domain/fini_goal_specs.dart';
import 'package:safini/features/fini/domain/fini_models.dart';

/// The boards of the Fini onboarding, in order (canvas row "Onboarding").
enum OnboardingStep { child, goals, tune, plan, trial }

enum ChildPhone { android, iphone }

/// Ages on the chips: 5 to 15, then "16+", stored as 16.
const onboardingAges = [5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16];
const onboardingOldest = 16;

/// Our suggested starting points by age band. They are where the plan ends,
/// not claims about what other families do.
class AgeDefaults {
  const AgeDefaults({
    required this.gamesMinutes,
    required this.scrollingMinutes,
    required this.bedtime,
  });

  final int gamesMinutes;
  final int scrollingMinutes;
  final FiniTime bedtime;

  static AgeDefaults forAge(int age) {
    if (age <= 8) {
      return const AgeDefaults(
        gamesMinutes: 30,
        scrollingMinutes: 15,
        bedtime: FiniTime(20, 30),
      );
    }
    if (age <= 12) {
      return const AgeDefaults(
        gamesMinutes: 45,
        scrollingMinutes: 60,
        bedtime: FiniTime(21, 30),
      );
    }
    return const AgeDefaults(
      gamesMinutes: 90,
      scrollingMinutes: 90,
      bedtime: FiniTime(22, 30),
    );
  }
}

/// What a picked goal needs on board C: minutes, a time window, or the
/// homework line. Learning apps need nothing, so picking only that skips C.
enum TuneKind { minutes, window, homework, none }

TuneKind tuneKindFor(GoalIntent intent) => switch (intent) {
  GoalIntent.games ||
  GoalIntent.scrolling ||
  GoalIntent.video => TuneKind.minutes,
  GoalIntent.bedtime ||
  GoalIntent.school ||
  GoalIntent.dinner => TuneKind.window,
  GoalIntent.homework => TuneKind.homework,
  GoalIntent.learning || GoalIntent.custom => TuneKind.none,
};

/// Everything the onboarding has collected. Immutable; [FiniOnboardingCubit]
/// moves it from board to board.
class FiniOnboarding {
  const FiniOnboarding({
    this.step = OnboardingStep.child,
    this.name = '',
    this.age = 9,
    this.phone,
    this.gender,
    this.picked = const [],
    this.minutes = const {},
    this.windows = const {},
    this.childId,
  });

  final OnboardingStep step;
  final String name;
  final int age;
  final ChildPhone? phone;

  /// `girl`, `boy` or null. Only for grammar in the copy; never sent to a
  /// model.
  final String? gender;

  /// Goals picked on board B, in the grid's order.
  final List<GoalIntent> picked;

  /// Board C's values. A goal missing here uses [AgeDefaults].
  final Map<GoalIntent, int> minutes;
  final Map<GoalIntent, (FiniTime, FiniTime)> windows;

  /// Set once board A has created the child.
  final String? childId;

  /// Board A needs a name and the phone; gender is optional.
  bool get childReady => name.trim().isNotEmpty && phone != null;

  AgeDefaults get defaults => AgeDefaults.forAge(age);

  /// The goals that get a row on board C.
  List<GoalIntent> get tuned =>
      picked.where((intent) => tuneKindFor(intent) != TuneKind.none).toList();

  int minutesFor(GoalIntent intent) =>
      minutes[intent] ??
      (intent == GoalIntent.scrolling
          ? defaults.scrollingMinutes
          : defaults.gamesMinutes);

  (FiniTime, FiniTime) windowFor(GoalIntent intent) {
    final set = windows[intent];
    if (set != null) return set;
    final spec = specFor(intent);
    if (intent == GoalIntent.bedtime) {
      return (defaults.bedtime, spec.windowEnd!);
    }
    return (spec.windowStart!, spec.windowEnd!);
  }

  /// The board after this one. C only shows when a picked goal has a value.
  OnboardingStep? get next => switch (step) {
    OnboardingStep.child => OnboardingStep.goals,
    OnboardingStep.goals =>
      tuned.isEmpty ? OnboardingStep.plan : OnboardingStep.tune,
    OnboardingStep.tune => OnboardingStep.plan,
    OnboardingStep.plan => OnboardingStep.trial,
    OnboardingStep.trial => null,
  };

  /// The board Back goes to. A is not reopened once the child exists.
  OnboardingStep? get previous => switch (step) {
    OnboardingStep.child => null,
    OnboardingStep.goals => childId == null ? OnboardingStep.child : null,
    OnboardingStep.tune => OnboardingStep.goals,
    OnboardingStep.plan =>
      tuned.isEmpty ? OnboardingStep.goals : OnboardingStep.tune,
    OnboardingStep.trial => OnboardingStep.plan,
  };

  /// The bodies of `POST /children/{id}/fini/goals`, one per picked goal.
  /// Budgets use the steady pace board D promises ("about a quarter less
  /// each week").
  List<Map<String, dynamic>> goalBodies() => [
    for (final intent in picked)
      if (!specFor(intent).comingSoon)
        switch (tuneKindFor(intent)) {
          TuneKind.minutes => specFor(
            intent,
          ).createBody(minutes: minutesFor(intent), pace: FiniPace.steady),
          TuneKind.window => specFor(
            intent,
          ).createBody(start: windowFor(intent).$1, end: windowFor(intent).$2),
          TuneKind.homework || TuneKind.none => specFor(intent).createBody(),
        },
  ];

  FiniOnboarding copyWith({
    OnboardingStep? step,
    String? name,
    int? age,
    ChildPhone? phone,
    String? Function()? gender,
    List<GoalIntent>? picked,
    Map<GoalIntent, int>? minutes,
    Map<GoalIntent, (FiniTime, FiniTime)>? windows,
    String? childId,
  }) => FiniOnboarding(
    step: step ?? this.step,
    name: name ?? this.name,
    age: age ?? this.age,
    phone: phone ?? this.phone,
    gender: gender == null ? this.gender : gender(),
    picked: picked ?? this.picked,
    minutes: minutes ?? this.minutes,
    windows: windows ?? this.windows,
    childId: childId ?? this.childId,
  );
}
