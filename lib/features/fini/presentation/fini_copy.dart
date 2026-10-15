import 'package:safini/core/translation/generated/l10n.dart';
import 'package:safini/features/fini/domain/fini_models.dart';
import 'package:safini/features/fini/presentation/widgets/goal_visuals.dart'
    show goalTitle;
import 'package:safini/features/parent/presentation/screens/monitor/parent_today_view.dart'
    show formatHm;

/// Fini's lines to the parent. All of it is templated here from typed
/// fields; no free text from the model reaches a screen except a proposal's
/// one-line `reason`.

/// The sentence under the mascot on the Fini home.
String finiStatusLine(
  S s, {
  required String childName,
  required FiniSettings settings,
  required int goals,
  required int pending,
}) {
  if (settings.paused || settings.level == FiniLevel.off) {
    return s.finiStatusPaused(childName);
  }
  if (goals == 0) return s.finiStatusNoGoals(childName);
  if (pending > 0) return s.finiStatusPending(pending);
  if (settings.level == FiniLevel.suggest) {
    return s.finiStatusSuggest(childName);
  }
  return s.finiStatusOnTrack(childName);
}

Map<String, dynamic>? _plan(FiniProposal p) {
  final plan = p.evidence['plan'];
  return plan is Map ? plan.cast<String, dynamic>() : null;
}

/// The app a rule change is about, or the goal's name for a pool (SAF-274).
String _app(FiniProposal p, [S? s]) {
  final named = p.payload['app_name'] ?? p.payload['app_slug'];
  if (named != null) return named.toString();
  final intent = GoalIntent.values
      .where((intent) => intent.name == _plan(p)?['intent'])
      .firstOrNull;
  return intent != null && s != null ? goalTitle(s, intent) : '';
}

/// Why, in the parent's own language. A plan change carries its numbers in
/// `evidence.plan`, so it is said here rather than by the server's English
/// `reason`; anything else shows the reason as sent.
String finiReasonLine(S s, FiniProposal p) {
  final plan = _plan(p);
  if (plan == null) return p.reason;
  String hm(String key) => formatHm(s, (plan[key] as num?)?.toInt() ?? 0);
  return switch ((plan['action'], plan['why'])) {
    ('start', 'at_target') => s.planLineAtTarget(hm('to')),
    ('start', _) => s.planLineStart(hm('to')),
    ('step', _) => s.planLineStep(hm('from'), hm('to'), hm('target')),
    ('jump', 'parent') => s.planLineJumped(hm('to')),
    ('jump', _) => s.planLineJump(hm('to')),
    ('ease', _) => s.planLineEase(hm('from'), hm('to')),
    _ => p.reason,
  };
}

int _minutes(FiniProposal p, String key) =>
    (p.payload[key] as num?)?.toInt() ?? 0;

/// What a proposal did, for the activity log: "Set Roblox to 1 h 40 m a day".
String finiActivityTitle(S s, FiniProposal p, {required String childName}) {
  switch (p.kind) {
    case 'rule_change':
      if (p.payload['is_blocked'] == true) return s.finiDidBlock(_app(p));
      if (p.payload['is_blocked'] == false) return s.finiDidUnblock(_app(p));
      return s.finiDidLimit(
        _app(p, s),
        formatHm(s, _minutes(p, 'daily_limit_minutes')),
      );
    case 'task_review':
      return p.payload['decision'] == 'reject'
          ? s.finiDidReject
          : s.finiDidApprove;
    case 'time_grant':
      return s.finiDidGrant(_minutes(p, 'minutes'));
    case 'task_pack':
      return s.finiDidTasks;
    case 'goal_draft':
      return s.finiDidGoal;
    case 'child_message':
      return s.finiDidMessage(childName);
  }
  return s.finiAskGeneric;
}

/// A pending card's question: "Amir asks for 15 more minutes".
String finiCardTitle(
  S s,
  FiniProposal p, {
  required String childName,
  int? currentLimit,
}) {
  switch (p.kind) {
    case 'time_grant':
      return s.finiAskGrant(childName, _minutes(p, 'minutes'));
    case 'rule_change':
      final limit = p.payload['daily_limit_minutes'];
      if (limit is num) {
        final time = formatHm(s, limit.toInt());
        final current =
            currentLimit ?? (_plan(p)?['from'] as num?)?.toInt();
        return current != null && limit > current
            ? s.finiAskRaiseLimit(_app(p, s), time)
            : s.finiAskLimit(_app(p, s), time);
      }
      return finiActivityTitle(s, p, childName: childName);
    case 'task_review':
      return s.finiAskApprove;
  }
  return s.finiAskGeneric;
}

/// The yes button on a card: "Give 15 min" for time, "Approve" otherwise.
String finiCardYes(S s, FiniProposal p) =>
    p.kind == 'time_grant' ? s.finiGive(_minutes(p, 'minutes')) : s.finiApprove;

/// How a settled entry ended, when it was not Fini acting alone.
String? finiResultLine(S s, FiniProposal p) => switch (p.status) {
  FiniProposalStatus.undone => s.finiResultUndone,
  FiniProposalStatus.dismissed => s.finiResultDismissed,
  FiniProposalStatus.accepted => s.finiResultAccepted,
  FiniProposalStatus.rejected => s.finiResultRefused,
  _ => null,
};

/// "What it looked at": the signals the server listed as evidence, as one
/// line. Only short text values are shown; numbers and nested data stay in
/// the log.
String finiEvidenceLine(FiniProposal p) => p.evidence.values
    .whereType<String>()
    .where((value) => value.isNotEmpty && value.length <= 60)
    .join(' · ');
