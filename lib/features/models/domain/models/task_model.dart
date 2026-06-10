class TaskTemplateModel {
  final String id;
  final String? childId;
  final String? source;
  final String? taskType;
  final String title;
  final String? description;
  final String? category;
  final String? proofMode;
  final String? verificationMode;
  final String? recurrenceRule;
  final int coinReward;
  final int xpReward;
  final int? targetValue;
  final String? targetUnit;
  final Map<String, dynamic>? metadata;
  final String? status;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const TaskTemplateModel({
    required this.id,
    this.childId,
    this.source,
    this.taskType,
    required this.title,
    this.description,
    this.category,
    this.proofMode,
    this.verificationMode,
    this.recurrenceRule,
    required this.coinReward,
    required this.xpReward,
    this.targetValue,
    this.targetUnit,
    this.metadata,
    this.status,
    this.createdAt,
    this.updatedAt,
  });
}

class TaskInstanceModel {
  final String id;
  final String childId;
  final String templateId;
  final String status;
  final DateTime dueDate;
  final DateTime? completedAt;
  final String? proofUrl;
  final String? parentNote;
  final DateTime createdAt;
  final DateTime updatedAt;

  const TaskInstanceModel({
    required this.id,
    required this.childId,
    required this.templateId,
    required this.status,
    required this.dueDate,
    this.completedAt,
    this.proofUrl,
    this.parentNote,
    required this.createdAt,
    required this.updatedAt,
  });
}
