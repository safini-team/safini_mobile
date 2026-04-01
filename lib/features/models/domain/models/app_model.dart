import 'package:freezed_annotation/freezed_annotation.dart';

part 'app_model.freezed.dart';

@freezed
class AppRuleModel with _$AppRuleModel {
  const factory AppRuleModel({
    required String id,
    required String childId,
    required String packageName,
    required String appName,
    required int dailyLimitMinutes,
    required bool isBlocked,
    required DateTime createdAt,
    required DateTime updatedAt,
  }) = _AppRuleModel;
}

@freezed
class AppUsageReportModel with _$AppUsageReportModel {
  const factory AppUsageReportModel({
    required String packageName,
    required String appName,
    required int usageMinutes,
  }) = _AppUsageReportModel;
}
