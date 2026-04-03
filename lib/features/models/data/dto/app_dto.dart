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
  final int usageMinutes;

  AppUsageReportDto({
    required this.packageName,
    required this.appName,
    required this.usageMinutes,
  });

  factory AppUsageReportDto.fromJson(Map<String, dynamic> json) => _$AppUsageReportDtoFromJson(json);
  Map<String, dynamic> toJson() => _$AppUsageReportDtoToJson(this);

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
  final String ruleId;
  final int minutes;

  RedemptionRequestDto({
    required this.ruleId,
    required this.minutes,
  });

  factory RedemptionRequestDto.fromJson(Map<String, dynamic> json) => _$RedemptionRequestDtoFromJson(json);
  Map<String, dynamic> toJson() => _$RedemptionRequestDtoToJson(this);
}
