import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import 'package:safini/core/network/dio_error_mapper.dart';
import 'package:safini/core/utils/constants/api_const.dart';
import 'package:safini/core/utils/error/failures.dart';
import 'package:safini/features/models/domain/models/installed_app.dart';
import 'package:safini/features/models/domain/models/screen_time_status.dart';
import 'package:safini/features/parent/domain/models/child_app_usage_model.dart';

/// Backend-facing service the **child** device uses for the blocking feature.
///
/// Two responsibilities, both against the Safini REST API via the shared authed
/// [Dio]:
///  1. **Pull the rules to enforce** — `GET /v1/children/{child_id}/app-usage`
///     returns each controlled app with `is_enabled`, `daily_limit_minutes`,
///     `used_minutes`, and the backend-computed `remaining_minutes_today`. The
///     child feeds these into `AppBlockService` to program the native engine.
///  2. **Report measured usage** — `POST /v1/children/{child_id}/app-usage`
///     (one app per call: `app_slug` + `used_minutes`) so the backend keeps
///     `remaining_minutes_today` accurate across devices.
class ChildAppRulesService {
  final Dio _dio;

  ChildAppRulesService(this._dio);

  /// Loads the controlled-app rules + today's usage the device must enforce.
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
      debugPrint('[ChildAppRulesService] fetchAppRules error: $e');
      return Left(ServerFailure(e.toString()));
    }
  }

  /// Reports total [usedMinutes] for a single controlled app ([appSlug]) on
  /// [usageDate] (defaults to today server-side when omitted).
  Future<Either<Failure, Unit>> reportUsage(
    String childId, {
    required String appSlug,
    required int usedMinutes,
    String source = 'client',
    DateTime? usageDate,
  }) async {
    try {
      await _dio.post<dynamic>(
        ApiConst.childAppUsage(childId),
        data: {
          'app_slug': appSlug,
          'used_minutes': usedMinutes,
          'source': source,
          if (usageDate != null)
            'usage_date': usageDate.toIso8601String().split('T').first,
        },
      );
      return const Right(unit);
    } on DioException catch (e) {
      return Left(mapDioError(e, 'Unable to report app usage.'));
    } catch (e) {
      debugPrint('[ChildAppRulesService] reportUsage error: $e');
      return Left(ServerFailure(e.toString()));
    }
  }

  /// The backend caps a snapshot at 1000 apps (`InstalledAppsReplaceRequest`).
  static const int _maxInstalledApps = 1000;

  /// Uploads the full snapshot of apps installed on the child's device so the
  /// parent can see them. Replaces the previous snapshot (PUT).
  Future<Either<Failure, Unit>> reportInstalledApps(
    String childId,
    List<InstalledApp> apps,
  ) async {
    try {
      final payload = apps.length > _maxInstalledApps
          ? apps.sublist(0, _maxInstalledApps)
          : apps;
      await _dio.put<dynamic>(
        ApiConst.childInstalledApps(childId),
        data: {'apps': payload.map((a) => a.toJson()).toList()},
      );
      return const Right(unit);
    } on DioException catch (e) {
      return Left(mapDioError(e, 'Unable to sync installed apps.'));
    } catch (e) {
      debugPrint('[ChildAppRulesService] reportInstalledApps error: $e');
      return Left(ServerFailure(e.toString()));
    }
  }

  /// Reads back the snapshot the child device previously uploaded (the child may
  /// read its own row). Used by the dev screen to verify the round-trip.
  Future<Either<Failure, InstalledAppsSnapshot>> fetchInstalledApps(
    String childId,
  ) async {
    try {
      final response = await _dio.get<Map<String, dynamic>>(
        ApiConst.childInstalledApps(childId),
      );
      final data = response.data;
      if (data == null) {
        return const Right(InstalledAppsSnapshot(apps: []));
      }
      return Right(InstalledAppsSnapshot.fromJson(data));
    } on DioException catch (e) {
      return Left(mapDioError(e, 'Unable to load installed apps.'));
    } catch (e) {
      debugPrint('[ChildAppRulesService] fetchInstalledApps error: $e');
      return Left(ServerFailure(e.toString()));
    }
  }

  /// Pushes the iOS Screen Time status (auth + token counts + shield flag) so
  /// the parent can see it. The iOS analogue of [reportInstalledApps]. The
  /// endpoint is not deployed yet (SAF-154) — a 404 here is expected until it
  /// ships.
  Future<Either<Failure, Unit>> reportScreenTimeStatus(
    String childId,
    ScreenTimeStatus status,
  ) async {
    try {
      await _dio.put<dynamic>(
        ApiConst.childScreenTimeStatus(childId),
        data: status.toJson(),
      );
      return const Right(unit);
    } on DioException catch (e) {
      return Left(mapDioError(e, 'Unable to sync Screen Time status.'));
    } catch (e) {
      debugPrint('[ChildAppRulesService] reportScreenTimeStatus error: $e');
      return Left(ServerFailure(e.toString()));
    }
  }

  /// Reads the Screen Time status back (child may read its own row).
  Future<Either<Failure, ScreenTimeStatus>> fetchScreenTimeStatus(
    String childId,
  ) async {
    try {
      final response = await _dio.get<Map<String, dynamic>>(
        ApiConst.childScreenTimeStatus(childId),
      );
      final data = response.data;
      if (data == null) {
        return const Right(ScreenTimeStatus(authorization: 'unavailable'));
      }
      return Right(ScreenTimeStatus.fromJson(data));
    } on DioException catch (e) {
      return Left(mapDioError(e, 'Unable to load Screen Time status.'));
    } catch (e) {
      debugPrint('[ChildAppRulesService] fetchScreenTimeStatus error: $e');
      return Left(ServerFailure(e.toString()));
    }
  }

  /// Convenience: report several apps at once (slug → used minutes).
  /// Returns the first failure encountered, or `unit` when all succeed.
  Future<Either<Failure, Unit>> reportUsageBatch(
    String childId,
    Map<String, int> usedMinutesBySlug, {
    DateTime? usageDate,
  }) async {
    for (final entry in usedMinutesBySlug.entries) {
      final result = await reportUsage(
        childId,
        appSlug: entry.key,
        usedMinutes: entry.value,
        usageDate: usageDate,
      );
      if (result.isLeft()) return result;
    }
    return const Right(unit);
  }
}
