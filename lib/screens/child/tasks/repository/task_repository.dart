import 'package:safini/screens/child/tasks/model/task_model.dart';

abstract class TaskRepository {
  Future<void> addTask(TaskModel task);
  Future<void> completeTask(String taskId);
  Future<List<TaskModel>> fetchTasks(String childId);
}
