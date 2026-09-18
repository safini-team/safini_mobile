class TaskTemplateModel {
  final String id;
  final String? childId;
  final String? source;
  final String? taskType;
  final String title;
  final String? description;
  final String? category;
  final String? proofMode;
  final String? verificationMode;
  final String? recurrenceRule;
  final int coinReward;
  final int xpReward;
  final int? targetValue;
  final String? targetUnit;
  final Map<String, dynamic>? metadata;
  final String? status;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const TaskTemplateModel({
    required this.id,
    this.childId,
    this.source,
    this.taskType,
    required this.title,
    this.description,
    this.category,
    this.proofMode,
    this.verificationMode,
    this.recurrenceRule,
    required this.coinReward,
    required this.xpReward,
    this.targetValue,
    this.targetUnit,
    this.metadata,
    this.status,
    this.createdAt,
    this.updatedAt,
  });
}

class TaskModel {
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

  /// `none` | `daily` | `weekly`, and the weekday bitmask for `weekly`
  /// (Mon=1 ... Sun=64). A rule makes the task a template.
  final String recurrence;
  final int? recurrenceDays;

  /// Short-lived signed playback URL. Present when the parent attached a
  /// voice instruction; the child player uses this, never the object key.
  final String? voiceInstructionUrl;
  final String? voiceInstructionObjectKey;
  final int? voiceInstructionDurationMs;
  final String? voiceInstructionMime;

  final String? status;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const TaskModel({
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
    this.recurrence = 'none',
    this.recurrenceDays,
    this.voiceInstructionUrl,
    this.voiceInstructionObjectKey,
    this.voiceInstructionDurationMs,
    this.voiceInstructionMime,
    this.status,
    this.createdAt,
    this.updatedAt,
  });

  bool get hasVoiceInstruction {
    final url = voiceInstructionUrl?.trim() ?? '';
    final key = voiceInstructionObjectKey?.trim() ?? '';
    return url.isNotEmpty || key.isNotEmpty;
  }
}

class TaskInstanceModel {
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

  const TaskInstanceModel({
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
}
