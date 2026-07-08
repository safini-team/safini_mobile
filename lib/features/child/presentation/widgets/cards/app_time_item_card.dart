import 'dart:async';

import 'package:flutter/material.dart';
import 'package:safini/core/theme/app_radius.dart';
import 'package:safini/core/theme/app_spacing.dart';
import 'package:safini/core/utils/extension/theme_extension.dart';
import 'package:safini/features/child/presentation/cubit/reward_store_model.dart';
import 'package:safini/core/translation/generated/l10n.dart';

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
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: disabled
                      ? context.colorScheme.onSurface.withValues(alpha: 0.08)
                      : item.iconBackground,
                  borderRadius: BorderRadius.circular(AppRadius.md),
                ),
                child: Icon(
                  item.icon,
                  color: disabled
                      ? context.colorScheme.onSurface.withValues(alpha: 0.4)
                      : item.iconColor,
                  size: 26,
                ),
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
                      '+${S.of(context).minuteCount(item.minutes)}',
                      style: context.textTheme.bodyMedium?.copyWith(
                        color: context.colorScheme.onSurface.withValues(
                          alpha: 0.5,
                        ),
                      ),
                    ),
                    if (!disabled && item.remainingMinutes > 0) ...[
                      const SizedBox(height: 8),
                      _RemainingTimeBar(minutes: item.remainingMinutes),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              disabled
                  ? const _LockPill()
                  : _CoinPill(cost: item.cost, canAfford: canAfford),
            ],
          ),
        ),
      ),
    );
  }
}

/// Live countdown (MM:SS) + progress line for redeemed app time.
///
/// Note: this counts down by wall-clock time from when the grant is shown.
/// Redeemed minutes are actually consumed only while the child uses the app
/// (tracked server-side); this is a visual indicator, not exact usage.
class _RemainingTimeBar extends StatefulWidget {
  final int minutes;

  const _RemainingTimeBar({required this.minutes});

  @override
  State<_RemainingTimeBar> createState() => _RemainingTimeBarState();
}

class _RemainingTimeBarState extends State<_RemainingTimeBar> {
  Timer? _timer;
  late DateTime _endTime;
  late int _totalSeconds;
  Duration _remaining = Duration.zero;

  @override
  void initState() {
    super.initState();
    _restart();
  }

  @override
  void didUpdateWidget(_RemainingTimeBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Only reset when the granted minutes actually change (new/updated grant).
    if (oldWidget.minutes != widget.minutes) {
      _restart();
    }
  }

  void _restart() {
    _totalSeconds = widget.minutes * 60;
    _endTime = DateTime.now().add(Duration(seconds: _totalSeconds));
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) => _tick());
    _tick();
  }

  void _tick() {
    final left = _endTime.difference(DateTime.now());
    if (!mounted) return;
    setState(() => _remaining = left.isNegative ? Duration.zero : left);
    if (_remaining == Duration.zero) _timer?.cancel();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final color = context.successColor;
    final total = _totalSeconds <= 0 ? 1 : _totalSeconds;
    final fraction = (_remaining.inSeconds / total).clamp(0.0, 1.0);
    final mm = _remaining.inMinutes.toString().padLeft(2, '0');
    final ss = (_remaining.inSeconds % 60).toString().padLeft(2, '0');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.timer_outlined, size: 13, color: color),
            const SizedBox(width: 4),
            Text(
              '$mm:$ss',
              style: context.textTheme.labelSmall?.copyWith(
                color: color,
                fontWeight: FontWeight.w800,
                fontFeatures: const [FontFeature.tabularFigures()],
              ),
            ),
          ],
        ),
        const SizedBox(height: 5),
        ClipRRect(
          borderRadius: BorderRadius.circular(999),
          child: LinearProgressIndicator(
            value: fraction,
            minHeight: 5,
            backgroundColor: color.withValues(alpha: 0.15),
            valueColor: AlwaysStoppedAnimation<Color>(color),
          ),
        ),
      ],
    );
  }
}

class _LockPill extends StatelessWidget {
  const _LockPill();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(
          color: context.colorScheme.onSurface.withValues(alpha: 0.2),
        ),
      ),
      child: Icon(
        Icons.lock_outline_rounded,
        size: 18,
        color: context.colorScheme.onSurface.withValues(alpha: 0.5),
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
                  ? context.colorScheme.onPrimary
                  : context.colorScheme.onSurface.withValues(alpha: 0.5),
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}
