import 'package:dartz/dartz.dart';
import 'package:safini/core/utils/error/failures.dart';
import 'package:safini/features/child/domain/models/child_home_response.dart';
import 'package:safini/features/child/domain/models/child_model.dart';
import 'package:safini/features/child/domain/models/child_today_response.dart';

abstract class IChildRepository {
  Future<Either<Failure, List<ChildModel>>> fetchChildren();
  Future<Either<Failure, ChildModel>> fetchChild(String childId);
  Future<Either<Failure, ChildModel>> fetchChildDashboard(String childId);
  Future<Either<Failure, ChildHomeResponse>> fetchChildHome(String childId);
  Future<Either<Failure, ChildTodayResponse>> fetchChildToday(
    String childId, {
    String? date,
  });
  Future<Either<Failure, void>> submitTask(
    String taskId, {
    String? note,
    String? imageObjectKey,
  });

  /// Signs an upload slot, PUTs [filePath] to it, and returns the object key
  /// to send with the submission. One call: the signed URL is only valid for
  /// fifteen minutes, so there is no reason to hold one open.
  Future<Either<Failure, String>> uploadTaskProof({
    required String childId,
    required String taskId,
    required String filePath,
  });
}
