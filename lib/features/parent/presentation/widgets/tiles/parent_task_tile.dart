import 'package:flutter/material.dart';
import 'package:safini/core/translation/generated/l10n.dart';
import 'package:safini/core/utils/extension/theme_extension.dart';

class ParentTaskTile extends StatelessWidget {
  final String title;
  final String? category;
  final int? rewardCoins;
  final String? statusLabel;
  final bool isPending;
  final bool isCompleted;
  final VoidCallback? onApprove;
  final VoidCallback? onDelete;

  const ParentTaskTile({
    super.key,
    required this.title,
    this.category,
    this.rewardCoins,
    this.statusLabel,
    this.isPending = false,
    this.isCompleted = false,
    this.onApprove,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    Color statusColor;
    Color statusBg;
    String statusText;
    IconData categoryIcon;

    if (isPending) {
      statusColor = context.colorScheme.primary;
      statusBg = context.colorScheme.primary.withValues(alpha: 0.1);
      statusText = statusLabel ?? S.of(context).statusPending;
    } else if (isCompleted) {
      statusColor = context.successColor;
      statusBg = context.successColor.withValues(alpha: 0.1);
      statusText = statusLabel ?? S.of(context).statusDone;
    } else {
      statusColor = context.colorScheme.tertiary;
      statusBg = context.colorScheme.tertiary.withValues(alpha: 0.1);
      statusText = statusLabel ?? S.of(context).statusActive;
    }

    switch ((category ?? '').toLowerCase()) {
      case 'educational':
        categoryIcon = Icons.menu_book_rounded;
        break;
      case 'hobby':
        categoryIcon = Icons.music_note;
        break;
      case 'daily chore':
      case 'chore':
        categoryIcon = Icons.cleaning_services;
        break;
      default:
        categoryIcon = Icons.task_alt_rounded;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: context.colorScheme.shadow.withValues(alpha: 0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: context.colorScheme.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(
              categoryIcon,
              color: context.colorScheme.primary,
              size: 26,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: context.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                    fontSize: 18,
                    color: context.colorScheme.onSurface,
                    letterSpacing: -0.2,
                  ),
                ),
                if (category?.trim().isNotEmpty == true) ...[
                  const SizedBox(height: 2),
                  Text(
                    category!.trim(),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: context.textTheme.bodySmall?.copyWith(
                      color: context.colorScheme.onSurface.withValues(
                        alpha: 0.4,
                      ),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
                if (rewardCoins != null) ...[
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Image.asset(
                        'assets/icons/coin.png',
                        width: 16,
                        height: 16,
                        errorBuilder: (_, _, _) => const Icon(
                          Icons.monetization_on,
                          color: Colors.amber,
                          size: 16,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        s.coinsReward(rewardCoins!),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: context.textTheme.labelSmall?.copyWith(
                          color: context.colorScheme.primary,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: statusBg,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Text(
                  statusText,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: statusColor,
                    fontWeight: FontWeight.w800,
                    fontSize: 11,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
              if (isPending && onApprove != null) ...[
                const SizedBox(height: 8),
                GestureDetector(
                  onTap: onApprove,
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: context.successColor,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.check,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                ),
              ] else if (!isPending && !isCompleted && onDelete != null) ...[
                const SizedBox(height: 8),
                GestureDetector(
                  onTap: onDelete,
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: context.colorScheme.onSurface.withValues(
                        alpha: 0.05,
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.close,
                      color: Colors.grey,
                      size: 20,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}
