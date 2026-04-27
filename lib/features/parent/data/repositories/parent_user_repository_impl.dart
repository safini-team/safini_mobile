import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:safini/core/utils/error/failures.dart';
import 'package:safini/features/parent/data/datasources/parent_remote_datasource.dart';
import 'package:safini/features/parent/domain/models/parent_user_model.dart';
import 'package:safini/features/parent/domain/repositories/i_parent_user_repository.dart';

@Injectable(as: IParentUserRepository)
class ParentUserRepositoryImpl implements IParentUserRepository {
  final ParentRemoteDataSource _remoteDataSource;

  ParentUserRepositoryImpl(this._remoteDataSource);

  @override
  Future<Either<Failure, ParentUserModel>> getParentProfile(
    String userId,
  ) async {
    try {
      final user = await _remoteDataSource.getUser(userId);
      return Right(user);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
