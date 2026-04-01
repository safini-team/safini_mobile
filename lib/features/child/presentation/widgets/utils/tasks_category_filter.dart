import 'package:flutter/material.dart';
import 'package:safini/core/theme/app_spacing.dart';
import 'package:safini/core/utils/extension/theme_extension.dart';
import 'package:safini/features/child/presentation/cubit/tasks_model.dart';

class TasksCategoryFilter extends StatelessWidget {
  final TaskCategory selectedCategory;
  final ValueChanged<TaskCategory> onChanged;

  const TasksCategoryFilter({
    super.key,
    required this.selectedCategory,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      child: Row(
        children: TaskCategory.values
            .map(
              (cat) => Padding(
                padding: const EdgeInsets.only(right: AppSpacing.sm),
                child: _CategoryPill(
                  category: cat,
                  isSelected: cat == selectedCategory,
                  onTap: () => onChanged(cat),
                ),
              ),
            )
            .toList(),
      ),
    );
  }
}

class _CategoryPill extends StatelessWidget {
  final TaskCategory category;
  final bool isSelected;
  final VoidCallback onTap;

  const _CategoryPill({
    required this.category,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? context.colorScheme.primary : Colors.white,
          borderRadius: BorderRadius.circular(999),
          border: isSelected
              ? null
              : Border.all(
                  color: context.colorScheme.onSurface.withValues(alpha: 0.12),
                ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: context.colorScheme.primary.withValues(alpha: 0.25),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ]
              : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(category.emoji, style: const TextStyle(fontSize: 14)),
            const SizedBox(width: 5),
            Text(
              category.label,
              style: context.textTheme.labelLarge?.copyWith(
                color: isSelected
                    ? Colors.white
                    : context.colorScheme.onSurface.withValues(alpha: 0.6),
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
