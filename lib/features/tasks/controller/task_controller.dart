import 'package:safini/features/tasks/model/task_model.dart';
import 'package:safini/features/tasks/repository/task_repository.dart';

class TaskController {
  final TaskRepository _repository;

  TaskController(this._repository);

  Future<List<TaskModel>> getTasksForChild(String childId) {
    return _repository.fetchTasks(childId);
  }

  Future<void> markComplete(String taskId) {
    return _repository.completeTask(taskId);
  }
}
