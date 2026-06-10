class ParentTasksResponseModel {
  final List<ParentTaskTemplateModel> templates;
  final List<ParentTaskInstanceModel> todayInstances;

  const ParentTasksResponseModel({
    required this.templates,
    required this.todayInstances,
  });

  factory ParentTasksResponseModel.fromJson(Map<String, dynamic> json) {
    return ParentTasksResponseModel(
      templates: _listFromJson(
        json['templates'],
        ParentTaskTemplateModel.fromJson,
      ),
      todayInstances: _listFromJson(
        json['today_instances'] ?? json['todayInstances'],
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

  const ParentTaskInstanceModel({
    required this.id,
    required this.status,
    this.title,
    this.category,
    this.rewardCoins,
  });

  factory ParentTaskInstanceModel.fromJson(Map<String, dynamic> json) {
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
        'reward_coins',
        'rewardCoins',
        'coins_reward',
        'coins',
        'points',
      ]),
    );
  }

  String get displayTitle =>
      title?.trim().isNotEmpty == true ? title!.trim() : id;

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
