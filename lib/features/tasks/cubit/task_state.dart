import 'package:safini/features/tasks/model/task_model.dart';

enum TaskStatus { initial, loading, loaded, error }

class TaskState {
  final TaskStatus status;
  final List<TaskModel> tasks;
  final String? errorMessage;

  const TaskState({
    required this.status,
    required this.tasks,
    this.errorMessage,
  });

  const TaskState.initial()
      : status = TaskStatus.initial,
        tasks = const [],
        errorMessage = null;

  TaskState copyWith({
    TaskStatus? status,
    List<TaskModel>? tasks,
    String? errorMessage,
  }) {
    return TaskState(
      status: status ?? this.status,
      tasks: tasks ?? this.tasks,
      errorMessage: errorMessage,
    );
  }
}
