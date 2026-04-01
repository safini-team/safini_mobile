import 'package:injectable/injectable.dart';
import 'package:dartz/dartz.dart';
import '../../domain/models/family_model.dart';
import '../../domain/repositories/i_family_repository.dart';
import '../../../../core/error/failures.dart';

@Injectable(as: IFamilyRepository)
class FamilyRepositoryImpl implements IFamilyRepository {
  @override
  Future<Either<Failure, FamilyModel>> createFamily(String name, String timezone) async {
    return const Left(ServerFailure('Not implemented'));
  }

  @override
  Future<Either<Failure, FamilyModel>> getCurrentFamily() async {
    return const Left(ServerFailure('Not implemented'));
  }
}
