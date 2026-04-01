import 'package:dartz/dartz.dart';
import '../models/family_model.dart';
import '../repositories/i_family_repository.dart';
import '../../../../core/error/failures.dart';

class FamilyController {
  final IFamilyRepository _repository;

  FamilyController(this._repository);

  Future<Either<Failure, FamilyModel>> createFamily(String name, String timezone) => _repository.createFamily(name, timezone);
  Future<Either<Failure, FamilyModel>> getCurrentFamily() => _repository.getCurrentFamily();
}
