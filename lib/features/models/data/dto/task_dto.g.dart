// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'task_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TaskTemplateDto _$TaskTemplateDtoFromJson(Map<String, dynamic> json) =>
    TaskTemplateDto(
      id: json['id'] as String,
      familyId: json['family_id'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      category: json['category'] as String,
      coinsReward: (json['coins_reward'] as num).toInt(),
      xpReward: (json['xp_reward'] as num).toInt(),
      isStarter: json['is_starter'] as bool,
      createdAt: DateTime.parse(json['created_at'] as String),
    );

Map<String, dynamic> _$TaskTemplateDtoToJson(TaskTemplateDto instance) =>
    <String, dynamic>{
      'id': instance.id,
      'family_id': instance.familyId,
      'title': instance.title,
      'description': instance.description,
      'category': instance.category,
      'coins_reward': instance.coinsReward,
      'xp_reward': instance.xpReward,
      'is_starter': instance.isStarter,
      'created_at': instance.createdAt.toIso8601String(),
    };

TaskInstanceDto _$TaskInstanceDtoFromJson(Map<String, dynamic> json) =>
    TaskInstanceDto(
      id: json['id'] as String,
      childId: json['child_id'] as String,
      templateId: json['template_id'] as String,
      status: json['status'] as String,
      dueDate: DateTime.parse(json['due_date'] as String),
      completedAt: json['completed_at'] == null
          ? null
          : DateTime.parse(json['completed_at'] as String),
      proofUrl: json['proof_url'] as String?,
      parentNote: json['parent_note'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );

Map<String, dynamic> _$TaskInstanceDtoToJson(TaskInstanceDto instance) =>
    <String, dynamic>{
      'id': instance.id,
      'child_id': instance.childId,
      'template_id': instance.templateId,
      'status': instance.status,
      'due_date': instance.dueDate.toIso8601String(),
      'completed_at': instance.completedAt?.toIso8601String(),
      'proof_url': instance.proofUrl,
      'parent_note': instance.parentNote,
      'created_at': instance.createdAt.toIso8601String(),
      'updated_at': instance.updatedAt.toIso8601String(),
    };

TaskSubmissionDto _$TaskSubmissionDtoFromJson(Map<String, dynamic> json) =>
    TaskSubmissionDto(proofUrl: json['proof_url'] as String);

Map<String, dynamic> _$TaskSubmissionDtoToJson(TaskSubmissionDto instance) =>
    <String, dynamic>{'proof_url': instance.proofUrl};

TaskReviewDto _$TaskReviewDtoFromJson(Map<String, dynamic> json) =>
    TaskReviewDto(
      status: json['status'] as String,
      parentNote: json['parent_note'] as String?,
    );

Map<String, dynamic> _$TaskReviewDtoToJson(TaskReviewDto instance) =>
    <String, dynamic>{
      'status': instance.status,
      'parent_note': instance.parentNote,
    };
