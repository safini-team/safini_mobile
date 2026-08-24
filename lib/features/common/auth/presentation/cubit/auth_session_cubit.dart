import 'package:flutter/foundation.dart' show debugPrint;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:safini/core/di/injection.dart';
import 'package:safini/core/network/auth_token_provider.dart';
import 'package:safini/core/utils/constants/app_constants.dart';
import 'package:safini/features/common/auth/data/auth_email_sign_in_service.dart';
import 'package:safini/features/common/auth/data/auth_google_sign_in_service.dart';
import 'package:safini/features/common/auth/data/user_me_service.dart';
import 'package:safini/features/common/auth/presentation/cubit/auth_session_state.dart';
import 'package:safini/features/common/auth/presentation/cubit/child_claim_cubit.dart';
import 'package:safini/features/parent/presentation/cubit/parent_family_cubit.dart';

/// Manages the entire authentication lifecycle:
///
/// 1. **App start** — [checkExistingSession] reads the persisted Supabase
///    session and, if present, refreshes as needed before fetching the profile.
/// 2. **Login** — Google is the public flow. [signInWithEmail] supports only
///    pre-created debug and App Review accounts.
/// 3. **Profile** — [_fetchProfile] calls `GET /v1/me` and emits
///    [AuthSessionStatus.authenticated] with `userId` / `accountType`.
/// 4. **Sign out** — [signOut] clears Google, Supabase, and local auth state.
class AuthSessionCubit extends Cubit<AuthSessionState> {
  AuthSessionCubit(
    this._googleAuth,
    this._emailAuth,
    this._meService,
    this._tokens,
  ) : super(const AuthSessionState.initial());

  final AuthGoogleSignInService _googleAuth;
  final AuthEmailSignInService _emailAuth;
  final UserMeService _meService;
  final AuthTokenProvider _tokens;

  // ── App-start path ──────────────────────────────────────────────────────

  /// Call once from [SplashScreen.initState].
  Future<void> checkExistingSession() async {
    emit(
      state.copyWith(
        status: AuthSessionStatus.checking,
        errorMessage: null,
        canRetry: false,
        isUnauthorized: false,
      ),
    );

    if (!_tokens.hasSession) {
      emit(state.copyWith(status: AuthSessionStatus.unauthenticated));
      return;
    }

    await _fetchProfile();
  }

  // ── Sign-in path ───────────────────────────────────────────────────────

  Future<void> signInWithGoogle() async {
    _emitSigningIn();

    try {
      final authResponse = await _googleAuth.signInWithGoogle();
      await _finishSignIn(
        authResponse,
        missingSessionMessage:
            'Supabase did not return a session after Google login.',
      );
    } catch (e) {
      _emitSignInError(e.toString().replaceFirst('Exception: ', ''));
    }
  }

  Future<void> signInWithEmail({
    required String email,
    required String password,
  }) async {
    _emitSigningIn();

    try {
      final authResponse = await _emailAuth.signIn(
        email: email.trim(),
        password: password,
      );
      await _finishSignIn(
        authResponse,
        missingSessionMessage:
            'Supabase did not return a session after email login.',
      );
    } catch (e) {
      _emitSignInError(e.toString().replaceFirst('Exception: ', ''));
    }
  }

  void _emitSigningIn() {
    emit(
      state.copyWith(
        status: AuthSessionStatus.signingIn,
        errorMessage: null,
        canRetry: false,
        isUnauthorized: false,
      ),
    );
  }

  Future<void> _finishSignIn(
    AuthResponse response, {
    required String missingSessionMessage,
  }) async {
    final accessToken = response.session?.accessToken;
    if (accessToken == null || accessToken.isEmpty) {
      _emitSignInError(missingSessionMessage);
      return;
    }
    await _fetchProfile();
  }

  void _emitSignInError(String message) {
    emit(
      state.copyWith(
        status: AuthSessionStatus.signInError,
        errorMessage: message,
        canRetry: false,
        isUnauthorized: false,
      ),
    );
  }

  // ── Profile fetch ──────────────────────────────────────────────────────

  Future<void> _fetchProfile() async {
    emit(
      state.copyWith(
        status: AuthSessionStatus.fetchingProfile,
        errorMessage: null,
        canRetry: false,
        isUnauthorized: false,
      ),
    );

    try {
      final me = await _meService.fetchMe();
      emit(
        AuthSessionState(
          status: AuthSessionStatus.authenticated,
          userId: me.userId,
          accountType: me.accountType,
        ),
      );
    } on UnauthorizedException {
      // A failed refresh is not a user sign-out. Keep the persisted Supabase
      // session and allow retry when connectivity/auth availability recovers.
      final sessionStillAvailable = _tokens.hasSession;
      emit(
        state.copyWith(
          status: AuthSessionStatus.profileError,
          errorMessage: sessionStillAvailable
              ? 'Could not refresh your session. Please try again.'
              : 'This session is no longer available. Please sign in again.',
          canRetry: sessionStillAvailable,
          isUnauthorized: sessionStillAvailable,
        ),
      );
    } on NetworkException catch (e) {
      emit(
        state.copyWith(
          status: AuthSessionStatus.profileError,
          errorMessage: e.message,
          canRetry: true,
          isUnauthorized: false,
        ),
      );
    } on UnexpectedResponseException catch (e) {
      debugPrint('Unexpected /v1/me response: $e');
      emit(
        AuthSessionState(
          status: AuthSessionStatus.authenticated,
          userId: Supabase.instance.client.auth.currentUser?.id,
          accountType: null,
        ),
      );
    } catch (e) {
      debugPrint('Unknown error fetching /v1/me: $e');
      emit(
        state.copyWith(
          status: AuthSessionStatus.profileError,
          errorMessage: 'An unexpected error occurred.',
          canRetry: true,
          isUnauthorized: false,
        ),
      );
    }
  }

  /// Retry fetching the profile with the current session token.
  Future<void> retryFetchProfile() async {
    if (!_tokens.hasSession) {
      emit(
        state.copyWith(
          status: AuthSessionStatus.profileError,
          errorMessage:
              'This session is no longer available. Please sign in again.',
          canRetry: false,
          isUnauthorized: false,
        ),
      );
      return;
    }
    await _fetchProfile();
  }

  // ── Sign out ───────────────────────────────────────────────────────────

  Future<void> signOut() async {
    await _clearFamilyState();
    await _clearAuthState();
    emit(
      const AuthSessionState(
        status: AuthSessionStatus.unauthenticated,
        isUnauthorized: false,
        canRetry: false,
      ),
    );
  }

  Future<void> _clearFamilyState() async {
    if (getIt.isRegistered<ParentFamilyCubit>()) {
      await getIt<ParentFamilyCubit>().reset();
    }
    if (getIt.isRegistered<ChildClaimCubit>()) {
      getIt<ChildClaimCubit>().reset();
    }
  }

  Future<void> _clearAuthState() async {
    if (getIt.isRegistered<SharedPreferences>()) {
      await getIt<SharedPreferences>().remove(AppConstants.accessToken);
    }
    // Clears both the native Google account selection and the Supabase session.
    await _googleAuth.signOut();
  }
}
