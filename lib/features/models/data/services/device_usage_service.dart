import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';

import 'package:safini/core/network/dio_error_mapper.dart';
import 'package:safini/core/utils/constants/api_const.dart';
import 'package:safini/core/utils/error/failures.dart';
import 'package:safini/features/models/domain/models/device_usage.dart';

/// Reads where a child's time went today. Parent and child both call it: the
/// API lets either read their own child.
class DeviceUsageService {
  DeviceUsageService(this._dio);

  final Dio _dio;

  Future<Either<Failure, DeviceUsage>> fetch(String childId) =>
      _fetch(childId, null);

  /// The seven days before [today], the family-local `usage_date` of a
  /// [fetch]. One request per day, all at once; any failure fails the week.
  Future<Either<Failure, WeekUsage>> fetchWeek(
    String childId,
    String today,
  ) async {
    // In UTC: a local day across a clock change is 23 or 25 hours long.
    final parsed = DateTime.parse(today);
    final day = DateTime.utc(parsed.year, parsed.month, parsed.day);
    final results = await Future.wait([
      for (var back = 7; back >= 1; back--)
        _fetch(childId, _date(day.subtract(Duration(days: back)))),
    ]);
    final days = <DeviceUsage>[];
    for (final result in results) {
      final failure = result.fold<Failure?>((f) => f, (usage) {
        days.add(usage);
        return null;
      });
      if (failure != null) return Left(failure);
    }
    return Right(WeekUsage.fromDays(days));
  }

  static String _date(DateTime day) =>
      '${day.year.toString().padLeft(4, '0')}-'
      '${day.month.toString().padLeft(2, '0')}-'
      '${day.day.toString().padLeft(2, '0')}';

  Future<Either<Failure, DeviceUsage>> _fetch(
    String childId,
    String? usageDate,
  ) async {
    try {
      final response = await _dio.get<Map<String, dynamic>>(
        ApiConst.childDeviceUsage(childId),
        queryParameters: {'usage_date': ?usageDate},
      );
      final data = response.data;
      if (data == null && usageDate == null) {
        return const Right(DeviceUsage.empty);
      }
      // A past day is read back under the date it was asked for.
      return Right(
        DeviceUsage.fromJson({
          ...?data,
          'usage_date': ?data?['usage_date'] ?? usageDate,
        }),
      );
    } on DioException catch (e) {
      return Left(mapDioError(e, 'Unable to load screen time.'));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
