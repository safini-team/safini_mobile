class AIConversationLogModel {
  final String id;
  final String childId;
  final int messageCount;
  final DateTime? lastMessageAt;
  final DateTime createdAt;

  const AIConversationLogModel({
    required this.id,
    required this.childId,
    required this.messageCount,
    this.lastMessageAt,
    required this.createdAt,
  });

  factory AIConversationLogModel.fromJson(Map<String, dynamic> json) {
    return AIConversationLogModel(
      id: json['id'] as String,
      childId: json['childId'] as String,
      messageCount: json['messageCount'] as int,
      lastMessageAt: json['lastMessageAt'] != null
          ? DateTime.parse(json['lastMessageAt'] as String)
          : null,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'childId': childId,
      'messageCount': messageCount,
      'lastMessageAt': lastMessageAt?.toIso8601String(),
      'createdAt': createdAt.toIso8601String(),
    };
  }
}

class AIMessageModel {
  final String role;
  final String content;
  final DateTime createdAt;

  const AIMessageModel({
    required this.role,
    required this.content,
    required this.createdAt,
  });

  factory AIMessageModel.fromJson(Map<String, dynamic> json) {
    return AIMessageModel(
      role: json['role'] as String,
      content: json['content'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'role': role,
      'content': content,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}

class TaskSuggestionModel {
  final String title;
  final String description;
  final String category;
  final int coinsReward;
  final int xpReward;
  final String reasoning;

  const TaskSuggestionModel({
    required this.title,
    required this.description,
    required this.category,
    required this.coinsReward,
    required this.xpReward,
    required this.reasoning,
  });

  factory TaskSuggestionModel.fromJson(Map<String, dynamic> json) {
    return TaskSuggestionModel(
      title: json['title'] as String,
      description: json['description'] as String,
      category: json['category'] as String,
      coinsReward: json['coinsReward'] as int,
      xpReward: json['xpReward'] as int,
      reasoning: json['reasoning'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'description': description,
      'category': category,
      'coinsReward': coinsReward,
      'xpReward': xpReward,
      'reasoning': reasoning,
    };
  }
}