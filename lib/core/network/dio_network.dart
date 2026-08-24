import 'dart:developer';

import 'package:dio/dio.dart';
import 'package:safini/core/di/injection.dart';
import 'package:safini/core/network/auth_token_provider.dart';
import 'package:safini/core/utils/constants/api_const.dart';

class DioNetwork {
  static const _authRetriedKey = 'safini.authRetried';

  static late Dio appAPI;

  static void initDio() {
    appAPI = Dio(_baseOptions(ApiConst.baseUrl));
    appAPI.interceptors.add(_authInterceptor());
  }

  static AuthTokenProvider get _tokens => getIt<AuthTokenProvider>();

  static InterceptorsWrapper _authInterceptor() {
    // Refresh serialization lives in AuthTokenProvider, so this interceptor
    // does not need Dio's error queue. Keeping error callbacks unqueued also
    // lets the one-time retry complete normally when that retry itself fails.
    return InterceptorsWrapper(
      onRequest: (options, handler) async {
        try {
          final token = await _tokens.getAccessToken();
          if (token != null && token.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $token';
          } else {
            options.headers.remove('Authorization');
          }
        } catch (error) {
          // Do not clear the session on a transient refresh failure. The
          // request can fail and be retried after connectivity returns.
          log('Token refresh before request failed: $error', name: 'Auth');
          options.headers.remove('Authorization');
        }
        handler.next(options);
      },
      onError: (error, handler) async {
        final request = error.requestOptions;
        final alreadyRetried = request.extra[_authRetriedKey] == true;
        if (error.response?.statusCode != 401 || alreadyRetried) {
          handler.next(error);
          return;
        }

        final rejectedToken = _bearerToken(request.headers['Authorization']);
        try {
          final refreshed = await _tokens.refreshAfterUnauthorized(
            rejectedToken,
          );
          if (refreshed == null || refreshed.isEmpty) {
            handler.next(error);
            return;
          }

          request.extra[_authRetriedKey] = true;
          request.headers['Authorization'] = 'Bearer $refreshed';
          final response = await appAPI.fetch<dynamic>(request);
          handler.resolve(response);
        } catch (refreshError) {
          // A failed refresh is not a user sign-out. Preserve the session and
          // let the feature display its normal retry/error state.
          log('Token refresh after 401 failed: $refreshError', name: 'Auth');
          handler.next(error);
        }
      },
    );
  }

  static String? _bearerToken(Object? header) {
    final value = header?.toString();
    if (value == null || !value.startsWith('Bearer ')) return null;
    final token = value.substring('Bearer '.length).trim();
    return token.isEmpty ? null : token;
  }

  static BaseOptions _baseOptions(String url) {
    return BaseOptions(
      baseUrl: url,
      validateStatus: (status) => status != null && status < 300,
      responseType: ResponseType.json,
    );
  }
}
