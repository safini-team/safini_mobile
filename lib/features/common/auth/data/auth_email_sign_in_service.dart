import 'package:supabase_flutter/supabase_flutter.dart';

class AuthEmailSignInFailure implements Exception {
  const AuthEmailSignInFailure(this.message);

  final String message;

  @override
  String toString() => message;
}

/// Signs an existing test/review user in with Supabase email and password.
///
/// User creation intentionally does not live in the mobile application.
class AuthEmailSignInService {
  Future<AuthResponse> signIn({
    required String email,
    required String password,
  }) async {
    try {
      final response = await Supabase.instance.client.auth.signInWithPassword(
        email: email.trim(),
        password: password,
      );

      if (response.session == null) {
        throw const AuthEmailSignInFailure(
          'Supabase did not return a session after email login.',
        );
      }

      return response;
    } on AuthEmailSignInFailure {
      rethrow;
    } on AuthException catch (e) {
      throw AuthEmailSignInFailure(e.message);
    } catch (_) {
      throw const AuthEmailSignInFailure(
        'Email sign-in failed. Please check the credentials and try again.',
      );
    }
  }
}
