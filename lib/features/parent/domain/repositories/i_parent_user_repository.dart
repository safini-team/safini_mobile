import 'package:dartz/dartz.dart';
import '../models/parent_user_model.dart';
import '../../../../core/error/failures.dart';

abstract class IParentUserRepository {
  Future<Either<Failure, ParentUserModel>> getParentProfile(String userId);
}
