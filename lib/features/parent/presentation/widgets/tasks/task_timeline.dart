import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:safini/core/theme/app_colors.dart';
import 'package:safini/core/theme/app_typography.dart';
import 'package:safini/core/translation/generated/l10n.dart';
import 'package:safini/core/utils/relative_date.dart';
import 'package:safini/features/parent/domain/models/parent_tasks_response_model.dart';

/// One moment on a task: what happened, and when.
class TaskTimelineEvent {
  const TaskTimelineEvent({
    required this.title,
    required this.when,
    required this.dot,
  });

  final String title;
  final String when;
  final Color dot;
}

/// "Today, 18:04" — the same shape the Done sheet used for the approval line.
String taskMomentLabel(BuildContext context, S s, DateTime at) {
  final locale = Localizations.localeOf(context).toLanguageTag();
  final day = relativeDateLabel(context, s, at);
  return '$day, ${DateFormat.Hm(locale).format(at)}';
}

/// Sent, then the parent's decision. A review that is still open only has the
/// first of those.
List<TaskTimelineEvent> taskTimeline(
  BuildContext context,
  S s,
  ParentTaskInstanceModel task, {
  required bool includeDecision,
}) {
  final events = <TaskTimelineEvent>[];
  final submitted = task.submittedAt;
  if (submitted != null) {
    events.add(
      TaskTimelineEvent(
        title: s.sentForApproval,
        when: taskMomentLabel(context, s, submitted),
        dot: AppColors.textTertiary,
      ),
    );
  }
  if (!includeDecision) return events;

  final name = task.reviewedByParent?.displayName?.trim() ?? '';
  final reviewed = task.reviewedAt;
  if (name.isEmpty && reviewed == null) return events;

  final rejected = task.status.toLowerCase() == 'rejected';
  events.add(
    TaskTimelineEvent(
      title: rejected
          ? (name.isEmpty ? s.askedToRedoLabel : s.askedToRedoBy(name))
          : (name.isEmpty ? s.approvedLabel : s.approvedBy(name)),
      when: reviewed == null ? '' : taskMomentLabel(context, s, reviewed),
      dot: rejected ? AppColors.danger : AppColors.success,
    ),
  );
  return events;
}

/// Two quiet rows and a rail: when the child sent it, then who decided.
class TaskTimeline extends StatelessWidget {
  const TaskTimeline({super.key, required this.events});

  final List<TaskTimelineEvent> events;

  @override
  Widget build(BuildContext context) {
    if (events.isEmpty) return const SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (var i = 0; i < events.length; i++)
          _EventRow(event: events[i], last: i == events.length - 1),
      ],
    );
  }
}

class _EventRow extends StatelessWidget {
  const _EventRow({required this.event, required this.last});

  final TaskTimelineEvent event;
  final bool last;

  @override
  Widget build(BuildContext context) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(
            width: 16,
            child: CustomPaint(
              painter: _RailPainter(
                dot: event.dot,
                drawLine: !last,
                line: AppColors.strokeQuiet,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(bottom: last ? 0 : 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    event.title,
                    style: AppText.chip.copyWith(fontWeight: FontWeight.w500),
                  ),
                  if (event.when.isNotEmpty) ...[
                    const SizedBox(height: 2),
                    Text(event.when, style: AppText.metaSm),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Dot sits on the first line of text. The rail runs into the next dot so the
/// two moments read as one sequence.
class _RailPainter extends CustomPainter {
  const _RailPainter({
    required this.dot,
    required this.drawLine,
    required this.line,
  });

  final Color dot;
  final bool drawLine;
  final Color line;

  static const double _dot = 8;
  static const double _centerY = 6 + _dot / 2;

  @override
  void paint(Canvas canvas, Size size) {
    final x = size.width / 2;
    canvas.drawCircle(Offset(x, _centerY), _dot / 2, Paint()..color = dot);
    if (!drawLine) return;
    canvas.drawLine(
      Offset(x, _centerY + _dot / 2),
      Offset(x, size.height + _centerY),
      Paint()
        ..color = line
        ..strokeWidth = 1.5
        ..strokeCap = StrokeCap.round,
    );
  }

  @override
  bool shouldRepaint(_RailPainter old) =>
      old.dot != dot || old.drawLine != drawLine || old.line != line;
}
