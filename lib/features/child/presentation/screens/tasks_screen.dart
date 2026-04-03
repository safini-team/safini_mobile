import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:safini/core/theme/app_radius.dart';
import 'package:safini/core/theme/app_spacing.dart';
import 'package:safini/core/utils/extension/theme_extension.dart';
import 'package:safini/features/child/presentation/cubit/coins_cubit.dart';
import 'package:safini/features/child/presentation/cubit/tasks_cubit.dart';
import 'package:safini/features/child/presentation/cubit/tasks_state.dart';
import 'package:safini/features/child/presentation/widgets/cards/tasks_stat_card.dart';
import 'package:safini/features/child/presentation/widgets/tiles/task_item_tile.dart';
import 'package:safini/features/child/presentation/widgets/utils/store_coin_badge.dart';
import 'package:safini/features/child/presentation/widgets/utils/tasks_category_filter.dart';

class TasksScreen extends StatelessWidget {
  const TasksScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (ctx) => TasksCubit(ctx.read<CoinsCubit>()),
      child: const _TasksView(),
    );
  }
}

// ─── Root View ────────────────────────────────────────────────────────────────

class _TasksView extends StatelessWidget {
  const _TasksView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0EAF8),
      body: Column(
        children: [
          _TasksHeader(),
          Expanded(child: _TasksBody()),
        ],
      ),
      bottomNavigationBar: _TasksBottomNavBar(),
    );
  }
}

// ─── Purple Header ─────────────────────────────────────────────────────────────

class _TasksHeader extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<TasksCubit, TasksState>(
      builder: (context, state) {
        return Container(
          width: double.infinity,
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF6200B3), Color(0xFF9000E0)],
            ),
          ),
          child: SafeArea(
            bottom: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.lg,
                AppSpacing.md,
                AppSpacing.lg,
                AppSpacing.xl,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title + Coin Badge
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'My Quests',
                        style: context.textTheme.headlineSmall?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const StoreCoinBadge(),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  // Stats Row
                  Row(
                    children: [
                      Expanded(
                        child: TasksStatCard(
                          value: '${state.doneToday}',
                          label: 'Done Today',
                        ),
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Expanded(
                        child: TasksStatCard(
                          value: '${state.remaining}',
                          label: 'Remaining',
                        ),
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Expanded(
                        child: TasksStatCard(
                          value: '${state.earnedToday}',
                          label: 'Earned Today',
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

// ─── Body (filter + list) ─────────────────────────────────────────────────────

class _TasksBody extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<TasksCubit, TasksState>(
      builder: (context, state) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(AppRadius.xl),
              topRight: Radius.circular(AppRadius.xl),
            ),
          ),
          child: Column(
            children: [
              // Category filter row
              Padding(
                padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
                child: TasksCategoryFilter(
                  selectedCategory: state.selectedCategory,
                  onChanged: (cat) =>
                      context.read<TasksCubit>().selectCategory(cat),
                ),
              ),
              // Quest list
              Expanded(
                child: state.filteredTasks.isEmpty
                    ? Center(
                        child: Text(
                          'No quests in this category',
                          style: context.textTheme.bodyMedium?.copyWith(
                            color: context.colorScheme.onSurface
                                .withValues(alpha: 0.4),
                          ),
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.only(
                          top: AppSpacing.xs,
                          bottom: AppSpacing.xl,
                        ),
                        itemCount: state.filteredTasks.length,
                        itemBuilder: (context, index) {
                          final task = state.filteredTasks[index];
                          return TaskItemTile(
                            task: task,
                            onTap: () =>
                                context.read<TasksCubit>().toggleTask(task.id),
                          );
                        },
                      ),
              ),
            ],
          ),
        );
      },
    );
  }
}

// ─── Bottom Nav Bar ───────────────────────────────────────────────────────────

class _TasksBottomNavBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: context.colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 12,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _NavItem(
                icon: Icons.home_rounded,
                label: 'Home',
                onTap: () => context.router.maybePop(),
              ),
              const _NavItem(
                icon: Icons.check_box_rounded,
                label: 'Tasks',
                isSelected: true,
              ),
              _NavItem(
                icon: Icons.shopping_bag_rounded,
                label: 'Store',
                onTap: () => context.router.push(const NamedRoute('store')),
              ),
              _NavItem(
                icon: Icons.person_rounded,
                label: 'Profile',
                onTap: () => context.router.push(const NamedRoute('profile')),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback? onTap;

  const _NavItem({
    required this.icon,
    required this.label,
    this.isSelected = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = isSelected
        ? context.colorScheme.primary
        : context.colorScheme.onSurface.withValues(alpha: 0.4);

    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 26),
          const SizedBox(height: 3),
          Text(
            label,
            style: context.textTheme.bodyMedium?.copyWith(
              color: color,
              fontSize: 11,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }
}
