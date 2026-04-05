import 'package:dartz/dartz.dart';
import '../models/profile_model.dart';
import '../repositories/i_profile_repository.dart';
import '../../../../core/error/failures.dart';

class ProfileController {
  final IProfileRepository _repository;

  ProfileController(this._repository);

  Future<Either<Failure, ProfileModel>> getMyProfile() => _repository.getMyProfile();
  Future<Either<Failure, ProfileModel>> updateProfile(ProfileModel profile) => _repository.updateProfile(profile);
}
