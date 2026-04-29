import 'package:dartz/dartz.dart';
import 'package:safini/core/utils/error/failures.dart';
import 'package:safini/features/child/domain/models/child_model.dart';
import 'package:safini/features/child/domain/repositories/i_child_repository.dart';

class ChildController {
  final IChildRepository _repository;

  ChildController(this._repository);

  Future<Either<Failure, List<ChildModel>>> fetchChildren() =>
      _repository.fetchChildren();
}
