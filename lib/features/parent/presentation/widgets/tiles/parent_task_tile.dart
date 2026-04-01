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
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: isPending 
            ? Border.all(color: Colors.amber.withOpacity(0.5), width: 2)
            : null,
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
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              _getCategoryIcon(category),
              color: context.colorScheme.primary,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: context.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    decoration: isCompleted && !isPending ? TextDecoration.lineThrough : null,
                  ),
                ),
                Text(
                  category,
                  style: context.textTheme.bodySmall?.copyWith(
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(Icons.monetization_on, color: Colors.amber, size: 14),
                    const SizedBox(width: 4),
                    Text(
                      "$rewardCoins coins",
                      style: context.textTheme.bodySmall?.copyWith(
                        color: context.colorScheme.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          if (isPending)
            ElevatedButton(
              onPressed: onApprove,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
                shape: const CircleBorder(),
                padding: const EdgeInsets.elliptical(8, 8),
              ),
              child: const Icon(Icons.check),
            )
          else if (!isCompleted && onDelete != null)
            IconButton(
              icon: const Icon(Icons.close, color: Colors.grey),
              onPressed: onDelete,
            )
          else if (isCompleted)
            const Icon(Icons.check_circle, color: Colors.green),
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
