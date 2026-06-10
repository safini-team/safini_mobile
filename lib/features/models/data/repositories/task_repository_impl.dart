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
    return const Left(ServerFailure('Not implemented'));
  }

  @override
  Future<Either<Failure, TaskTemplateModel>> createTaskTemplate(
    String childId,
    TaskTemplateCreateRequestDto request,
  ) async {
    try {
      final response = await _dio.post(
        ApiConst.childTaskTemplates(childId),
        data: request.toJson(),
      );
      final raw = response.data;
      final map = raw is Map<String, dynamic>
          ? raw
          : (raw as Map).map((k, v) => MapEntry(k.toString(), v));
      return Right(TaskTemplateDto.fromJson(map).toDomain());
    } on DioException catch (e) {
      final status = e.response?.statusCode;
      if (status == 401) {
        return const Left(
          UnauthorizedFailure('Missing, expired, or invalid token.'),
        );
      }
      if (status == 403) {
        return const Left(
          ServerFailure('Access to this child is not allowed.'),
        );
      }
      if (status == 404) {
        return const Left(NotFoundFailure('Child not found.'));
      }
      if (status == 422) {
        final body = e.response?.data;
        final fieldErrors = _extractFieldErrors(body);
        return Left(
          FieldValidationFailure(
            _extractErrorMessage(
              body,
              defaultMessage: 'Please check the form fields.',
            ),
            fieldErrors,
          ),
        );
      }
      if (status == 503) {
        return const Left(
          ServerFailure('Service unavailable. Please try again later.'),
        );
      }
      return Left(
        ServerFailure(e.message ?? 'Unable to create task template.'),
      );
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
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
