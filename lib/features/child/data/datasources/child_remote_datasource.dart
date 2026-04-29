import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:safini/core/error/exceptions.dart';
import 'package:safini/core/utils/constants/api_const.dart';
import 'package:safini/features/child/data/dto/child_dto.dart';
import 'package:safini/features/child/domain/models/child_model.dart';

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

      debugPrint(
        '[ChildRemoteDataSource] Parsed ${children.length} children',
      );
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
}
