import 'package:flutter/material.dart';
import 'package:safini/core/theme/app_radius.dart';
import 'package:safini/core/translation/generated/l10n.dart';
import 'package:safini/core/theme/app_spacing.dart';
import 'package:safini/core/utils/extension/theme_extension.dart';
import 'package:safini/features/child/presentation/cubit/quest_model.dart';

class QuestTile extends StatelessWidget {
  final QuestModel quest;
  final bool isHighlighted;
  final VoidCallback? onTap;

  const QuestTile({
    super.key,
    required this.quest,
    this.isHighlighted = false,
    this.onTap,
  });

  String _getLocalizedTitle(BuildContext context, String id) {
    switch (id) {
      case '1':
        return S.of(context).taskDuolingoTitle;
      case '2':
        return S.of(context).taskStepsTitle;
      case '3':
        return S.of(context).taskPuzzleTitle;
      case '4':
        return S.of(context).taskChessTitle;
      case '5':
        return S.of(context).taskReadingTitle;
      case '6':
        return S.of(context).taskRoomTitle;
      default:
        return quest.title;
    }
  }

  String _getLocalizedSubtitle(BuildContext context, String id) {
    switch (id) {
      case '1':
        return S.of(context).taskDuolingoSub;
      case '2':
        return S.of(context).taskStepsSub;
      case '3':
        return S.of(context).taskPuzzleSub;
      case '4':
        return S.of(context).taskChessSub;
      case '5':
        return S.of(context).taskReadingSub;
      case '6':
        return S.of(context).taskRoomSub;
      default:
        return quest.subtitle;
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.xs,
        ),
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.md,
        ),
        decoration: BoxDecoration(
          color: isHighlighted
              ? context.colorScheme.primary.withValues(alpha: 0.1)
              : context.colorScheme.surface,
          borderRadius: BorderRadius.circular(AppRadius.lg),
          border: isHighlighted
              ? Border.all(color: context.colorScheme.primary.withValues(alpha: 0.3), width: 1)
              : null,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            _QuestIcon(
              icon: quest.icon,
              iconColor: quest.iconColor,
              iconBackground: quest.iconBackground,
              emoji: quest.emoji,
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: _QuestLabels(
                title: _getLocalizedTitle(context, quest.id),
                subtitle: _getLocalizedSubtitle(context, quest.id),
                isCompleted: quest.isCompleted,
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            _CompletionBadge(isCompleted: quest.isCompleted, isSubmitted: quest.isSubmitted),
          ],
        ),
      ),
    );
  }
}

class _QuestIcon extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final Color iconBackground;
  final String? emoji;

  const _QuestIcon({
    required this.icon,
    required this.iconColor,
    required this.iconBackground,
    this.emoji,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 44,
      height: 44,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: iconBackground,
        borderRadius: BorderRadius.circular(AppRadius.md),
      ),
      child: emoji != null && emoji!.trim().isNotEmpty
          ? Text(emoji!.trim(), style: const TextStyle(fontSize: 22))
          : Icon(icon, color: iconColor, size: 22),
    );
  }
}

class _QuestLabels extends StatelessWidget {
  final String title;
  final String subtitle;
  final bool isCompleted;

  const _QuestLabels({
    required this.title,
    required this.subtitle,
    required this.isCompleted,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: context.textTheme.bodyLarge?.copyWith(
            fontWeight: FontWeight.w600,
            decoration: isCompleted ? TextDecoration.lineThrough : null,
            decorationColor: context.colorScheme.onSurface.withValues(
              alpha: 0.45,
            ),
            color: isCompleted
                ? context.colorScheme.onSurface.withValues(alpha: 0.45)
                : context.colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          subtitle,
          style: context.textTheme.bodyMedium?.copyWith(
            color: context.colorScheme.onSurface.withValues(alpha: 0.45),
          ),
        ),
      ],
    );
  }
}

class _CompletionBadge extends StatelessWidget {
  final bool isCompleted;
  final bool isSubmitted;

  const _CompletionBadge({required this.isCompleted, this.isSubmitted = false});

  @override
  Widget build(BuildContext context) {
    if (isCompleted) {
      return AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        width: 30,
        height: 30,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: context.successColor,
        ),
        child: Icon(Icons.check_rounded, color: context.colorScheme.onPrimary, size: 16),
      );
    }
    if (isSubmitted) {
      return Container(
        width: 30,
        height: 30,
        decoration: const BoxDecoration(
          shape: BoxShape.circle,
          color: Color(0xFFFFF8E1),
        ),
        child: const Icon(Icons.hourglass_top_rounded, size: 16, color: Color(0xFFF59E0B)),
      );
    }
    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      width: 30,
      height: 30,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: context.colorScheme.surface,
        border: Border.all(
          color: context.colorScheme.onSurface.withValues(alpha: 0.2),
          width: 1.5,
        ),
      ),
    );
  }
}
