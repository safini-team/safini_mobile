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
            child: Icon(icon, color: const Color(0xFF8B46FF), size: 26),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
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
                  style: TextStyle(
                    color: Colors.grey[400],
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(2),
                      decoration: const BoxDecoration(
                        color: Color(0xFFFFD700),
                        shape: BoxShape.circle,
                      ),
                      child: const Text("🪙", style: TextStyle(fontSize: 10)),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      "$rewardCoins coins reward",
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
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: statusBg,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Center(
              child: Text(
                status.toUpperCase(),
                style: TextStyle(
                  color: statusColor,
                  fontWeight: FontWeight.w800,
                  fontSize: 11,
                  letterSpacing: 0.5,
                ),
              ),
            ),
          ),
          if (status.toUpperCase() == 'PENDING') ...[
            const SizedBox(width: 12),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFF00C566),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.check, color: Colors.white, size: 20),
            ),
          ] else if (status.toUpperCase() == 'ACTIVE') ...[
            const SizedBox(width: 12),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFFF5F5F5),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.close, color: Colors.grey, size: 20),
            ),
          ],
        ],
      ),
    );
  }
}
