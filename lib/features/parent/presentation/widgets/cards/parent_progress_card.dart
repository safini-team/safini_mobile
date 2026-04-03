import 'package:flutter/material.dart';
import 'package:safini/core/utils/extension/theme_extension.dart';

class ParentProgressCard extends StatelessWidget {
  final String childName;
  final String level;
  final int timeCoins;
  final String? avatarUrl;

  const ParentProgressCard({
    super.key,
    required this.childName,
    required this.level,
    required this.timeCoins,
    this.avatarUrl,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 32,
            backgroundColor: Colors.white.withOpacity(0.3),
            // Placeholder avatar
            child: const Icon(Icons.person, color: Colors.white, size: 40),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  childName,
                  style: context.textTheme.headlineSmall?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(Icons.star, color: Colors.amber, size: 16),
                    const SizedBox(width: 4),
                    Text(
                      level,
                      style: context.textTheme.bodyMedium?.copyWith(
                        color: Colors.white.withOpacity(0.9),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Image.asset('assets/icons/coin.png', width: 20, height: 20, errorBuilder: (_, __, ___) => const Icon(Icons.monetization_on, color: Colors.amber, size: 20)),
                    const SizedBox(width: 4),
                    Text(
                      "$timeCoins Time Coins",
                      style: context.textTheme.bodyLarge?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
