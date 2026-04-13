import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:safini/core/di/injection.dart';
import 'package:safini/features/parent/presentation/cubit/parent_tasks_cubit.dart';
import 'package:safini/features/parent/presentation/cubit/parent_tasks_state.dart';
import 'package:safini/features/parent/presentation/widgets/tiles/parent_task_tile.dart';
import 'package:safini/generated/l10n.dart';

class ParentTasksScreen extends StatelessWidget {
  const ParentTasksScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    return BlocProvider(
      create: (context) => getIt<ParentTasksCubit>()..loadTasks(),
      child: Scaffold(
        backgroundColor: const Color(0xFF43008F),
        body: Column(
          children: [
            // ── Header ──────────────────────────────────────────
            Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Color(0xFF2D006F), Color(0xFF5A00B4)],
                ),
              ),
              child: SafeArea(
                bottom: false,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(24, 20, 20, 24),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          s.tasksAndRewards,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 30,
                            fontWeight: FontWeight.w900,
                            letterSpacing: -0.5,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      GestureDetector(
                        onTap: () {},
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 18,
                            vertical: 10,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(22),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.add,
                                color: Colors.white,
                                size: 18,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                s.newBtn,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 15,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            // ── Content ─────────────────────────────────────────
            Expanded(
              child: Container(
                decoration: const BoxDecoration(
                  color: Color(0xFFF0EEF9),
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(36),
                    topRight: Radius.circular(36),
                  ),
                ),
                child: BlocBuilder<ParentTasksCubit, ParentTasksState>(
                  builder: (context, state) {
                    if (state is ParentTasksLoading) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    if (state is ParentTasksLoaded) {
                      return ListView(
                        padding: const EdgeInsets.fromLTRB(20, 28, 20, 100),
                        children: [
                          if (state.pendingApproval.isNotEmpty) ...[
                            _buildSectionHeader(
                              context,
                              icon: Icons.access_time_filled,
                              iconColor: const Color(0xFFFFD700),
                              title: s.pendingApproval,
                              badgeCount: state.pendingApproval.length,
                              badgeColor: const Color(0xFFFFD700),
                            ),
                            const SizedBox(height: 16),
                            ...state.pendingApproval.map(
                              (task) => ParentTaskTile(
                                title: task.title,
                                category: s.educational,
                                rewardCoins: 50,
                                isPending: true,
                                onApprove: () => context
                                    .read<ParentTasksCubit>()
                                    .approveTask(task.id),
                              ),
                            ),
                            const SizedBox(height: 32),
                          ],
                          _buildSectionHeader(
                            context,
                            icon: Icons.circle,
                            iconColor: const Color(0xFF8B46FF),
                            iconSize: 12,
                            title: s.activeTasks,
                            badgeCount: state.activeTasks.length,
                            badgeColor: const Color(0xFFF2F0FF),
                            badgeTextColor: const Color(0xFF8B46FF),
                          ),
                          const SizedBox(height: 16),
                          ...state.activeTasks.map(
                            (task) => ParentTaskTile(
                              title: task.title,
                              category: s.dailyChore,
                              rewardCoins: 30,
                              onDelete: () {},
                            ),
                          ),
                          const SizedBox(height: 32),
                          _buildSectionHeader(
                            context,
                            icon: Icons.check_circle_rounded,
                            iconColor: const Color(0xFF00C566),
                            title: s.completed,
                          ),
                          const SizedBox(height: 16),
                          ...state.completedTasks.map(
                            (task) => ParentTaskTile(
                              title: task.title,
                              category: s.educational,
                              rewardCoins: 40,
                              isCompleted: true,
                            ),
                          ),
                        ],
                      );
                    }

                    return const SizedBox.shrink();
                  },
                ),
              ),
            ),
          ],
        ),
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
        Expanded(
          child: Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 20,
              color: Color(0xFF1A1A1A),
            ),
          ),
        ),
        const SizedBox(width: 8),
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