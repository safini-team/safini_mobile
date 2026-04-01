import 'package:freezed_annotation/freezed_annotation.dart';

part 'task_model.freezed.dart';

@freezed
class TaskTemplateModel with _$TaskTemplateModel {
  const factory TaskTemplateModel({
    required String id,
    required String familyId,
    required String title,
    required String description,
    required String category,
    required int coinsReward,
    required int xpReward,
    required bool isStarter,
    required DateTime createdAt,
  }) = _TaskTemplateModel;
}

@freezed
class TaskInstanceModel with _$TaskInstanceModel {
  const factory TaskInstanceModel({
    required String id,
    required String childId,
    required String templateId,
    required String status,
    required DateTime dueDate,
    DateTime? completedAt,
    String? proofUrl,
    String? parentNote,
    required DateTime createdAt,
    required DateTime updatedAt,
  }) = _TaskInstanceModel;
}
