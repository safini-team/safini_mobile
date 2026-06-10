import 'package:dartz/dartz.dart';
import 'package:safini/core/utils/error/failures.dart';
import 'package:safini/features/parent/domain/models/parent_tasks_response_model.dart';

abstract class IParentTaskRepository {
  Future<Either<Failure, ParentTasksResponseModel>> fetchTasks(String childId);

  Future<Either<Failure, ParentTaskTemplateCreateResult>> createTaskTemplate(
    String childId,
    ParentTaskTemplateCreateRequest request,
  );
}
