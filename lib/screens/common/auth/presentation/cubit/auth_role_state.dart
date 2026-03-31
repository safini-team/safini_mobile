enum AuthRoleStatus { initial, saving, saved, error }

class AuthRoleState {
  final AuthRoleStatus status;
  final String? selectedRole;
  final String? errorMessage;

  const AuthRoleState({
    required this.status,
    this.selectedRole,
    this.errorMessage,
  });

  const AuthRoleState.initial()
      : status = AuthRoleStatus.initial,
        selectedRole = null,
        errorMessage = null;

  AuthRoleState copyWith({
    AuthRoleStatus? status,
    String? selectedRole,
    String? errorMessage,
  }) {
    return AuthRoleState(
      status: status ?? this.status,
      selectedRole: selectedRole ?? this.selectedRole,
      errorMessage: errorMessage,
    );
  }
}
