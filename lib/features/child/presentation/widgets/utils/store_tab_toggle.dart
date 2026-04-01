import 'package:flutter/material.dart';
import 'package:safini/core/utils/extension/theme_extension.dart';
import 'package:safini/features/child/presentation/cubit/reward_store_model.dart';

class StoreTabToggle extends StatelessWidget {
  final StoreTab selectedTab;
  final ValueChanged<StoreTab> onTabChanged;

  const StoreTabToggle({
    super.key,
    required this.selectedTab,
    required this.onTabChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.18),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        children: [
          Expanded(
            child: _TabPill(
              label: 'App Time',
              isSelected: selectedTab == StoreTab.appTime,
              onTap: () => onTabChanged(StoreTab.appTime),
            ),
          ),
          Expanded(
            child: _TabPill(
              label: 'Avatar Items',
              isSelected: selectedTab == StoreTab.avatarItems,
              onTap: () => onTabChanged(StoreTab.avatarItems),
            ),
          ),
        ],
      ),
    );
  }
}

class _TabPill extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _TabPill({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(999),
        ),
        child: Center(
          child: Text(
            label,
            style: context.textTheme.labelLarge?.copyWith(
              color: isSelected ? context.colorScheme.primary : Colors.white,
              fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }
}
