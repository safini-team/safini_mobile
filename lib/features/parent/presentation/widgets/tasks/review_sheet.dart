import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
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

/// The artboard's review sheet: what was submitted, when the child sent it,
/// their note, then approve or ask to redo — with an optional note on redo.
Future<void> showReviewSheet(
  BuildContext context, {
  required ParentTasksCubit cubit,
  required ParentTaskInstanceModel task,
  String? childName,
}) {
  return showDsSheet<void>(
    context: context,
    builder: (context) => BlocProvider.value(
      value: cubit,
      child: _ReviewSheet(task: task, childName: childName),
    ),
  );
}

class _ReviewSheet extends StatefulWidget {
  const _ReviewSheet({required this.task, this.childName});

  final ParentTaskInstanceModel task;
  final String? childName;

  @override
  State<_ReviewSheet> createState() => _ReviewSheetState();
}

class _ReviewSheetState extends State<_ReviewSheet> {
  late ParentTaskInstanceModel _task = widget.task;
  bool? _deciding;
  bool _composingRedo = false;
  final _note = TextEditingController();
  final _noteFocus = FocusNode();
  final _noteKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _note.dispose();
    _noteFocus.dispose();
    super.dispose();
  }

  /// The list row already has the photo. The detail call is for `submitted_at`,
  /// which the day list does not always carry.
  Future<void> _load() async {
    final result = await context.read<ParentTasksCubit>().fetchTaskDetail(
      widget.task.id,
    );
    if (!mounted) return;
    result.fold((_) {}, (task) {
      final freshUrl = (task.submissionImageUrl ?? '').trim();
      final currentUrl = (_task.submissionImageUrl ?? '').trim();
      // Detail signing can come back empty while the list URL still works.
      setState(() {
        _task = freshUrl.isEmpty && currentUrl.isNotEmpty
            ? task.copyWith(submissionImageUrl: currentUrl)
            : task;
      });
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

  void _startRedo() {
    setState(() => _composingRedo = true);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _noteFocus.requestFocus();
      final field = _noteKey.currentContext;
      if (field != null) {
        Scrollable.ensureVisible(
          field,
          alignment: 0.6,
          duration: const Duration(milliseconds: 220),
        );
      }
    });
  }

  void _cancelRedo() {
    _noteFocus.unfocus();
    setState(() => _composingRedo = false);
  }

  Future<void> _decide(bool approve) async {
    if (_deciding != null) return;
    if (!approve && !_composingRedo) {
      _startRedo();
      return;
    }
    setState(() => _deciding = approve);
    final navigator = Navigator.of(context);
    await context.read<ParentTasksCubit>().reviewTask(
      widget.task.id,
      approve: approve,
      note: approve ? null : _note.text,
    );
    if (mounted) navigator.pop();
  }

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final task = _task;
    final child = _childFor(context, task.childId);
    final kid = widget.childName ?? child?.nickname ?? '';
    final coins = task.rewardCoins ?? 0;
    final note = (task.submissionNote ?? '').trim();
    // proof_mode is `text_image` when a photo was asked for. The old check
    // looked for 'photo', which never matches, so this panel never rendered.
    final wantsPhoto = (task.proofMode ?? '').toLowerCase().contains('image');
    final photoUrl = (task.submissionImageUrl ?? '').trim();
    final events = taskTimeline(context, s, task, includeDecision: false);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        DsOverlineText(s.reviewTaskSheetTitle),
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
                  s.worthCoins(kid, s.coinCountShort(coins)),
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
        if (wantsPhoto) ...[
          const SizedBox(height: 18),
          TaskProofPhoto(url: photoUrl, emptyLabel: s.photoProofAsked),
        ],
        if (note.isNotEmpty) ...[
          const SizedBox(height: 16),
          DsSheetPanel(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                DsOverlineText(s.theirNote),
                const SizedBox(height: 7),
                Text(
                  note,
                  style: AppText.body.copyWith(
                    fontWeight: FontWeight.w400,
                    height: 1.45,
                  ),
                ),
              ],
            ),
          ),
        ],
        if ((task.description ?? '').trim().isNotEmpty) ...[
          const SizedBox(height: 12),
          Text(
            task.description!.trim(),
            style: AppText.bodyRegular.copyWith(color: AppColors.inkSoft),
          ),
        ],
        const SizedBox(height: 20),
        if (!_composingRedo)
          DsPrimaryButton(
            label: s.approvePayCoins(s.coinCountShort(coins)),
            busy: _deciding == true,
            onTap: () => _decide(true),
          ),
        if (!_composingRedo) const SizedBox(height: 9),
        if (_composingRedo) ...[
          DsSheetPanel(
            key: _noteKey,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                DsOverlineText(s.noteForParent),
                const SizedBox(height: 7),
                TextField(
                  controller: _note,
                  focusNode: _noteFocus,
                  maxLines: 3,
                  minLines: 2,
                  maxLength: 2000,
                  textCapitalization: TextCapitalization.sentences,
                  textInputAction: TextInputAction.newline,
                  cursorColor: AppColors.primary,
                  style: AppText.body.copyWith(
                    fontWeight: FontWeight.w400,
                    height: 1.4,
                  ),
                  buildCounter:
                      (
                        _, {
                        required currentLength,
                        required isFocused,
                        maxLength,
                      }) => null,
                  decoration: InputDecoration(
                    filled: false,
                    isDense: true,
                    border: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    contentPadding: EdgeInsets.zero,
                    hintText: s.redoNoteHint,
                    hintStyle: AppText.body.copyWith(
                      fontWeight: FontWeight.w400,
                      color: AppColors.textTertiary,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
        ],
        DsPrimaryButton.secondary(
          label: s.askToRedo,
          busy: _deciding == false,
          onTap: () => _decide(false),
        ),
        if (_composingRedo) ...[
          const SizedBox(height: 4),
          Pressable(
            onTap: _deciding != null ? null : _cancelRedo,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Text(
                s.cancel,
                textAlign: TextAlign.center,
                style: AppText.link,
              ),
            ),
          ),
        ],
      ],
    );
  }
}
