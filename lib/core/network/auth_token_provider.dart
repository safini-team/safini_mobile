import 'dart:async';

import 'package:supabase_flutter/supabase_flutter.dart';

/// The single source of truth for API bearer tokens.
///
/// Supabase owns persistence and refresh-token rotation. Application code must
/// never keep a second access-token copy because that copy becomes stale as
/// soon as Supabase refreshes the session in the background.
abstract interface class AuthTokenProvider {
  bool get hasSession;

  String? get currentAccessToken;

  /// Returns a usable access token, refreshing shortly before expiry.
  Future<String?> getAccessToken();

  /// Handles a backend 401. If another request already refreshed the rejected
  /// token, returns that newer token; otherwise performs one shared refresh.
  Future<String?> refreshAfterUnauthorized(String? rejectedAccessToken);
}

class AuthSessionSnapshot {
  const AuthSessionSnapshot({
    required this.accessToken,
    required this.expiresAt,
  });

  final String accessToken;
  final int? expiresAt;
}

abstract interface class AuthSessionGateway {
  AuthSessionSnapshot? get currentSession;

  Future<AuthSessionSnapshot> refreshSession();
}

/// Used only when the app is rendered without Supabase initialization, such
/// as widget previews and the basic application smoke test.
class UnavailableAuthSessionGateway implements AuthSessionGateway {
  const UnavailableAuthSessionGateway();

  @override
  AuthSessionSnapshot? get currentSession => null;

  @override
  Future<AuthSessionSnapshot> refreshSession() =>
      Future.error(AuthSessionMissingException('Supabase is not initialized.'));
}

class SupabaseAuthSessionGateway implements AuthSessionGateway {
  SupabaseAuthSessionGateway(this._client);

  final SupabaseClient _client;

  @override
  AuthSessionSnapshot? get currentSession {
    final session = _client.auth.currentSession;
    if (session == null) return null;
    return AuthSessionSnapshot(
      accessToken: session.accessToken,
      expiresAt: session.expiresAt,
    );
  }

  @override
  Future<AuthSessionSnapshot> refreshSession() async {
    final response = await _client.auth.refreshSession();
    final session = response.session;
    if (session == null || session.accessToken.isEmpty) {
      throw AuthSessionMissingException(
        'Supabase did not return a session after token refresh.',
      );
    }
    return AuthSessionSnapshot(
      accessToken: session.accessToken,
      expiresAt: session.expiresAt,
    );
  }
}

class SupabaseAuthTokenProvider implements AuthTokenProvider {
  SupabaseAuthTokenProvider(
    this._gateway, {
    DateTime Function()? now,
    this.refreshLeeway = const Duration(minutes: 1),
  }) : _now = now ?? DateTime.now;

  final AuthSessionGateway _gateway;
  final DateTime Function() _now;
  final Duration refreshLeeway;

  Future<String?>? _refreshInFlight;

  @override
  bool get hasSession => _gateway.currentSession != null;

  @override
  String? get currentAccessToken {
    final token = _gateway.currentSession?.accessToken;
    return token == null || token.isEmpty ? null : token;
  }

  @override
  Future<String?> getAccessToken() async {
    final session = _gateway.currentSession;
    if (session == null || session.accessToken.isEmpty) return null;
    if (!_expiresSoon(session)) return session.accessToken;

    try {
      return await _refreshOnce();
    } catch (_) {
      // A refresh attempted slightly ahead of expiry may fail during a brief
      // outage. The current JWT is still usable until its actual expiry.
      final fallback = _gateway.currentSession;
      if (fallback != null && !_isExpired(fallback)) {
        return fallback.accessToken;
      }
      rethrow;
    }
  }

  @override
  Future<String?> refreshAfterUnauthorized(String? rejectedAccessToken) async {
    final session = _gateway.currentSession;
    if (session == null || session.accessToken.isEmpty) return null;

    // A concurrent request may already have rotated the token while this 401
    // was travelling back from the API. Reuse it instead of rotating again.
    if (rejectedAccessToken != null &&
        session.accessToken != rejectedAccessToken &&
        !_isExpired(session)) {
      return session.accessToken;
    }

    return _refreshOnce();
  }

  Future<String?> _refreshOnce() {
    final inFlight = _refreshInFlight;
    if (inFlight != null) return inFlight;

    final completer = Completer<String?>();
    _refreshInFlight = completer.future;

    () async {
      try {
        final refreshed = await _gateway.refreshSession();
        completer.complete(
          refreshed.accessToken.isEmpty ? null : refreshed.accessToken,
        );
      } catch (error, stackTrace) {
        completer.completeError(error, stackTrace);
      } finally {
        _refreshInFlight = null;
      }
    }();

    return completer.future;
  }

  bool _expiresSoon(AuthSessionSnapshot session) {
    final expiresAt = session.expiresAt;
    if (expiresAt == null) return false;
    final refreshAt = DateTime.fromMillisecondsSinceEpoch(
      expiresAt * Duration.millisecondsPerSecond,
    ).subtract(refreshLeeway);
    return !_now().isBefore(refreshAt);
  }

  bool _isExpired(AuthSessionSnapshot session) {
    final expiresAt = session.expiresAt;
    if (expiresAt == null) return false;
    final expiry = DateTime.fromMillisecondsSinceEpoch(
      expiresAt * Duration.millisecondsPerSecond,
    );
    return !_now().isBefore(expiry);
  }
}
