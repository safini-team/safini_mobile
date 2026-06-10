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

/// Create OR update in flight (the sheet shows a spinner).
class ParentTaskSaving extends ParentTasksState {
  final ParentTasksLoaded base;

  const ParentTaskSaving(this.base);
}

/// Create OR update succeeded. [wasCreate] distinguishes the toast wording.
class ParentTaskSaved extends ParentTasksState {
  final ParentTasksLoaded base;
  final bool wasCreate;

  const ParentTaskSaved(this.base, {required this.wasCreate});
}

class ParentTaskDeleting extends ParentTasksState {
  final ParentTasksLoaded base;

  const ParentTaskDeleting(this.base);
}

class ParentTaskDeleted extends ParentTasksState {
  final ParentTasksLoaded base;

  const ParentTaskDeleted(this.base);
}

/// Any create/update/delete failure. [isConflict] is a 409 (approved task).
class ParentTaskActionError extends ParentTasksState {
  final ParentTasksLoaded base;
  final String message;
  final bool isConflict;
  final bool isUnauthorized;

  const ParentTaskActionError({
    required this.base,
    required this.message,
    this.isConflict = false,
    this.isUnauthorized = false,
  });
}
