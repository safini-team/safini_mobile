import 'package:dio/dio.dart';
import 'package:http/http.dart' as http;
import 'package:injectable/injectable.dart';
import 'package:dartz/dartz.dart';
import '../../domain/models/task_model.dart';
import '../../domain/models/task_voice.dart';
import '../../domain/repositories/i_task_repository.dart';
import '../../../../core/utils/error/failures.dart';
import '../../../../core/utils/constants/api_const.dart';
import '../dto/task_dto.dart';

@Injectable(as: ITaskRepository)
class TaskRepositoryImpl implements ITaskRepository {
  final Dio _dio;

  /// Storage uploads go out on a bare client: the signed URL carries its own
  /// token, and dio would attach our API bearer to a request that is not
  /// going to our API.
  final http.Client _uploadClient;

  TaskRepositoryImpl(this._dio, {http.Client? uploadClient})
    : _uploadClient = uploadClient ?? http.Client();

  @override
  Future<Either<Failure, List<TaskTemplateModel>>> getTaskTemplates() async {
    return const Left(ServerFailure('Not implemented'));
  }

  @override
  Future<Either<Failure, List<TaskInstanceModel>>> getChildTasks(
    String childId,
  ) async {
    return const Left(ServerFailure('Not implemented'));
  }

  @override
  Future<Either<Failure, TaskInstanceModel>> submitTask(
    String instanceId,
    String proofUrl,
  ) async {
    return const Left(ServerFailure('Not implemented'));
  }

