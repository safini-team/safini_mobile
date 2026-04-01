import 'package:dartz/dartz.dart';
import '../models/family_model.dart';
import '../../../../core/error/failures.dart';

abstract class IFamilyRepository {
  Future<Either<Failure, FamilyModel>> createFamily(String name, String timezone);
  Future<Either<Failure, FamilyModel>> getCurrentFamily();
}
