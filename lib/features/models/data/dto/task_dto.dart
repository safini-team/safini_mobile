import '../../domain/models/task_model.dart';

class TaskDto {
  final String id;
  final String? childId;
  final String? source;
  final String? taskType;
  final String title;
  final String? description;
  final String? category;
  final String? proofMode;
  final String? verificationMode;
  final int coinReward;
  final int xpReward;
  final int? targetValue;
  final String? targetUnit;
  final Map<String, dynamic>? metadata;
  final String? dueOn;
  final String? status;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  TaskDto({
    required this.id,
    this.childId,
    this.source,
    this.taskType,
    required this.title,
    this.description,
    this.category,
    this.proofMode,
    this.verificationMode,
    required this.coinReward,
    required this.xpReward,
    this.targetValue,
    this.targetUnit,
    this.metadata,
    this.dueOn,
    this.status,
    this.createdAt,
    this.updatedAt,
  });

  factory TaskDto.fromJson(Map<String, dynamic> json) {
    return TaskDto(
      id: json['id'] as String? ?? '',
      childId: json['child_id'] as String?,
      source: json['source'] as String?,
      taskType: json['task_type'] as String?,
      title: json['title'] as String? ?? '',
      description: json['description'] as String?,
      category: json['category'] as String?,
      proofMode: json['proof_mode'] as String?,
      verificationMode: json['verification_mode'] as String?,
      coinReward: json['coin_reward'] as int? ?? 0,
      xpReward: json['xp_reward'] as int? ?? 0,
      targetValue: json['target_value'] as int?,
      targetUnit: json['target_unit'] as String?,
      metadata: json['metadata'] as Map<String, dynamic>?,
      dueOn: json['due_on'] as String?,
      status: json['status'] as String?,
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'] as String)
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.tryParse(json['updated_at'] as String)
          : null,
    );
  }

  TaskModel toDomain() {
    return TaskModel(
      id: id,
      childId: childId,
      source: source,
      taskType: taskType,
      title: title,
      description: description,
      category: category,
      proofMode: proofMode,
      verificationMode: verificationMode,
      coinReward: coinReward,
      xpReward: xpReward,
      targetValue: targetValue,
      targetUnit: targetUnit,
      metadata: metadata,
      dueOn: dueOn,
      status: status,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }
}

class TaskCreateRequestDto {
  final String title;
  final String category;
  final String taskType;
  final String proofMode;
  final String verificationMode;
  final int coinReward;
  final int xpReward;
  final String? description;
  final int? targetValue;
  final String? targetUnit;
  final String? contentRef;
  final String? dueOn;
  final Map<String, dynamic>? metadata;

  const TaskCreateRequestDto({
    required this.title,
    required this.category,
    required this.taskType,
    required this.proofMode,
    required this.verificationMode,
    required this.coinReward,
    required this.xpReward,
    this.description,
    this.targetValue,
    this.targetUnit,
    this.contentRef,
    this.dueOn,
    this.metadata,
  });

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{
      'title': title,
      'category': category,
      'task_type': taskType,
      'proof_mode': proofMode,
      'verification_mode': verificationMode,
      'coin_reward': coinReward.clamp(0, 100000),
      'xp_reward': xpReward.clamp(0, 100000),
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
    addOptional('due_on', dueOn);
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
