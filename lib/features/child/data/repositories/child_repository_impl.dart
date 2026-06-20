import 'package:dartz/dartz.dart';
import 'package:flutter/foundation.dart';
import 'package:safini/core/error/exceptions.dart';
import 'package:safini/core/utils/error/failures.dart';
import 'package:safini/features/child/data/datasources/child_remote_datasource.dart';
import 'package:safini/features/child/domain/models/child_home_response.dart';
import 'package:safini/features/child/domain/models/child_model.dart';
import 'package:safini/features/child/domain/models/child_today_response.dart';
import 'package:safini/features/child/domain/repositories/i_child_repository.dart';

class ChildRepositoryImpl implements IChildRepository {
  final ChildRemoteDataSource _remote;

  ChildRepositoryImpl(this._remote);

  @override
  Future<Either<Failure, List<ChildModel>>> fetchChildren() async {
    debugPrint('[ChildRepositoryImpl] fetchChildren called');
    try {
      final children = await _remote.fetchChildren();
      debugPrint('[ChildRepositoryImpl] Fetched ${children.length} children');
      return Right(children);
    } on ServerException catch (e) {
      debugPrint('[ChildRepositoryImpl] ServerException: ${e.message}');
      return Left(ServerFailure(e.message));
    } catch (e) {
      debugPrint('[ChildRepositoryImpl] Unexpected error: $e');
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, ChildModel>> fetchChild(String childId) async {
    debugPrint('[ChildRepositoryImpl] fetchChild called for $childId');
    try {
      final child = await _remote.fetchChild(childId);
      return Right(child);
    } on ServerException catch (e) {
      debugPrint('[ChildRepositoryImpl] ServerException: ${e.message}');
      return Left(ServerFailure(e.message));
    } catch (e) {
      debugPrint('[ChildRepositoryImpl] Unexpected error: $e');
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, ChildModel>> fetchChildDashboard(
    String childId,
  ) async {
    debugPrint('[ChildRepositoryImpl] fetchChildDashboard called for $childId');
    try {
      final child = await _remote.fetchChildDashboard(childId);
      return Right(child);
    } on ServerException catch (e) {
      debugPrint('[ChildRepositoryImpl] ServerException: ${e.message}');
      return Left(ServerFailure(e.message));
    } catch (e) {
      debugPrint('[ChildRepositoryImpl] Unexpected error: $e');
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, ChildHomeResponse>> fetchChildHome(
    String childId,
  ) async {
    debugPrint('[ChildRepositoryImpl] fetchChildHome called for $childId');
    try {
      final home = await _remote.fetchChildHome(childId);
      return Right(home);
    } on ServerException catch (e) {
      debugPrint('[ChildRepositoryImpl] ServerException: ${e.message}');
      return Left(ServerFailure(e.message));
    } catch (e) {
      debugPrint('[ChildRepositoryImpl] Unexpected error: $e');
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, ChildTodayResponse>> fetchChildToday(
    String childId, {
    String? date,
  }) async {
    debugPrint('[ChildRepositoryImpl] fetchChildToday called for $childId');
    try {
      final today = await _remote.fetchChildToday(childId, date: date);
      return Right(today);
    } on ServerException catch (e) {
      debugPrint('[ChildRepositoryImpl] ServerException: ${e.message}');
      return Left(ServerFailure(e.message));
    } catch (e) {
      debugPrint('[ChildRepositoryImpl] Unexpected error: $e');
      return Left(ServerFailure(e.toString()));
    }
  }
}
