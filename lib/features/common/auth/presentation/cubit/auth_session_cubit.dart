import 'package:flutter/foundation.dart' show debugPrint;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:safini/features/common/auth/data/auth_google_sign_in_service.dart';
import 'package:safini/features/common/auth/data/user_me_service.dart';
import 'package:safini/features/common/auth/presentation/cubit/auth_session_state.dart';

/// Manages the entire authentication lifecycle:
///
/// 1. **App start** — [checkExistingSession] reads the persisted Supabase
///    session and, if valid, immediately fetches the user profile.
/// 2. **Login** — [signInWithGoogle] drives the native Google flow, exchanges
///    tokens with Supabase, then fetches the profile.
/// 3. **Profile** — [_fetchProfile] calls `GET /v1/me` and emits
///    [AuthSessionStatus.authenticated] with `userId` / `accountType`.
/// 4. **Sign out** — [signOut] clears the Supabase session.
class AuthSessionCubit extends Cubit<AuthSessionState> {
  AuthSessionCubit(this._googleAuth, this._meService)
      : super(const AuthSessionState.initial());

  final AuthGoogleSignInService _googleAuth;
  final UserMeService _meService;

  // ── App-start path ──────────────────────────────────────────────────────

  /// Call once from [SplashScreen.initState].
  Future<void> checkExistingSession() async {
    emit(state.copyWith(
      status: AuthSessionStatus.checking,
      errorMessage: null,
      canRetry: false,
      isUnauthorized: false,
    ));

    final session = Supabase.instance.client.auth.currentSession;

    if (session == null || session.isExpired) {
      if (session != null) {
        await Supabase.instance.client.auth.signOut();
      }
      emit(state.copyWith(status: AuthSessionStatus.unauthenticated));
      return;
    }

    await _fetchProfile(session.accessToken);
  }

  // ── Sign-in path ───────────────────────────────────────────────────────

  Future<void> signInWithGoogle() async {
    emit(state.copyWith(
      status: AuthSessionStatus.signingIn,
      errorMessage: null,
      canRetry: false,
      isUnauthorized: false,
    ));

    try {
      final authResponse = await _googleAuth.signInWithGoogle();
      final accessToken = authResponse.session?.accessToken;

      if (accessToken == null || accessToken.isEmpty) {
        emit(state.copyWith(
          status: AuthSessionStatus.signInError,
          errorMessage: 'Supabase did not return a session after Google login.',
          canRetry: false,
          isUnauthorized: false,
        ));
        return;
      }

      await _fetchProfile(accessToken);
    } catch (e) {
      final message = e.toString().replaceFirst('Exception: ', '');
      emit(state.copyWith(
        status: AuthSessionStatus.signInError,
        errorMessage: message,
        canRetry: false,
        isUnauthorized: false,
      ));
    }
  }

  // ── Profile fetch ──────────────────────────────────────────────────────

  Future<void> _fetchProfile(String accessToken) async {
    emit(state.copyWith(
      status: AuthSessionStatus.fetchingProfile,
      errorMessage: null,
      canRetry: false,
      isUnauthorized: false,
    ));

    try {
      final me = await _meService.fetchMe(accessToken);
      emit(AuthSessionState(
        status: AuthSessionStatus.authenticated,
        userId: me.userId,
        accountType: me.accountType,
      ));
    } on UnauthorizedException {
      // Token is invalid — force re-login.
      await Supabase.instance.client.auth.signOut();
      emit(state.copyWith(
        status: AuthSessionStatus.unauthenticated,
        errorMessage: null,
        canRetry: false,
        isUnauthorized: true,
      ));
    } on NetworkException catch (e) {
      emit(state.copyWith(
        status: AuthSessionStatus.profileError,
        errorMessage: e.message,
        canRetry: true,
        isUnauthorized: false,
      ));
    } on UnexpectedResponseException catch (e) {
      debugPrint('Unexpected /v1/me response: $e');
      emit(state.copyWith(
        status: AuthSessionStatus.profileError,
        errorMessage: 'Something went wrong. Please try again.',
        canRetry: true,
        isUnauthorized: false,
      ));
    } catch (e) {
      debugPrint('Unknown error fetching /v1/me: $e');
      emit(state.copyWith(
        status: AuthSessionStatus.profileError,
        errorMessage: 'An unexpected error occurred.',
        canRetry: true,
        isUnauthorized: false,
      ));
    }
  }

  /// Retry fetching the profile with the current session token.
  Future<void> retryFetchProfile() async {
    final session = Supabase.instance.client.auth.currentSession;
    if (session == null || session.isExpired) {
      if (session != null) {
        await Supabase.instance.client.auth.signOut();
      }
      emit(state.copyWith(status: AuthSessionStatus.unauthenticated));
      return;
    }
    await _fetchProfile(session.accessToken);
  }

  // ── Sign out ───────────────────────────────────────────────────────────

  Future<void> signOut() async {
    await Supabase.instance.client.auth.signOut();
    emit(const AuthSessionState(
      status: AuthSessionStatus.unauthenticated,
      isUnauthorized: false,
      canRetry: false,
    ));
  }
}
