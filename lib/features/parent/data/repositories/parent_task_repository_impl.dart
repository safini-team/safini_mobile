import 'package:safini/features/parent/domain/models/parent_task_model.dart';
import 'package:safini/features/parent/domain/repositories/i_parent_task_repository.dart';

class ParentTaskRepositoryImpl implements IParentTaskRepository {
  final List<ParentTaskModel> _tasks = [
    const ParentTaskModel(
      id: '1',
      title: 'Math homework',
      durationMinutes: 30,
      isCompleted: false,
      assignedToChildId: 'child_1',
    ),
    const ParentTaskModel(
      id: '2',
      title: 'Read 10 pages',
      durationMinutes: 20,
      isCompleted: false,
      assignedToChildId: 'child_1',
    ),
    const ParentTaskModel(
      id: '3',
      title: 'Clean room',
      durationMinutes: 15,
      isCompleted: true,
      assignedToChildId: 'child_2',
    ),
  ];

  @override
  Future<void> addTask(ParentTaskModel task) async {
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
  Future<List<ParentTaskModel>> fetchTasks(String childId) async {
    return _tasks.where((task) => task.assignedToChildId == childId).toList();
  }
}
