/// Fini's data as `safini-api` serves it under `/fini/` (SAF-268, SAF-271).
library;

enum FiniLevel { off, suggest, auto }

enum FiniPace { gentle, steady, now }

/// What a child's Fini may do, and whether it is paused.
class FiniSettings {
  const FiniSettings({
    this.level = FiniLevel.suggest,
    this.paused = false,
    this.mayLowerLimits = true,
    this.maySortNewApps = true,
    this.mayGrantTime = false,
    this.autoApproveUsage = false,
    this.autoApprovePhoto = false,
    this.extraTimeEnvelopeMinutes = 15,
  });

  final FiniLevel level;
  final bool paused;
  final bool mayLowerLimits;
  final bool maySortNewApps;
  final bool mayGrantTime;
  final bool autoApproveUsage;
  final bool autoApprovePhoto;
  final int extraTimeEnvelopeMinutes;

  /// How many of the five "on its own" switches are on.
  int get switchesOn => [
    mayLowerLimits,
    maySortNewApps,
    autoApproveUsage,
    autoApprovePhoto,
    mayGrantTime,
  ].where((on) => on).length;

  bool get actsAlone => level == FiniLevel.auto && !paused;

  FiniSettings copyWith({
    FiniLevel? level,
    bool? paused,
    bool? mayLowerLimits,
    bool? maySortNewApps,
    bool? mayGrantTime,
    bool? autoApproveUsage,
    bool? autoApprovePhoto,
    int? extraTimeEnvelopeMinutes,
  }) => FiniSettings(
    level: level ?? this.level,
    paused: paused ?? this.paused,
    mayLowerLimits: mayLowerLimits ?? this.mayLowerLimits,
    maySortNewApps: maySortNewApps ?? this.maySortNewApps,
    mayGrantTime: mayGrantTime ?? this.mayGrantTime,
    autoApproveUsage: autoApproveUsage ?? this.autoApproveUsage,
    autoApprovePhoto: autoApprovePhoto ?? this.autoApprovePhoto,
    extraTimeEnvelopeMinutes:
        extraTimeEnvelopeMinutes ?? this.extraTimeEnvelopeMinutes,
  );

  factory FiniSettings.fromJson(Map<String, dynamic> json) => FiniSettings(
    level: FiniLevel.values.firstWhere(
      (level) => level.name == json['level'],
      orElse: () => FiniLevel.suggest,
    ),
    paused: json['paused'] == true,
    mayLowerLimits: json['may_lower_limits'] != false,
    maySortNewApps: json['may_sort_new_apps'] != false,
    mayGrantTime: json['may_grant_time'] == true,
    autoApproveUsage: json['auto_approve_usage'] == true,
    autoApprovePhoto: json['auto_approve_photo'] == true,
    extraTimeEnvelopeMinutes:
        (json['extra_time_envelope_minutes'] as num?)?.toInt() ?? 15,
  );

  Map<String, dynamic> toJson() => {
    'level': level.name,
    'paused': paused,
    'may_lower_limits': mayLowerLimits,
    'may_sort_new_apps': maySortNewApps,
    'may_grant_time': mayGrantTime,
    'auto_approve_usage': autoApproveUsage,
    'auto_approve_photo': autoApprovePhoto,
    'extra_time_envelope_minutes': extraTimeEnvelopeMinutes,
  };
}

/// A tile on the goal grid. The API stores it as `target.intent`; the kind
/// and targets it maps to live in [GoalIntentSpec].
enum GoalIntent {
  games,
  scrolling,
  video,
  homework,
  bedtime,
  school,
  dinner,
  learning,
  custom,
}

/// A time of day, as the API's `HH:MM:SS`.
class FiniTime {
  const FiniTime(this.hour, this.minute);

  final int hour;
  final int minute;

  static FiniTime? parse(Object? raw) {
    final parts = raw?.toString().split(':');
    if (parts == null || parts.length < 2) return null;
    final hour = int.tryParse(parts[0]);
    final minute = int.tryParse(parts[1]);
    if (hour == null || minute == null) return null;
    return FiniTime(hour, minute);
  }

  String get label =>
      '${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}';

  String toJson() => '$label:00';

  @override
  bool operator ==(Object other) =>
      other is FiniTime && other.hour == hour && other.minute == minute;

