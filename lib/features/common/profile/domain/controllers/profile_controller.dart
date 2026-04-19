import 'package:dartz/dartz.dart';
import 'package:safini/core/utils/error/failures.dart';
import 'package:safini/features/common/profile/data/repositories/profile_repository.dart';
import 'package:safini/features/common/profile/domain/models/profile_model.dart';

class ProfileController {
  final ProfileRepository _repository;

  ProfileController(this._repository);

  Future<Either<Failure, ProfileModel>> fetchMe() => _repository.fetchMe();
}