import 'package:freezed_annotation/freezed_annotation.dart';

part 'ai_model.freezed.dart';

@freezed
class AIConversationLogModel with _$AIConversationLogModel {
  const factory AIConversationLogModel({
    required String id,
    required String childId,
    required int messageCount,
    DateTime? lastMessageAt,
    required DateTime createdAt,
  }) = _AIConversationLogModel;
} 

@freezed
class AIMessageModel with _$AIMessageModel {
  const factory AIMessageModel({
    required String role,
    required String content,
    required DateTime createdAt,
  }) = _AIMessageModel;
}

@freezed
class TaskSuggestionModel with _$TaskSuggestionModel {
  const factory TaskSuggestionModel({
    required String title,
    required String description,
    required String category,
    required int coinsReward,
    required int xpReward,
    required String reasoning,
  }) = _TaskSuggestionModel;
}
