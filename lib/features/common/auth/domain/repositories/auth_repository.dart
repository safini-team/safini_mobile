abstract class AuthRepository {
  Future<void> saveSelectedRole(String role);
  Future<String?> getSelectedRole();
}
