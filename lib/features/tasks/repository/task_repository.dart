import 'package:safini/features/tasks/model/task_model.dart';

abstract class TaskRepository {
  Future<List<TaskModel>> fetchTasks(String childId);
  Future<void> completeTask(String taskId);
  Future<void> addTask(TaskModel task);
}