  @override
  int get hashCode => Object.hash(hour, minute);
}

class FiniGoal {
  const FiniGoal({
    required this.id,
    required this.childId,
    required this.kind,
    required this.intent,
    this.appSlugs = const [],
    this.categories = const [],
    this.minutesPerDay,
    this.weekdayMinutes,
    this.weekendMinutes,
    this.startMinutes,
    this.windowStart,
    this.windowEnd,
    this.windowDays = allWeekdays,
    this.pace = FiniPace.gentle,
    this.status = 'active',
    this.currentMinutes,
    this.plan,
  });

  final String id;
  final String childId;
  final String kind;
  final GoalIntent intent;

  /// A pool's limit today, as the phone enforces it. Null while Fini watches.
  final int? currentMinutes;

  /// Where the step-down stands; null for goals with no plan, or an older API.
  final FiniPlan? plan;
  final List<String> appSlugs;
  final List<String> categories;
  final int? minutesPerDay;
  final int? weekdayMinutes;
  final int? weekendMinutes;
  final int? startMinutes;
  final FiniTime? windowStart;
  final FiniTime? windowEnd;

  /// The days a window starts on: Mon=1, Tue=2, Wed=4 ... Sun=64 (SAF-277).
  final int windowDays;
  final FiniPace pace;
  final String status;

  bool get isBudget =>
      kind == 'category_budget' || kind == 'group_budget' || kind == 'app_cap';
  bool get isWindow => kind == 'schedule_window';
  bool get isPaused => status == 'paused';

  /// The weekday goal, the one the big number shows.
  int? get targetMinutes => weekdayMinutes ?? minutesPerDay;

  /// "Extra on weekends": a weekend value above the weekday one.
  bool get hasWeekendExtra =>
      weekendMinutes != null &&
      targetMinutes != null &&
      weekendMinutes! > targetMinutes!;

  factory FiniGoal.fromJson(Map<String, dynamic> json) {
    final target = (json['target'] as Map?)?.cast<String, dynamic>() ?? {};
    return FiniGoal(
      id: json['id'].toString(),
      childId: json['child_id'].toString(),
      kind: (json['kind'] ?? '').toString(),
      intent: intentFor(json['kind']?.toString(), target),
      appSlugs: _strings(target['app_slugs']),
      categories: _strings(target['categories']),
      minutesPerDay: (json['minutes_per_day'] as num?)?.toInt(),
      weekdayMinutes: (json['weekday_minutes'] as num?)?.toInt(),
      weekendMinutes: (json['weekend_minutes'] as num?)?.toInt(),
      startMinutes: (json['start_minutes'] as num?)?.toInt(),
      windowStart: FiniTime.parse(json['window_start']),
      windowEnd: FiniTime.parse(json['window_end']),
      windowDays: (json['window_days'] as num?)?.toInt() ?? allWeekdays,
      pace: FiniPace.values.firstWhere(
        (pace) => pace.name == json['pace'],
        orElse: () => FiniPace.gentle,
      ),
      status: (json['status'] ?? 'active').toString(),
      currentMinutes: (json['current_minutes'] as num?)?.toInt(),
      plan: json['plan'] is Map
          ? FiniPlan.fromJson((json['plan'] as Map).cast<String, dynamic>())
          : null,
    );
  }

  /// A goal made before intents existed falls back on its kind.
  static GoalIntent intentFor(String? kind, Map<String, dynamic> target) {
    final named = GoalIntent.values
        .where((intent) => intent.name == target['intent'])
        .firstOrNull;
    if (named != null) return named;
    return switch (kind) {
      'group_budget' => GoalIntent.scrolling,
      'task_gate' => GoalIntent.homework,
      'schedule_window' => GoalIntent.bedtime,
      'exempt' => GoalIntent.learning,
      'app_cap' || 'category_budget' => GoalIntent.games,
      _ => GoalIntent.custom,
    };
  }

  static List<String> _strings(Object? raw) =>
      raw is List ? raw.map((item) => item.toString()).toList() : const [];
}

enum FiniPlanPhase { waitingForPhone, watching, stepping, atTarget }

/// A budget goal's step-down plan as the server runs it (SAF-274).
class FiniPlan {
  const FiniPlan({
    required this.phase,
    this.platform,
    this.stepsDown = false,
    this.currentMinutes,
    this.startMinutes,
    this.watchDays = 3,
    this.watchedDays = 0,
    this.steps = const [],
    this.nextStepOn,
    this.appCount = 0,
  });

