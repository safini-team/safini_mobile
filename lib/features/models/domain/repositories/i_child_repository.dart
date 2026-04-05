import 'package:dartz/dartz.dart';
import '../models/child_model.dart';
import '../../../../core/error/failures.dart';

abstract class IChildRepository {
  Future<Either<Failure, ChildModel>> createChild(String nickname, int age, String gender);
  Future<Either<Failure, ChildModel>> updateChild(String childId, {String? nickname, int? age, String? gender, AvatarStateModel? avatarState});
  Future<Either<Failure, ChildModel>> claimChild(String inviteCode);
}
