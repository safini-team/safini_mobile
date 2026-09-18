import 'package:dartz/dartz.dart';
import '../models/task_model.dart';
import '../repositories/i_task_repository.dart';
import '../../../../core/utils/error/failures.dart';
import '../../data/dto/task_dto.dart';

class TaskController {
  final ITaskRepository _repository;

  TaskController(this._repository);

  Future<Either<Failure, TaskInstanceModel>> reviewTask(
    String instanceId,
    String status,
    String? parentNote,
  ) => _repository.reviewTask(instanceId, status, parentNote);

  Future<Either<Failure, TaskModel>> createTask(
    String childId,
    TaskCreateRequestDto request,
  ) => _repository.createTask(childId, request);

  Future<Either<Failure, TaskModel>> updateTask(
    String taskId,
    TaskUpdateRequestDto request,
  ) => _repository.updateTask(taskId, request);

  Future<Either<Failure, bool>> deleteTask(String taskId) =>
      _repository.deleteTask(taskId);
}
