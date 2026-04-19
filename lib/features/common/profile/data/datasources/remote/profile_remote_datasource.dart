import 'package:dio/dio.dart';
import 'package:safini/core/error/exceptions.dart';
import 'package:safini/core/utils/constants/api_const.dart';
import 'package:safini/features/common/profile/domain/models/profile_model.dart';

class ProfileRemoteDataSource {
  final Dio _dio;

  ProfileRemoteDataSource(this._dio);

  Future<ProfileModel> fetchMe() async {
    try {
      final response = await _dio.get(ApiConst.me);
      return ProfileModel.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw ServerException(e.message ?? 'Server error');
    } catch (e) {
      throw ServerException(e.toString());
    }
  }
}