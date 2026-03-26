class AuthLocalDataSource {
  String? _selectedRole;

  Future<void> saveSelectedRole(String role) async {
    _selectedRole = role;
  }

  Future<String?> getSelectedRole() async {
    return _selectedRole;
  }
}
