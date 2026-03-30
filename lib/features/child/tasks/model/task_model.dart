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

  TaskModel copyWith({
    String? id,
    String? title,
    int? durationMinutes,
    bool? isCompleted,
    String? assignedToChildId,
  }) {
    return TaskModel(
      id: id ?? this.id,
      title: title ?? this.title,
      durationMinutes: durationMinutes ?? this.durationMinutes,
      isCompleted: isCompleted ?? this.isCompleted,
      assignedToChildId: assignedToChildId ?? this.assignedToChildId,
    );
  }
}
