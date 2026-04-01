import 'package:safini/features/parent/domain/models/parent_task_model.dart';

abstract class IParentTaskRepository {
  Future<List<ParentTaskModel>> fetchTasks(String childId);
  Future<void> completeTask(String taskId);
  Future<void> addTask(ParentTaskModel task);
}
