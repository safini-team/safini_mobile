import 'package:safini/features/common/auth/data/datasource/local/auth_local_datasource.dart';
import 'package:safini/features/common/auth/data/datasource/remote/auth_remote_datasource.dart';
import 'package:safini/features/common/auth/domain/repositories/auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthLocalDataSource _localDataSource;
  final AuthRemoteDataSource _remoteDataSource;

  AuthRepositoryImpl(this._localDataSource, this._remoteDataSource);

  @override
  Future<String?> getSelectedRole() {
    return _localDataSource.getSelectedRole();
  }

  @override
  Future<void> saveSelectedRole(String role) async {
    await _localDataSource.saveSelectedRole(role);
    await _remoteDataSource.syncSelectedRole(role);
  }
}
