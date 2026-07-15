import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:safini/core/translation/generated/l10n.dart';
import 'package:safini/core/utils/extension/theme_extension.dart';
import 'package:safini/features/parent/domain/models/parent_tasks_response_model.dart';
import 'package:safini/features/parent/presentation/cubit/parent_tasks_cubit.dart';
import 'package:safini/features/parent/presentation/cubit/parent_tasks_state.dart';
import 'package:safini/features/parent/presentation/widgets/tasks/task_sheet.dart';
import 'package:safini/features/parent/presentation/widgets/tiles/parent_task_tile.dart';

class MonitorTasksSection extends StatelessWidget {
  const MonitorTasksSection({super.key});

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                s.realWorldTasks,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF1A1A1A),
                  letterSpacing: -0.5,
                ),
              ),
            ),
            const SizedBox(width: 8),
            BlocBuilder<ParentTasksCubit, ParentTasksState>(
              builder: (context, state) {
                final loaded = _loadedOf(state);
                return ElevatedButton.icon(
                  onPressed: loaded != null
                      ? () => showTaskSheet(
                            context,
                            cubit: context.read<ParentTasksCubit>(),
                            childId: loaded.childId,
                          )
                      : null,
                  icon: const Icon(Icons.add, size: 20),
                  label: Text(
                    s.newTask,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: context.colorScheme.primary,
                    foregroundColor: context.colorScheme.onPrimary,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 10,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                );
              },
            ),
          ],
        ),
        const SizedBox(height: 20),
        BlocBuilder<ParentTasksCubit, ParentTasksState>(
          builder: (context, state) {
            if (state is ParentTasksLoading || state is ParentTasksInitial) {
              return const Center(
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 24),
                  child: CircularProgressIndicator(),
                ),
              );
            }

            if (state is ParentTasksError) {
              return const SizedBox.shrink();
            }

            final loaded = _loadedOf(state);
            if (loaded == null) return const SizedBox.shrink();

            final preview = [
              ...loaded.pendingApproval,
              ...loaded.activeTasks,
              ...loaded.completedTasks,
            ].take(3).toList();

            if (preview.isEmpty) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Text(
                  s.noTasksYet,
                  style: TextStyle(
                    color: context.colorScheme.onSurface.withValues(alpha: 0.45),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              );
            }

            return Column(
              children: preview
                  .map((task) => _buildTile(context, task))
                  .toList(),
            );
          },
        ),
      ],
    );
  }

  ParentTaskTile _buildTile(
    BuildContext context,
    ParentTaskInstanceModel task,
  ) {
    return ParentTaskTile(
      title: task.displayTitle,
      category: task.category,
      rewardCoins: task.rewardCoins,
      statusLabel: task.status,
      isPending: task.isPendingApproval,
      isCompleted: task.isCompleted,
      onTap: task.isEditable
          ? () {
              final cubit = context.read<ParentTasksCubit>();
              final loaded = _loadedOf(cubit.state);
              if (loaded == null) return;
              showTaskSheet(
                context,
                cubit: cubit,
                childId: loaded.childId,
                task: task.toTaskModel(),
              );
            }
          : null,
    );
  }
}

ParentTasksLoaded? _loadedOf(ParentTasksState state) {
  return switch (state) {
    ParentTasksLoaded s => s,
    ParentTaskSaving s => s.base,
    ParentTaskSaved s => s.base,
    ParentTaskDeleting s => s.base,
    ParentTaskDeleted s => s.base,
    ParentTaskActionError s => s.base,
    _ => null,
  };
}
