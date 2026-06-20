import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import 'package:dartz/dartz.dart';
import '../../domain/models/task_model.dart';
import '../../domain/repositories/i_task_repository.dart';
import '../../../../core/utils/error/failures.dart';
import '../../../../core/utils/constants/api_const.dart';
import '../dto/task_dto.dart';

@Injectable(as: ITaskRepository)
class TaskRepositoryImpl implements ITaskRepository {
  final Dio _dio;

  TaskRepositoryImpl(this._dio);

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
