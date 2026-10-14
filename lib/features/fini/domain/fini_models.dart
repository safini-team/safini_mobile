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
    this.pace = FiniPace.gentle,
    this.status = 'active',
  });

  final String id;
  final String childId;
  final String kind;
  final GoalIntent intent;
  final List<String> appSlugs;
  final List<String> categories;
  final int? minutesPerDay;
  final int? weekdayMinutes;
  final int? weekendMinutes;
  final int? startMinutes;
  final FiniTime? windowStart;
  final FiniTime? windowEnd;
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
      pace: FiniPace.values.firstWhere(
        (pace) => pace.name == json['pace'],
        orElse: () => FiniPace.gentle,
      ),
      status: (json['status'] ?? 'active').toString(),
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
