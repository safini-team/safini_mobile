import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:safini/core/error/exceptions.dart';
import 'package:safini/core/utils/constants/api_const.dart';
import 'package:safini/features/child/data/dto/child_dto.dart';
import 'package:safini/features/child/domain/models/child_home_response.dart';
import 'package:safini/features/child/domain/models/child_model.dart';
import 'package:safini/features/child/domain/models/child_today_response.dart';

class ChildRemoteDataSource {
  final Dio _dio;

  ChildRemoteDataSource(this._dio);

  /// Fetches the current family and returns the list of children.
  Future<List<ChildModel>> fetchChildren() async {
    debugPrint(
      '[ChildRemoteDataSource] GET ${ApiConst.baseUrl}${ApiConst.currentFamily}',
    );
    try {
      final response = await _dio.get(ApiConst.currentFamily);
      debugPrint(
        '[ChildRemoteDataSource] Response ${response.statusCode}: ${response.data}',
      );

      final data = response.data as Map<String, dynamic>;
      final rawChildren = data['children'] as List<dynamic>? ?? [];

      final children = rawChildren
          .map((e) => ChildDto.fromJson(e as Map<String, dynamic>).toDomain())
          .toList();

      debugPrint('[ChildRemoteDataSource] Parsed ${children.length} children');
      return children;
    } on DioException catch (e) {
      debugPrint(
        '[ChildRemoteDataSource] DioException ${e.response?.statusCode}: ${e.message}',
      );
      throw ServerException(e.message ?? 'Server error');
    } catch (e) {
      debugPrint('[ChildRemoteDataSource] Unexpected error: $e');
      throw ServerException(e.toString());
    }
  }

  /// Fetches a specific child by ID.
  Future<ChildModel> fetchChild(String childId) async {
    final path = ApiConst.childById(childId);
    debugPrint('[ChildRemoteDataSource] GET ${ApiConst.baseUrl}$path');
    try {
      final response = await _dio.get(path);
      debugPrint(
        '[ChildRemoteDataSource] Response ${response.statusCode}: ${response.data}',
      );

      final data = response.data as Map<String, dynamic>;
      return ChildDto.fromJson(data).toDomain();
    } on DioException catch (e) {
      debugPrint(
        '[ChildRemoteDataSource] DioException ${e.response?.statusCode}: ${e.message}',
      );
      throw ServerException(e.message ?? 'Server error');
    } catch (e) {
      debugPrint('[ChildRemoteDataSource] Unexpected error: $e');
      throw ServerException(e.toString());
    }
  }

  /// Fetches the child home summary (nickname + done_today count).
  Future<ChildHomeResponse> fetchChildHome(String childId) async {
    final path = ApiConst.childHome(childId);
    debugPrint('[ChildRemoteDataSource] GET ${ApiConst.baseUrl}$path');
    try {
      final response = await _dio.get(path);
      debugPrint(
        '[ChildRemoteDataSource] Response ${response.statusCode}: ${response.data}',
      );
      final data = response.data as Map<String, dynamic>;
      return ChildHomeResponse.fromJson(data);
    } on DioException catch (e) {
      debugPrint(
        '[ChildRemoteDataSource] DioException ${e.response?.statusCode}: ${e.message}',
      );
      final code = e.response?.statusCode;
      if (code == 403) throw const ServerException('Access denied.');
      if (code == 404) throw const ServerException('Child not found.');
      if (code == 422) throw const ServerException('Invalid request.');
      if (code == 503) {
        throw const ServerException(
          'Service unavailable. Please try again later.',
        );
      }
      throw ServerException(e.message ?? 'Server error');
    } catch (e) {
      debugPrint('[ChildRemoteDataSource] Unexpected error: $e');
      throw ServerException(e.toString());
    }
  }

  /// Fetches today's task list for the child along with remaining_today count.
  Future<ChildTodayResponse> fetchChildToday(
    String childId, {
    String? date,
  }) async {
    final path = ApiConst.childToday(childId);
    final queryParams = date != null ? {'date': date} : null;
    debugPrint('[ChildRemoteDataSource] GET ${ApiConst.baseUrl}$path');
    try {
      final response = await _dio.get(
        path,
        queryParameters: queryParams,
      );
      debugPrint(
        '[ChildRemoteDataSource] Response ${response.statusCode}: ${response.data}',
      );
      final data = response.data as Map<String, dynamic>;
      return ChildTodayResponse.fromJson(data);
    } on DioException catch (e) {
      debugPrint(
        '[ChildRemoteDataSource] DioException ${e.response?.statusCode}: ${e.message}',
      );
      final code = e.response?.statusCode;
      if (code == 403) throw const ServerException('Access denied.');
      if (code == 404) throw const ServerException('Child not found.');
      if (code == 422) throw const ServerException('Invalid request.');
      if (code == 503) {
        throw const ServerException(
          'Service unavailable. Please try again later.',
        );
      }
      throw ServerException(e.message ?? 'Server error');
    } catch (e) {
      debugPrint('[ChildRemoteDataSource] Unexpected error: $e');
      throw ServerException(e.toString());
    }
  }

  /// Fetches child dashboard summary and returns child identity/progression data.
  Future<ChildModel> fetchChildDashboard(String childId) async {
    final path = ApiConst.childDashboard(childId);
    debugPrint('[ChildRemoteDataSource] GET ${ApiConst.baseUrl}$path');
    try {
      final response = await _dio.get(path);
      debugPrint(
        '[ChildRemoteDataSource] Response ${response.statusCode}: ${response.data}',
      );

      final data = response.data as Map<String, dynamic>;
      final childJson = data['child'];
      if (childJson is! Map<String, dynamic>) {
        throw const ServerException(
          'Invalid dashboard payload: missing child object',
        );
      }
      return ChildDto.fromJson(childJson).toDomain();
    } on DioException catch (e) {
      debugPrint(
        '[ChildRemoteDataSource] DioException ${e.response?.statusCode}: ${e.message}',
      );
      throw ServerException(e.message ?? 'Server error');
    } catch (e) {
      debugPrint('[ChildRemoteDataSource] Unexpected error: $e');
      throw ServerException(e.toString());
    }
  }
}
