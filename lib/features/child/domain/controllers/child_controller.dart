import 'package:dartz/dartz.dart';
import 'package:safini/core/utils/error/failures.dart';
import 'package:safini/features/child/domain/models/child_model.dart';
import 'package:safini/features/child/domain/repositories/i_child_repository.dart';

class ChildController {
  final IChildRepository _repository;

  ChildController(this._repository);

  Future<Either<Failure, List<ChildModel>>> fetchChildren() =>
      _repository.fetchChildren();

  Future<Either<Failure, ChildModel>> fetchChild(String childId) =>
      _repository.fetchChild(childId);

  Future<Either<Failure, ChildModel>> fetchChildDashboard(String childId) =>
      _repository.fetchChildDashboard(childId);
}
