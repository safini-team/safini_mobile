import 'package:dartz/dartz.dart';
import 'package:flutter/foundation.dart';
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
    debugPrint('[ProfileRepository] fetchMe called');
    try {
      final model = await _remote.fetchMe();
      await _local.cache(model);
      debugPrint('[ProfileRepository] Remote success — cached profile');
      return Right(model);
    } on ServerException catch (e) {
      debugPrint('[ProfileRepository] ServerException: ${e.message} — trying cache');
      final cached = _local.getCached();
      if (cached != null) {
        debugPrint('[ProfileRepository] Returning cached profile');
        return Right(cached);
      }
      debugPrint('[ProfileRepository] No cache available — returning failure');
      return Left(ServerFailure(e.message));
    } on CacheException catch (e) {
      debugPrint('[ProfileRepository] CacheException: ${e.message}');
      return Left(CacheFailure(e.message));
    }
  }
}