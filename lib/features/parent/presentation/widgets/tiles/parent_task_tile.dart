import 'package:flutter/material.dart';
import 'package:safini/core/utils/extension/theme_extension.dart';

class ParentTaskTile extends StatelessWidget {
  final String title;
  final String category;
  final int rewardCoins;
  final bool isCompleted;
  final bool isPending;
  final VoidCallback? onApprove;
  final VoidCallback? onDelete;

  const ParentTaskTile({
    super.key,
    required this.title,
    required this.category,
    required this.rewardCoins,
    this.isCompleted = false,
    this.isPending = false,
    this.onApprove,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFFF0E6FF),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              _getCategoryIcon(category),
              color: context.colorScheme.primary,
              size: 24,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: context.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  category,
                  style: context.textTheme.bodySmall?.copyWith(
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          _buildStatusBadge(context),
        ],
      ),
    );
  }

  Widget _buildStatusBadge(BuildContext context) {
    Color bgColor;
    Color textColor;
    String statusText;

    if (isPending) {
      bgColor = const Color(0xFFF0E6FF);
      textColor = const Color(0xFF8100D1);
      statusText = "PENDING";
    } else if (isCompleted) {
      bgColor = const Color(0xFFE6FFF0);
      textColor = const Color(0xFF00B050);
      statusText = "DONE";
    } else {
      bgColor = const Color(0xFFFFF9E6);
      textColor = const Color(0xFFFFA800);
      statusText = "ACTIVE";
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Image.asset('assets/icons/coin.png', width: 14, height: 14, 
                errorBuilder: (_, __, ___) => const Icon(Icons.monetization_on, color: Colors.amber, size: 14)),
              const SizedBox(width: 4),
              Text(
                rewardCoins.toString(),
                style: context.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
          Text(
            statusText,
            style: context.textTheme.labelSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: textColor,
              letterSpacing: 0.5,
              fontSize: 10,
            ),
          ),
        ],
      ),
    );
  }

  IconData _getCategoryIcon(String category) {
    switch (category.toLowerCase()) {
      case 'educational': return Icons.book;
      case 'chore': return Icons.home;
      case 'habit': return Icons.repeat;
      default: return Icons.task;
    }
  }
}
