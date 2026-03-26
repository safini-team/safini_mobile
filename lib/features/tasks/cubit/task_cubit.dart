import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:safini/features/tasks/controller/task_controller.dart';
import 'package:safini/features/tasks/cubit/task_state.dart';

class TaskCubit extends Cubit<TaskState> {
  final TaskController _controller;

  TaskCubit(this._controller) : super(const TaskState.initial());

  Future<void> loadTasks(String childId) async {
    emit(state.copyWith(status: TaskStatus.loading));
    try {
      final tasks = await _controller.getTasksForChild(childId);
      emit(state.copyWith(status: TaskStatus.loaded, tasks: tasks));
    } catch (error) {
      emit(
        state.copyWith(
          status: TaskStatus.error,
          errorMessage: error.toString(),
        ),
      );
    }
  }

  Future<void> completeTask(String taskId) async {
    try {
      await _controller.markComplete(taskId);
      final updatedTasks = state.tasks
          .map((task) => task.id == taskId ? task.copyWith(isCompleted: true) : task)
          .toList();
      emit(state.copyWith(status: TaskStatus.loaded, tasks: updatedTasks));
    } catch (error) {
      emit(
        state.copyWith(
          status: TaskStatus.error,
          errorMessage: error.toString(),
        ),
      );
    }
  }
}
