import 'dart:convert';
import 'dart:io';

import 'package:dartz/dartz.dart';
import 'package:http/http.dart' as http;
import 'package:safini/core/config/supabase_config.dart';
import 'package:safini/core/network/authenticated_http_client.dart';
import 'package:safini/core/utils/constants/app_constants.dart';
import 'package:safini/core/utils/error/failures.dart';
import 'package:safini/features/parent/domain/models/parent_tasks_response_model.dart';
import 'package:safini/features/parent/domain/repositories/i_parent_task_repository.dart';

class ParentTaskRepositoryImpl implements IParentTaskRepository {
  final AuthenticatedHttpClient _client;

  ParentTaskRepositoryImpl(this._client);

  @override
  Future<Either<Failure, ParentTasksResponseModel>> fetchTasks(
    String childId,
  ) async {
    late final http.Response response;
    try {
      response = await _client
          .get(
            _uri('/v1/children/$childId/tasks'),
            headers: {'Accept': 'application/json'},
          )
          .timeout(AppConstants.apiTimeout);
    } on AuthSessionUnavailableException {
      return const Left(UnauthorizedFailure('Session is unavailable.'));
    } on SocketException catch (e) {
      return Left(NetworkFailure(e.message));
    } on HttpException catch (e) {
      return Left(NetworkFailure(e.message));
    } on http.ClientException catch (e) {
      return Left(NetworkFailure(e.message));
    } catch (e) {
      return Left(NetworkFailure(e.toString()));
    }

    if (response.statusCode == 401) {
      return const Left(
        UnauthorizedFailure('Missing, expired, or invalid token.'),
      );
    }

    if (response.statusCode == 422) {
      return Left(
        ValidationFailure(
          _extractErrorMessage(
            response.body,
            defaultMessage: 'Invalid child or task request.',
          ),
        ),
      );
    }

    if (response.statusCode == 503) {
      return const Left(
        ServerFailure('Service unavailable. Please try again later.'),
      );
    }

    if (response.statusCode < 200 || response.statusCode >= 300) {
      return Left(
        ServerFailure(
          _extractErrorMessage(
            response.body,
            defaultMessage: 'Unable to load tasks. Please try again.',
          ),
        ),
      );
    }

    final decoded = _decodeBody(response.body);
    if (decoded is Map<String, dynamic>) {
      return Right(ParentTasksResponseModel.fromJson(decoded));
    }
    if (decoded is Map) {
      return Right(
        ParentTasksResponseModel.fromJson(
          decoded.map((key, value) => MapEntry(key.toString(), value)),
        ),
      );
    }

    return const Left(ServerFailure('Unexpected tasks response format.'));
  }

  @override
  Future<Either<Failure, void>> reviewTask(
    String taskId, {
    required String decision,
    String? note,
  }) async {
    final body = <String, dynamic>{'decision': decision};
    if (note != null && note.trim().isNotEmpty) body['note'] = note.trim();

    late final http.Response response;
    try {
      response = await _client
          .post(
            _uri('/v1/tasks/$taskId/review'),
            headers: {
              'Accept': 'application/json',
              'Content-Type': 'application/json',
            },
            body: jsonEncode(body),
          )
          .timeout(AppConstants.apiTimeout);
    } on AuthSessionUnavailableException {
      return const Left(UnauthorizedFailure('Session is unavailable.'));
    } on SocketException catch (e) {
      return Left(NetworkFailure(e.message));
    } on HttpException catch (e) {
      return Left(NetworkFailure(e.message));
    } on http.ClientException catch (e) {
      return Left(NetworkFailure(e.message));
    } catch (e) {
      return Left(NetworkFailure(e.toString()));
    }

    if (response.statusCode == 401) {
      return const Left(
        UnauthorizedFailure('Missing, expired, or invalid token.'),
      );
    }

    if (response.statusCode == 403) {
      return Left(
        ServerFailure(
          _extractErrorMessage(
            response.body,
            defaultMessage: 'Access to this resource is not allowed.',
          ),
        ),
      );
    }

    if (response.statusCode == 404) {
      return Left(
        ServerFailure(
          _extractErrorMessage(
            response.body,
            defaultMessage: 'Task not found.',
          ),
        ),
      );
    }

    if (response.statusCode == 409) {
      return Left(
        ConflictFailure(
          _extractErrorMessage(
            response.body,
            defaultMessage: 'This task can no longer be reviewed.',
          ),
        ),
      );
    }

    if (response.statusCode == 422) {
      return Left(
        ValidationFailure(
          _extractErrorMessage(
            response.body,
            defaultMessage: 'Invalid review request.',
          ),
        ),
      );
    }

    if (response.statusCode == 503) {
      return const Left(
        ServerFailure('Service unavailable. Please try again later.'),
      );
    }

    if (response.statusCode < 200 || response.statusCode >= 300) {
      return Left(
        ServerFailure(
          _extractErrorMessage(
            response.body,
            defaultMessage: 'Unable to review task. Please try again.',
          ),
        ),
      );
    }

    return const Right(null);
  }

  Uri _uri(String path) {
    return Uri.parse('${SupabaseConfig.apiBaseUrl}$path');
  }

  dynamic _decodeBody(String body) {
    if (body.trim().isEmpty) return null;
    try {
      return jsonDecode(body);
    } catch (_) {
      return null;
    }
  }

  String _extractErrorMessage(String body, {required String defaultMessage}) {
    final decoded = _decodeBody(body);
    if (decoded is Map<String, dynamic>) {
      for (final key in ['message', 'error', 'detail']) {
        final value = decoded[key];
        if (value is String && value.trim().isNotEmpty) {
          return value.trim();
        }
      }
    }
    return defaultMessage;
  }
}
