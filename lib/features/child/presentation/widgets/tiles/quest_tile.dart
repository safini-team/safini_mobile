import 'package:flutter/material.dart';
import 'package:safini/core/theme/app_radius.dart';
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
              ? const Color(0xFFEDE4F9)
              : context.colorScheme.surface,
          borderRadius: BorderRadius.circular(AppRadius.lg),
          border: isHighlighted
              ? Border.all(color: const Color(0xFFCFB8F0), width: 1)
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
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: _QuestLabels(
                title: quest.title,
                subtitle: quest.subtitle,
                isCompleted: quest.isCompleted,
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            _CompletionBadge(isCompleted: quest.isCompleted),
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

  const _QuestIcon({
    required this.icon,
    required this.iconColor,
    required this.iconBackground,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        color: iconBackground,
        borderRadius: BorderRadius.circular(AppRadius.md),
      ),
      child: Icon(icon, color: iconColor, size: 22),
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
            decorationColor:
                context.colorScheme.onSurface.withValues(alpha: 0.45),
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

  const _CompletionBadge({required this.isCompleted});

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      width: 30,
      height: 30,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: isCompleted
            ? const Color(0xFF3FC48A)
            : context.colorScheme.surface,
        border: isCompleted
            ? null
            : Border.all(
                color: context.colorScheme.onSurface.withValues(alpha: 0.2),
                width: 1.5,
              ),
      ),
      child: isCompleted
          ? const Icon(Icons.check_rounded, color: Colors.white, size: 16)
          : null,
    );
  }
}
