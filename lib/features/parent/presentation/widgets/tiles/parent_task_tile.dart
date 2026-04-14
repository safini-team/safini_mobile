import 'package:flutter/material.dart';
import 'package:safini/generated/l10n.dart';

class ParentTaskTile extends StatelessWidget {
  final String title;
  final String category;
  final int rewardCoins;
  final bool isPending;
  final bool isCompleted;
  final VoidCallback? onApprove;
  final VoidCallback? onDelete;

  const ParentTaskTile({
    super.key,
    required this.title,
    required this.category,
    required this.rewardCoins,
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
      statusColor = const Color(0xFF8100D1);
      statusBg = const Color(0xFFF0E6FF);
      statusText = s.statusPending;
    } else if (isCompleted) {
      statusColor = const Color(0xFF00C566);
      statusBg = const Color(0xFFE2F9EE);
      statusText = s.statusDone;
    } else {
      statusColor = const Color(0xFFF8B400);
      statusBg = const Color(0xFFFFF3D6);
      statusText = s.statusActive;
    }

    switch (category.toLowerCase()) {
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
            color: Colors.black.withOpacity(0.02),
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
              color: const Color(0xFFF2F0FF),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(
              categoryIcon,
              color: const Color(0xFF8B46FF),
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
                  style: const TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 18,
                    color: Color(0xFF1A1A1A),
                    letterSpacing: -0.2,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  category,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: Colors.grey[400],
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Image.asset(
                      'assets/icons/coin.png',
                      width: 16,
                      height: 16,
                      errorBuilder: (_, __, ___) => const Icon(
                        Icons.monetization_on,
                        color: Colors.amber,
                        size: 16,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      s.coinsReward(rewardCoins),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Color(0xFF8B46FF),
                        fontWeight: FontWeight.w700,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
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
                      color: const Color(0xFF00C566),
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
                      color: const Color(0xFFF5F5F5),
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
