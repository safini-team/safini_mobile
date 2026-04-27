import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:safini/core/di/injection.dart';
import 'package:safini/features/parent/presentation/cubit/parent_tasks_cubit.dart';
import 'package:safini/features/parent/presentation/cubit/parent_tasks_state.dart';
import 'package:safini/features/parent/presentation/widgets/tiles/parent_task_tile.dart';
import 'package:safini/core/translation/generated/l10n.dart';
import 'package:safini/core/utils/extension/theme_extension.dart';

class ParentTasksScreen extends StatelessWidget {
  const ParentTasksScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    return BlocProvider(
      create: (context) => getIt<ParentTasksCubit>()..loadTasks(),
      child: Scaffold(
        backgroundColor: context.colorScheme.primary.withValues(alpha: 0.9),
        body: Column(
          children: [
            // ── Header ──────────────────────────────────────────
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    context.colorScheme.primary.withValues(alpha: 0.8),
                    context.colorScheme.primary,
                  ],
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
                          style: context.textTheme.displaySmall?.copyWith(
                            color: context.colorScheme.onPrimary,
                            fontSize: 30,
                            fontWeight: FontWeight.w900,
                            letterSpacing: -0.5,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Flexible(
                        child: GestureDetector(
                          onTap: () {},
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 18,
                              vertical: 10,
                            ),
                            decoration: BoxDecoration(
                              color: context.colorScheme.onPrimary
                                  .withOpacity(0.15),
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
                                Flexible(
                                  child: Text(
                                    s.newBtn,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      color: context.colorScheme.onPrimary,
                                      fontWeight: FontWeight.w700,
                                      fontSize: 15,
                                    ),
                                  ),
                                ),
                              ],
                            ),
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
                decoration: BoxDecoration(
                  color: context.colorScheme.surface,
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
                              iconColor: Colors.amber,
                              title: s.pendingApproval,
                              badgeCount: state.pendingApproval.length,
                              badgeColor: Colors.amber,
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
        Text(
          title,
          style: context.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
            fontSize: 20,
            color: context.colorScheme.onSurface,
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
              style: context.textTheme.labelLarge?.copyWith(
                color: badgeTextColor ?? context.colorScheme.onPrimary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
      ],
    );
  }
}