import 'package:safini/features/fini/data/fini_repository.dart';
import 'package:safini/features/fini/demo/fini_demo.dart';
import 'package:safini/features/fini/domain/fini_models.dart';

/// The Fini repository behind `--dart-define=FINI_DEMO=true`: fixed fixtures
/// per [FiniDemoState], kept in memory so taps work, and nothing sent to the
/// production API. Also the fixtures of the widget tests.
class FiniDemoRepository implements FiniRepository {
  FiniDemoRepository(this.state, {DateTime? now})
    : _now = now ?? DateTime.now();

  final FiniDemoState state;
  final DateTime _now;

  final Map<String, FiniSettings> _settings = {};
  final Map<String, List<FiniGoal>> _goals = {};
  final Map<String, List<FiniProposal>> _proposals = {};
  var _nextId = 0;

  bool get _running => state != FiniDemoState.androidChildWithUsage;

  DateTime _nextMonday() {
    final today = DateTime(_now.year, _now.month, _now.day);
    return today.add(
      Duration(
        days: (8 - today.weekday) % 7 == 0 ? 7 : (8 - today.weekday) % 7,
      ),
    );
  }

  void _seed(String childId) {
    if (_goals.containsKey(childId)) return;
    _settings[childId] = _running
        ? const FiniSettings(
            level: FiniLevel.auto,
            mayGrantTime: true,
            autoApproveUsage: true,
          )
        : const FiniSettings();
    _goals[childId] = _running
        ? [
            FiniGoal(
              id: '$childId-games',
              childId: childId,
              kind: 'category_budget',
              intent: GoalIntent.games,
              categories: const ['games'],
              minutesPerDay: 45,
              weekendMinutes: 75,
              startMinutes: 130,
              currentMinutes: 98,
              pace: FiniPace.steady,
              plan: FiniPlan(
                phase: FiniPlanPhase.stepping,
                platform: 'android',
                stepsDown: true,
                currentMinutes: 98,
                startMinutes: 130,
                watchedDays: 3,
                steps: const [98, 74, 56, 45],
                nextStepOn: _nextMonday(),
                appCount: 3,
              ),
            ),
            FiniGoal(
              id: '$childId-scrolling',
              childId: childId,
              kind: 'group_budget',
              intent: GoalIntent.scrolling,
              categories: const ['social', 'short_video'],
              minutesPerDay: 60,
              plan: const FiniPlan(
                phase: FiniPlanPhase.watching,
                platform: 'android',
                stepsDown: true,
                watchedDays: 2,
                appCount: 2,
              ),
            ),
            FiniGoal(
              id: '$childId-homework',
              childId: childId,
              kind: 'task_gate',
              intent: GoalIntent.homework,
            ),
            FiniGoal(
              id: '$childId-bedtime',
              childId: childId,
              kind: 'schedule_window',
              intent: GoalIntent.bedtime,
              windowStart: const FiniTime(22, 0),
              windowEnd: const FiniTime(7, 0),
            ),
          ]
        : [];
    DateTime at(int hour, int minute) =>
        DateTime(_now.year, _now.month, _now.day, hour, minute);
    _proposals[childId] = [
      if (_running) ...[
        FiniProposal(
          id: '$childId-p1',
          childId: childId,
          kind: 'task_review',
          status: FiniProposalStatus.applied,
          decidedBy: 'fini',
          canUndo: true,
          reason: '12 min in Duolingo, the task asked for 10.',
          payload: const {'decision': 'approve', 'coins': 20},
          evidence: const {
            'task': 'The task and its reward',
            'usage': 'Duolingo minutes today',
            'age_band': 'Age 9-11',
          },
          createdAt: at(16, 20),
        ),
        FiniProposal(
          id: '$childId-p2',
          childId: childId,
          kind: 'rule_change',
          status: FiniProposalStatus.applied,
          decidedBy: 'fini',
          canUndo: true,
          reason: 'A new game on the phone.',
          payload: const {
            'app_slug': 'brawl-stars',
            'app_name': 'Brawl Stars',
            'daily_limit_minutes': 0,
            'newly_detected': true,
          },
          createdAt: at(14, 3),
        ),
        FiniProposal(
          id: '$childId-p3',
          childId: childId,
          kind: 'rule_change',
          status: FiniProposalStatus.applied,
          decidedBy: 'fini',
          reason: 'Monday step: 130 -> 98 min a day, on the way to 45 min.',
          payload: {'goal_id': '$childId-games', 'daily_limit_minutes': 98},
          evidence: const {
            'plan': {
              'action': 'step',
              'intent': 'games',
              'from': 130,
              'to': 98,
              'target': 45,
            },
          },
          createdAt: at(9, 40).subtract(const Duration(days: 2)),
        ),
      ],
      if (state == FiniDemoState.pendingTimeRequest)
        FiniProposal(
          id: '$childId-ask',
          childId: childId,
          kind: 'time_grant',
          status: FiniProposalStatus.pending,
          reason: 'Amir asked for 15 more minutes.',
          payload: {
            'goal_id': '$childId-games',
            'intent': 'games',
            'minutes': 15,
            'tasks_done': false,
          },
          evidence: const {
            'ask': {'intent': 'games', 'minutes': 15},
          },
          createdAt: at(17, 42),
        ),
    ];
  }

  @override
  Future<FiniSettings> settings(String childId) async {
    _seed(childId);
    return _settings[childId]!;
  }

  @override
  Future<FiniSettings> saveSettings(
    String childId,
    FiniSettings settings,
  ) async {
    _seed(childId);
    return _settings[childId] = settings;
  }

  @override
  Future<List<FiniGoal>> goals(String childId) async {
    _seed(childId);
    return List.of(_goals[childId]!);
  }

