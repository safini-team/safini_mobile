import 'package:safini/features/child/presentation/cubit/tasks_model.dart';

class TasksState {
  final List<TaskItem> tasks;
  final TaskCategory selectedCategory;

  const TasksState({
    required this.tasks,
    this.selectedCategory = TaskCategory.all,
  });

  const TasksState.initial()
      : tasks = const [],
        selectedCategory = TaskCategory.all;

  List<TaskItem> get filteredTasks => selectedCategory == TaskCategory.all
      ? tasks
      : tasks.where((t) => t.category == selectedCategory).toList();

  int get doneToday => tasks.where((t) => t.isCompleted).length;
  int get remaining => tasks.where((t) => !t.isCompleted).length;

  /// Sum of coins from completed tasks — shown as "Earned Today" stat.
  int get earnedToday =>
      tasks.where((t) => t.isCompleted).fold(0, (sum, t) => sum + t.coins);

  TasksState copyWith({
    List<TaskItem>? tasks,
    TaskCategory? selectedCategory,
  }) {
    return TasksState(
      tasks: tasks ?? this.tasks,
      selectedCategory: selectedCategory ?? this.selectedCategory,
    );
  }
}
