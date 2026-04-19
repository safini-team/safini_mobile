enum LoginStatus { initial, loading, success, failure }

class LoginState {
  final LoginStatus status;
  final String? errorMessage;
  final String? accountType;

  const LoginState({
    required this.status,
    this.errorMessage,
    this.accountType,
  });

  const LoginState.initial()
      : status = LoginStatus.initial,
        errorMessage = null,
        accountType = null;

  LoginState copyWith({
    LoginStatus? status,
    String? errorMessage,
    String? accountType,
  }) {
    return LoginState(
      status: status ?? this.status,
      errorMessage: errorMessage,
      accountType: accountType ?? this.accountType,
    );
  }
}