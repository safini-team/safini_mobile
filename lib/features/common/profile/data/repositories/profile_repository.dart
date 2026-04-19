import 'package:dartz/dartz.dart';
import 'package:safini/core/error/exceptions.dart';
import 'package:safini/core/utils/error/failures.dart';
import 'package:safini/features/common/profile/data/datasources/local/profile_local_datasource.dart';
import 'package:safini/features/common/profile/data/datasources/remote/profile_remote_datasource.dart';
import 'package:safini/features/common/profile/domain/models/profile_model.dart';

class ProfileRepository {
  final ProfileRemoteDataSource _remote;
  final ProfileLocalDataSource _local;

  ProfileRepository(this._remote, this._local);

  Future<Either<Failure, ProfileModel>> fetchMe() async {
    try {
      final model = await _remote.fetchMe();
      await _local.cache(model);
      return Right(model);
    } on ServerException catch (e) {
      final cached = _local.getCached();
      if (cached != null) return Right(cached);
      return Left(ServerFailure(e.message));
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    }
  }
}