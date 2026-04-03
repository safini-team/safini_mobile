import 'package:json_annotation/json_annotation.dart';
import '../../domain/models/task_model.dart';

part 'task_dto.g.dart';

@JsonSerializable()
class TaskTemplateDto {
  final String id;
  @JsonKey(name: 'family_id')
import '../../domain/models/task_model.dart';

class TaskTemplateDto {
  final String id;
  final String familyId;
  final String title;
  final String description;
  final String category;

  @JsonKey(name: 'coins_reward')
  final int coinsReward;
  @JsonKey(name: 'xp_reward')
  final int xpReward;
  @JsonKey(name: 'is_starter')
  final bool isStarter;
  @JsonKey(name: 'created_at')

  final int coinsReward;
  final int xpReward;
  final bool isStarter;
  final DateTime createdAt;

  TaskTemplateDto({
    required this.id,
    required this.familyId,
    required this.title,
    required this.description,
    required this.category,
    required this.coinsReward,
    required this.xpReward,
    required this.isStarter,
    required this.createdAt,
  });

  factory TaskTemplateDto.fromJson(Map<String, dynamic> json) => _$TaskTemplateDtoFromJson(json);
  Map<String, dynamic> toJson() => _$TaskTemplateDtoToJson(this);
  factory TaskTemplateDto.fromJson(Map<String, dynamic> json) {
    return TaskTemplateDto(
      id: json['id'] as String? ?? '',
      familyId: json['family_id'] as String? ?? '',
      title: json['title'] as String? ?? '',
      description: json['description'] as String? ?? '',
      category: json['category'] as String? ?? '',
      coinsReward: json['coins_reward'] as int? ?? 0,
      xpReward: json['xp_reward'] as int? ?? 0,
      isStarter: json['is_starter'] as bool? ?? false,
      createdAt: json['created_at'] != null ? DateTime.parse(json['created_at'] as String) : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'family_id': familyId,
      'title': title,
      'description': description,
      'category': category,
      'coins_reward': coinsReward,
      'xp_reward': xpReward,
      'is_starter': isStarter,
      'created_at': createdAt.toIso8601String(),
    };
  }

  TaskTemplateModel toDomain() {
    return TaskTemplateModel(
      id: id,
      familyId: familyId,
      title: title,
      description: description,
      category: category,
      coinsReward: coinsReward,
      xpReward: xpReward,
      isStarter: isStarter,
      createdAt: createdAt,
    );
  }
}

@JsonSerializable()
class TaskInstanceDto {
  final String id;
  @JsonKey(name: 'child_id')
  final String childId;
  @JsonKey(name: 'template_id')
  final String templateId;
  final String status;
  @JsonKey(name: 'due_date')
  final DateTime dueDate;
  @JsonKey(name: 'completed_at')
  final DateTime? completedAt;
  @JsonKey(name: 'proof_url')
  final String? proofUrl;
  @JsonKey(name: 'parent_note')
  final String? parentNote;
  @JsonKey(name: 'created_at')
  final DateTime createdAt;
  @JsonKey(name: 'updated_at')

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

  factory TaskInstanceDto.fromJson(Map<String, dynamic> json) => _$TaskInstanceDtoFromJson(json);
  Map<String, dynamic> toJson() => _$TaskInstanceDtoToJson(this);
  factory TaskInstanceDto.fromJson(Map<String, dynamic> json) {
    return TaskInstanceDto(
      id: json['id'] as String? ?? '',
      childId: json['child_id'] as String? ?? '',
      templateId: json['template_id'] as String? ?? '',
      status: json['status'] as String? ?? '',
      dueDate: json['due_date'] != null ? DateTime.parse(json['due_date'] as String) : DateTime.now(),
      completedAt: json['completed_at'] != null ? DateTime.parse(json['completed_at'] as String) : null,
      proofUrl: json['proof_url'] as String?,
      parentNote: json['parent_note'] as String?,
      createdAt: json['created_at'] != null ? DateTime.parse(json['created_at'] as String) : DateTime.now(),
      updatedAt: json['updated_at'] != null ? DateTime.parse(json['updated_at'] as String) : DateTime.now(),
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

@JsonSerializable()
class TaskSubmissionDto {
  @JsonKey(name: 'proof_url')
class TaskSubmissionDto {
  final String proofUrl;

  TaskSubmissionDto({required this.proofUrl});

  factory TaskSubmissionDto.fromJson(Map<String, dynamic> json) => _$TaskSubmissionDtoFromJson(json);
  Map<String, dynamic> toJson() => _$TaskSubmissionDtoToJson(this);
}

@JsonSerializable()
class TaskReviewDto {
  final String status;
  @JsonKey(name: 'parent_note')
  factory TaskSubmissionDto.fromJson(Map<String, dynamic> json) {
    return TaskSubmissionDto(
      proofUrl: json['proof_url'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'proof_url': proofUrl,
    };
  }
}

class TaskReviewDto {
  final String status;
  final String? parentNote;

  TaskReviewDto({required this.status, this.parentNote});

  factory TaskReviewDto.fromJson(Map<String, dynamic> json) => _$TaskReviewDtoFromJson(json);
  Map<String, dynamic> toJson() => _$TaskReviewDtoToJson(this);
  factory TaskReviewDto.fromJson(Map<String, dynamic> json) {
    return TaskReviewDto(
      status: json['status'] as String? ?? '',
      parentNote: json['parent_note'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'status': status,
      'parent_note': parentNote,
    };
  }
}
