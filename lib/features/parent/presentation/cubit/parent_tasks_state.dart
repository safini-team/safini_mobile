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
  final List<ParentTaskTemplateModel> templates;
  final List<ParentTaskInstanceModel> todayInstances;

  const ParentTasksLoaded({
    required this.childId,
    required this.childName,
    required this.templates,
    required this.todayInstances,
  });

  List<ParentTaskInstanceModel> get pendingApproval => todayInstances
      .where((task) => task.isPendingApproval)
      .toList(growable: false);

  List<ParentTaskInstanceModel> get activeTasks => todayInstances
      .where((task) => !task.isPendingApproval && !task.isCompleted)
      .toList(growable: false);

  List<ParentTaskInstanceModel> get completedTasks =>
      todayInstances.where((task) => task.isCompleted).toList(growable: false);
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

class ParentTaskTemplateCreateInFlight extends ParentTasksState {
  final ParentTasksLoaded base;

  const ParentTaskTemplateCreateInFlight(this.base);
}

class ParentTaskTemplateCreateFailed extends ParentTasksState {
  final ParentTasksLoaded base;
  final String message;
  final bool isUnauthorized;
  final bool isServiceUnavailable;
  final Map<String, String> fieldErrors;

  const ParentTaskTemplateCreateFailed({
    required this.base,
    required this.message,
    this.isUnauthorized = false,
    this.isServiceUnavailable = false,
    this.fieldErrors = const {},
  });
}

class ParentTaskTemplateCreateSucceeded extends ParentTasksState {
  final ParentTasksLoaded data;
  final String message;

  const ParentTaskTemplateCreateSucceeded(
    this.data, {
    this.message = 'Task template created.',
  });
}
