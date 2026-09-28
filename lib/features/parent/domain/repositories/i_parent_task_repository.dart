import 'package:dartz/dartz.dart';
import 'package:safini/core/utils/error/failures.dart';
import 'package:safini/features/parent/domain/models/parent_tasks_response_model.dart';

abstract class IParentTaskRepository {
  Future<Either<Failure, ParentTasksResponseModel>> fetchTasks(String childId);

  /// One task, with its proof photo signed whatever its status. The list only
  /// signs photos still waiting for review.
  Future<Either<Failure, ParentTaskInstanceModel>> fetchTask(String taskId);

  Future<Either<Failure, void>> reviewTask(
    String taskId, {
    required String decision,
    String? note,
  });
}
