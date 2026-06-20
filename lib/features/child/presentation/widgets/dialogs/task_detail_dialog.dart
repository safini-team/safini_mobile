import 'package:flutter/material.dart';
import 'package:safini/core/theme/app_radius.dart';
import 'package:safini/core/theme/app_spacing.dart';
import 'package:safini/core/utils/extension/theme_extension.dart';
import 'package:safini/core/translation/generated/l10n.dart';
import 'package:safini/features/child/presentation/cubit/quest_model.dart';

class TaskDetailDialog extends StatefulWidget {
  final QuestModel quest;

  /// If provided, the dialog shows a submit flow for available tasks.
  /// Return value: null = success, non-null = error message.
  final Future<String?> Function(String? note)? onSubmit;

  const TaskDetailDialog({super.key, required this.quest, this.onSubmit});

  static Future<void> show(
    BuildContext context,
    QuestModel quest, {
    Future<String?> Function(String? note)? onSubmit,
  }) {
    return showDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (_) => TaskDetailDialog(quest: quest, onSubmit: onSubmit),
    );
  }

  @override
  State<TaskDetailDialog> createState() => _TaskDetailDialogState();
}

class _TaskDetailDialogState extends State<TaskDetailDialog> {
  final _noteController = TextEditingController();
  bool _submitting = false;
  String? _error;

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _handleSubmit() async {
    if (_submitting) return;
    setState(() {
      _submitting = true;
      _error = null;
    });
    final error = await widget.onSubmit!(_noteController.text.trim().isEmpty ? null : _noteController.text.trim());
    if (!mounted) return;
    if (error == null) {
      Navigator.of(context).pop();
    } else {
      setState(() {
        _submitting = false;
        _error = error;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final quest = widget.quest;
    final canSubmit = widget.onSubmit != null && !quest.isSubmitted && !quest.isCompleted;

    return AlertDialog(
      backgroundColor: context.colorScheme.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.xl),
      ),
      contentPadding: EdgeInsets.zero,
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // ── Icon header ──────────────────────────────────────────────────
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: AppSpacing.xl),
            decoration: BoxDecoration(
              color: quest.iconBackground.withValues(alpha: 0.5),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(AppRadius.xl),
                topRight: Radius.circular(AppRadius.xl),
              ),
            ),
            child: Center(
              child: Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: quest.iconBackground,
                  borderRadius: BorderRadius.circular(AppRadius.xl),
                ),
                child: Icon(quest.icon, color: quest.iconColor, size: 40),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // ── Title + subtitle ──────────────────────────────────────
                Text(
                  quest.title,
                  textAlign: TextAlign.center,
                  style: context.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  quest.subtitle,
                  textAlign: TextAlign.center,
                  style: context.textTheme.bodyLarge?.copyWith(
                    color: context.colorScheme.onSurface.withValues(alpha: 0.5),
                  ),
                ),
                const SizedBox(height: AppSpacing.xl),
                // ── Reward pills ─────────────────────────────────────────
                _RewardRow(coins: quest.coins, xp: quest.xp),
                const SizedBox(height: AppSpacing.xl),

                // ── Submitted banner ─────────────────────────────────────
                if (quest.isSubmitted) ...[
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.md,
                      vertical: AppSpacing.sm,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFF8E1),
                      borderRadius: BorderRadius.circular(AppRadius.md),
                      border: Border.all(color: const Color(0xFFFFE082)),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.hourglass_top_rounded,
                            size: 16, color: Color(0xFFF59E0B)),
                        const SizedBox(width: AppSpacing.xs),
                        Expanded(
                          child: Text(
                            'Awaiting parent approval',
                            style: context.textTheme.bodySmall?.copyWith(
                              color: const Color(0xFF92400E),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                ],

                // ── Note field (available tasks only) ─────────────────────
                if (canSubmit) ...[
                  TextField(
                    controller: _noteController,
                    maxLines: 3,
                    maxLength: 200,
                    textCapitalization: TextCapitalization.sentences,
                    decoration: InputDecoration(
                      hintText: 'Add a note (optional)',
                      hintStyle: context.textTheme.bodyMedium?.copyWith(
                        color: context.colorScheme.onSurface.withValues(alpha: 0.4),
                      ),
                      filled: true,
                      fillColor: context.colorScheme.surface,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.md,
                        vertical: AppSpacing.sm,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(AppRadius.md),
                        borderSide: BorderSide(
                          color: context.colorScheme.onSurface.withValues(alpha: 0.15),
                        ),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(AppRadius.md),
                        borderSide: BorderSide(
                          color: context.colorScheme.onSurface.withValues(alpha: 0.15),
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(AppRadius.md),
                        borderSide: BorderSide(
                          color: context.colorScheme.primary,
                        ),
                      ),
                      counterStyle: context.textTheme.bodySmall?.copyWith(
                        color: context.colorScheme.onSurface.withValues(alpha: 0.4),
                      ),
                    ),
                  ),
                  if (_error != null) ...[
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      _error!,
                      style: context.textTheme.bodySmall?.copyWith(
                        color: context.colorScheme.error,
                      ),
                    ),
                  ],
                  const SizedBox(height: AppSpacing.md),
                ],

                // ── Action button ─────────────────────────────────────────
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: canSubmit
                        ? (_submitting ? null : _handleSubmit)
                        : () => Navigator.of(context).pop(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: context.colorScheme.primary,
                      foregroundColor: Colors.white,
                      disabledBackgroundColor:
                          context.colorScheme.primary.withValues(alpha: 0.5),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppRadius.pill),
                      ),
                      elevation: 0,
                    ),
                    child: _submitting
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : Text(
                            canSubmit ? 'Submit Task' : s.ok,
                            style: context.textTheme.labelLarge?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _RewardRow extends StatelessWidget {
  final int coins;
  final int xp;

  const _RewardRow({required this.coins, required this.xp});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _RewardPill(emoji: '🪙', label: '$coins', color: const Color(0xFFF5A623)),
        const SizedBox(width: AppSpacing.md),
        _RewardPill(emoji: '⭐', label: '$xp XP', color: const Color(0xFF7B6EF6)),
      ],
    );
  }
}

class _RewardPill extends StatelessWidget {
  final String emoji;
  final String label;
  final Color color;

  const _RewardPill({required this.emoji, required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(emoji, style: const TextStyle(fontSize: 16)),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.w700,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}
