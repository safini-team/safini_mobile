import 'package:flutter/foundation.dart'
    show TargetPlatform, debugPrint, defaultTargetPlatform, kIsWeb;
import 'package:google_sign_in/google_sign_in.dart';
import 'package:safini/core/config/supabase_config.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AuthGoogleSignInFailure implements Exception {
  const AuthGoogleSignInFailure(this.message);

  final String message;

  @override
  String toString() => message;
}

/// Signs in with Google natively, then exchanges tokens with Supabase Auth.
class AuthGoogleSignInService {
  static Future<void>? _initializeFuture;

  Future<void> _ensureGoogleSignInInitialized() async {
    if (!SupabaseConfig.isGoogleConfigured) {
      throw StateError(
        'Missing GOOGLE_WEB_CLIENT_ID. Set it in assets/env/app.env or '
        '--dart-define=GOOGLE_WEB_CLIENT_ID=...',
      );
    }

    final String webClientId = SupabaseConfig.googleWebClientId;

    /// Web: OAuth client is the web app client. iOS: native iOS client.
    /// Android: `clientId` omitted; Play Services uses app signing + [webClientId] as server.
    final String? clientId = kIsWeb
        ? webClientId
        : (defaultTargetPlatform == TargetPlatform.iOS
            ? (SupabaseConfig.googleIosClientId.isEmpty
                ? null
                : SupabaseConfig.googleIosClientId)
            : null);

    debugPrint(
      '[GoogleSignIn] initialize platform=$defaultTargetPlatform '
      'webClient=${_redactedClientId(webClientId)} '
      'clientId=${clientId == null ? 'none' : _redactedClientId(clientId)}',
    );

    _initializeFuture ??= GoogleSignIn.instance.initialize(
      serverClientId: webClientId,
      clientId: clientId,
    );
    await _initializeFuture!;
  }

  Future<AuthResponse> signInWithGoogle() async {
    await _ensureGoogleSignInInitialized();

    try {
      debugPrint('[GoogleSignIn] Starting interactive authentication');
      final GoogleSignInAccount account = await GoogleSignIn.instance
          .authenticate(scopeHint: const <String>['email', 'profile']);
      debugPrint('[GoogleSignIn] Account selected; reading idToken');

      final GoogleSignInAuthentication auth = account.authentication;
      final String? idToken = auth.idToken;

      if (idToken == null || idToken.isEmpty) {
        throw const AuthGoogleSignInFailure(
          'Google did not return an idToken. Check GOOGLE_WEB_CLIENT_ID and Supabase Google provider setup.',
        );
      }

      debugPrint('[GoogleSignIn] Exchanging Google idToken with Supabase');
      final response = await Supabase.instance.client.auth.signInWithIdToken(
        provider: OAuthProvider.google,
        idToken: idToken,
        accessToken: null,
      );

      if (response.session == null) {
        throw const AuthGoogleSignInFailure(
          'Supabase accepted the Google token but did not return a session.',
        );
      }

      return response;
    } on GoogleSignInException catch (e) {
      debugPrint(
        '[GoogleSignIn] GoogleSignInException code=${e.code.name} '
        'description=${e.description} details=${e.details}',
      );
      if (e.code == GoogleSignInExceptionCode.canceled ||
          e.code == GoogleSignInExceptionCode.interrupted) {
        throw const AuthGoogleSignInFailure(
          'Google sign-in was cancelled. If this happens after choosing an account, check the Android OAuth package name, SHA-1, and web serverClientId.',
        );
      }
      if (e.code == GoogleSignInExceptionCode.clientConfigurationError ||
          e.code == GoogleSignInExceptionCode.providerConfigurationError) {
        throw AuthGoogleSignInFailure(
          'Google sign-in is misconfigured: ${e.description ?? e.code.name}',
        );
      }
      throw AuthGoogleSignInFailure(
        'Google sign-in failed: ${e.description ?? e.code.name}',
      );
    } on AuthException catch (e) {
      debugPrint(
        '[GoogleSignIn] Supabase auth failed: message=${e.message} '
        'status=${e.statusCode} code=${e.code}',
      );
      throw AuthGoogleSignInFailure(
        'Supabase rejected the Google token: ${e.message}${e.statusCode == null ? '' : ' (${e.statusCode})'}',
      );
    }
  }

  String _redactedClientId(String clientId) {
    final parts = clientId.split('-');
    if (parts.length < 2) {
      return 'set';
    }
    final suffix = parts.last;
    final visibleSuffix =
        suffix.length <= 8 ? suffix : suffix.substring(suffix.length - 8);
    return '${parts.first}-...$visibleSuffix';
  }

  Future<void> signOut() async {
    try {
      await _ensureGoogleSignInInitialized();
      await GoogleSignIn.instance.signOut();
      await Supabase.instance.client.auth.signOut();
    } catch (e) {
      debugPrint('[GoogleSignIn] signOut error: $e');
    }
  }
}
