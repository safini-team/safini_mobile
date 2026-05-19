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
