import 'package:dartz/dartz.dart';
import '../models/task_model.dart';
import '../models/task_voice.dart';
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

  Future<Either<Failure, TaskVoiceUpload>> createVoiceUploadUrl({
    required String childId,
    required String taskId,
    required String extension,
  });

  Future<Either<Failure, void>> uploadVoiceBytes({
    required TaskVoiceUpload upload,
    required List<int> bytes,
    required String mime,
  });

  Future<Either<Failure, TaskModel>> attachVoiceInstruction({
    required String taskId,
    required String objectKey,
    required int durationMs,
    required String mime,
  });

  Future<Either<Failure, TaskModel>> removeVoiceInstruction(String taskId);
}
