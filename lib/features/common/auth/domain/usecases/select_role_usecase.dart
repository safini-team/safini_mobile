import 'package:safini/features/common/auth/domain/repositories/auth_repository.dart';

class SelectRoleUseCase {
  final AuthRepository _repository;

  SelectRoleUseCase(this._repository);

  Future<void> call(String role) {
    return _repository.saveSelectedRole(role);
  }
}
