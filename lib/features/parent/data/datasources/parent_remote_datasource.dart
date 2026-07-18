import 'package:dio/dio.dart';
import 'package:safini/core/utils/constants/api_const.dart';
import 'package:safini/features/parent/domain/models/parent_user_model.dart';

class ParentRemoteDataSource {
  final Dio _dio;

  ParentRemoteDataSource(this._dio);

  /// Reads the signed-in parent's profile from the backend (`/v1/me`) — the
  /// same source the edit screen writes to. Reading it directly from Supabase
  /// `public.profiles` returned a stale row, because the backend stores
  /// profiles in its own `safini_api` schema, so edits never showed up.
  Future<ParentUserModel> getUser(String userId) async {
    try {
      final response = await _dio.get(ApiConst.me);
      return ParentUserModel.fromJson(response.data as Map<String, dynamic>);
    } catch (e) {
      rethrow;
    }
  }
}
