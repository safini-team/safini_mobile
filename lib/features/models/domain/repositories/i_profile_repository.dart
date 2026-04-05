import 'package:dartz/dartz.dart';
import '../models/profile_model.dart';
import '../../../../core/error/failures.dart';

abstract class IProfileRepository {
  Future<Either<Failure, ProfileModel>> getMyProfile();
  Future<Either<Failure, ProfileModel>> updateProfile(ProfileModel profile);
}
