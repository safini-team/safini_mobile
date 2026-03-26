import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:safini/core/di/injection.dart';
import 'package:safini/features/tasks/cubit/task_cubit.dart';
import 'package:safini/features/tasks/cubit/task_state.dart';
import 'package:safini/features/tasks/model/task_model.dart';

class TaskListScreen extends StatelessWidget {
  final String childId;

  const TaskListScreen({required this.childId, super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<TaskCubit>()..loadTasks(childId),
      child: Scaffold(
        appBar: AppBar(title: const Text('Safini Tasks')),
        body: BlocBuilder<TaskCubit, TaskState>(
          builder: (context, state) {
            switch (state.status) {
              case TaskStatus.initial:
              case TaskStatus.loading:
                return const Center(child: CircularProgressIndicator());
              case TaskStatus.error:
                return Center(
                  child: Text(state.errorMessage ?? 'Something went wrong'),
                );
              case TaskStatus.loaded:
                if (state.tasks.isEmpty) {
                  return const Center(child: Text('No tasks found'));
                }
                return _TaskList(tasks: state.tasks);
            }
          },
        ),
      ),
    );
  }
}

class _TaskList extends StatelessWidget {
  final List<TaskModel> tasks;

  const _TaskList({required this.tasks});

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemBuilder: (context, index) {
        final task = tasks[index];
        return ListTile(
          tileColor: Theme.of(context).colorScheme.surfaceContainerHighest,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          title: Text(task.title),
          subtitle: Text('${task.durationMinutes} min'),
          trailing: task.isCompleted
              ? const Icon(Icons.check_circle, color: Colors.green)
              : TextButton(
                  onPressed: () =>
                      context.read<TaskCubit>().completeTask(task.id),
                  child: const Text('Complete'),
                ),
        );
      },
      separatorBuilder: (context, index) => const SizedBox(height: 8),
      itemCount: tasks.length,
    );
  }
}
