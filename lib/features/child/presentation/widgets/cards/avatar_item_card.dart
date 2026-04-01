import 'package:flutter/material.dart';
import 'package:safini/core/theme/app_radius.dart';
import 'package:safini/core/utils/extension/theme_extension.dart';
import 'package:safini/features/child/presentation/cubit/reward_store_model.dart';

class AvatarItemCard extends StatelessWidget {
  final AvatarItem item;
  final bool canAfford;
  final VoidCallback? onTap;

  const AvatarItemCard({
    super.key,
    required this.item,
    required this.canAfford,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final bgColor = item.isEquipped
        ? context.colorScheme.primary
        : item.isLocked
            ? const Color(0xFFF0F0F0)
            : context.colorScheme.surface;

    return GestureDetector(
      onTap: item.isLocked ? null : onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(AppRadius.lg),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Opacity(
              opacity: item.isLocked ? 0.35 : 1.0,
              child: Text(
                item.emoji,
                style: const TextStyle(fontSize: 36),
              ),
            ),
            const SizedBox(height: 6),
            _ItemLabel(item: item, canAfford: canAfford),
          ],
        ),
      ),
    );
  }
}

class _ItemLabel extends StatelessWidget {
  final AvatarItem item;
  final bool canAfford;

  const _ItemLabel({required this.item, required this.canAfford});

  @override
  Widget build(BuildContext context) {
    if (item.isEquipped) {
      return Text(
        'EQUIPPED',
        style: context.textTheme.labelLarge?.copyWith(
          color: Colors.white,
          fontWeight: FontWeight.w700,
          fontSize: 10,
          letterSpacing: 0.6,
        ),
      );
    }
    if (item.isFree) {
      return Text(
        'FREE',
        style: context.textTheme.labelLarge?.copyWith(
          color: const Color(0xFF3EBF6A),
          fontWeight: FontWeight.w700,
          fontSize: 11,
        ),
      );
    }
    if (item.isLocked) {
      return Column(
        children: [
          Icon(
            Icons.lock_rounded,
            size: 14,
            color: context.colorScheme.onSurface.withValues(alpha: 0.35),
          ),
          if (item.lockLabel != null)
            Text(
              item.lockLabel!,
              style: context.textTheme.bodyMedium?.copyWith(
                color: context.colorScheme.onSurface.withValues(alpha: 0.4),
                fontSize: 10,
                fontWeight: FontWeight.w600,
              ),
            ),
        ],
      );
    }
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Text('🪙', style: TextStyle(fontSize: 11)),
        const SizedBox(width: 2),
        Text(
          '${item.cost}',
          style: context.textTheme.labelLarge?.copyWith(
            color: canAfford
                ? context.colorScheme.primary
                : context.colorScheme.onSurface.withValues(alpha: 0.45),
            fontWeight: FontWeight.w700,
            fontSize: 12,
          ),
        ),
      ],
    );
  }
}
