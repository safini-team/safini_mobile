import 'package:dio/dio.dart';

class AccountDeletionException implements Exception {
  const AccountDeletionException({required this.isRetryable});

  final bool isRetryable;
}

class AccountDeletionService {
  const AccountDeletionService(this._dio);

  final Dio _dio;

  Future<void> deleteAccount() async {
    try {
      await _dio.delete<void>('/v1/me');
    } on DioException catch (error) {
      final statusCode = error.response?.statusCode;
      throw AccountDeletionException(
        isRetryable: statusCode == null || statusCode >= 500,
      );
    }
  }
}
