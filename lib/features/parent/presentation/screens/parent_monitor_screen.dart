import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:safini/core/di/injection.dart';
import 'package:safini/core/utils/extension/theme_extension.dart';
import 'package:safini/features/parent/presentation/cubit/parent_monitor_cubit.dart';
import 'package:safini/features/parent/presentation/cubit/parent_monitor_state.dart';
import 'package:safini/features/parent/presentation/widgets/cards/parent_progress_card.dart';
import 'package:safini/features/parent/presentation/widgets/cards/parent_stat_card.dart';
import 'package:safini/features/parent/presentation/widgets/charts/parent_screen_time_chart.dart';
import 'package:safini/features/parent/presentation/widgets/tiles/parent_app_limit_tile.dart';
import 'package:safini/features/parent/presentation/widgets/tiles/parent_task_tile.dart';

class ParentMonitorScreen extends StatelessWidget {
  const ParentMonitorScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => getIt<ParentMonitorCubit>()..loadMonitorData(),
      child: Scaffold(
        body: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0xFF43008F), Color(0xFF8100D1)],
              stops: [0.0, 0.4],
            ),
          ),
          child: SafeArea(
            bottom: false,
            child: BlocBuilder<ParentMonitorCubit, ParentMonitorState>(
              builder: (context, state) {
                if (state is ParentMonitorLoading) {
                  return const Center(child: CircularProgressIndicator(color: Colors.white));
                }
                
                if (state is ParentMonitorLoaded) {
                  return SingleChildScrollView(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Good morning 👋",
                                  style: context.textTheme.bodyMedium?.copyWith(
                                    color: Colors.white.withOpacity(0.8),
                                  ),
                                ),
                                Text(
                                  "Safinio Parent",
                                  style: context.textTheme.headlineLarge?.copyWith(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.1),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.settings_outlined, color: Colors.white),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),
                        ParentProgressCard(
                          childName: state.childName,
                          level: state.level,
                          timeCoins: state.timeCoins,
                        ),
                        const SizedBox(height: 24),
                        Row(
                          children: [
                            Expanded(
                              child: ParentStatCard(
                                title: "Steps",
                                value: state.stepsToday.toString(),
                                label: "Steps Today",
                                change: state.stepsChange,
                                icon: Icons.trending_up,
                                iconBackgroundColor: const Color(0xFFF0E6FF),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: ParentStatCard(
                                title: "Lessons",
                                value: state.lessonsToday,
                                label: "Lessons",
                                change: state.lessonsChange,
                                icon: Icons.book_outlined,
                                iconBackgroundColor: const Color(0xFFE6FFF0),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),
                        ParentScreenTimeChart(weeklyUsage: state.weeklyUsage),
                        const SizedBox(height: 24),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "App Limits",
                              style: context.textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            TextButton(
                              onPressed: () {},
                              child: Text(
                                "Manage All",
                                style: TextStyle(color: context.colorScheme.primary),
                              ),
                            ),
                          ],
                        ),
                        ...state.appLimits.map((app) => ParentAppLimitTile(
                          appName: app['name'],
                          usedMinutes: app['used'],
                          limitMinutes: app['limit'],
                          iconPath: app['icon'],
                        )),
                        const SizedBox(height: 24),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "Real-world Tasks",
                              style: context.textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            ElevatedButton.icon(
                              onPressed: () {},
                              icon: const Icon(Icons.add, size: 18),
                              label: const Text("New Task"),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: context.colorScheme.primary,
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        const ParentTaskTile(
                          title: "Clean the room",
                          category: "Daily Chore",
                          rewardCoins: 30,
                        ),
                        const ParentTaskTile(
                          title: "Read for 20 mins",
                          category: "Educational",
                          rewardCoins: 50,
                          isPending: true,
                        ),
                        const ParentTaskTile(
                          title: "Do homework",
                          category: "Educational",
                          rewardCoins: 40,
                          isCompleted: true,
                        ),
                        const SizedBox(height: 100), // Bottom padding for navigation
                      ],
                    ),
                  );
                }
                
                return const SizedBox.shrink();
              },
            ),
          ),
        ),
      ),
    );
  }
}
