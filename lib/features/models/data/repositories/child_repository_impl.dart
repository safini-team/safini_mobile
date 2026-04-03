import 'package:dartz/dartz.dart';
import '../../domain/models/child_model.dart';
import '../../domain/repositories/i_child_repository.dart';
import '../../../../core/error/failures.dart';

class ChildRepositoryImpl implements IChildRepository {
  @override
  Future<Either<Failure, ChildModel>> createChild(String nickname, int age, String gender) async {
    return const Left(ServerFailure('Not implemented'));
  }

  @override
  Future<Either<Failure, ChildModel>> updateChild(String childId, {String? nickname, int? age, String? gender, AvatarStateModel? avatarState}) async {
    return const Left(ServerFailure('Not implemented'));
  }

  @override
  Future<Either<Failure, ChildModel>> claimChild(String inviteCode) async {
    return const Left(ServerFailure('Not implemented'));
  }
}
