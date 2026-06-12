import 'package:flutter/material.dart';
import 'package:safini/core/theme/app_spacing.dart';
import 'package:safini/core/utils/extension/theme_extension.dart';

class AppNavBarItem {
  final IconData icon;
  final IconData? activeIcon;
  final String label;
  final bool isSelected;
  final VoidCallback? onTap;

  const AppNavBarItem({
    required this.icon,
    this.activeIcon,
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
        border: Border(
          top: BorderSide(
            color: context.colorScheme.onSurface.withValues(alpha: 0.05),
            width: 1,
          ),
        ),
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

    final currentIcon = item.isSelected ? (item.activeIcon ?? item.icon) : item.icon;

    return GestureDetector(
      onTap: item.onTap,
      behavior: HitTestBehavior.opaque,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(currentIcon, color: color, size: 26),
          const SizedBox(height: 3),
          Text(
            item.label,
            style: context.textTheme.bodyMedium?.copyWith(
              color: color,
              fontSize: 11,
              fontWeight: item.isSelected ? FontWeight.w600 : FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