  @override
  Future<Either<Failure, TaskInstanceModel>> reviewTask(
    String instanceId,
    String status,
    String? parentNote,
  ) async {
    try {
      final body = <String, dynamic>{'decision': status};
      if (parentNote != null && parentNote.trim().isNotEmpty) {
        body['note'] = parentNote.trim();
      }
      final response = await _dio.post(ApiConst.reviewTask(instanceId), data: body);
      final raw = response.data is Map<String, dynamic>
          ? response.data as Map<String, dynamic>
          : (response.data as Map).map((k, v) => MapEntry(k.toString(), v));
      final taskRaw = raw['task'];
      final taskMap = taskRaw is Map<String, dynamic>
          ? taskRaw
          : (taskRaw as Map).map((k, v) => MapEntry(k.toString(), v));
      return Right(TaskInstanceModel(
        id: taskMap['id']?.toString() ?? instanceId,
        childId: '',
        templateId: '',
        status: taskMap['status']?.toString() ?? status,
        dueDate: DateTime.now(),
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ));
    } on DioException catch (e) {
      return Left(
        _mapDioError(
          e,
          defaultMessage: 'Unable to review task.',
          notFoundMessage: 'Task not found.',
          conflictMessage: 'This task can no longer be reviewed.',
        ),
      );
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, TaskModel>> createTask(
    String childId,
    TaskCreateRequestDto request,
  ) async {
    try {
      final response = await _dio.post(
        ApiConst.childTasks(childId),
        data: request.toJson(),
      );
      final raw = response.data;
      final map = raw is Map<String, dynamic>
          ? raw
          : (raw as Map).map((k, v) => MapEntry(k.toString(), v));
      return Right(TaskDto.fromJson(map).toDomain());
    } on DioException catch (e) {
      return Left(
        _mapDioError(
          e,
          defaultMessage: 'Unable to create task.',
          notFoundMessage: 'Child not found.',
        ),
      );
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, TaskModel>> updateTask(
    String taskId,
    TaskUpdateRequestDto request,
  ) async {
    try {
      final response = await _dio.patch(
        ApiConst.task(taskId),
        data: request.toJson(),
      );
      final raw = response.data;
      final map = raw is Map<String, dynamic>
          ? raw
          : (raw as Map).map((k, v) => MapEntry(k.toString(), v));
      return Right(TaskDto.fromJson(map).toDomain());
    } on DioException catch (e) {
      return Left(
        _mapDioError(
          e,
          defaultMessage: 'Unable to update task.',
          notFoundMessage: 'Task not found.',
          conflictMessage: 'Approved tasks can\'t be edited.',
        ),
      );
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, bool>> deleteTask(String taskId) async {
    try {
      final response = await _dio.delete(ApiConst.task(taskId));
      final raw = response.data;
      if (raw is Map && raw['deleted'] == false) {
        return const Right(false);
      }
      return const Right(true);
    } on DioException catch (e) {
      return Left(
        _mapDioError(
          e,
          defaultMessage: 'Unable to delete task.',
          notFoundMessage: 'Task not found.',
          conflictMessage: 'Approved tasks can\'t be deleted.',
        ),
      );
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, TaskVoiceUpload>> createVoiceUploadUrl({
    required String childId,
    required String taskId,
    required String extension,
  }) async {
    try {
      final response = await _dio.post(
        ApiConst.taskVoiceUploadUrl(childId),
        data: {'task_id': taskId, 'extension': extension},
      );
      final raw = response.data;
      if (raw is! Map) {
        return const Left(ServerFailure('Unexpected upload response.'));
      }
      final upload = TaskVoiceUpload.fromJson(
        raw.map((k, v) => MapEntry(k.toString(), v)),
      );
      if (!upload.isUsable) {
        return const Left(ServerFailure('Unexpected upload response.'));
      }
      return Right(upload);
    } on DioException catch (e) {
      return Left(
        _mapDioError(
          e,
          defaultMessage: 'Unable to prepare the voice upload.',
          notFoundMessage: 'Task not found.',
          conflictMessage: 'Voice instructions are not available yet.',
        ),
      );
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> uploadVoiceBytes({
    required TaskVoiceUpload upload,
    required List<int> bytes,
    required String mime,
  }) async {
    if (bytes.length > upload.maxBytes) {
      return const Left(ValidationFailure('That recording is too large.'));
    }

    late final http.Response response;
    try {
      response = await _uploadClient.put(
        Uri.parse(upload.uploadUrl),
        headers: {'Content-Type': mime},
        body: bytes,
      );
    } on http.ClientException catch (e) {
      return Left(NetworkFailure(e.message));
    } catch (e) {
      return Left(NetworkFailure(e.toString()));
    }

    if (response.statusCode < 200 || response.statusCode >= 300) {
      return const Left(ServerFailure('Could not upload the voice note.'));
    }
    return const Right(null);
  }

  @override
  Future<Either<Failure, TaskModel>> attachVoiceInstruction({
    required String taskId,
    required String objectKey,
    required int durationMs,
    required String mime,
  }) async {
    try {
      final response = await _dio.post(
        ApiConst.taskVoice(taskId),
        data: {
          'object_key': objectKey,
          'duration_ms': durationMs,
          'mime': mime,
        },
      );
      return Right(_taskFromResponse(response.data, taskId));
    } on DioException catch (e) {
      return Left(
        _mapDioError(
          e,
          defaultMessage: 'Unable to attach the voice note.',
          notFoundMessage: 'Task not found.',
          conflictMessage: 'Approved tasks can\'t be edited.',
        ),
      );
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, TaskModel>> removeVoiceInstruction(
    String taskId,
  ) async {
    try {
      final response = await _dio.delete(ApiConst.taskVoice(taskId));
      return Right(_taskFromResponse(response.data, taskId));
    } on DioException catch (e) {
      return Left(
        _mapDioError(
          e,
          defaultMessage: 'Unable to remove the voice note.',
          notFoundMessage: 'Task not found.',
          conflictMessage: 'Approved tasks can\'t be edited.',
        ),
      );
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  TaskModel _taskFromResponse(dynamic raw, String fallbackId) {
    if (raw is Map) {
      final map = raw is Map<String, dynamic>
          ? raw
          : raw.map((k, v) => MapEntry(k.toString(), v));
      return TaskDto.fromJson(map).toDomain();
    }
    return TaskModel(
      id: fallbackId,
      title: '',
      coinReward: 0,
      xpReward: 0,
    );
  }

  Failure _mapDioError(
    DioException e, {
    required String defaultMessage,
    required String notFoundMessage,
    String? conflictMessage,
  }) {
    final status = e.response?.statusCode;
    if (status == 401) {
      return const UnauthorizedFailure('Missing, expired, or invalid token.');
    }
    if (status == 403) {
      return const ServerFailure('Access to this resource is not allowed.');
    }
    if (status == 404) {
      return NotFoundFailure(notFoundMessage);
    }
    if (status == 409) {
      return ConflictFailure(
        _extractErrorMessage(
          e.response?.data,
          defaultMessage: conflictMessage ?? 'This task can no longer change.',
        ),
      );
    }
    if (status == 422) {
      final body = e.response?.data;
      return FieldValidationFailure(
        _extractErrorMessage(
          body,
          defaultMessage: 'Please check the form fields.',
        ),
        _extractFieldErrors(body),
      );
    }
    if (status == 503) {
      return const ServerFailure('Service unavailable. Please try again later.');
    }
    return ServerFailure(e.message ?? defaultMessage);
  }

  Map<String, String> _extractFieldErrors(dynamic body) {
    final out = <String, String>{};
    if (body is! Map) return out;
    final mapped = body is Map<String, dynamic>
        ? body
        : body.map((k, v) => MapEntry(k.toString(), v));
    final detail = mapped['detail'];
    if (detail is! List) return out;
    for (final item in detail) {
      if (item is! Map) continue;
      final entry = item is Map<String, dynamic>
          ? item
          : item.map((k, v) => MapEntry(k.toString(), v));
      final rawField =
          entry['field'] ?? entry['path'] ?? entry['loc'];
      final field = rawField
          ?.toString()
          .split('.')
          .last
          .split('/')
          .last
          .replaceAll('[', '')
          .replaceAll(']', '')
          .trim();
      final message =
          (entry['message'] ?? entry['msg'] ?? entry['error'])
              ?.toString()
              .trim();
      if (field != null &&
          field.isNotEmpty &&
          message != null &&
          message.isNotEmpty) {
        out[field] = message;
      }
    }
    return out;
  }

  String _extractErrorMessage(dynamic body, {required String defaultMessage}) {
    if (body is! Map) return defaultMessage;
    final mapped = body is Map<String, dynamic>
        ? body
        : body.map((k, v) => MapEntry(k.toString(), v));
    for (final key in ['message', 'error', 'detail']) {
      final value = mapped[key];
      if (value is String && value.trim().isNotEmpty) return value.trim();
    }
    return defaultMessage;
  }
}
