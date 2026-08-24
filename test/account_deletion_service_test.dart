import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:safini/features/common/auth/data/account_deletion_service.dart';

void main() {
  test(
    'deleteAccount sends an authenticated DELETE request to /v1/me',
    () async {
      late RequestOptions captured;
      final dio = Dio(BaseOptions(baseUrl: 'https://api.safini.fun'));
      dio.interceptors.add(
        InterceptorsWrapper(
          onRequest: (options, handler) {
            captured = options;
            handler.resolve(
              Response<void>(requestOptions: options, statusCode: 204),
            );
          },
        ),
      );

      await AccountDeletionService(dio).deleteAccount();

      expect(captured.method, 'DELETE');
      expect(captured.path, '/v1/me');
    },
  );

  test('deleteAccount returns a safe retryable failure', () async {
    final dio = Dio(BaseOptions(baseUrl: 'https://api.safini.fun'));
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          handler.reject(
            DioException(
              requestOptions: options,
              response: Response<void>(
                requestOptions: options,
                statusCode: 503,
              ),
              type: DioExceptionType.badResponse,
            ),
          );
        },
      ),
    );

    await expectLater(
      AccountDeletionService(dio).deleteAccount,
      throwsA(
        isA<AccountDeletionException>().having(
          (error) => error.isRetryable,
          'isRetryable',
          isTrue,
        ),
      ),
    );
  });
}
