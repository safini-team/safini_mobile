import 'package:safini/features/tasks/model/task_model.dart';
import 'package:safini/features/tasks/repository/task_repository.dart';

class TaskRepositoryImpl implements TaskRepository {
  final List<TaskModel> _tasks = [
    const TaskModel(
      id: '1',
      title: 'Math homework',
      durationMinutes: 30,
      isCompleted: false,
      assignedToChildId: 'child_1',
    ),
    const TaskModel(
      id: '2',
      title: 'Read 10 pages',
      durationMinutes: 20,
      isCompleted: false,
      assignedToChildId: 'child_1',
    ),
    const TaskModel(
      id: '3',
      title: 'Clean room',
      durationMinutes: 15,
      isCompleted: true,
      assignedToChildId: 'child_2',
    ),
  ];

  @override
  Future<void> addTask(TaskModel task) async {
    _tasks.add(task);
  }

  @override
  Future<void> completeTask(String taskId) async {
    final index = _tasks.indexWhere((task) => task.id == taskId);
    if (index == -1) {
      throw StateError('Task with id $taskId not found');
    }
    _tasks[index] = _tasks[index].copyWith(isCompleted: true);
  }

  @override
  Future<List<TaskModel>> fetchTasks(String childId) async {
    return _tasks.where((task) => task.assignedToChildId == childId).toList();
  }
}
