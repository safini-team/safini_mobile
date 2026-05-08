import 'package:dartz/dartz.dart';
import 'package:safini/core/utils/error/failures.dart';
import 'package:safini/features/child/domain/models/child_model.dart';

abstract class IChildRepository {
  Future<Either<Failure, List<ChildModel>>> fetchChildren();
  Future<Either<Failure, ChildModel>> fetchChild(String childId);
  Future<Either<Failure, ChildModel>> fetchChildDashboard(String childId);
}
