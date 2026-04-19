import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:safini/core/error/exceptions.dart';
import 'package:safini/core/utils/constants/api_const.dart';
import 'package:safini/features/common/profile/domain/models/profile_model.dart';

class ProfileRemoteDataSource {
  final Dio _dio;

  ProfileRemoteDataSource(this._dio);

  Future<ProfileModel> fetchMe() async {
    debugPrint('[ProfileRemoteDataSource] GET ${ApiConst.baseUrl}${ApiConst.me}');
    try {
      final response = await _dio.get(ApiConst.me);
      debugPrint('[ProfileRemoteDataSource] Response ${response.statusCode}: ${response.data}');
      final model = ProfileModel.fromJson(response.data as Map<String, dynamic>);
      debugPrint('[ProfileRemoteDataSource] Parsed accountType: ${model.accountType}');
      return model;
    } on DioException catch (e) {
      debugPrint('[ProfileRemoteDataSource] DioException ${e.response?.statusCode}: ${e.message}');
      throw ServerException(e.message ?? 'Server error');
    } catch (e) {
      debugPrint('[ProfileRemoteDataSource] Unexpected error: $e');
      throw ServerException(e.toString());
    }
  }
}