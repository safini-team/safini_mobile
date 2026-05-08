import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:safini/core/error/exceptions.dart';
import 'package:safini/core/utils/constants/api_const.dart';
import 'package:safini/features/common/profile/domain/models/profile_model.dart';

class ProfileRemoteDataSource {
  final Dio _dio;

  ProfileRemoteDataSource(this._dio);

  Future<ProfileModel> fetchMe() async {
    debugPrint(
      '[ProfileRemoteDataSource] GET ${ApiConst.baseUrl}${ApiConst.me}',
    );
    try {
      final response = await _dio.get(ApiConst.me);
      debugPrint(
        '[ProfileRemoteDataSource] Response ${response.statusCode}: ${response.data}',
      );
      final model = ProfileModel.fromJson(
        response.data as Map<String, dynamic>,
      );
      debugPrint(
        '[ProfileRemoteDataSource] Parsed accountType: ${model.accountType}',
      );
      return model;
    } on DioException catch (e) {
      debugPrint(
        '[ProfileRemoteDataSource] DioException ${e.response?.statusCode}: ${e.message}',
      );
      throw ServerException(e.message ?? 'Server error');
    } catch (e) {
      debugPrint('[ProfileRemoteDataSource] Unexpected error: $e');
      throw ServerException(e.toString());
    }
  }

  Future<ProfileModel> updateMe({
    String? displayName,
    String? bio,
    String? timezone,
    String? avatarUrl,
  }) async {
    final payload = <String, dynamic>{};
    if (displayName != null) payload['display_name'] = displayName;
    if (bio != null) payload['bio'] = bio;
    if (timezone != null) payload['timezone'] = timezone;
    if (avatarUrl != null) payload['avatar_url'] = avatarUrl;

    debugPrint(
      '[ProfileRemoteDataSource] PATCH ${ApiConst.baseUrl}${ApiConst.me} payload=$payload',
    );

    try {
      final response = await _dio.patch(ApiConst.me, data: payload);
      debugPrint(
        '[ProfileRemoteDataSource] Response ${response.statusCode}: ${response.data}',
      );
      return ProfileModel.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      final status = e.response?.statusCode;
      debugPrint(
        '[ProfileRemoteDataSource] DioException $status: ${e.message}',
      );
      final message = switch (status) {
        401 => 'Session expired. Please sign in again.',
        409 => 'This update conflicts with current account state.',
        422 => 'Invalid profile input. Display name must be 1-120 chars.',
        503 => 'Service unavailable. Please try again later.',
        _ => e.message ?? 'Server error',
      };
      throw ServerException(message);
    } catch (e) {
      debugPrint('[ProfileRemoteDataSource] Unexpected error: $e');
      throw ServerException(e.toString());
    }
  }
}
