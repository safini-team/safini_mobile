import 'dart:io';

import 'package:injectable/injectable.dart';
import 'package:dartz/dartz.dart';
import '../models/task_model.dart';
import '../models/task_voice.dart';
import '../repositories/i_task_repository.dart';
import '../../../../core/utils/error/failures.dart';
import '../../data/dto/task_dto.dart';

@lazySingleton
class TaskController {
  final ITaskRepository _repository;

  TaskController(this._repository);

  Future<Either<Failure, List<TaskTemplateModel>>> getTaskTemplates() =>
      _repository.getTaskTemplates();

  Future<Either<Failure, List<TaskInstanceModel>>> getChildTasks(
    String childId,
  ) => _repository.getChildTasks(childId);

  Future<Either<Failure, TaskInstanceModel>> submitTask(
    String instanceId,
    String proofUrl,
  ) => _repository.submitTask(instanceId, proofUrl);

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

  /// Create the task first, then this: sign a slot, PUT the bytes, attach.
  Future<Either<Failure, TaskModel>> attachVoiceFromFile({
    required String childId,
    required String taskId,
    required TaskVoiceDraft draft,
  }) async {
    if (!draft.isAttachable) {
      return const Left(
        ValidationFailure('That recording is too short or the wrong type.'),
      );
    }

    final slot = await _repository.createVoiceUploadUrl(
      childId: childId,
      taskId: taskId,
      extension: draft.extension,
    );
    return slot.fold((failure) => Left(failure), (upload) async {
      late final List<int> bytes;
      try {
        bytes = await File(draft.filePath).readAsBytes();
      } catch (e) {
        return Left(ServerFailure(e.toString()));
      }
      final put = await _repository.uploadVoiceBytes(
        upload: upload,
        bytes: bytes,
        mime: draft.mime,
      );
      return put.fold(
        (failure) => Left(failure),
        (_) => _repository.attachVoiceInstruction(
          taskId: taskId,
          objectKey: upload.objectKey,
          durationMs: draft.durationMs,
          mime: draft.mime,
        ),
      );
    });
  }

  Future<Either<Failure, TaskModel>> removeVoiceInstruction(String taskId) =>
      _repository.removeVoiceInstruction(taskId);
}
