import 'package:dio/dio.dart';

import 'package:safini/core/utils/error/failures.dart';

/// Translates a [DioException] into a domain [Failure] so data-layer services
/// can return `Either<Failure, T>` consistently across the app.
///
/// [fallback] is used as the message when the backend does not supply a
/// human-readable `detail` / `message` / `error` field.
Failure mapDioError(DioException e, String fallback) {
  final status = e.response?.statusCode;
  final message = _extractMessage(e.response?.data) ?? e.message ?? fallback;

  switch (status) {
    case 401:
      return const UnauthorizedFailure('Missing, expired, or invalid token.');
    case 404:
      return NotFoundFailure(message);
    case 409:
      return ConflictFailure(message);
    case 422:
      return ValidationFailure(message);
  }

  // No response at all → treat as a connectivity problem.
  switch (e.type) {
    case DioExceptionType.connectionTimeout:
    case DioExceptionType.sendTimeout:
    case DioExceptionType.receiveTimeout:
    case DioExceptionType.connectionError:
      return NetworkFailure(e.message ?? 'Network error. Please try again.');
    default:
      return ServerFailure(status == null ? (e.message ?? fallback) : message);
  }
}

String? _extractMessage(dynamic data) {
  if (data is Map) {
    final candidate = data['detail'] ?? data['message'] ?? data['error'];
    if (candidate is String && candidate.trim().isNotEmpty) {
      return candidate.trim();
    }
  }
  return null;
}
