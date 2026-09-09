import 'dart:convert';
import 'dart:math';

import 'package:crypto/crypto.dart';
import 'package:flutter/foundation.dart' show debugPrint;
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AuthAppleSignInFailure implements Exception {
  const AuthAppleSignInFailure(this.message);

  final String message;

  @override
  String toString() => message;
}

/// Signs in with Apple natively, then exchanges the identity token with
/// Supabase Auth.
///
/// Supabase's Apple provider must be enabled with this app's bundle ID
/// (`com.safini.app`) listed under "Client IDs" — the native flow sends no
/// client secret, only the ID token, and Supabase validates its `aud` against
/// that list.
class AuthAppleSignInService {
  /// Whether the current platform can present the native Apple sheet.
  Future<bool> get isAvailable => SignInWithApple.isAvailable();

  Future<AuthResponse> signInWithApple() async {
    // Apple returns a token bound to sha256(rawNonce); Supabase re-hashes the
    // rawNonce we pass and compares. Both must see the same rawNonce.
    final rawNonce = _generateRawNonce();
    final hashedNonce = sha256.convert(utf8.encode(rawNonce)).toString();

    try {
      debugPrint('[AppleSignIn] Requesting Apple ID credential');
      final credential = await SignInWithApple.getAppleIDCredential(
        scopes: const [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
        nonce: hashedNonce,
      );

      final idToken = credential.identityToken;
      if (idToken == null || idToken.isEmpty) {
        throw const AuthAppleSignInFailure(
          'Apple did not return an identityToken. Check the Sign in with Apple '
          'capability and the Supabase Apple provider setup.',
        );
      }

      debugPrint('[AppleSignIn] Exchanging Apple idToken with Supabase');
      final response = await Supabase.instance.client.auth.signInWithIdToken(
        provider: OAuthProvider.apple,
        idToken: idToken,
        nonce: rawNonce,
      );

      if (response.session == null) {
        throw const AuthAppleSignInFailure(
          'Supabase accepted the Apple token but did not return a session.',
        );
      }

      // Apple only sends the name on the first authorization. Persist it so the
      // profile is not left blank for accounts created via Apple.
      final fullName = [
        credential.givenName,
        credential.familyName,
      ].where((part) => part != null && part.isNotEmpty).join(' ').trim();
      if (fullName.isNotEmpty) {
        try {
          await Supabase.instance.client.auth.updateUser(
            UserAttributes(data: {'full_name': fullName}),
          );
        } catch (e) {
          debugPrint('[AppleSignIn] Could not store full name: $e');
        }
      }

      return response;
    } on SignInWithAppleAuthorizationException catch (e) {
      debugPrint(
        '[AppleSignIn] Authorization failed code=${e.code} message=${e.message}',
      );
      if (e.code == AuthorizationErrorCode.canceled) {
        throw const AuthAppleSignInFailure('Apple sign-in was cancelled.');
      }
      throw AuthAppleSignInFailure('Apple sign-in failed: ${e.message}');
    } on SignInWithAppleException catch (e) {
      debugPrint('[AppleSignIn] SignInWithAppleException: $e');
      throw AuthAppleSignInFailure('Apple sign-in failed: $e');
    } on AuthException catch (e) {
      debugPrint(
        '[AppleSignIn] Supabase auth failed: message=${e.message} '
        'status=${e.statusCode} code=${e.code}',
      );
      throw AuthAppleSignInFailure(
        'Supabase rejected the Apple token: ${e.message}'
        '${e.statusCode == null ? '' : ' (${e.statusCode})'}',
      );
    }
  }

  String _generateRawNonce([int length = 32]) {
    const charset =
        '0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz-._';
    final random = Random.secure();
    return List.generate(
      length,
      (_) => charset[random.nextInt(charset.length)],
    ).join();
  }
}
