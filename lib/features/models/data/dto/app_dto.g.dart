// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AppRuleDto _$AppRuleDtoFromJson(Map<String, dynamic> json) => AppRuleDto(
  id: json['id'] as String,
  childId: json['child_id'] as String,
  packageName: json['package_name'] as String,
  appName: json['app_name'] as String,
  dailyLimitMinutes: (json['daily_limit_minutes'] as num).toInt(),
  isBlocked: json['is_blocked'] as bool,
  createdAt: DateTime.parse(json['created_at'] as String),
  updatedAt: DateTime.parse(json['updated_at'] as String),
);

Map<String, dynamic> _$AppRuleDtoToJson(AppRuleDto instance) =>
    <String, dynamic>{
      'id': instance.id,
      'child_id': instance.childId,
      'package_name': instance.packageName,
      'app_name': instance.appName,
      'daily_limit_minutes': instance.dailyLimitMinutes,
      'is_blocked': instance.isBlocked,
      'created_at': instance.createdAt.toIso8601String(),
      'updated_at': instance.updatedAt.toIso8601String(),
    };

AppUsageReportDto _$AppUsageReportDtoFromJson(Map<String, dynamic> json) =>
    AppUsageReportDto(
      packageName: json['package_name'] as String,
      appName: json['app_name'] as String,
      usageMinutes: (json['usage_minutes'] as num).toInt(),
    );

Map<String, dynamic> _$AppUsageReportDtoToJson(AppUsageReportDto instance) =>
    <String, dynamic>{
      'package_name': instance.packageName,
      'app_name': instance.appName,
      'usage_minutes': instance.usageMinutes,
    };

RedemptionRequestDto _$RedemptionRequestDtoFromJson(
  Map<String, dynamic> json,
) => RedemptionRequestDto(
  ruleId: json['rule_id'] as String,
  minutes: (json['minutes'] as num).toInt(),
);

Map<String, dynamic> _$RedemptionRequestDtoToJson(
  RedemptionRequestDto instance,
) => <String, dynamic>{'rule_id': instance.ruleId, 'minutes': instance.minutes};
