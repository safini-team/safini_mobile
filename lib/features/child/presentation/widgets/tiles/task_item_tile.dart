import 'package:flutter/material.dart';
import 'package:safini/core/theme/app_radius.dart';
import 'package:safini/core/theme/app_spacing.dart';
import 'package:safini/core/utils/extension/theme_extension.dart';
import 'package:safini/features/child/presentation/cubit/tasks_model.dart';

class TaskItemTile extends StatelessWidget {
  final TaskItem task;
  final VoidCallback? onTap;

  const TaskItemTile({
    super.key,
    required this.task,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.xs,
        ),
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.md,
        ),
        decoration: BoxDecoration(
          color: context.colorScheme.surface,
          borderRadius: BorderRadius.circular(AppRadius.lg),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            _TaskIcon(
              icon: task.icon,
              iconColor: task.iconColor,
              iconBackground: task.iconBackground,
              isCompleted: task.isCompleted,
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    task.title,
                    style: context.textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                      decoration: task.isCompleted
                          ? TextDecoration.lineThrough
                          : null,
                      decorationColor:
                          context.colorScheme.onSurface.withValues(alpha: 0.4),
                      color: task.isCompleted
                          ? context.colorScheme.onSurface.withValues(alpha: 0.4)
                          : context.colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    task.subtitle,
                    style: context.textTheme.bodyMedium?.copyWith(
                      color:
                          context.colorScheme.onSurface.withValues(alpha: 0.45),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      _RewardBadge(
                        label: '${task.coins} coins',
                        emoji: '🪙',
                        bgColor: const Color(0xFFFFF3D6),
                        textColor: const Color(0xFFB07D1A),
                      ),
                      const SizedBox(width: AppSpacing.xs),
                      _RewardBadge(
                        label: '${task.xp} XP',
                        emoji: '⚡',
                        bgColor: const Color(0xFFFFFACC),
                        textColor: const Color(0xFFB09A00),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            _CompletionBadge(isCompleted: task.isCompleted),
          ],
        ),
      ),
    );
  }
}

class _TaskIcon extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final Color iconBackground;
  final bool isCompleted;

  const _TaskIcon({
    required this.icon,
    required this.iconColor,
    required this.iconBackground,
    required this.isCompleted,
  });

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: isCompleted ? 0.55 : 1.0,
      child: Container(
        width: 46,
        height: 46,
        decoration: BoxDecoration(
          color: iconBackground,
          borderRadius: BorderRadius.circular(AppRadius.md),
        ),
        child: Icon(icon, color: iconColor, size: 24),
      ),
    );
  }
}

class _RewardBadge extends StatelessWidget {
  final String emoji;
  final String label;
  final Color bgColor;
  final Color textColor;

  const _RewardBadge({
    required this.emoji,
    required this.label,
    required this.bgColor,
    required this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(emoji, style: const TextStyle(fontSize: 11)),
          const SizedBox(width: 3),
          Text(
            label,
            style: context.textTheme.bodyMedium?.copyWith(
              color: textColor,
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
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
