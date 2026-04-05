import 'package:dartz/dartz.dart';
import '../models/task_model.dart';
import '../repositories/i_task_repository.dart';
import '../../../../core/error/failures.dart';

class TaskController {
  final ITaskRepository _repository;

  TaskController(this._repository);

  Future<Either<Failure, List<TaskTemplateModel>>> getTaskTemplates() => _repository.getTaskTemplates();
  Future<Either<Failure, List<TaskInstanceModel>>> getChildTasks(String childId) => _repository.getChildTasks(childId);
  Future<Either<Failure, TaskInstanceModel>> submitTask(String instanceId, String proofUrl) => _repository.submitTask(instanceId, proofUrl);
  Future<Either<Failure, TaskInstanceModel>> reviewTask(String instanceId, String status, String? parentNote) => _repository.reviewTask(instanceId, status, parentNote);
}
