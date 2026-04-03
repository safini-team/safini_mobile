// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ai_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AIConversationLogDto _$AIConversationLogDtoFromJson(
  Map<String, dynamic> json,
) => AIConversationLogDto(
  id: json['id'] as String,
  childId: json['child_id'] as String,
  messageCount: (json['message_count'] as num).toInt(),
  lastMessageAt: json['last_message_at'] == null
      ? null
      : DateTime.parse(json['last_message_at'] as String),
  createdAt: DateTime.parse(json['created_at'] as String),
);

Map<String, dynamic> _$AIConversationLogDtoToJson(
  AIConversationLogDto instance,
) => <String, dynamic>{
  'id': instance.id,
  'child_id': instance.childId,
  'message_count': instance.messageCount,
  'last_message_at': instance.lastMessageAt?.toIso8601String(),
  'created_at': instance.createdAt.toIso8601String(),
};

AIMessageDto _$AIMessageDtoFromJson(Map<String, dynamic> json) => AIMessageDto(
  role: json['role'] as String,
  content: json['content'] as String,
  createdAt: DateTime.parse(json['created_at'] as String),
);

Map<String, dynamic> _$AIMessageDtoToJson(AIMessageDto instance) =>
    <String, dynamic>{
      'role': instance.role,
      'content': instance.content,
      'created_at': instance.createdAt.toIso8601String(),
    };

TaskSuggestionDto _$TaskSuggestionDtoFromJson(Map<String, dynamic> json) =>
    TaskSuggestionDto(
      title: json['title'] as String,
      description: json['description'] as String,
      category: json['category'] as String,
      coinsReward: (json['coins_reward'] as num).toInt(),
      xpReward: (json['xp_reward'] as num).toInt(),
      reasoning: json['reasoning'] as String,
    );

Map<String, dynamic> _$TaskSuggestionDtoToJson(TaskSuggestionDto instance) =>
    <String, dynamic>{
      'title': instance.title,
      'description': instance.description,
      'category': instance.category,
      'coins_reward': instance.coinsReward,
      'xp_reward': instance.xpReward,
      'reasoning': instance.reasoning,
    };
