import 'package:safini/features/models/domain/models/task_model.dart';

class ParentTasksResponseModel {
  /// The day this payload represents (YYYY-MM-DD), echoed by the API.
  final String? date;

  /// Flat list of tasks for the child on [date]. Each carries its own status;
  /// the UI groups them into pending / active / completed.
  final List<ParentTaskInstanceModel> tasks;

  const ParentTasksResponseModel({this.date, required this.tasks});

  factory ParentTasksResponseModel.fromJson(Map<String, dynamic> json) {
    return ParentTasksResponseModel(
      date: _nullableStringValue(json, ['date']),
      tasks: _listFromJson(
        json['tasks'] ?? json['today_instances'] ?? json['todayInstances'],
        ParentTaskInstanceModel.fromJson,
      ),
    );
  }

  static List<T> _listFromJson<T>(
    dynamic value,
    T Function(Map<String, dynamic>) fromJson,
  ) {
    if (value is! List) return const [];
    return value
        .whereType<Map>()
        .map(
          (item) => item.map((key, value) => MapEntry(key.toString(), value)),
        )
        .map(fromJson)
        .toList();
  }
}

class ParentTaskTemplateCreateRequest {
  final String title;
  final String category;
  final String taskType;
  final String recurrenceRule;
  final String proofMode;
  final String verificationMode;
  final int coinReward;
  final int xpReward;
  final String? description;
  final String? targetUnit;
  final num? targetValue;
  final String? contentRef;
  final Map<String, dynamic>? metadata;

  const ParentTaskTemplateCreateRequest({
    required this.title,
    required this.category,
    required this.taskType,
    required this.recurrenceRule,
    required this.proofMode,
    required this.verificationMode,
    required this.coinReward,
    required this.xpReward,
    this.description,
    this.targetUnit,
    this.targetValue,
    this.contentRef,
    this.metadata,
  });

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{
      'title': title,
      'category': category,
      'task_type': taskType,
      'recurrence_rule': recurrenceRule,
      'proof_mode': proofMode,
      'verification_mode': verificationMode,
      'coin_reward': coinReward,
      'xp_reward': xpReward,
    };

    void addOptional(String key, Object? value) {
      if (value == null) return;
      if (value is String && value.trim().isEmpty) return;
      json[key] = value;
    }

    addOptional('description', description);
    addOptional('target_unit', targetUnit);
    addOptional('target_value', targetValue);
    addOptional('content_ref', contentRef);
    addOptional('metadata', metadata);
    return json;
  }

  bool get mayGenerateTodayInstance {
    final normalized = recurrenceRule.trim().toLowerCase();
    return normalized == 'once' || normalized == 'manual';
  }
}

class ParentTaskTemplateCreateResult {
  final ParentTaskTemplateModel template;
  final List<ParentTaskInstanceModel> todayInstances;

  const ParentTaskTemplateCreateResult({
    required this.template,
    required this.todayInstances,
  });

  factory ParentTaskTemplateCreateResult.fromJson(Map<String, dynamic> json) {
    final templateJson = _extractObject(json, [
      'template',
      'task_template',
      'taskTemplate',
      'data',
      'result',
    ]);
    return ParentTaskTemplateCreateResult(
      template: ParentTaskTemplateModel.fromJson(templateJson ?? json),
      todayInstances: ParentTasksResponseModel._listFromJson(
        json['today_instances'] ?? json['todayInstances'],
        ParentTaskInstanceModel.fromJson,
      ),
    );
  }
}

class ParentTaskTemplateModel {
  final String id;
  final String? title;
  final String? category;
  final int? rewardCoins;
  final String? status;

  const ParentTaskTemplateModel({
    required this.id,
    this.title,
    this.category,
    this.rewardCoins,
    this.status,
  });

  factory ParentTaskTemplateModel.fromJson(Map<String, dynamic> json) {
    return ParentTaskTemplateModel(
      id: _stringValue(json, ['id', 'template_id', 'task_template_id']),
      title: _nullableStringValue(json, [
        'title',
        'name',
        'task_title',
        'description',
      ]),
      category: _nullableStringValue(json, ['category', 'type']),
      rewardCoins: _intValue(json, [
        'reward_coins',
        'rewardCoins',
        'coins_reward',
        'coins',
        'points',
      ]),
      status: _nullableStringValue(json, ['status']),
    );
  }

  String get displayTitle =>
      title?.trim().isNotEmpty == true ? title!.trim() : id;
}

class ParentTaskInstanceModel {
  final String id;
  final String status;
  final String? title;
  final String? category;
  final int? rewardCoins;
  final int? xpReward;
  final String? childId;
  final String? taskType;
  final String? proofMode;
  final String? verificationMode;
  final String? description;
  final int? targetValue;
  final String? targetUnit;
  final String? dueOn;
  final Map<String, dynamic>? metadata;

  /// `none` | `daily` | `weekly`. A task with a rule is a template the server
  /// materialises one instance from per matching day.
  final String recurrence;

  /// Weekday bitmask for `weekly`: Mon=1, Tue=2, Wed=4 … Sun=64.
  final int? recurrenceDays;

