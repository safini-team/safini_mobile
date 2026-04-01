import 'package:json_annotation/json_annotation.dart';
import '../../domain/models/task_model.dart';

part 'task_dto.g.dart';

@JsonSerializable()
class TaskTemplateDto {
  final String id;
  @JsonKey(name: 'family_id')
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
