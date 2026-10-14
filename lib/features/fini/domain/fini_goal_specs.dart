import 'package:safini/features/fini/domain/fini_models.dart';

/// What a tile on the goal grid turns into on the API, and its defaults.
///
/// Categories name SAF-229's app categories; until apps carry one, budgets
/// over them are stored and shown but have no usage to step down from.
class GoalIntentSpec {
  const GoalIntentSpec({
    required this.intent,
    required this.kind,
    this.categories = const [],
    this.minutesPerDay,
    this.windowStart,
    this.windowEnd,
    this.comingSoon = false,
  });

  final GoalIntent intent;
  final String kind;
  final List<String> categories;
  final int? minutesPerDay;
  final FiniTime? windowStart;
  final FiniTime? windowEnd;

  /// Shown dimmed with "soon"; cannot be added yet.
  final bool comingSoon;

  bool get hasMinutes => minutesPerDay != null;
  bool get hasWindow => windowStart != null;

  /// The body of `POST /children/{id}/fini/goals`. [minutes] overrides the
  /// default for a budget; [start] and [end] for a window.
  Map<String, dynamic> createBody({
    int? minutes,
    FiniTime? start,
    FiniTime? end,
    FiniPace pace = FiniPace.gentle,
  }) => {
    'kind': kind,
    'target': {
      'intent': intent.name,
      if (categories.isNotEmpty) 'categories': categories,
    },
    if (hasMinutes) 'minutes_per_day': minutes ?? minutesPerDay,
    if (hasWindow) ...{
      'window_start': (start ?? windowStart)!.toJson(),
      'window_end': (end ?? windowEnd)!.toJson(),
    },
    'pace': pace.name,
  };
}

/// The grid, in the order the Add-a-goal sheet and onboarding show it.
/// "Something else" waits for the goal-drafting call (SAF-274), so it is not
/// here yet.
const goalIntentSpecs = <GoalIntentSpec>[
  GoalIntentSpec(
    intent: GoalIntent.games,
    kind: 'category_budget',
    categories: ['games'],
    minutesPerDay: 60,
  ),
  GoalIntentSpec(
    intent: GoalIntent.scrolling,
    kind: 'group_budget',
    categories: ['social', 'short_video'],
    minutesPerDay: 60,
  ),
  GoalIntentSpec(
    intent: GoalIntent.video,
    kind: 'category_budget',
    categories: ['video'],
    minutesPerDay: 60,
    comingSoon: true,
  ),
  GoalIntentSpec(intent: GoalIntent.homework, kind: 'task_gate'),
  GoalIntentSpec(
    intent: GoalIntent.bedtime,
    kind: 'schedule_window',
    windowStart: FiniTime(21, 30),
    windowEnd: FiniTime(7, 0),
  ),
  GoalIntentSpec(
    intent: GoalIntent.school,
    kind: 'schedule_window',
    windowStart: FiniTime(8, 0),
    windowEnd: FiniTime(14, 0),
  ),
  GoalIntentSpec(
    intent: GoalIntent.dinner,
    kind: 'schedule_window',
    windowStart: FiniTime(19, 0),
    windowEnd: FiniTime(20, 0),
  ),
  GoalIntentSpec(
    intent: GoalIntent.learning,
    kind: 'exempt',
    categories: ['education'],
  ),
];

GoalIntentSpec specFor(GoalIntent intent) => goalIntentSpecs.firstWhere(
  (spec) => spec.intent == intent,
  orElse: () => goalIntentSpecs.first,
);
