import 'package:flutter/foundation.dart'
    show TargetPlatform, defaultTargetPlatform, kIsWeb;
import 'package:google_sign_in/google_sign_in.dart';
import 'package:safini/core/config/supabase_config.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

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

    _initializeFuture ??= GoogleSignIn.instance.initialize(
      serverClientId: webClientId,
      clientId: clientId,
    );
    await _initializeFuture!;
  }

  Future<AuthResponse> signInWithGoogle() async {
    await _ensureGoogleSignInInitialized();

    try {
      final GoogleSignInAccount account = await GoogleSignIn.instance
          .authenticate(scopeHint: const <String>['email', 'profile']);

      final GoogleSignInAuthentication auth = account.authentication;
      final String? idToken = auth.idToken;

      if (idToken == null || idToken.isEmpty) {
        throw StateError(
          'Google did not return an idToken. Check GOOGLE_WEB_CLIENT_ID and Supabase Google provider setup.',
        );
      }

      return Supabase.instance.client.auth.signInWithIdToken(
        provider: OAuthProvider.google,
        idToken: idToken,
        accessToken: null,
      );
    } on GoogleSignInException catch (e) {
      if (e.code == GoogleSignInExceptionCode.canceled ||
          e.code == GoogleSignInExceptionCode.interrupted) {
        throw Exception('Sign in cancelled');
      }
      rethrow;
    }
  }
}
