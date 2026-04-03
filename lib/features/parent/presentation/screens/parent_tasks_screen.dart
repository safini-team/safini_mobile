import 'package:flutter/material.dart';
import 'package:safini/core/utils/extension/theme_extension.dart';
import 'package:safini/features/parent/presentation/widgets/tiles/parent_task_tile.dart';

class ParentTasksScreen extends StatelessWidget {
  const ParentTasksScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FE),
      appBar: AppBar(
        backgroundColor: const Color(0xFF8100D1),
        elevation: 0,
        leading: const Icon(Icons.arrow_back, color: Colors.white),
        title: const Text(
          "Tasks & Rew...",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 24),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  children: const [
                    Icon(Icons.add, color: Colors.white, size: 18),
                    SizedBox(width: 4),
                    Text(
                      "New",
                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          _buildSectionHeader(
            context,
            icon: Icons.access_time_filled,
            iconColor: const Color(0xFFFFD54F),
            title: "Pending Approval",
            badgeCount: 1,
            badgeColor: const Color(0xFFFFD54F),
          ),
          const SizedBox(height: 16),
          const ParentTaskTile(
            title: "Read for 20 mins",
            category: "Educational",
            rewardCoins: 50,
            status: "PENDING",
            icon: Icons.menu_book_outlined,
          ),
          const SizedBox(height: 32),
          _buildSectionHeader(
            context,
            icon: Icons.circle,
            iconColor: const Color(0xFF8100D1),
            iconSize: 12,
            title: "Active Tasks",
            badgeCount: 2,
            badgeColor: const Color(0xFFF5F5F5),
            badgeTextColor: Colors.grey,
          ),
          const SizedBox(height: 16),
          const ParentTaskTile(
            title: "Clean the room",
            category: "Daily Chore",
            rewardCoins: 30,
            status: "ACTIVE",
            icon: Icons.assignment_outlined,
          ),
          const ParentTaskTile(
            title: "Practice piano",
            category: "Daily Chore",
            rewardCoins: 30,
            status: "ACTIVE",
            icon: Icons.assignment_outlined,
          ),
          const SizedBox(height: 32),
          _buildSectionHeader(
            context,
            icon: Icons.check_circle_outline,
            iconColor: const Color(0xFF00C566),
            title: "Completed",
          ),
          const SizedBox(height: 16),
          const ParentTaskTile(
            title: "Do homework",
            category: "Educational",
            rewardCoins: 40,
            status: "DONE",
            icon: Icons.menu_book_outlined,
          ),
          const SizedBox(height: 100),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(
    BuildContext context, {
    required IconData icon,
    required Color iconColor,
    double iconSize = 24,
    required String title,
    int? badgeCount,
    Color? badgeColor,
    Color? badgeTextColor,
  }) {
    return Row(
      children: [
        Icon(icon, color: iconColor, size: iconSize),
        const SizedBox(width: 12),
        Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 20,
            color: Color(0xFF1A1A1A),
          ),
        ),
        const Spacer(),
        if (badgeCount != null)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: badgeColor,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              badgeCount.toString(),
              style: TextStyle(
                color: badgeTextColor ?? Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
      ],
    );
  }
}