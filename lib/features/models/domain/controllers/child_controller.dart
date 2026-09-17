import 'package:dartz/dartz.dart';
import '../models/child_model.dart';
import '../repositories/i_child_repository.dart';
import '../../../../core/utils/error/failures.dart';

class ChildController {
  final IChildRepository _repository;

  ChildController(this._repository);

  Future<Either<Failure, ChildModel>> claimChild(String inviteCode) =>
      _repository.claimChild(inviteCode);
}
