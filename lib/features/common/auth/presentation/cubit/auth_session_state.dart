/// All possible states for the authentication / session lifecycle.
///
/// Used by [AuthSessionCubit] and consumed by the splash screen, login page,
/// and any guard that needs to know the current auth status.
enum AuthSessionStatus {
  /// App just launched, nothing checked yet.
  initial,

  /// Checking for an existing Supabase session (app restart path).
  checking,

  /// No valid session — show the login page.
  unauthenticated,

  /// Google Sign-In is in progress.
  signingIn,

  /// Session exists; calling GET /v1/me to fetch profile.
  fetchingProfile,

  /// Profile loaded — ready to route by [accountType].
  authenticated,

  /// Google sign-in failed (cancel, network, permission denied).
  signInError,

  /// GET /v1/me failed (network error, unexpected response).
  profileError,
}

class AuthSessionState {
  final AuthSessionStatus status;

  /// Non-null only when [status] is [AuthSessionStatus.authenticated].
  final String? userId;
  final String? accountType;

  /// Non-null when [status] is [signInError] or [profileError].
  final String? errorMessage;

  /// True when the profile error is retryable (network issue).
  final bool canRetry;

  /// True when the profile fetch returned 401 (token invalid).
  final bool isUnauthorized;

  const AuthSessionState({
    required this.status,
    this.userId,
    this.accountType,
    this.errorMessage,
    this.canRetry = false,
    this.isUnauthorized = false,
  });

  const AuthSessionState.initial()
      : status = AuthSessionStatus.initial,
        userId = null,
        accountType = null,
        errorMessage = null,
        canRetry = false,
        isUnauthorized = false;

  AuthSessionState copyWith({
    AuthSessionStatus? status,
    String? userId,
    String? accountType,
    String? errorMessage,
    bool? canRetry,
    bool? isUnauthorized,
  }) {
    return AuthSessionState(
      status: status ?? this.status,
      userId: userId ?? this.userId,
      accountType: accountType ?? this.accountType,
      errorMessage: errorMessage,
      canRetry: canRetry ?? this.canRetry,
      isUnauthorized: isUnauthorized ?? this.isUnauthorized,
    );
  }

  @override
  String toString() =>
      'AuthSessionState(status: $status, userId: $userId, '
      'accountType: $accountType, error: $errorMessage)';
}
