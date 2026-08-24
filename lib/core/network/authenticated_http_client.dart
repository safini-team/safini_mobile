import 'dart:convert';

import 'package:http/http.dart' as http;

import 'package:safini/core/network/auth_token_provider.dart';

class AuthSessionUnavailableException implements Exception {
  const AuthSessionUnavailableException();

  @override
  String toString() => 'No authenticated Supabase session is available.';
}

/// Small HTTP facade that applies the same auth policy as the shared Dio
/// client: proactive refresh, one refresh on 401, and one retry.
class AuthenticatedHttpClient {
  AuthenticatedHttpClient(this._tokens, {http.Client? client})
    : _client = client ?? http.Client();

  final AuthTokenProvider _tokens;
  final http.Client _client;

  Future<http.Response> get(Uri url, {Map<String, String>? headers}) =>
      _send((token) => _client.get(url, headers: _headers(headers, token)));

  Future<http.Response> post(
    Uri url, {
    Map<String, String>? headers,
    Object? body,
    Encoding? encoding,
  }) => _send(
    (token) => _client.post(
      url,
      headers: _headers(headers, token),
      body: body,
      encoding: encoding,
    ),
  );

  Future<http.Response> put(
    Uri url, {
    Map<String, String>? headers,
    Object? body,
    Encoding? encoding,
  }) => _send(
    (token) => _client.put(
      url,
      headers: _headers(headers, token),
      body: body,
      encoding: encoding,
    ),
  );

  Future<http.Response> patch(
    Uri url, {
    Map<String, String>? headers,
    Object? body,
    Encoding? encoding,
  }) => _send(
    (token) => _client.patch(
      url,
      headers: _headers(headers, token),
      body: body,
      encoding: encoding,
    ),
  );

  Future<http.Response> delete(
    Uri url, {
    Map<String, String>? headers,
    Object? body,
    Encoding? encoding,
  }) => _send(
    (token) => _client.delete(
      url,
      headers: _headers(headers, token),
      body: body,
      encoding: encoding,
    ),
  );

  Future<http.Response> _send(
    Future<http.Response> Function(String token) request,
  ) async {
    final token = await _tokens.getAccessToken();
    if (token == null || token.isEmpty) {
      throw const AuthSessionUnavailableException();
    }

    final response = await request(token);
    if (response.statusCode != 401) return response;

    String? refreshed;
    try {
      refreshed = await _tokens.refreshAfterUnauthorized(token);
    } catch (_) {
      // Keep the Supabase session intact. A transient refresh failure should
      // surface as the original request error and remain retryable in the UI.
      return response;
    }
    if (refreshed == null || refreshed.isEmpty) return response;

    return request(refreshed);
  }

  Map<String, String> _headers(Map<String, String>? headers, String token) =>
      <String, String>{...?headers, 'Authorization': 'Bearer $token'};

  void close() => _client.close();
}
