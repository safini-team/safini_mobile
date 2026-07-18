import 'package:flutter/material.dart';
import 'package:safini/core/theme/app_radius.dart';
import 'package:safini/core/theme/app_spacing.dart';
import 'package:safini/core/utils/extension/theme_extension.dart';
import 'package:safini/features/child/presentation/cubit/reward_store_model.dart';
import 'package:safini/features/child/presentation/widgets/cards/app_coin_pill.dart';
import 'package:safini/features/child/presentation/widgets/cards/app_lock_pill.dart';
import 'package:safini/features/child/presentation/widgets/cards/remaining_time_bar.dart';
import 'package:safini/core/translation/generated/l10n.dart';

/// A store row for one app: its icon, name, granted minutes, a live countdown
/// while time is active, and a price/lock pill on the right.
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
    final disabled = !item.isEnabled;
    return GestureDetector(
      onTap: disabled ? null : onTap,
      child: Opacity(
        opacity: disabled ? 0.5 : 1,
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
              _AppIcon(item: item, disabled: disabled),
              const SizedBox(width: AppSpacing.md),
              Expanded(child: _AppInfo(item: item, disabled: disabled)),
              const SizedBox(width: AppSpacing.sm),
              disabled
                  ? const AppLockPill()
                  : AppCoinPill(cost: item.cost, canAfford: canAfford),
            ],
          ),
        ),
      ),
    );
  }
}

/// Rounded app icon, muted when redemptions are disabled.
class _AppIcon extends StatelessWidget {
  final AppTimeItem item;
  final bool disabled;

  const _AppIcon({required this.item, required this.disabled});

  @override
  Widget build(BuildContext context) {
    final muted = context.colorScheme.onSurface;
    return Container(
      width: 50,
      height: 50,
      decoration: BoxDecoration(
        color: disabled ? muted.withValues(alpha: 0.08) : item.iconBackground,
        borderRadius: BorderRadius.circular(AppRadius.md),
      ),
      child: Icon(
        item.icon,
        color: disabled ? muted.withValues(alpha: 0.4) : item.iconColor,
        size: 26,
      ),
    );
  }
}

/// App title, granted minutes, and the live countdown when time is active.
class _AppInfo extends StatelessWidget {
  final AppTimeItem item;
  final bool disabled;

  const _AppInfo({required this.item, required this.disabled});

  @override
  Widget build(BuildContext context) {
    return Column(
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
          '+${S.of(context).minuteCount(item.minutes)}',
          style: context.textTheme.bodyMedium?.copyWith(
            color: context.colorScheme.onSurface.withValues(alpha: 0.5),
          ),
        ),
        if (!disabled && item.remainingMinutes > 0) ...[
          const SizedBox(height: 8),
          RemainingTimeBar(minutes: item.remainingMinutes),
        ],
      ],
    );
  }
}
