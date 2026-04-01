class TaskTemplateModel {
  final String id;
  final String familyId;
  final String title;
  final String description;
  final String category;
  final int coinsReward;
  final int xpReward;
  final bool isStarter;
  final DateTime createdAt;

  const TaskTemplateModel({
    required this.id,
    required this.familyId,
    required this.title,
    required this.description,
    required this.category,
    required this.coinsReward,
    required this.xpReward,
    required this.isStarter,
    required this.createdAt,
  });

  factory TaskTemplateModel.fromJson(Map<String, dynamic> json) {
    return TaskTemplateModel(
      id: json['id'] as String,
      familyId: json['familyId'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      category: json['category'] as String,
      coinsReward: json['coinsReward'] as int,
      xpReward: json['xpReward'] as int,
      isStarter: json['isStarter'] as bool,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'familyId': familyId,
      'title': title,
      'description': description,
      'category': category,
      'coinsReward': coinsReward,
      'xpReward': xpReward,
      'isStarter': isStarter,
      'createdAt': createdAt.toIso8601String(),
    };
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

  factory TaskInstanceModel.fromJson(Map<String, dynamic> json) {
    return TaskInstanceModel(
      id: json['id'] as String,
      childId: json['childId'] as String,
      templateId: json['templateId'] as String,
      status: json['status'] as String,
      dueDate: DateTime.parse(json['dueDate'] as String),
      completedAt: json['completedAt'] != null
          ? DateTime.parse(json['completedAt'] as String)
          : null,
      proofUrl: json['proofUrl'] as String?,
      parentNote: json['parentNote'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'childId': childId,
      'templateId': templateId,
      'status': status,
      'dueDate': dueDate.toIso8601String(),
      'completedAt': completedAt?.toIso8601String(),
      'proofUrl': proofUrl,
      'parentNote': parentNote,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }
}
