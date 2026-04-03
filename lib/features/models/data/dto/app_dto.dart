import 'package:json_annotation/json_annotation.dart';
import '../../domain/models/app_model.dart';

part 'app_dto.g.dart';

@JsonSerializable()
class AppRuleDto {
  final String id;
  @JsonKey(name: 'child_id')
  final String childId;
  @JsonKey(name: 'package_name')
  final String packageName;
  @JsonKey(name: 'app_name')
  final String appName;
  @JsonKey(name: 'daily_limit_minutes')
  final int dailyLimitMinutes;
  @JsonKey(name: 'is_blocked')
  final bool isBlocked;
  @JsonKey(name: 'created_at')
  final DateTime createdAt;
  @JsonKey(name: 'updated_at')

import '../../domain/models/app_model.dart';

class AppRuleDto {
  final String id;
  final String childId;
  final String packageName;
  final String appName;
  final int dailyLimitMinutes;
  final bool isBlocked;
  final DateTime createdAt;

  final DateTime updatedAt;

  AppRuleDto({
    required this.id,
    required this.childId,
    required this.packageName,
    required this.appName,
    required this.dailyLimitMinutes,
    required this.isBlocked,
    required this.createdAt,
    required this.updatedAt,
  });


  factory AppRuleDto.fromJson(Map<String, dynamic> json) => _$AppRuleDtoFromJson(json);
  Map<String, dynamic> toJson() => _$AppRuleDtoToJson(this);

  factory AppRuleDto.fromJson(Map<String, dynamic> json) {
    return AppRuleDto(
      id: json['id'] as String? ?? '',
      childId: json['child_id'] as String? ?? '',
      packageName: json['package_name'] as String? ?? '',
      appName: json['app_name'] as String? ?? '',
      dailyLimitMinutes: json['daily_limit_minutes'] as int? ?? 0,
      isBlocked: json['is_blocked'] as bool? ?? false,
      createdAt: json['created_at'] != null ? DateTime.parse(json['created_at'] as String) : DateTime.now(),
      updatedAt: json['updated_at'] != null ? DateTime.parse(json['updated_at'] as String) : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'child_id': childId,
      'package_name': packageName,
      'app_name': appName,
      'daily_limit_minutes': dailyLimitMinutes,
      'is_blocked': isBlocked,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }


  AppRuleModel toDomain() {
    return AppRuleModel(
      id: id,
      childId: childId,
      packageName: packageName,
      appName: appName,
      dailyLimitMinutes: dailyLimitMinutes,
      isBlocked: isBlocked,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }
}


@JsonSerializable()
class AppUsageReportDto {
  @JsonKey(name: 'package_name')
  final String packageName;
  @JsonKey(name: 'app_name')
  final String appName;
  @JsonKey(name: 'usage_minutes')

class AppUsageReportDto {
  final String packageName;
  final String appName;

  final int usageMinutes;

  AppUsageReportDto({
    required this.packageName,
    required this.appName,
    required this.usageMinutes,
  });


  factory AppUsageReportDto.fromJson(Map<String, dynamic> json) => _$AppUsageReportDtoFromJson(json);
  Map<String, dynamic> toJson() => _$AppUsageReportDtoToJson(this);

  factory AppUsageReportDto.fromJson(Map<String, dynamic> json) {
    return AppUsageReportDto(
      packageName: json['package_name'] as String? ?? '',
      appName: json['app_name'] as String? ?? '',
      usageMinutes: json['usage_minutes'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'package_name': packageName,
      'app_name': appName,
      'usage_minutes': usageMinutes,
    };
  }


  AppUsageReportModel toDomain() {
    return AppUsageReportModel(
      packageName: packageName,
      appName: appName,
      usageMinutes: usageMinutes,
    );
  }
}


@JsonSerializable()
class RedemptionRequestDto {
  @JsonKey(name: 'rule_id')

class RedemptionRequestDto {

  final String ruleId;
  final int minutes;

  RedemptionRequestDto({
    required this.ruleId,
    required this.minutes,
  });


  factory RedemptionRequestDto.fromJson(Map<String, dynamic> json) => _$RedemptionRequestDtoFromJson(json);
  Map<String, dynamic> toJson() => _$RedemptionRequestDtoToJson(this);

  factory RedemptionRequestDto.fromJson(Map<String, dynamic> json) {
    return RedemptionRequestDto(
      ruleId: json['rule_id'] as String? ?? '',
      minutes: json['minutes'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'rule_id': ruleId,
      'minutes': minutes,
    };
  }
}
