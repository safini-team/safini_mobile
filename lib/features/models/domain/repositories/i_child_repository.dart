import 'package:dartz/dartz.dart';
import '../models/child_model.dart';
import '../../../../core/utils/error/failures.dart';

abstract class IChildRepository {
  Future<Either<Failure, ChildModel>> claimChild(String inviteCode);
}
