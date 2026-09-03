import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import 'package:safini/core/network/dio_error_mapper.dart';
import 'package:safini/core/utils/constants/api_const.dart';
import 'package:safini/core/utils/error/failures.dart';
import 'package:safini/features/models/domain/models/installed_app.dart';
import 'package:safini/features/parent/domain/models/child_app_usage_model.dart';

/// Backend-facing service the **parent** uses to read and configure the
/// app-blocking rules for a child.
///
/// This is the parent side of the blocking feature: the parent picks apps, sets
/// daily limits, and blocks/unblocks. Nothing is enforced here — enforcement
/// happens on the child device (see `AppBlockService`). We only persist the
/// rule set the child device will later pull and enforce.
///
/// Talks to the Safini REST API through the shared authed [Dio] (bearer token +
/// refresh handled by the Dio interceptors):
///  - `GET /v1/children/{child_id}/app-usage`           → current rules + usage
///  - `PUT /v1/children/{child_id}/app-rules/{app_slug}` → upsert a rule
///
/// Blocking semantics: the backend has no `is_blocked` field, so a **manual
/// block** is expressed as `is_enabled = false` on the rule.
class ParentAppBlockingService {
  final Dio _dio;

  ParentAppBlockingService(this._dio);

  /// Loads every controlled-app rule + today's usage for [childId].
  Future<Either<Failure, List<ChildAppUsageModel>>> fetchAppRules(
    String childId,
  ) async {
    try {
      final response = await _dio.get<Map<String, dynamic>>(
        ApiConst.childAppUsage(childId),
      );
      final apps = response.data?['apps'];
      if (apps is! List) return const Right([]);
      final rules = apps
          .whereType<Map>()
          .map(
            (e) => ChildAppUsageModel.fromJson(
              e.map((k, v) => MapEntry(k.toString(), v)),
            ),
          )
          .toList();
      return Right(rules);
    } on DioException catch (e) {
      return Left(mapDioError(e, 'Unable to load app rules.'));
    } catch (e) {
      debugPrint('[ParentAppBlockingService] fetchAppRules error: $e');
      return Left(ServerFailure(e.toString()));
    }
  }

  /// Upserts the full [rule] (the backend requires all four fields).
  Future<Either<Failure, Unit>> upsertRule(
    String childId,
    ChildAppUsageModel rule,
  ) async {
    try {
      await _dio.put<dynamic>(
        ApiConst.childAppRule(childId, rule.appSlug),
        data: rule.toRuleJson(),
      );
      return const Right(unit);
    } on DioException catch (e) {
      return Left(mapDioError(e, 'Unable to update app rule.'));
    } catch (e) {
      debugPrint('[ParentAppBlockingService] upsertRule error: $e');
      return Left(ServerFailure(e.toString()));
    }
  }

  /// Manual block / unblock. Modelled as `is_enabled = !blocked`.
  Future<Either<Failure, Unit>> setBlocked(
    String childId,
    ChildAppUsageModel rule,
    bool blocked,
  ) => upsertRule(childId, rule.copyWith(isLimited: !blocked));

  /// Sets the base daily limit (minutes) for an app.
  Future<Either<Failure, Unit>> setDailyLimit(
    String childId,
    ChildAppUsageModel rule,
    int dailyLimitMinutes,
  ) => upsertRule(childId, rule.copyWith(dailyLimitMinutes: dailyLimitMinutes));

  /// Loads the apps installed on the child's device (uploaded by the child
  /// device — see `ChildAppRulesService.reportInstalledApps`), plus the
  /// `updated_at` of that upload (`null` → the phone has never synced).
  Future<Either<Failure, InstalledAppsSnapshot>> fetchInstalledApps(
    String childId,
  ) async {
    final path = ApiConst.childInstalledApps(childId);
    debugPrint('[ParentAppBlockingService] GET $path');
    try {
      final response = await _dio.get<Map<String, dynamic>>(path);
      final data = response.data;
      debugPrint(
        '[ParentAppBlockingService] GET $path -> ${response.statusCode} $data',
      );
      if (data == null) {
        return const Right(InstalledAppsSnapshot(apps: []));
      }
      return Right(InstalledAppsSnapshot.fromJson(data));
    } on DioException catch (e) {
      debugPrint(
        '[ParentAppBlockingService] GET $path -> DioException '
        '${e.response?.statusCode} ${e.response?.data ?? e.message}',
      );
      return Left(mapDioError(e, 'Unable to load the child\'s apps.'));
    } catch (e) {
      debugPrint('[ParentAppBlockingService] fetchInstalledApps error: $e');
      return Left(ServerFailure(e.toString()));
    }
  }
}
