import '../../domain/models/task_model.dart';

class TaskTemplateDto {
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

  TaskTemplateDto({
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

  factory TaskTemplateDto.fromJson(Map<String, dynamic> json) {
    return TaskTemplateDto(
      id: json['id'] as String? ?? '',
      childId: json['child_id'] as String?,
      source: json['source'] as String?,
      taskType: json['task_type'] as String?,
      title: json['title'] as String? ?? '',
      description: json['description'] as String?,
      category: json['category'] as String?,
      proofMode: json['proof_mode'] as String?,
      verificationMode: json['verification_mode'] as String?,
      recurrenceRule: json['recurrence_rule'] as String?,
      coinReward: json['coin_reward'] as int? ?? 0,
      xpReward: json['xp_reward'] as int? ?? 0,
      targetValue: json['target_value'] as int?,
      targetUnit: json['target_unit'] as String?,
      metadata: json['metadata'] as Map<String, dynamic>?,
      status: json['status'] as String?,
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'] as String)
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.tryParse(json['updated_at'] as String)
          : null,
    );
  }

  TaskTemplateModel toDomain() {
    return TaskTemplateModel(
      id: id,
      childId: childId,
      source: source,
      taskType: taskType,
      title: title,
      description: description,
      category: category,
      proofMode: proofMode,
      verificationMode: verificationMode,
      recurrenceRule: recurrenceRule,
      coinReward: coinReward,
      xpReward: xpReward,
      targetValue: targetValue,
      targetUnit: targetUnit,
      metadata: metadata,
      status: status,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }
}

class TaskTemplateCreateRequestDto {
  final String title;
  final String category;
  final String taskType;
  final String proofMode;
  final String recurrenceRule;
  final String verificationMode;
  final int coinReward;
  final int xpReward;
  final String? description;
  final int? targetValue;
  final String? targetUnit;
  final String? contentRef;
  final Map<String, dynamic>? metadata;

  const TaskTemplateCreateRequestDto({
    required this.title,
    required this.category,
    required this.taskType,
    required this.proofMode,
    required this.recurrenceRule,
    required this.verificationMode,
    required this.coinReward,
    required this.xpReward,
    this.description,
    this.targetValue,
    this.targetUnit,
    this.contentRef,
    this.metadata,
  });

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{
      'title': title,
      'category': category,
      'task_type': taskType,
      'proof_mode': proofMode,
      'recurrence_rule': recurrenceRule,
      'verification_mode': verificationMode,
      'coin_reward': coinReward,
      'xp_reward': xpReward,
    };

    void addOptional(String key, Object? value) {
      if (value == null) return;
      if (value is String && value.trim().isEmpty) return;
      json[key] = value;
    }

    addOptional('description', description);
    addOptional('target_value', targetValue);
    addOptional('target_unit', targetUnit);
    addOptional('content_ref', contentRef);
    addOptional('metadata', metadata);
    return json;
  }
}

class TaskInstanceDto {
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

  TaskInstanceDto({
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

  factory TaskInstanceDto.fromJson(Map<String, dynamic> json) {
    return TaskInstanceDto(
      id: json['id'] as String? ?? '',
      childId: json['child_id'] as String? ?? '',
      templateId: json['template_id'] as String? ?? '',
      status: json['status'] as String? ?? '',
      dueDate: json['due_date'] != null
          ? DateTime.parse(json['due_date'] as String)
          : DateTime.now(),
      completedAt: json['completed_at'] != null
          ? DateTime.parse(json['completed_at'] as String)
          : null,
      proofUrl: json['proof_url'] as String?,
      parentNote: json['parent_note'] as String?,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : DateTime.now(),
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'child_id': childId,
      'template_id': templateId,
      'status': status,
      'due_date': dueDate.toIso8601String(),
      'completed_at': completedAt?.toIso8601String(),
      'proof_url': proofUrl,
      'parent_note': parentNote,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  TaskInstanceModel toDomain() {
    return TaskInstanceModel(
      id: id,
      childId: childId,
      templateId: templateId,
      status: status,
      dueDate: dueDate,
      completedAt: completedAt,
      proofUrl: proofUrl,
      parentNote: parentNote,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }
}

class TaskSubmissionDto {
  final String proofUrl;

  TaskSubmissionDto({required this.proofUrl});

  factory TaskSubmissionDto.fromJson(Map<String, dynamic> json) {
    return TaskSubmissionDto(proofUrl: json['proof_url'] as String? ?? '');
  }

  Map<String, dynamic> toJson() {
    return {'proof_url': proofUrl};
  }
}

class TaskReviewDto {
  final String status;
  final String? parentNote;

  TaskReviewDto({required this.status, this.parentNote});

  factory TaskReviewDto.fromJson(Map<String, dynamic> json) {
    return TaskReviewDto(
      status: json['status'] as String? ?? '',
      parentNote: json['parent_note'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {'status': status, 'parent_note': parentNote};
  }
}
