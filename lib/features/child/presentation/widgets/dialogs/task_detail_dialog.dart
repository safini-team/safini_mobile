import 'package:flutter/material.dart';
import 'package:safini/core/theme/app_colors.dart';
import 'package:safini/core/theme/app_radius.dart';
import 'package:safini/core/theme/app_typography.dart';
import 'package:safini/core/translation/generated/l10n.dart';
import 'package:safini/core/utils/widgets/ds/ds.dart';
import 'package:safini/features/child/presentation/cubit/quest_model.dart';

/// The child's task sheet from the artboard: icon, title, coins, the detail
/// copy, an optional note for the parent, then press-and-hold to send.
///
/// Still named `TaskDetailDialog` because every caller uses `.show()`; it is a
/// bottom sheet now, not a dialog.
class TaskDetailDialog extends StatefulWidget {
  const TaskDetailDialog({super.key, required this.quest, this.onSubmit});

  final QuestModel quest;

  /// Submit flow for an open task. Returns null on success, else the message.
  final Future<String?> Function(String? note)? onSubmit;

  static Future<void> show(
    BuildContext context,
    QuestModel quest, {
    Future<String?> Function(String? note)? onSubmit,
  }) {
    return showDsSheet<void>(
      context: context,
      builder: (_) => TaskDetailDialog(quest: quest, onSubmit: onSubmit),
    );
  }

  @override
  State<TaskDetailDialog> createState() => _TaskDetailDialogState();
}

class _TaskDetailDialogState extends State<TaskDetailDialog> {
  final _note = TextEditingController();
  bool _submitting = false;
  String? _error;

  @override
  void dispose() {
    _note.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_submitting) return;
    setState(() {
      _submitting = true;
      _error = null;
    });

    final text = _note.text.trim();
    final error = await widget.onSubmit!(text.isEmpty ? null : text);
    if (!mounted) return;

    if (error == null) {
      Navigator.of(context).pop();
      return;
    }
    setState(() {
      _submitting = false;
      _error = error;
    });
  }

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final quest = widget.quest;
    final subtitle = quest.localizedSubtitle(s);
    final canSubmit = widget.onSubmit != null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            DsEmojiTile(
              emoji: quest.emoji ?? '⭐',
              size: 52,
              radius: AppRadius.icon,
              background: AppColors.primaryTint,
              fontSize: 26,
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    quest.title,
                    style: AppText.title4.copyWith(height: 1.18),
                  ),
                  if (subtitle.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(subtitle, style: AppText.meta.copyWith(fontSize: 14)),
                  ],
                ],
              ),
            ),
            const SizedBox(width: 10),
            DsPill.coins(
              label: '+${quest.coins}',
              height: 28,
              fontSize: 14.5,
              horizontalPadding: 12,
            ),
          ],
        ),
        if (quest.reviewNote != null && quest.reviewNote!.isNotEmpty) ...[
          const SizedBox(height: 18),
          DsSheetPanel(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                DsOverlineText(s.noteFromParent),
                const SizedBox(height: 7),
                Text(
                  quest.reviewNote!,
                  style: AppText.body.copyWith(
                    fontWeight: FontWeight.w400,
                    height: 1.45,
                  ),
                ),
              ],
            ),
          ),
        ],
        if (canSubmit) ...[
          const SizedBox(height: 16),
          DsSheetPanel(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                DsOverlineText(s.noteForParent),
                const SizedBox(height: 7),
                TextField(
                  controller: _note,
                  maxLines: 2,
                  minLines: 2,
                  cursorColor: AppColors.primary,
                  style: AppText.body.copyWith(
                    fontWeight: FontWeight.w400,
                    height: 1.4,
                  ),
                  decoration: InputDecoration(
                    filled: false,
                    isDense: true,
                    border: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    contentPadding: EdgeInsets.zero,
                    hintText: s.reviewNoteHint,
                    hintStyle: AppText.body.copyWith(
                      fontWeight: FontWeight.w400,
                      color: AppColors.textTertiary,
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (_error != null) ...[
            const SizedBox(height: 12),
            Text(
              _error!,
              style: AppText.metaSm.copyWith(color: AppColors.dangerDeep),
            ),
          ],
          const SizedBox(height: 20),
          if (_submitting)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 18),
              child: Center(
                child: SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(strokeWidth: 2.4),
                ),
              ),
            )
          else
            DsHoldButton(
              label: s.holdToMarkDone,
              holdingLabel: s.keepHolding,
              radius: AppRadius.panel,
              padding: const EdgeInsets.all(18),
              fontSize: 17,
              onComplete: _submit,
            ),
        ] else ...[
          const SizedBox(height: 20),
          DsSheetPanel(
            padding: const EdgeInsets.all(16),
            child: Text(
              quest.isSubmitted ? s.waitingForParentCheck : s.paidOutNice,
              textAlign: TextAlign.center,
              style: AppText.body.copyWith(
                fontWeight: FontWeight.w600,
                color: AppColors.textSecondary,
              ),
            ),
          ),
        ],
      ],
    );
  }
}
