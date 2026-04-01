import 'package:dartz/dartz.dart';
import '../models/child_model.dart';
import '../repositories/i_child_repository.dart';
import '../../../../core/error/failures.dart';

class ChildController {
  final IChildRepository _repository;

  ChildController(this._repository);

  Future<Either<Failure, ChildModel>> createChild(String nickname, int age, String gender) => _repository.createChild(nickname, age, gender);
  Future<Either<Failure, ChildModel>> updateChild(String childId, {String? nickname, int? age, String? gender, AvatarStateModel? avatarState}) => 
      _repository.updateChild(childId, nickname: nickname, age: age, gender: gender, avatarState: avatarState);
  Future<Either<Failure, ChildModel>> claimChild(String inviteCode) => _repository.claimChild(inviteCode);
}