  @override
  Future<FiniGoal> createGoal(String childId, Map<String, dynamic> body) async {
    _seed(childId);
    final goal = FiniGoal.fromJson({
      ...body,
      'id': 'demo-goal-${_nextId++}',
      'child_id': childId,
    });
    _goals[childId]!.add(goal);
    return goal;
  }

  @override
  Future<FiniGoal> updateGoal(
    String goalId,
    Map<String, dynamic> changes,
  ) async {
    for (final goals in _goals.values) {
      final index = goals.indexWhere((goal) => goal.id == goalId);
      if (index == -1) continue;
      final old = goals[index];
      final updated = FiniGoal.fromJson({
        'id': old.id,
        'child_id': old.childId,
        'kind': old.kind,
        'target': {
          'intent': old.intent.name,
          'app_slugs': old.appSlugs,
          'categories': old.categories,
        },
        'minutes_per_day': old.minutesPerDay,
        'weekday_minutes': old.weekdayMinutes,
        'weekend_minutes': old.weekendMinutes,
        'start_minutes': old.startMinutes,
        'window_start': old.windowStart?.toJson(),
        'window_end': old.windowEnd?.toJson(),
        'pace': old.pace.name,
        'status': old.status,
        ...changes,
      });
      return goals[index] = updated;
    }
    throw StateError('no goal $goalId');
  }

  @override
  Future<void> deleteGoal(String goalId) async {
    for (final goals in _goals.values) {
      goals.removeWhere((goal) => goal.id == goalId);
    }
  }

  @override
  Future<List<FiniProposal>> pending(String childId) async {
    _seed(childId);
    return _proposals[childId]!
        .where((p) => p.status == FiniProposalStatus.pending)
        .toList();
  }

  @override
  Future<List<FiniProposal>> activity(String childId) async {
    _seed(childId);
    return _proposals[childId]!
        .where((p) => p.status != FiniProposalStatus.pending)
        .toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  @override
  Future<FiniProposal> decide(String proposalId, FiniDecision decision) async {
    for (final list in _proposals.values) {
      final index = list.indexWhere((p) => p.id == proposalId);
      if (index == -1) continue;
      final old = list[index];
      final updated = FiniProposal(
        id: old.id,
        childId: old.childId,
        kind: old.kind,
        reason: old.reason,
        payload: old.payload,
        evidence: old.evidence,
        createdAt: old.createdAt,
        decidedBy: decision == FiniDecision.undo ? old.decidedBy : 'parent',
        status: switch (decision) {
          FiniDecision.accept => FiniProposalStatus.accepted,
          FiniDecision.dismiss => FiniProposalStatus.dismissed,
          FiniDecision.undo => FiniProposalStatus.undone,
        },
        canUndo: decision == FiniDecision.accept,
      );
      return list[index] = updated;
    }
    throw StateError('no proposal $proposalId');
  }

  @override
  Future<FiniTrial> trial() async => switch (state) {
    FiniDemoState.trialExpired => const FiniTrial(
      state: FiniTrialState.expired,
      daysLeft: 0,
    ),
    _ => const FiniTrial(state: FiniTrialState.trial, daysLeft: 11),
  };

  @override
  Future<FiniTrial> startTrial() => trial();

  @override
  Future<FiniInbox> inbox() async {
    final byChild = <String, int>{
      for (final entry in _proposals.entries)
        entry.key: entry.value
            .where((p) => p.status == FiniProposalStatus.pending)
            .length,
    }..removeWhere((_, count) => count == 0);
    return FiniInbox(
      total: byChild.values.fold(0, (sum, count) => sum + count),
      byChild: byChild,
    );
  }

  @override
  Future<FiniGoal> jumpToTarget(String goalId) async {
    for (final goals in _goals.values) {
      final index = goals.indexWhere((goal) => goal.id == goalId);
      if (index == -1) continue;
      final goal = goals[index];
      final jumped = FiniGoal(
        id: goal.id,
        childId: goal.childId,
        kind: goal.kind,
        intent: goal.intent,
        categories: goal.categories,
        minutesPerDay: goal.minutesPerDay,
        weekendMinutes: goal.weekendMinutes,
        startMinutes: goal.startMinutes,
        currentMinutes: goal.minutesPerDay,
        pace: goal.pace,
        plan: FiniPlan(
          phase: FiniPlanPhase.atTarget,
          platform: goal.plan?.platform,
          stepsDown: goal.plan?.stepsDown ?? false,
          currentMinutes: goal.minutesPerDay,
          startMinutes: goal.startMinutes,
          appCount: goal.plan?.appCount ?? 0,
        ),
      );
      goals[index] = jumped;
      return jumped;
    }
    throw StateError('No goal $goalId');
  }

  @override
  Future<List<FiniPool>> pools(String childId) async {
    _seed(childId);
    return [
      for (final goal in _goals[childId]!)
        if (goal.currentMinutes != null)
          FiniPool(
            goalId: goal.id,
            intent: goal.intent,
            limitMinutes: goal.currentMinutes!,
            goalMinutes: goal.minutesPerDay,
            usedMinutes: 52,
            apps: const [
              FiniPoolApp(
                packageName: 'com.roblox.client',
                name: 'Roblox',
                usedMinutes: 32,
              ),
              FiniPoolApp(
                packageName: 'com.supercell.brawlstars',
                name: 'Brawl Stars',
                usedMinutes: 14,
              ),
              FiniPoolApp(
                packageName: 'com.mojang.minecraftpe',
                name: 'Minecraft',
                usedMinutes: 6,
              ),
            ],
          ),
    ];
  }
}
