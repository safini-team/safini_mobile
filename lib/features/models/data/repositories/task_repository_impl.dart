import 'package:injectable/injectable.dart';
import 'package:dartz/dartz.dart';
import '../../domain/models/task_model.dart';
import '../../domain/repositories/i_task_repository.dart';
import '../../../../core/error/failures.dart';

@Injectable(as: ITaskRepository)
class TaskRepositoryImpl implements ITaskRepository {
  @override
  Future<Either<Failure, List<TaskTemplateModel>>> getTaskTemplates() async {
    return const Left(ServerFailure('Not implemented'));
  }

  @override
  Future<Either<Failure, List<TaskInstanceModel>>> getChildTasks(String childId) async {
    return const Left(ServerFailure('Not implemented'));
  }

  @override
  Future<Either<Failure, TaskInstanceModel>> submitTask(String instanceId, String proofUrl) async {
    return const Left(ServerFailure('Not implemented'));
  }

  @override
  Future<Either<Failure, TaskInstanceModel>> reviewTask(String instanceId, String status, String? parentNote) async {
    return const Left(ServerFailure('Not implemented'));
  }
}
