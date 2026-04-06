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
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "Tasks & Rewards",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w900,
            fontSize: 26,
            letterSpacing: -0.5,
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Center(
              child: ElevatedButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.add, size: 18),
                label: const Text("New"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white.withOpacity(0.2),
                  foregroundColor: Colors.white,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                ),
              ),
            ),
          ),
        ],
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF43008F), Color(0xFF8100D1)],
            ),
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        children: [
          _buildSectionHeader(
            context,
            icon: Icons.access_time_filled,
            iconColor: const Color(0xFFFFD700),
            title: "Pending Approval",
            badgeCount: 1,
            badgeColor: const Color(0xFFFFD700),
          ),
          const SizedBox(height: 16),
          const ParentTaskTile(
            title: "Read for 20 mins",
            category: "Educational",
            rewardCoins: 50,
            status: "PENDING",
            icon: Icons.menu_book_rounded,
          ),
          const SizedBox(height: 32),
          _buildSectionHeader(
            context,
            icon: Icons.circle,
            iconColor: const Color(0xFF8B46FF),
            iconSize: 12,
            title: "Active Tasks",
            badgeCount: 2,
            badgeColor: const Color(0xFFF2F0FF),
            badgeTextColor: const Color(0xFF8B46FF),
          ),
          const SizedBox(height: 16),
          const ParentTaskTile(
            title: "Clean the room",
            category: "Daily Chore",
            rewardCoins: 30,
            status: "ACTIVE",
            icon: Icons.cleaning_services,
          ),
          const ParentTaskTile(
            title: "Practice piano",
            category: "Hobby",
            rewardCoins: 35,
            status: "ACTIVE",
            icon: Icons.music_note,
          ),
          const SizedBox(height: 32),
          _buildSectionHeader(
            context,
            icon: Icons.check_circle_rounded,
            iconColor: const Color(0xFF00C566),
            title: "Completed",
          ),
          const SizedBox(height: 16),
          const ParentTaskTile(
            title: "Do homework",
            category: "Educational",
            rewardCoins: 40,
            status: "DONE",
            icon: Icons.edit_note_rounded,
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