  /// The note the child wrote when submitting the task for review.
  final String? submissionNote;

  /// The note the parent left when approving/rejecting the task.
  final String? reviewNote;

  const ParentTaskInstanceModel({
    required this.id,
    required this.status,
    this.title,
    this.category,
    this.rewardCoins,
    this.xpReward,
    this.childId,
    this.taskType,
    this.proofMode,
    this.verificationMode,
    this.description,
    this.targetValue,
    this.targetUnit,
    this.dueOn,
    this.metadata,
    this.recurrence = 'none',
    this.recurrenceDays,
    this.submissionNote,
    this.reviewNote,
  });

  factory ParentTaskInstanceModel.fromJson(Map<String, dynamic> json) {
    final rawMetadata = json['metadata'];
    return ParentTaskInstanceModel(
      id: _stringValue(json, ['id', 'instance_id', 'task_instance_id']),
      status: _stringValue(json, ['status']),
      title: _nullableStringValue(json, [
        'title',
        'name',
        'task_title',
        'template_title',
        'description',
      ]),
      category: _nullableStringValue(json, ['category', 'type']),
      rewardCoins: _intValue(json, [
        'coin_reward',
        'reward_coins',
        'rewardCoins',
        'coins_reward',
        'coins',
        'points',
      ]),
      xpReward: _intValue(json, ['xp_reward', 'xpReward']),
      childId: _nullableStringValue(json, ['child_id', 'childId']),
      taskType: _nullableStringValue(json, ['task_type', 'taskType']),
      proofMode: _nullableStringValue(json, ['proof_mode', 'proofMode']),
      verificationMode: _nullableStringValue(json, [
        'verification_mode',
        'verificationMode',
      ]),
      description: _nullableStringValue(json, ['description']),
      targetValue: _intValue(json, ['target_value', 'targetValue']),
      targetUnit: _nullableStringValue(json, ['target_unit', 'targetUnit']),
      dueOn: _nullableStringValue(json, ['due_on', 'dueOn']),
      recurrence:
          _nullableStringValue(json, ['recurrence', 'recurrence_rule']) ??
          'none',
      recurrenceDays: _intValue(json, ['recurrence_days', 'recurrenceDays']),
      metadata: rawMetadata is Map
          ? rawMetadata.map((key, value) => MapEntry(key.toString(), value))
          : null,
      submissionNote: _nullableStringValue(json, [
        'submission_note',
        'submissionNote',
        'note',
      ]),
      reviewNote: _nullableStringValue(json, [
        'review_note',
        'reviewNote',
        'parent_note',
      ]),
    );
  }

  String get displayTitle =>
      title?.trim().isNotEmpty == true ? title!.trim() : id;

  /// Emoji the parent picked when creating the task (stored in metadata).
  String? get emoji {
    final value = metadata?['emoji'];
    if (value is String && value.trim().isNotEmpty) return value.trim();
    return null;
  }

  bool get isPendingApproval {
    final normalized = status.toLowerCase();
    return normalized == 'pending' ||
        normalized == 'pending_approval' ||
        normalized == 'awaiting_approval' ||
        normalized == 'submitted';
  }

  bool get isCompleted {
    final normalized = status.toLowerCase();
    return normalized == 'completed' ||
        normalized == 'done' ||
        normalized == 'approved';
  }

  /// Whether the parent may still edit/delete this task. Approved/completed
  /// tasks are locked (the backend rejects edits with 409).
  bool get isEditable => !isCompleted;

  /// Build a [TaskModel] for prefilling the edit sheet and diffing the PATCH.
  TaskModel toTaskModel() {
    return TaskModel(
      id: id,
      childId: childId,
      taskType: taskType,
      title: displayTitle,
      description: description,
      category: category,
      proofMode: proofMode,
      verificationMode: verificationMode,
      coinReward: rewardCoins ?? 0,
      xpReward: xpReward ?? (rewardCoins ?? 0),
      targetValue: targetValue,
      targetUnit: targetUnit,
      metadata: metadata,
      dueOn: dueOn,
      recurrence: recurrence,
      recurrenceDays: recurrenceDays,
      status: status,
    );
  }
}

String _stringValue(Map<String, dynamic> json, List<String> keys) {
  return _nullableStringValue(json, keys) ?? '';
}

String? _nullableStringValue(Map<String, dynamic> json, List<String> keys) {
  for (final key in keys) {
    final value = json[key];
    if (value == null) continue;
    final text = value.toString().trim();
    if (text.isNotEmpty) return text;
  }
  return null;
}

int? _intValue(Map<String, dynamic> json, List<String> keys) {
  for (final key in keys) {
    final value = json[key];
    if (value is int) return value;
    if (value is num) return value.toInt();
    final parsed = int.tryParse(value?.toString() ?? '');
    if (parsed != null) return parsed;
  }
  return null;
}

Map<String, dynamic>? _extractObject(
  Map<String, dynamic> json,
  List<String> keys,
) {
  for (final key in keys) {
    final value = json[key];
    if (value is Map<String, dynamic>) return value;
    if (value is Map) {
      return value.map((key, value) => MapEntry(key.toString(), value));
    }
  }
  return null;
}
