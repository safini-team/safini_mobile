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
              pace: FiniPace.steady,
            ),
            FiniGoal(
              id: '$childId-scrolling',
              childId: childId,
              kind: 'group_budget',
              intent: GoalIntent.scrolling,
              categories: const ['social', 'short_video'],
              minutesPerDay: 60,
              startMinutes: 95,
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
    final at = (int hour, int minute) =>
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
            'age_band': 'Age 9–11',
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
          reason: 'Next step of the Games plan.',
          payload: const {
            'app_slug': 'roblox',
            'app_name': 'Roblox',
            'daily_limit_minutes': 100,
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
          reason: 'Already had 15 extra today. Homework is done.',
          payload: const {'minutes': 15},
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
  Future<FiniSettings> saveSettings(String childId, FiniSettings settings) async {
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
  Future<FiniGoal> updateGoal(String goalId, Map<String, dynamic> changes) async {
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
}
