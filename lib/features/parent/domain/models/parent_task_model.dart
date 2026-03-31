class ParentTaskModel {
  final String id;
  final String title;
  final int durationMinutes;
  final bool isCompleted;
  final String assignedToChildId;

  const ParentTaskModel({
    required this.id,
    required this.title,
    required this.durationMinutes,
    required this.isCompleted,
    required this.assignedToChildId,
  });

  ParentTaskModel copyWith({bool? isCompleted}) {
    return ParentTaskModel(
      id: id,
      title: title,
      durationMinutes: durationMinutes,
      isCompleted: isCompleted ?? this.isCompleted,
      assignedToChildId: assignedToChildId,
    );
  }
}
