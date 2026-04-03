import 'package:flutter/material.dart';
import 'package:safini/features/parent/presentation/widgets/cards/parent_progress_card.dart';
import 'package:safini/features/parent/presentation/widgets/cards/parent_stat_card.dart';
import 'package:safini/features/parent/presentation/widgets/charts/parent_screen_time_chart.dart';
import 'package:safini/features/parent/presentation/widgets/tiles/parent_task_tile.dart';

class ParentMonitorScreen extends StatelessWidget {
  const ParentMonitorScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF8100D1),
      body: CustomScrollView(
        slivers: [
          _buildSliverAppBar(context),
          SliverToBoxAdapter(
            child: Container(
              decoration: const BoxDecoration(
                color: Color(0xFFF8F9FE),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(40),
                  topRight: Radius.circular(40),
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const ParentScreenTimeChart(
                      weeklyUsage: [0.4, 0.6, 0.3, 0.8, 0.9, 0.5, 0.2],
                    ),
                    const SizedBox(height: 32),
                    Text(
                      "App Limits",
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1A1A1A),
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildAppLimitCard(
                      context,
                      "YouTube Kids",
                      48,
                      60,
                      Icons.play_circle_outline,
                      const Color(0xFFFFE6E6),
                      const Color(0xFFFF3B30),
                    ),
                    _buildAppLimitCard(
                      context,
                      "Roblox",
                      15,
                      60,
                      Icons.videogame_asset_outlined,
                      const Color(0xFFE6F0FF),
                      const Color(0xFF007AFF),
                    ),
                    const SizedBox(height: 32),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          "Tasks",
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1A1A1A),
                          ),
                        ),
                        TextButton(
                          onPressed: () {},
                          child: const Text(
                            "See all",
                            style: TextStyle(
                              color: Color(0xFF8100D1),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    _buildTasksList(context),
                    const SizedBox(height: 100),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSliverAppBar(BuildContext context) {
    return SliverAppBar(
      expandedHeight: 280,
      floating: false,
      pinned: true,
      backgroundColor: const Color(0xFF8100D1),
      elevation: 0,
      flexibleSpace: FlexibleSpaceBar(
        background: Padding(
          padding: const EdgeInsets.only(top: 60, left: 24, right: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text(
                        "Good morning,",
                        style: TextStyle(color: Colors.white70, fontSize: 16),
                      ),
                      Text(
                        "Alex Parent",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const CircleAvatar(
                    backgroundColor: Colors.white24,
                    child: Icon(Icons.settings_outlined, color: Colors.white),
                  ),
                ],
              ),
              const SizedBox(height: 32),
              const ParentProgressCard(
                name: "Alex",
                level: "Level 5",
                coins: 150,
              ),
            ],
          ),
        ),
      ),
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(100),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          decoration: const BoxDecoration(
            color: Color(0xFFF8F9FE),
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(40),
              topRight: Radius.circular(40),
            ),
          ),
          child: Row(
            children: const [
              Expanded(
                child: ParentStatCard(
                  title: "Active Apps",
                  value: "3",
                  icon: Icons.apps,
                  color: Color(0xFF8100D1),
                  backgroundColor: Color(0xFFF0E6FF),
                  status: "+12% vs yesterday",
                ),
              ),
              SizedBox(width: 16),
              Expanded(
                child: ParentStatCard(
                  title: "Tasks Done",
                  value: "12",
                  icon: Icons.check_circle_outline,
                  color: Color(0xFF00C566),
                  backgroundColor: Color(0xFFE2F9EE),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAppLimitCard(
    BuildContext context,
    String name,
    int used,
    int limit,
    IconData icon,
    Color bgColor,
    Color iconColor,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(32),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: bgColor,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(icon, color: iconColor, size: 24),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                        color: Color(0xFF1A1A1A),
                      ),
                    ),
                    Text(
                      "$used / ${limit}m",
                      style: TextStyle(color: Colors.grey[500], fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
              ),
              Switch(
                value: true,
                onChanged: (v) {},
                activeColor: const Color(0xFF8100D1),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: used / limit,
              backgroundColor: Colors.grey[100],
              color: const Color(0xFF8100D1),
              minHeight: 8,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            "${limit - used} minutes remaining",
            style: TextStyle(color: Colors.grey[500], fontSize: 14),
          ),
        ],
      ),
    );
  }

  Widget _buildTasksList(BuildContext context) {
    return Column(
      children: const [
        ParentTaskTile(
          title: "Clean the room",
          category: "Daily Chore",
          rewardCoins: 30,
          status: "ACTIVE",
          icon: Icons.assignment_outlined,
        ),
        ParentTaskTile(
          title: "Read for 20 mins",
          category: "Educational",
          rewardCoins: 50,
          status: "PENDING",
          icon: Icons.menu_book_outlined,
        ),
        ParentTaskTile(
          title: "Do homework",
          category: "Educational",
          rewardCoins: 40,
          status: "DONE",
          icon: Icons.menu_book_outlined,
        ),
      ],
    );
  }
}