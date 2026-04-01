import 'package:flutter/material.dart';
import 'package:safini/core/theme/app_radius.dart';
import 'package:safini/core/theme/app_spacing.dart';
import 'package:safini/core/utils/extension/theme_extension.dart';
import 'package:safini/features/child/presentation/cubit/reward_store_model.dart';

class AppTimeItemCard extends StatelessWidget {
  final AppTimeItem item;
  final bool canAfford;
  final VoidCallback? onTap;

  const AppTimeItemCard({
    super.key,
    required this.item,
    required this.canAfford,
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
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: item.iconBackground,
                borderRadius: BorderRadius.circular(AppRadius.md),
              ),
              child: Icon(item.icon, color: item.iconColor, size: 26),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.title,
                    style: context.textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    item.subtitle,
                    style: context.textTheme.bodyMedium?.copyWith(
                      color: context.colorScheme.onSurface.withValues(alpha: 0.5),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            _CoinPill(cost: item.cost, canAfford: canAfford),
          ],
        ),
      ),
    );
  }
}

class _CoinPill extends StatelessWidget {
  final int cost;
  final bool canAfford;

  const _CoinPill({required this.cost, required this.canAfford});

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: canAfford ? context.colorScheme.primary : Colors.transparent,
        borderRadius: BorderRadius.circular(999),
        border: canAfford
            ? null
            : Border.all(
                color: context.colorScheme.onSurface.withValues(alpha: 0.2),
              ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('🪙', style: TextStyle(fontSize: 14)),
          const SizedBox(width: 4),
          Text(
            '$cost',
            style: context.textTheme.labelLarge?.copyWith(
              color: canAfford
                  ? Colors.white
                  : context.colorScheme.onSurface.withValues(alpha: 0.5),
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}
