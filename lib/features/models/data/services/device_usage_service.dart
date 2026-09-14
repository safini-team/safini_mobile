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

  Future<Either<Failure, DeviceUsage>> fetch(String childId) async {
    try {
      final response = await _dio.get<Map<String, dynamic>>(
        ApiConst.childDeviceUsage(childId),
      );
      final data = response.data;
      if (data == null) return const Right(DeviceUsage.empty);
      return Right(DeviceUsage.fromJson(data));
    } on DioException catch (e) {
      return Left(mapDioError(e, 'Unable to load screen time.'));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
