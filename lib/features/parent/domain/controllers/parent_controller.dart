import 'package:dartz/dartz.dart';
import 'package:safini/core/utils/error/failures.dart';
import 'package:safini/features/parent/domain/models/parent_user_model.dart';
import 'package:safini/features/parent/domain/repositories/i_parent_user_repository.dart';

class ParentController {
  final IParentUserRepository _userRepository;

  const ParentController(this._userRepository);

  Future<Either<Failure, ParentUserModel>> getParentProfile(String userId) {
    return _userRepository.getParentProfile(userId);
  }
}
