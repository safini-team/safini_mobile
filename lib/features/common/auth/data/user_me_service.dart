import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:safini/core/config/supabase_config.dart';
import 'package:safini/core/utils/constants/app_constants.dart';
import 'package:safini/features/common/auth/data/me_response.dart';

// ── Typed exceptions ────────────────────────────────────────────────────────

/// HTTP 401 — token is invalid or expired.
class UnauthorizedException implements Exception {
  final String message;
  const UnauthorizedException([this.message = 'Unauthorized']);
  @override
  String toString() => 'UnauthorizedException: $message';
}

/// Network-level failure (DNS, timeout, socket error).
class NetworkException implements Exception {
  final String message;
  const NetworkException([this.message = 'Network error']);
  @override
  String toString() => 'NetworkException: $message';
}

/// The server returned a response we could not parse.
class UnexpectedResponseException implements Exception {
  final int? statusCode;
  final String message;
  const UnexpectedResponseException(this.statusCode, this.message);
  @override
  String toString() =>
      'UnexpectedResponseException($statusCode): $message';
}

// ── Service ─────────────────────────────────────────────────────────────────

/// HTTP client for `GET /v1/me`.
class UserMeService {
  /// Fetches the current user profile using the Supabase access token.
  ///
  /// Throws [UnauthorizedException] on 401,
  /// [NetworkException] on connectivity issues,
  /// [UnexpectedResponseException] on anything else unexpected.
  Future<MeResponse> fetchMe(String accessToken) async {
    final baseUrl = SupabaseConfig.apiBaseUrl;
    if (baseUrl.isEmpty) {
      throw const UnexpectedResponseException(
        null,
        'API_BASE_URL is not configured',
      );
    }

    final uri = Uri.parse('$baseUrl/v1/me');

    late final http.Response response;
    try {
      response = await http
          .get(
            uri,
            headers: {
              'Authorization': 'Bearer $accessToken',
              'Accept': 'application/json',
            },
          )
          .timeout(AppConstants.apiTimeout);
    } on TimeoutException {
      throw const NetworkException(
        'Server is not responding. Please check your internet connection and try again.',
      );
    } on SocketException catch (e) {
      throw NetworkException(e.message);
    } on HttpException catch (e) {
      throw NetworkException(e.message);
    } on http.ClientException catch (e) {
      throw NetworkException(e.message);
    } catch (e) {
      throw NetworkException(e.toString());
    }

    if (response.statusCode == 401) {
      throw const UnauthorizedException('Invalid or expired token');
    }

    if (response.statusCode != 200) {
      throw UnexpectedResponseException(
        response.statusCode,
        'GET /v1/me returned ${response.statusCode}',
      );
    }

    try {
      final body = jsonDecode(response.body);
      if (body is! Map<String, dynamic>) {
        throw const FormatException('Response body is not a JSON object');
      }
      return MeResponse.fromJson(body);
    } on FormatException catch (e) {
      debugPrint('GET /v1/me parse error: $e');
      throw UnexpectedResponseException(
        response.statusCode,
        'Could not parse /v1/me response: $e',
      );
    }
  }
}
