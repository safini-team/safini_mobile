import 'package:flutter/material.dart';
import 'package:safini/core/utils/extension/theme_extension.dart';

/// A price pill showing a coin icon and a cost.
///
/// When [canAfford] is true it is filled with the primary color; otherwise it
/// is a muted outline so the child sees the item is out of reach.
class AppCoinPill extends StatelessWidget {
  /// The coin cost to display.
  final int cost;

  /// Whether the child currently has enough coins.
  final bool canAfford;

  const AppCoinPill({super.key, required this.cost, required this.canAfford});

  @override
  Widget build(BuildContext context) {
    final scheme = context.colorScheme;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: canAfford ? scheme.primary : Colors.transparent,
        borderRadius: BorderRadius.circular(999),
        border: canAfford
            ? null
            : Border.all(color: scheme.onSurface.withValues(alpha: 0.2)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('🪙', style: context.textTheme.bodyMedium),
          const SizedBox(width: 4),
          Text(
            '$cost',
            style: context.textTheme.labelLarge?.copyWith(
              color: canAfford
                  ? scheme.onPrimary
                  : scheme.onSurface.withValues(alpha: 0.5),
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}
