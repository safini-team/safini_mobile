import 'package:safini/features/parent/domain/models/parent_task_model.dart';

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
  final List<ParentTaskModel> pendingApproval;
  final List<ParentTaskModel> activeTasks;
  final List<ParentTaskModel> completedTasks;

  const ParentTasksLoaded({
    required this.pendingApproval,
    required this.activeTasks,
    required this.completedTasks,
  });
}

class ParentTasksError extends ParentTasksState {
  final String message;
  const ParentTasksError(this.message);
}
