class AppRuleModel {
  final String id;
  final String childId;
  final String packageName;
  final String appName;
  final int dailyLimitMinutes;
  final bool isBlocked;
  final DateTime createdAt;
  final DateTime updatedAt;

  const AppRuleModel({
    required this.id,
    required this.childId,
    required this.packageName,
    required this.appName,
    required this.dailyLimitMinutes,
    required this.isBlocked,
    required this.createdAt,
    required this.updatedAt,
  });

  factory AppRuleModel.fromJson(Map<String, dynamic> json) {
    return AppRuleModel(
      id: json['id'] as String,
      childId: json['childId'] as String,
      packageName: json['packageName'] as String,
      appName: json['appName'] as String,
      dailyLimitMinutes: json['dailyLimitMinutes'] as int,
      isBlocked: json['isBlocked'] as bool,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'childId': childId,
      'packageName': packageName,
      'appName': appName,
      'dailyLimitMinutes': dailyLimitMinutes,
      'isBlocked': isBlocked,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }
}

class AppUsageReportModel {
  final String packageName;
  final String appName;
  final int usageMinutes;

  const AppUsageReportModel({
    required this.packageName,
    required this.appName,
    required this.usageMinutes,
  });

  factory AppUsageReportModel.fromJson(Map<String, dynamic> json) {
    return AppUsageReportModel(
      packageName: json['packageName'] as String,
      appName: json['appName'] as String,
      usageMinutes: json['usageMinutes'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'packageName': packageName,
      'appName': appName,
      'usageMinutes': usageMinutes,
    };
  }
}
