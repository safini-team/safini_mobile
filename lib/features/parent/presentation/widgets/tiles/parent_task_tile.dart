import 'package:flutter/material.dart';
import 'package:safini/core/utils/extension/theme_extension.dart';

class ParentTaskTile extends StatelessWidget {
  final String title;
  final String category;
  final int rewardCoins;
  final String status; // PENDING, ACTIVE, DONE
  final IconData icon;

  const ParentTaskTile({
    super.key,
    required this.title,
    required this.category,
    required this.rewardCoins,
    required this.status,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    Color statusColor;
    Color statusBg;

    switch (status.toUpperCase()) {
      case 'PENDING':
        statusColor = const Color(0xFF8100D1);
        statusBg = const Color(0xFFF0E6FF);
        break;
      case 'ACTIVE':
        statusColor = const Color(0xFFF8B400);
        statusBg = const Color(0xFFFFF3D6);
        break;
      case 'DONE':
        statusColor = const Color(0xFF00C566);
        statusBg = const Color(0xFFE2F9EE);
        break;
      default:
        statusColor = Colors.grey;
        statusBg = Colors.grey[100]!;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFF0E6FF),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(icon, color: const Color(0xFF8100D1), size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                    color: Color(0xFF1A1A1A),
                  ),
                ),
                Text(
                  category,
                  style: TextStyle(
                    color: Colors.grey[500],
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: statusBg,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.monetization_on, color: Color(0xFFFFD54F), size: 16),
                    const SizedBox(width: 4),
                    Text(
                      "$rewardCoins",
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  status.toUpperCase(),
                  style: TextStyle(
                    color: statusColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 10,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
