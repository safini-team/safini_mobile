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
import 'package:safini/core/translation/generated/l10n.dart';

class ChildTasksScreen extends StatelessWidget {
  const ChildTasksScreen({super.key});

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
      backgroundColor: context.colorScheme.surface,
      body: Column(
        children: [
          _TasksHeader(),
          Expanded(child: _TasksBody()),
        ],
      ),
    );
  }
}

// ─── Purple Header ─────────────────────────────────────────────────────────────

class _TasksHeader extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    return BlocBuilder<TasksCubit, TasksState>(
      builder: (context, state) {
        return Container(
          width: double.infinity,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                context.colorScheme.primary.withValues(alpha: 0.9),
                context.colorScheme.primary,
              ],
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
                    children: [
                      Expanded(
                        child: Text(
                          s.myQuests,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: context.textTheme.headlineSmall?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      const Flexible(child: StoreCoinBadge()),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  // Stats Row
                  Row(
                    children: [
                      Expanded(
                        child: TasksStatCard(
                          value: '${state.doneToday}',
                          label: s.doneToday,
                        ),
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Expanded(
                        child: TasksStatCard(
                          value: '${state.remaining}',
                          label: s.remaining,
                        ),
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Expanded(
                        child: TasksStatCard(
                          value: '${state.earnedToday}',
                          label: s.earnedToday,
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
    final s = S.of(context);
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
                          s.noQuestsInCategory,
                          style: context.textTheme.bodyMedium?.copyWith(
                            color: context.colorScheme.onSurface.withValues(
                              alpha: 0.4,
                            ),
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

