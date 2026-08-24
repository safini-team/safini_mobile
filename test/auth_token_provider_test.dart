import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:safini/core/network/auth_token_provider.dart';
import 'package:safini/core/network/authenticated_http_client.dart';

class _FakeGateway implements AuthSessionGateway {
  _FakeGateway(this.session);

  AuthSessionSnapshot? session;
  int refreshCalls = 0;
  Completer<AuthSessionSnapshot>? refreshCompleter;
  Object? refreshError;
  AuthSessionSnapshot? refreshedSession;

  @override
  AuthSessionSnapshot? get currentSession => session;

  @override
  Future<AuthSessionSnapshot> refreshSession() async {
    refreshCalls++;
    final completer = refreshCompleter;
    if (completer != null) {
      final refreshed = await completer.future;
      session = refreshed;
      return refreshed;
    }
    if (refreshError case final error?) throw error;
    final refreshed = refreshedSession!;
    session = refreshed;
    return refreshed;
  }
}

class _FakeTokens implements AuthTokenProvider {
  _FakeTokens({required this.token, this.refreshedToken});

  String? token;
  String? refreshedToken;
  int refreshCalls = 0;
  Object? refreshError;

  @override
  bool get hasSession => token != null;

  @override
  String? get currentAccessToken => token;

  @override
  Future<String?> getAccessToken() async => token;

  @override
  Future<String?> refreshAfterUnauthorized(String? rejectedAccessToken) async {
    refreshCalls++;
    if (refreshError case final error?) throw error;
    token = refreshedToken;
    return token;
  }
}

void main() {
  final now = DateTime.utc(2026, 8, 24, 12);
  int epochAfter(Duration duration) =>
      now.add(duration).millisecondsSinceEpoch ~/ 1000;

  test(
    'returns the current access token while it is comfortably valid',
    () async {
      final gateway = _FakeGateway(
        AuthSessionSnapshot(
          accessToken: 'current',
          expiresAt: epochAfter(const Duration(minutes: 30)),
        ),
      );
      final tokens = SupabaseAuthTokenProvider(gateway, now: () => now);

      expect(await tokens.getAccessToken(), 'current');
      expect(gateway.refreshCalls, 0);
    },
  );

  test('refreshes shortly before access-token expiry', () async {
    final gateway =
        _FakeGateway(
            AuthSessionSnapshot(
              accessToken: 'old',
              expiresAt: epochAfter(const Duration(seconds: 30)),
            ),
          )
          ..refreshedSession = AuthSessionSnapshot(
            accessToken: 'new',
            expiresAt: epochAfter(const Duration(hours: 1)),
          );
    final tokens = SupabaseAuthTokenProvider(gateway, now: () => now);

    expect(await tokens.getAccessToken(), 'new');
    expect(gateway.refreshCalls, 1);
  });

  test('concurrent callers share one refresh-token exchange', () async {
    final gateway = _FakeGateway(
      AuthSessionSnapshot(
        accessToken: 'old',
        expiresAt: epochAfter(const Duration(seconds: 1)),
      ),
    )..refreshCompleter = Completer<AuthSessionSnapshot>();
    final tokens = SupabaseAuthTokenProvider(gateway, now: () => now);

    final first = tokens.getAccessToken();
    final second = tokens.getAccessToken();
    await Future<void>.delayed(Duration.zero);

    expect(gateway.refreshCalls, 1);
    gateway.refreshCompleter!.complete(
      AuthSessionSnapshot(
        accessToken: 'new',
        expiresAt: epochAfter(const Duration(hours: 1)),
      ),
    );
    expect(await Future.wait([first, second]), ['new', 'new']);
  });

  test('a proactive refresh outage keeps a still-valid token', () async {
    final gateway = _FakeGateway(
      AuthSessionSnapshot(
        accessToken: 'still-valid',
        expiresAt: epochAfter(const Duration(seconds: 30)),
      ),
    )..refreshError = StateError('offline');
    final tokens = SupabaseAuthTokenProvider(gateway, now: () => now);

    expect(await tokens.getAccessToken(), 'still-valid');
    expect(gateway.currentSession?.accessToken, 'still-valid');
  });

  test('a 401 for an already-rotated token does not refresh again', () async {
    final gateway = _FakeGateway(
      AuthSessionSnapshot(
        accessToken: 'new',
        expiresAt: epochAfter(const Duration(hours: 1)),
      ),
    );
    final tokens = SupabaseAuthTokenProvider(gateway, now: () => now);

    expect(await tokens.refreshAfterUnauthorized('old'), 'new');
    expect(gateway.refreshCalls, 0);
  });

  test(
    'authenticated HTTP retries a 401 once with the refreshed token',
    () async {
      final seen = <String?>[];
      final tokens = _FakeTokens(token: 'old', refreshedToken: 'new');
      final client = AuthenticatedHttpClient(
        tokens,
        client: MockClient((request) async {
          seen.add(request.headers['Authorization']);
          return request.headers['Authorization'] == 'Bearer old'
              ? http.Response('unauthorized', 401)
              : http.Response('ok', 200);
        }),
      );

      final response = await client.get(
        Uri.parse('https://api.safini.fun/v1/me'),
      );

      expect(response.statusCode, 200);
      expect(seen, ['Bearer old', 'Bearer new']);
      expect(tokens.refreshCalls, 1);
    },
  );

  test('refresh failure returns 401 without clearing the token', () async {
    final tokens = _FakeTokens(token: 'old')
      ..refreshError = StateError('offline');
    final client = AuthenticatedHttpClient(
      tokens,
      client: MockClient((_) async => http.Response('unauthorized', 401)),
    );

    final response = await client.get(
      Uri.parse('https://api.safini.fun/v1/me'),
    );

    expect(response.statusCode, 401);
    expect(tokens.token, 'old');
    expect(tokens.refreshCalls, 1);
  });
}
