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

  /// A Google or test email sign-in is in progress.
  signingIn,

  /// Session exists; calling GET /v1/me to fetch profile.
  fetchingProfile,

  /// Profile loaded — ready to route by [accountType].
  authenticated,

  /// Sign-in failed (credentials, cancel, network, or configuration).
  signInError,

  /// GET /v1/me failed (network error, unexpected response).
  profileError,
}

/// Which sign-in action is currently running. Lets the login page show the
/// busy state on only the button the user tapped.
enum AuthMethod { google, apple, email }

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

  /// Set while [status] is [signingIn] or [fetchingProfile]; identifies the
  /// tapped button so only that one shows a spinner. Cleared on every terminal
  /// state, like [errorMessage].
  final AuthMethod? pendingMethod;

  const AuthSessionState({
    required this.status,
    this.userId,
    this.accountType,
    this.errorMessage,
    this.canRetry = false,
    this.isUnauthorized = false,
    this.pendingMethod,
  });

  const AuthSessionState.initial()
    : status = AuthSessionStatus.initial,
      userId = null,
      accountType = null,
      errorMessage = null,
      canRetry = false,
      isUnauthorized = false,
      pendingMethod = null;

  AuthSessionState copyWith({
    AuthSessionStatus? status,
    String? userId,
    String? accountType,
    String? errorMessage,
    bool? canRetry,
    bool? isUnauthorized,
    AuthMethod? pendingMethod,
  }) {
    return AuthSessionState(
      status: status ?? this.status,
      userId: userId ?? this.userId,
      accountType: accountType ?? this.accountType,
      errorMessage: errorMessage,
      canRetry: canRetry ?? this.canRetry,
      isUnauthorized: isUnauthorized ?? this.isUnauthorized,
      pendingMethod: pendingMethod,
    );
  }

  @override
  String toString() =>
      'AuthSessionState(status: $status, userId: $userId, '
      'accountType: $accountType, error: $errorMessage)';
}
