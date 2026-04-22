import 'package:flutter/material.dart';
import 'package:safini/core/theme/app_spacing.dart';
import 'package:safini/core/utils/extension/theme_extension.dart';

class AppNavBarItem {
  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback? onTap;

  const AppNavBarItem({
    required this.icon,
    required this.label,
    this.isSelected = false,
    this.onTap,
  });
}

class AppNavBar extends StatelessWidget {
  final List<AppNavBarItem> items;

  const AppNavBar({super.key, required this.items});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: context.colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 12,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: items.map((item) => _NavItem(item: item)).toList(),
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final AppNavBarItem item;

  const _NavItem({required this.item});

  @override
  Widget build(BuildContext context) {
    final color = item.isSelected
        ? context.colorScheme.primary
        : context.colorScheme.onSurface.withValues(alpha: 0.4);

    return GestureDetector(
      onTap: item.onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(item.icon, color: color, size: 26),
          const SizedBox(height: 3),
          Text(
            item.label,
            style: context.textTheme.bodyMedium?.copyWith(
              color: color,
              fontSize: 11,
              fontWeight: item.isSelected ? FontWeight.w600 : FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }
}
