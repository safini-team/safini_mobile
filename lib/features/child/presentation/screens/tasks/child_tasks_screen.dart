import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:safini/core/di/injection.dart';
import 'package:safini/core/theme/app_colors.dart';
import 'package:safini/core/theme/app_radius.dart';
import 'package:safini/core/theme/app_spacing.dart';
import 'package:safini/core/translation/generated/l10n.dart';
import 'package:safini/core/utils/widgets/ds/ds.dart';
import 'package:safini/features/child/presentation/cubit/home/home_cubit.dart';
import 'package:safini/features/child/presentation/cubit/home/home_state.dart';
import 'package:safini/features/child/presentation/cubit/quest_model.dart';
import 'package:safini/features/child/presentation/cubit/tasks_cubit.dart';
import 'package:safini/features/child/presentation/cubit/tasks_model.dart';
import 'package:safini/features/child/presentation/cubit/tasks_state.dart';
import 'package:safini/features/child/presentation/screens/tasks/child_tasks_view.dart';
import 'package:safini/features/child/presentation/widgets/dialogs/task_detail_dialog.dart';

class ChildTasksScreen extends StatelessWidget {
  const ChildTasksScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (ctx) => getIt<TasksCubit>(),
      // Reload when the Tasks tab becomes active so submissions made on the
      // Today tab (a separate cubit) show up here.
      child: BlocListener<ChildHomeCubit, ChildHomeState>(
        listenWhen: (prev, curr) =>
            prev.selectedIndex != curr.selectedIndex && curr.selectedIndex == 1,
        listener: (ctx, _) => ctx.read<TasksCubit>().loadTasks(),
        child: const _ChildTasksScreen(),
      ),
    );
  }
}

class _ChildTasksScreen extends StatelessWidget {
  const _ChildTasksScreen();

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);

    return BlocBuilder<TasksCubit, TasksState>(
      builder: (context, state) {
        if (state.isLoading && state.tasks.isEmpty) {
          return const _TasksSkeleton();
        }

        final cubit = context.read<TasksCubit>();
        final categories = TaskCategory.values;

        return ChildTasksView(
          data: ChildTasksData(
            done: state.doneToday,
            total: state.tasks.length,
            pendingCoins: state.tasks
                .where((t) => t.isSubmitted)
                .fold(0, (sum, t) => sum + t.coins),
            categories: [
              for (final category in categories)
                ChildTasksCategory(
                  label: _categoryLabel(s, category),
                  selected: category == state.selectedCategory,
                ),
            ],
            rows: [
              for (final task in state.filteredTasks)
                ChildTaskRow(
                  id: task.id,
                  title: task.title,
                  meta: task.localizedSubtitle(s),
                  coins: task.coins,
                  state: task.isCompleted
                      ? ChildTaskState.done
                      : task.isSubmitted
                      ? ChildTaskState.sent
                      : ChildTaskState.open,
                ),
            ],
            emptyMessage: s.noQuestsInCategory,
          ),
          onSelectCategory: (index) => cubit.selectCategory(categories[index]),
          onOpenTask: (row) => _openTask(context, state, row.id),
          onRefresh: () => cubit.loadTasks(),
        );
      },
    );
  }

  /// `TaskCategoryX.label` is English-only; the UI needs the localised name.
  String _categoryLabel(S s, TaskCategory category) => switch (category) {
    TaskCategory.all => s.catAll,
    TaskCategory.learn => s.catLearn,
    TaskCategory.fitness => s.catFitness,
    TaskCategory.logic => s.catLogic,
  };

  void _openTask(BuildContext context, TasksState state, String taskId) {
    final task = state.tasks.where((t) => t.id == taskId).firstOrNull;
    if (task == null) return;
    final cubit = context.read<TasksCubit>();

    TaskDetailDialog.show(
      context,
      QuestModel(
        id: task.id,
        title: task.title,
        subtitle: task.localizedSubtitle(S.of(context)),
        icon: task.icon,
        iconColor: task.iconColor,
        iconBackground: task.iconBackground,
        emoji: task.emoji,
        isCompleted: task.isCompleted,
        coins: task.coins,
        xp: task.xp,
        status: task.status,
      ),
      onSubmit: task.isCompleted || task.isSubmitted
          ? null
          : (note) => cubit.submitTask(task.id, note: note),
    );
  }
}

class _TasksSkeleton extends StatelessWidget {
  const _TasksSkeleton();

  @override
  Widget build(BuildContext context) {
    return DsScreen(
      background: AppColors.bgChild,
      animateEntrance: false,
      slivers: [
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.textGutter,
              6,
              AppSpacing.textGutter,
              0,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 120,
                  height: 32,
                  decoration: BoxDecoration(
                    color: AppColors.fillPressed,
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                const SizedBox(height: 28),
                Container(
                  height: 36,
                  decoration: BoxDecoration(
                    color: AppColors.fillPressed,
                    borderRadius: BorderRadius.circular(AppRadius.pill),
                  ),
                ),
                const SizedBox(height: 20),
                Container(
                  height: 320,
                  decoration: BoxDecoration(
                    color: AppColors.fillPressed,
                    borderRadius: BorderRadius.circular(AppRadius.group),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
