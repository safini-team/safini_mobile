import 'package:flutter/material.dart';
import 'package:safini/features/parent/presentation/widgets/cards/parent_progress_card.dart';
import 'package:safini/features/parent/presentation/widgets/charts/parent_screen_time_chart.dart';
import 'package:safini/features/parent/presentation/widgets/tiles/parent_task_tile.dart';

class ParentMonitorScreen extends StatelessWidget {
  const ParentMonitorScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF43008F),
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
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const ParentScreenTimeChart(
                      weeklyUsage: [0.4, 0.6, 0.3, 0.8, 1.0, 0.7, 0.5],
                    ),
                    const SizedBox(height: 40),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          "App Limits",
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF1A1A1A),
                            letterSpacing: -0.5,
                          ),
                        ),
                        TextButton(
                          onPressed: () {},
                          child: const Text(
                            "Manage All",
                            style: TextStyle(
                              color: Color(0xFF8B46FF),
                              fontWeight: FontWeight.w700,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    _buildAppLimitCard(
                      context,
                      "YouTube Kids",
                      48,
                      60,
                      Icons.play_circle_filled,
                      const Color(0xFFFFE6E6),
                      const Color(0xFFFF3B30),
                    ),
                    _buildAppLimitCard(
                      context,
                      "Roblox",
                      15,
                      60,
                      Icons.videogame_asset_rounded,
                      const Color(0xFFE6F0FF),
                      const Color(0xFF007AFF),
                    ),
                    const SizedBox(height: 40),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          "Real-world Tasks",
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF1A1A1A),
                            letterSpacing: -0.5,
                          ),
                        ),
                        ElevatedButton.icon(
                          onPressed: () {},
                          icon: const Icon(Icons.add, size: 20),
                          label: const Text("New Task"),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF8B46FF),
                            foregroundColor: Colors.white,
                            elevation: 0,
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
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
      expandedHeight: 320,
      floating: false,
      pinned: true,
      backgroundColor: const Color(0xFF43008F),
      elevation: 0,
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0xFF43008F), Color(0xFF6A0DAD)],
            ),
          ),
          child: Padding(
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
                          "Good morning 🖐️",
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          "Safinio Parent",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 32,
                            fontWeight: FontWeight.w900,
                            letterSpacing: -0.5,
                          ),
                        ),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.15),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.settings_outlined, color: Colors.white, size: 28),
                    ),
                  ],
                ),
                const SizedBox(height: 40),
                const ParentProgressCard(
                  name: "Alex",
                  level: "Level 5",
                  coins: 150,
                ),
              ],
            ),
          ),
        ),
      ),
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(80),
        child: Container(
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 20),
          decoration: const BoxDecoration(
            color: Color(0xFFF8F9FE),
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(40),
              topRight: Radius.circular(40),
            ),
          ),
          child: Row(
            children: [
              Expanded(
                child: _buildCompactStatChip(
                  icon: Icons.trending_up,
                  iconColor: const Color(0xFF8B46FF),
                  iconBg: const Color(0xFFF0E6FF),
                  value: "4,230",
                  label: "Steps",
                  trend: "+12%",
                  trendColor: const Color(0xFF8B46FF),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildCompactStatChip(
                  icon: Icons.menu_book_rounded,
                  iconColor: const Color(0xFF00C566),
                  iconBg: const Color(0xFFE2F9EE),
                  value: "1/8",
                  label: "Lessons",
                  trend: "+1 today",
                  trendColor: const Color(0xFF00C566),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCompactStatChip({
    required IconData icon,
    required Color iconColor,
    required Color iconBg,
    required String value,
    required String label,
    required String trend,
    required Color trendColor,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(7),
            decoration: BoxDecoration(color: iconBg, shape: BoxShape.circle),
            child: Icon(icon, color: iconColor, size: 16),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  value,
                  style: const TextStyle(
                    fontWeight: FontWeight.w900,
                    fontSize: 16,
                    color: Color(0xFF1A1A1A),
                    height: 1.1,
                  ),
                ),
                Text(
                  label,
                  style: TextStyle(color: Colors.grey[500], fontSize: 11, fontWeight: FontWeight.w500),
                ),
              ],
            ),
          ),
          Text(
            trend,
            style: TextStyle(color: trendColor, fontWeight: FontWeight.w700, fontSize: 11),
          ),
        ],
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
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(32),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
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
                        fontWeight: FontWeight.w800,
                        fontSize: 20,
                        color: Color(0xFF1A1A1A),
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      "$used / ${limit}m used today",
                      style: TextStyle(
                        color: used / limit > 0.8 ? const Color(0xFFFF3B30) : const Color(0xFF00C566),
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
              Switch(
                value: true,
                onChanged: (v) {},
                activeTrackColor: const Color(0xFF8B46FF),
                activeColor: Colors.white,
              ),
            ],
          ),
          const SizedBox(height: 20),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: used / limit,
              backgroundColor: const Color(0xFFF0F0F0),
              valueColor: AlwaysStoppedAnimation<Color>(
                used / limit > 0.8 ? const Color(0xFFFF3B30) : const Color(0xFF00C566),
              ),
              minHeight: 12,
            ),
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
          icon: Icons.cleaning_services,
        ),
        ParentTaskTile(
          title: "Read for 20 mins",
          category: "Educational",
          rewardCoins: 50,
          status: "PENDING",
          icon: Icons.menu_book_rounded,
        ),
        ParentTaskTile(
          title: "Do homework",
          category: "Educational",
          rewardCoins: 40,
          status: "DONE",
          icon: Icons.edit_note_rounded,
        ),
      ],
    );
  }
}