import 'dart:async';
import 'dart:convert';
import 'dart:developer';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:safini/core/app/app_router.dart';
import 'package:safini/core/di/injection.dart';
import 'package:safini/core/utils/constants/api_const.dart';
import 'package:safini/core/utils/constants/app_constants.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class DioNetwork {
  static late Dio appAPI;
  static late Dio retryAPI;

  static bool isRefreshing = false;
  static List<Function> tokenRequestQueue = [];

  static void initDio() {
    appAPI = Dio(_baseOptions(ApiConst.baseUrl));
    appAPI.interceptors.add(_appQueuedInterceptorsWrapper());

    retryAPI = Dio(_baseOptions(ApiConst.baseUrl));
    retryAPI.interceptors.add(_interceptorsWrapper());
  }

  static String? get _accessToken =>
      getIt<SharedPreferences>().getString(AppConstants.accessToken);

  static Future<void> _refreshToken() async {
    await Supabase.instance.client.auth.refreshSession();
    final newToken =
        Supabase.instance.client.auth.currentSession?.accessToken;
    if (newToken != null) {
      await getIt<SharedPreferences>().setString(
        AppConstants.accessToken,
        newToken,
      );
    }
  }

  static Future<void> _signOut() async {
    await getIt<SharedPreferences>().remove(AppConstants.accessToken);
    await Supabase.instance.client.auth.signOut();
  }

  // ── Queued interceptor (main appAPI) ──────────────────────────────────────

  static QueuedInterceptorsWrapper _appQueuedInterceptorsWrapper() {
    return QueuedInterceptorsWrapper(
      onRequest: (RequestOptions options, RequestInterceptorHandler handler) async {
        var token = _accessToken;
        var isExpired = token == null || JwtDecoder.isExpired(token);

        // Proactively refresh an expired token *before* sending, so the
        // request never goes out unauthenticated (which the backend answers
        // with 401 and the app then treats as a forced sign-out). The queued
        // interceptor serialises requests, so awaiting here is safe.
        if (isExpired &&
            Supabase.instance.client.auth.currentSession != null) {
          try {
            await _refreshToken();
            token = _accessToken;
            isExpired = token == null || JwtDecoder.isExpired(token);
          } catch (e) {
            log('Proactive token refresh failed: $e');
          }
        }

        debugPrint('[DioNetwork] → ${options.method} ${options.path} | token: ${token != null ? '✓' : '✗ null'} | expired: $isExpired');
        log('Access token is expired: $isExpired');

        if (!isExpired) {
          options.headers['Authorization'] = 'Bearer $token';
        }

        if (kDebugMode) {
          print('Request Headers:');
          print(json.encode(options.headers));
        }

        return handler.next(options);
      },
      onError: (DioException error, ErrorInterceptorHandler handler) async {
        final session = Supabase.instance.client.auth.currentSession;

        // Only attempt refresh / redirect when there is an active session.
        // Requests made without a session (e.g. background fetch right after
        // a debug login bypass) should fail silently.
        if (error.response?.statusCode == 401 && session != null) {
          if (!isRefreshing) {
            isRefreshing = true;
            try {
              await _refreshToken();

              final newToken = _accessToken;

              for (final callback in tokenRequestQueue) {
                callback();
              }
              tokenRequestQueue.clear();
              isRefreshing = false;

              if (newToken != null) {
                error.requestOptions.headers['Authorization'] =
                    'Bearer $newToken';
                getIt<Dio>()
                    .fetch(error.requestOptions)
                    .then((retried) => handler.resolve(retried))
                    .catchError((e) {
                  log('Error retrying request: $e');
                  handler.reject(error);
                });
              } else {
                handler.reject(error);
              }
            } catch (e) {
              log('Exception during token refresh: $e');
              isRefreshing = false;
              await _signOut();
              getIt<AppRouter>().navigateToSplash();
              return handler.reject(error);
            }
          } else {
            return _addToQueue(error.requestOptions, handler);
          }
        }

        return handler.next(error);
      },
    );
  }

  // ── Queue helper ──────────────────────────────────────────────────────────

  static Future<void> _addToQueue(
    RequestOptions requestOptions,
    ErrorInterceptorHandler handler,
  ) async {
    final completer = Completer<void>();
    tokenRequestQueue.add(() async {
      final newToken = _accessToken;

      if (newToken != null) {
        requestOptions.headers['Authorization'] = 'Bearer $newToken';
        getIt<Dio>()
            .fetch(requestOptions)
            .then((retried) {
              handler.resolve(retried);
              completer.complete();
            })
            .catchError((e) {
              log('Error fetching queued request: $e');
              handler.reject(
                DioException(requestOptions: requestOptions, error: e),
              );
              completer.complete();
            });
      } else {
        handler.reject(
          DioException(
            requestOptions: requestOptions,
            error: 'No access token available',
          ),
        );
        completer.complete();
      }
    });
    return completer.future;
  }

  // ── Retry interceptor (retryAPI) ──────────────────────────────────────────

  static InterceptorsWrapper _interceptorsWrapper() {
    return InterceptorsWrapper(
      onRequest: (RequestOptions options, RequestInterceptorHandler handler) async {
        final token = _accessToken;

        if (token != null) {
          final isExpired = JwtDecoder.isExpired(token);
          if (isExpired) {
            log('Access token expired, refreshing…', name: 'AccessToken');
            try {
              await _refreshToken();
              final newToken = _accessToken;
              if (newToken != null) {
                options.headers['Authorization'] = 'Bearer $newToken';
              }
            } catch (e) {
              log('Failed to refresh token: $e', name: 'AccessToken');
            }
          } else {
            options.headers['Authorization'] = 'Bearer $token';
          }
        }

        if (kDebugMode) {
          print('Request Headers:');
          print(json.encode(options.headers));
        }

        return handler.next(options);
      },
      onError: (error, handler) {
        try {
          return handler.next(error);
        } catch (e) {
          return handler.reject(error);
        }
      },
    );
  }

  // ── Base options ──────────────────────────────────────────────────────────

  static BaseOptions _baseOptions(String url) {
    return BaseOptions(
      baseUrl: url,
      validateStatus: (status) => status != null && status < 300,
      responseType: ResponseType.json,
    );
  }
}