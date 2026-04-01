import '../../domain/models/ai_model.dart';

class AIConversationLogDto {
  final String id;
  final String childId;
  final int messageCount;
  final DateTime? lastMessageAt;
  final DateTime createdAt;

  AIConversationLogDto({
    required this.id,
    required this.childId,
    required this.messageCount,
    this.lastMessageAt,
    required this.createdAt,
  });

  factory AIConversationLogDto.fromJson(Map<String, dynamic> json) {
    return AIConversationLogDto(
      id: json['id'] as String? ?? '',
      childId: json['child_id'] as String? ?? '',
      messageCount: json['message_count'] as int? ?? 0,
      lastMessageAt: json['last_message_at'] != null ? DateTime.parse(json['last_message_at'] as String) : null,
      createdAt: json['created_at'] != null ? DateTime.parse(json['created_at'] as String) : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'child_id': childId,
      'message_count': messageCount,
      'last_message_at': lastMessageAt?.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
    };
  }

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

class AIMessageDto {
  final String role;
  final String content;
  final DateTime createdAt;

  AIMessageDto({
    required this.role,
    required this.content,
    required this.createdAt,
  });

  factory AIMessageDto.fromJson(Map<String, dynamic> json) {
    return AIMessageDto(
      role: json['role'] as String? ?? '',
      content: json['content'] as String? ?? '',
      createdAt: json['created_at'] != null ? DateTime.parse(json['created_at'] as String) : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'role': role,
      'content': content,
      'created_at': createdAt.toIso8601String(),
    };
  }

  AIMessageModel toDomain() {
    return AIMessageModel(
      role: role,
      content: content,
      createdAt: createdAt,
    );
  }
}

class TaskSuggestionDto {
  final String title;
  final String description;
  final String category;
  final int coinsReward;
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

  factory TaskSuggestionDto.fromJson(Map<String, dynamic> json) {
    return TaskSuggestionDto(
      title: json['title'] as String? ?? '',
      description: json['description'] as String? ?? '',
      category: json['category'] as String? ?? '',
      coinsReward: json['coins_reward'] as int? ?? 0,
      xpReward: json['xp_reward'] as int? ?? 0,
      reasoning: json['reasoning'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'description': description,
      'category': category,
      'coins_reward': coinsReward,
      'xp_reward': xpReward,
      'reasoning': reasoning,
    };
  }

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
