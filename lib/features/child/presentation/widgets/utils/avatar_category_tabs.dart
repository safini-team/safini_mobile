import 'package:flutter/material.dart';
import 'package:safini/core/utils/extension/theme_extension.dart';
import 'package:safini/features/child/presentation/cubit/profile_model.dart';

class AvatarCategoryTabs extends StatelessWidget {
  final AvatarCategory selectedCategory;
  final ValueChanged<AvatarCategory> onChanged;

  const AvatarCategoryTabs({
    super.key,
    required this.selectedCategory,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: AvatarCategory.values
          .map(
            (cat) => Expanded(
              child: _CategoryTab(
                category: cat,
                isSelected: cat == selectedCategory,
                onTap: () => onChanged(cat),
              ),
            ),
          )
          .toList(),
    );
  }
}

class _CategoryTab extends StatelessWidget {
  final AvatarCategory category;
  final bool isSelected;
  final VoidCallback onTap;

  const _CategoryTab({
    required this.category,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 12),
          Text(
            category.label,
            style: context.textTheme.labelLarge?.copyWith(
              color: isSelected
                  ? context.colorScheme.primary
                  : context.colorScheme.onSurface.withValues(alpha: 0.4),
              fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
              fontSize: 11,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 8),
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            height: 2.5,
            decoration: BoxDecoration(
              color: isSelected
                  ? context.colorScheme.primary
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        ],
      ),
    );
  }
}
