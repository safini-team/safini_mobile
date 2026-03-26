class TaskModel {
  final String id;
  final String title;
  final int durationMinutes;
  final bool isCompleted;
  final String assignedToChildId;

  const TaskModel({
    required this.id,
    required this.title,
    required this.durationMinutes,
    required this.isCompleted,
    required this.assignedToChildId,
  });

  TaskModel copyWith({bool? isCompleted}) {
    return TaskModel(
      id: id,
      title: title,
      durationMinutes: durationMinutes,
      isCompleted: isCompleted ?? this.isCompleted,
      assignedToChildId: assignedToChildId,
    );
  }
}
