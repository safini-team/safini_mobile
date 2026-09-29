import 'package:flutter/material.dart';
import 'package:safini/core/theme/app_colors.dart';
import 'package:safini/core/theme/app_typography.dart';
import 'package:safini/core/translation/generated/l10n.dart';
import 'package:safini/core/utils/widgets/ds/ds.dart';
import 'package:safini/features/models/domain/models/family_model.dart';
import 'package:safini/features/parent/domain/models/parent_tasks_response_model.dart';
import 'package:safini/features/parent/presentation/cubit/parent_family_cubit.dart';
import 'package:safini/features/parent/presentation/cubit/parent_tasks_cubit.dart';
import 'package:safini/features/parent/presentation/widgets/tasks/task_proof_photo.dart';
import 'package:safini/features/parent/presentation/widgets/tasks/task_timeline.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// A done task from the history, read-only: who did it and what it paid,
/// when the child sent it and which parent decided, and what was sent.
///
/// The list carries the note but not the photo (it only signs photos still in
/// review), so the sheet opens on the list's copy and fetches the task once
/// for a fresh photo URL.
Future<void> showDoneTaskSheet(
  BuildContext context, {
  required ParentTasksCubit cubit,
  required ParentTaskInstanceModel task,
  String? childName,
}) {
  return showDsSheet<void>(
    context: context,
    builder: (context) => BlocProvider.value(
      value: cubit,
      child: DoneTaskSheet(task: task, childName: childName),
    ),
  );
}

class DoneTaskSheet extends StatefulWidget {
  const DoneTaskSheet({super.key, required this.task, this.childName});

  final ParentTaskInstanceModel task;
  final String? childName;

  @override
  State<DoneTaskSheet> createState() => _DoneTaskSheetState();
}

class _DoneTaskSheetState extends State<DoneTaskSheet> {
  late ParentTaskInstanceModel _task = widget.task;
  bool _loading = true;
  bool _failed = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final result = await context.read<ParentTasksCubit>().fetchTaskDetail(
      widget.task.id,
    );
    if (!mounted) return;
    setState(() {
      _loading = false;
      result.fold((_) => _failed = true, (task) => _task = task);
    });
  }

  ChildSummaryModel? _childFor(BuildContext context, String? childId) {
    if (childId == null || childId.isEmpty) return null;
    try {
      return context
          .read<ParentFamilyCubit>()
          .state
          .family
          ?.children
          .where((c) => c.id == childId)
          .firstOrNull;
    } catch (_) {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final task = _task;
    final child = _childFor(context, task.childId);
    final kid = widget.childName ?? child?.nickname ?? '';
    final coins = task.rewardCoins ?? 0;
    final note = (task.submissionNote ?? '').trim();
    final reply = (task.reviewNote ?? '').trim();
    final description = (task.description ?? '').trim();
    final photoUrl = (task.submissionImageUrl ?? '').trim();
    final wantsPhoto = (task.proofMode ?? '').toLowerCase().contains('image');
    final showPhoto = wantsPhoto || photoUrl.isNotEmpty;
    final events = taskTimeline(context, s, task, includeDecision: true);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        DsOverlineText(s.doneTaskSheetTitle),
        const SizedBox(height: 8),
        Text(task.displayTitle, style: AppText.title3),
        if (kid.isNotEmpty) ...[
          const SizedBox(height: 14),
          Row(
            children: [
              DsKidFace(
                name: kid,
                avatar: child?.avatarLook,
                color: AppColors.kidColor(task.childId ?? kid),
                size: 30,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  s.paidCoinsTo(kid, s.coinCountShort(coins)),
                  style: AppText.chip.copyWith(
                    fontWeight: FontWeight.w400,
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
            ],
          ),
        ],
        if (events.isNotEmpty) ...[
          const SizedBox(height: 16),
          TaskTimeline(events: events),
        ],
        if (showPhoto) ...[
          const SizedBox(height: 18),
          TaskProofPhoto(
            url: photoUrl,
            loading: _loading,
            emptyLabel: _failed ? s.proofPhotoFailed : s.photoProofAsked,
            failedLabel: s.proofPhotoFailed,
          ),
        ],
        if (note.isNotEmpty) ...[
          const SizedBox(height: 16),
          _NotePanel(label: s.theirNote, text: note),
        ],
        if (reply.isNotEmpty) ...[
          const SizedBox(height: 12),
          _NotePanel(label: s.parentsNote, text: reply),
        ],
        if (!showPhoto && note.isEmpty) ...[
          const SizedBox(height: 16),
          Text(
            s.nothingSentWithTask,
            style: AppText.metaSm.copyWith(color: AppColors.textTertiary),
          ),
        ],
        if (description.isNotEmpty) ...[
          const SizedBox(height: 12),
          Text(
            description,
            style: AppText.bodyRegular.copyWith(color: AppColors.inkSoft),
          ),
        ],
        const SizedBox(height: 20),
        DsPrimaryButton.secondary(
          label: s.close,
          onTap: () => Navigator.of(context).pop(),
        ),
      ],
    );
  }
}

class _NotePanel extends StatelessWidget {
  const _NotePanel({required this.label, required this.text});

  final String label;
  final String text;

  @override
  Widget build(BuildContext context) {
    return DsSheetPanel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          DsOverlineText(label),
          const SizedBox(height: 7),
          Text(
            text,
            style: AppText.body.copyWith(
              fontWeight: FontWeight.w400,
              height: 1.45,
            ),
          ),
        ],
      ),
    );
  }
}