  final FiniPlanPhase phase;

  /// `android`, `ios`, or null while no phone is paired.
  final String? platform;

  /// False on an iPhone and at "right away": the goal applies as set.
  final bool stepsDown;
  final int? currentMinutes;
  final int? startMinutes;
  final int watchDays;
  final int watchedDays;

  /// Weekly limits from today's to the goal.
  final List<int> steps;
  final DateTime? nextStepOn;

  /// Apps on the phone in this goal's pool.
  final int appCount;

  bool get isIphone => platform == 'ios';

  /// Mondays left until the goal.
  int get weeksLeft => steps.isEmpty ? 0 : steps.length - 1;

  factory FiniPlan.fromJson(Map<String, dynamic> json) => FiniPlan(
    phase: switch (json['phase']) {
      'waiting_for_phone' => FiniPlanPhase.waitingForPhone,
      'stepping' => FiniPlanPhase.stepping,
      'at_target' => FiniPlanPhase.atTarget,
      _ => FiniPlanPhase.watching,
    },
    platform: json['platform'] as String?,
    stepsDown: json['steps_down'] == true,
    currentMinutes: (json['current_minutes'] as num?)?.toInt(),
    startMinutes: (json['start_minutes'] as num?)?.toInt(),
    watchDays: (json['watch_days'] as num?)?.toInt() ?? 3,
    watchedDays: (json['watched_days'] as num?)?.toInt() ?? 0,
    steps: [
      for (final step in (json['steps'] as List?) ?? const [])
        (step as num).toInt(),
    ],
    nextStepOn: DateTime.tryParse(json['next_step_on']?.toString() ?? ''),
    appCount: (json['app_count'] as num?)?.toInt() ?? 0,
  );
}

/// A budget goal as one shared daily limit over its apps (SAF-274).
class FiniPool {
  const FiniPool({
    required this.goalId,
    required this.intent,
    required this.limitMinutes,
    required this.usedMinutes,
    this.goalMinutes,
    this.apps = const [],
  });

  final String goalId;
  final GoalIntent intent;
  final int limitMinutes;
  final int usedMinutes;
  final int? goalMinutes;
  final List<FiniPoolApp> apps;

  bool get isSpent => usedMinutes >= limitMinutes;

  factory FiniPool.fromJson(Map<String, dynamic> json) => FiniPool(
    goalId: json['goal_id'].toString(),
    intent: GoalIntent.values
            .where((intent) => intent.name == json['intent'])
            .firstOrNull ??
        GoalIntent.games,
    limitMinutes: (json['limit_minutes'] as num?)?.toInt() ?? 0,
    usedMinutes: (json['used_minutes'] as num?)?.toInt() ?? 0,
    goalMinutes: (json['goal_minutes'] as num?)?.toInt(),
    apps: [
      for (final app in (json['apps'] as List?) ?? const [])
        if (app is Map)
          FiniPoolApp(
            packageName: app['package_name'].toString(),
            name: (app['app_name'] ?? app['package_name']).toString(),
            usedMinutes: (app['used_minutes'] as num?)?.toInt() ?? 0,
          ),
    ],
  );
}

class FiniPoolApp {
  const FiniPoolApp({
    required this.packageName,
    required this.name,
    required this.usedMinutes,
  });

  final String packageName;
  final String name;
  final int usedMinutes;
}

enum FiniProposalStatus {
  pending,
  applied,
  accepted,
  dismissed,
  undone,
  rejected,
  expired,
}

/// One thing Fini proposed: a card while pending, an activity entry after.
class FiniProposal {
  const FiniProposal({
    required this.id,
    required this.childId,
    required this.kind,
    required this.status,
    required this.reason,
    required this.createdAt,
    this.payload = const {},
    this.evidence = const {},
    this.decidedBy,
    this.canUndo = false,
    this.undoUntil,
  });

  final String id;
  final String childId;
  final String kind;
  final FiniProposalStatus status;

  /// Fini's one-line reason, in the parent's words.
  final String reason;
  final Map<String, dynamic> payload;

  /// What it looked at: names of signals, never the child's data itself.
  final Map<String, dynamic> evidence;
  final String? decidedBy;
  final bool canUndo;
  final DateTime? undoUntil;
  final DateTime createdAt;

