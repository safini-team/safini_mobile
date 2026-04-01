import 'package:dartz/dartz.dart';
import '../models/task_model.dart';
import '../../../../core/error/failures.dart';

abstract class ITaskRepository {
  Future<Either<Failure, List<TaskTemplateModel>>> getTaskTemplates();
  Future<Either<Failure, List<TaskInstanceModel>>> getChildTasks(String childId);
  Future<Either<Failure, TaskInstanceModel>> submitTask(String instanceId, String proofUrl);
  Future<Either<Failure, TaskInstanceModel>> reviewTask(String instanceId, String status, String? parentNote);
}
