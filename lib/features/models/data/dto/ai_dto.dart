import 'package:json_annotation/json_annotation.dart';
import '../../domain/models/ai_model.dart';

part 'ai_dto.g.dart';

@JsonSerializable()
class AIConversationLogDto {
  final String id;
  @JsonKey(name: 'child_id')
  final String childId;
  @JsonKey(name: 'message_count')
  final int messageCount;
  @JsonKey(name: 'last_message_at')
  final DateTime? lastMessageAt;
  @JsonKey(name: 'created_at')
  final DateTime createdAt;

  AIConversationLogDto({
    required this.id,
    required this.childId,
    required this.messageCount,
    this.lastMessageAt,
    required this.createdAt,
  });

  factory AIConversationLogDto.fromJson(Map<String, dynamic> json) => _$AIConversationLogDtoFromJson(json);
  Map<String, dynamic> toJson() => _$AIConversationLogDtoToJson(this);

  AIConversationLogModel toDomain() {
    return AIConversationLogModel(
      id: id,
      childId: childId,
      messageCount: messageCount,
      lastMessageAt: lastMessageAt,
      createdAt: createdAt,
    );
  }
}

@JsonSerializable()
class AIMessageDto {
  final String role;
  final String content;
  @JsonKey(name: 'created_at')
  final DateTime createdAt;

  AIMessageDto({
    required this.role,
    required this.content,
    required this.createdAt,
  });

  factory AIMessageDto.fromJson(Map<String, dynamic> json) => _$AIMessageDtoFromJson(json);
  Map<String, dynamic> toJson() => _$AIMessageDtoToJson(this);

  AIMessageModel toDomain() {
    return AIMessageModel(
      role: role,
      content: content,
      createdAt: createdAt,
    );
  }
}

@JsonSerializable()
class TaskSuggestionDto {
  final String title;
  final String description;
  final String category;
  @JsonKey(name: 'coins_reward')
  final int coinsReward;
  @JsonKey(name: 'xp_reward')
  final int xpReward;
  final String reasoning;

  TaskSuggestionDto({
    required this.title,
    required this.description,
    required this.category,
    required this.coinsReward,
    required this.xpReward,
    required this.reasoning,
  });

  factory TaskSuggestionDto.fromJson(Map<String, dynamic> json) => _$TaskSuggestionDtoFromJson(json);
  Map<String, dynamic> toJson() => _$TaskSuggestionDtoToJson(this);

  TaskSuggestionModel toDomain() {
    return TaskSuggestionModel(
      title: title,
      description: description,
      category: category,
      coinsReward: coinsReward,
      xpReward: xpReward,
      reasoning: reasoning,
    );
  }
}
