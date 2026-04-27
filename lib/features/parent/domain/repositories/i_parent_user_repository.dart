import 'package:dartz/dartz.dart';
import 'package:safini/core/utils/error/failures.dart';
import '../models/parent_user_model.dart';

abstract class IParentUserRepository {
  Future<Either<Failure, ParentUserModel>> getParentProfile(String userId);
}
