import 'package:injectable/injectable.dart';
import 'package:dartz/dartz.dart';
import '../../domain/models/profile_model.dart';
import '../../domain/repositories/i_profile_repository.dart';
import '../../../../core/error/failures.dart';

@Injectable(as: IProfileRepository)
class ProfileRepositoryImpl implements IProfileRepository {
  @override
  Future<Either<Failure, ProfileModel>> getMyProfile() async {
    return const Left(ServerFailure('Not implemented'));
  }

  @override
  Future<Either<Failure, ProfileModel>> updateProfile(ProfileModel profile) async {
    return const Left(ServerFailure('Not implemented'));
  }
}
