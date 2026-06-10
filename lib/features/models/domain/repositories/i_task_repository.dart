import 'package:dartz/dartz.dart';
import '../models/task_model.dart';
import '../../../../core/utils/error/failures.dart';
import '../../data/dto/task_dto.dart';

abstract class ITaskRepository {
  Future<Either<Failure, List<TaskTemplateModel>>> getTaskTemplates();
  Future<Either<Failure, List<TaskInstanceModel>>> getChildTasks(
    String childId,
  );
  Future<Either<Failure, TaskInstanceModel>> submitTask(
    String instanceId,
    String proofUrl,
  );
  Future<Either<Failure, TaskInstanceModel>> reviewTask(
    String instanceId,
    String status,
    String? parentNote,
  );
  Future<Either<Failure, TaskModel>> createTask(
    String childId,
    TaskCreateRequestDto request,
  );
  Future<Either<Failure, TaskModel>> updateTask(
    String taskId,
    TaskUpdateRequestDto request,
  );
  Future<Either<Failure, bool>> deleteTask(String taskId);
}