  bool get ranAlone =>
      decidedBy == 'fini' && status == FiniProposalStatus.applied;

  /// A new app Fini sorted, or could not sort, or the parent placed.
  bool get isAppSort => kind == 'app_sort';
  String get appPackage => (payload['package_name'] ?? '').toString();
  String get appName => (payload['app_name'] ?? appPackage).toString();

  /// Where the app went: Fini's sure category, or the parent's pick.
  String? get appCategory => payload['category'] as String?;

  /// Fini could not tell: the parent picks a category on the card.
  bool get cantSort => payload['cant_sort'] == true && decidedBy != 'parent';

  factory FiniProposal.fromJson(Map<String, dynamic> json) => FiniProposal(
    id: json['id'].toString(),
    childId: json['child_id'].toString(),
    kind: (json['kind'] ?? '').toString(),
    status: FiniProposalStatus.values.firstWhere(
      (status) => status.name == json['status'],
      orElse: () => FiniProposalStatus.pending,
    ),
    reason: (json['reason'] ?? '').toString(),
    payload: (json['payload'] as Map?)?.cast<String, dynamic>() ?? const {},
    evidence: (json['evidence'] as Map?)?.cast<String, dynamic>() ?? const {},
    decidedBy: json['decided_by'] as String?,
    canUndo: json['can_undo'] == true,
    undoUntil: DateTime.tryParse(json['undo_until']?.toString() ?? ''),
    createdAt:
        DateTime.tryParse(json['created_at']?.toString() ?? '')?.toLocal() ??
        DateTime.now(),
  );
}

enum FiniTrialState { notStarted, trial, expired, pro }

/// The family's one 14-day Fini trial (SAF-273). Expired means Fini is
/// paused: every rule stays as it was, and Pro turns it back on.
class FiniTrial {
  const FiniTrial({this.state = FiniTrialState.notStarted, this.daysLeft});

  final FiniTrialState state;
  final int? daysLeft;

  bool get paused => state == FiniTrialState.expired;
  bool get inTrial => state == FiniTrialState.trial;

  factory FiniTrial.fromJson(Map<String, dynamic> json) => FiniTrial(
    state: switch (json['state']) {
      'trial' => FiniTrialState.trial,
      'expired' => FiniTrialState.expired,
      'pro' => FiniTrialState.pro,
      _ => FiniTrialState.notStarted,
    },
    daysLeft: (json['days_left'] as num?)?.toInt(),
  );
}

/// Pending cards per child, for the tab badge and the dots on the circles.
class FiniInbox {
  const FiniInbox({this.total = 0, this.byChild = const {}});

  final int total;
  final Map<String, int> byChild;

  factory FiniInbox.fromJson(Map<String, dynamic> json) => FiniInbox(
    total: (json['total'] as num?)?.toInt() ?? 0,
    byChild: {
      for (final row in (json['children'] as List? ?? const []))
        if (row is Map)
          row['child_id'].toString(): (row['pending'] as num?)?.toInt() ?? 0,
    },
  );
}

/// Every day of the week as a `window_days` mask.
const allWeekdays = 127;

/// Monday to Friday, school's default.
const schoolDays = 31;

/// Fini's Sunday report for one child (SAF-278): at most three bullets in
/// the parent's language, written from the week's numbers.
class FiniReport {
  const FiniReport({
    required this.id,
    required this.weekStart,
    required this.weekEnd,
    required this.bullets,
  });

  final String id;
  final DateTime weekStart;
  final DateTime weekEnd;
  final List<String> bullets;

  /// Shown on the Fini home through the week after it was written.
  bool isCurrent(DateTime now) =>
      now.difference(weekEnd) < const Duration(days: 8);

  factory FiniReport.fromJson(Map<String, dynamic> json) => FiniReport(
    id: json['id'].toString(),
    weekStart:
        DateTime.tryParse(json['week_start']?.toString() ?? '') ??
        DateTime(2026),
    weekEnd:
        DateTime.tryParse(json['week_end']?.toString() ?? '') ?? DateTime(2026),
    bullets: [
      for (final bullet in (json['bullets'] as List?) ?? const [])
        if (bullet is String && bullet.isNotEmpty) bullet,
    ],
  );
}
