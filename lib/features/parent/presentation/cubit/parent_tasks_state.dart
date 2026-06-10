import 'package:safini/features/parent/domain/models/parent_tasks_response_model.dart';

abstract class ParentTasksState {
  const ParentTasksState();
}

class ParentTasksInitial extends ParentTasksState {
  const ParentTasksInitial();
}

class ParentTasksLoading extends ParentTasksState {
  const ParentTasksLoading();
}

class ParentTasksLoaded extends ParentTasksState {
  final String childId;
  final String childName;
  final List<ParentTaskInstanceModel> tasks;

  const ParentTasksLoaded({
    required this.childId,
    required this.childName,
    required this.tasks,
  });

  List<ParentTaskInstanceModel> get pendingApproval =>
      tasks.where((task) => task.isPendingApproval).toList(growable: false);

  List<ParentTaskInstanceModel> get activeTasks => tasks
      .where((task) => !task.isPendingApproval && !task.isCompleted)
      .toList(growable: false);

  List<ParentTaskInstanceModel> get completedTasks =>
      tasks.where((task) => task.isCompleted).toList(growable: false);
}

class ParentTasksError extends ParentTasksState {
  final String message;
  final bool isUnauthorized;
  final bool canRetry;

  const ParentTasksError(
    this.message, {
    this.isUnauthorized = false,
    this.canRetry = true,
  });
}

class ParentTaskCreating extends ParentTasksState {
  final ParentTasksLoaded base;

  const ParentTaskCreating(this.base);
}

class ParentTaskCreated extends ParentTasksState {
  final ParentTasksLoaded base;

  const ParentTaskCreated(this.base);
}

class ParentTaskCreateError extends ParentTasksState {
  final ParentTasksLoaded base;
  final String message;
  final bool isUnauthorized;

  const ParentTaskCreateError({
    required this.base,
    required this.message,
    this.isUnauthorized = false,
  });
}
