import 'dart:convert';
import 'dart:io';

import 'package:dartz/dartz.dart';
import 'package:http/http.dart' as http;
import 'package:safini/core/config/supabase_config.dart';
import 'package:safini/core/network/authenticated_http_client.dart';
import 'package:safini/core/utils/constants/app_constants.dart';
import 'package:safini/core/utils/error/failures.dart';
import 'package:safini/features/parent/domain/models/catalog_app_model.dart';
import 'package:safini/features/parent/domain/models/child_app_usage_model.dart';
import 'package:safini/features/parent/domain/models/screen_time_model.dart';
import 'package:safini/features/parent/domain/repositories/i_parent_app_usage_repository.dart';

class ParentAppUsageRepositoryImpl implements IParentAppUsageRepository {
  final AuthenticatedHttpClient _client;

  ParentAppUsageRepositoryImpl(this._client);

  @override
  Future<Either<Failure, List<CatalogAppModel>>> fetchCatalog() async {
    late final http.Response response;
    try {
      response = await _client
          .get(_uri('/v1/apps'), headers: {'Accept': 'application/json'})
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

    if (response.statusCode < 200 || response.statusCode >= 300) {
      return Left(
        ServerFailure(
          _extractErrorMessage(
            response.body,
            'Unable to load the app list. Please try again.',
          ),
        ),
      );
    }

    final decoded = _decodeBody(response.body);
    if (decoded is Map<String, dynamic> && decoded['apps'] is List) {
      return Right(
        (decoded['apps'] as List)
            .whereType<Map>()
            .map(
              (e) => CatalogAppModel.fromJson(
                e.map((k, v) => MapEntry(k.toString(), v)),
              ),
            )
            .where((app) => app.appSlug.isNotEmpty)
            .toList(),
      );
    }

    return const Left(ServerFailure('Unexpected app catalog response format.'));
  }

  @override
  Future<Either<Failure, ChildAppUsageSnapshot>> fetchAppUsage(
    String childId,
  ) async {
    late final http.Response response;
    try {
      response = await _client
          .get(
            _uri('/v1/children/$childId/app-usage'),
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

    if (response.statusCode < 200 || response.statusCode >= 300) {
      return Left(
        ServerFailure(
          _extractErrorMessage(
            response.body,
            'Unable to load app usage. Please try again.',
          ),
        ),
      );
    }

    final decoded = _decodeBody(response.body);
    if (decoded is Map<String, dynamic>) {
      final rawScreenTime = decoded['screen_time'];
      final screenTime = rawScreenTime is Map
          ? ScreenTimeModel.fromJson(
              rawScreenTime.map((k, v) => MapEntry(k.toString(), v)),
            )
          : ScreenTimeModel.none;
      final apps = decoded['apps'];
      if (apps is List) {
        final list = apps
            .whereType<Map>()
            .map(
              (e) => ChildAppUsageModel.fromJson(
                e.map((k, v) => MapEntry(k.toString(), v)),
              ),
            )
            .toList();
        return Right(ChildAppUsageSnapshot(apps: list, screenTime: screenTime));
      }
      // Response shape is valid but has no apps — treat as empty.
      return Right(
        ChildAppUsageSnapshot(apps: const [], screenTime: screenTime),
      );
    }

    return const Left(ServerFailure('Unexpected app usage response format.'));
  }

  @override
  Future<Either<Failure, Unit>> updateAppRule(
    String childId,
    ChildAppUsageModel rule,
  ) async {
    late final http.Response response;
    try {
      response = await _client
          .put(
            _uri('/v1/children/$childId/app-rules/${rule.appSlug}'),
            headers: {
              'Accept': 'application/json',
              'Content-Type': 'application/json',
            },
            body: jsonEncode(rule.toRuleJson()),
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
          _extractErrorMessage(response.body, 'Invalid app rule request.'),
        ),
      );
    }

    if (response.statusCode < 200 || response.statusCode >= 300) {
      return Left(
        ServerFailure(
          _extractErrorMessage(
            response.body,
            'Unable to update app rule. Please try again.',
          ),
        ),
      );
    }

    return const Right(unit);
  }

  @override
  Future<String?> fetchChildFaceEmoji(String childId) async {
    try {
      final response = await _client
          .get(
            _uri('/v1/children/$childId/dashboard'),
            headers: {'Accept': 'application/json'},
          )
          .timeout(AppConstants.apiTimeout);
      if (response.statusCode < 200 || response.statusCode >= 300) return null;
      final decoded = _decodeBody(response.body);
      if (decoded is! Map) return null;
      final child = decoded['child'];
      final avatarState = child is Map ? child['avatar_state'] : null;
      final emojis = avatarState is Map ? avatarState['emojis'] : null;
      final face = emojis is Map ? emojis['face'] : null;
      final value = face?.toString().trim();
      return (value == null || value.isEmpty) ? null : value;
    } catch (_) {
      return null;
    }
  }

  Uri _uri(String path) => Uri.parse('${SupabaseConfig.apiBaseUrl}$path');

  dynamic _decodeBody(String body) {
    if (body.trim().isEmpty) return null;
    try {
      return jsonDecode(body);
    } catch (_) {
      return null;
    }
  }

  String _extractErrorMessage(String body, String fallback) {
    final decoded = _decodeBody(body);
    if (decoded is Map<String, dynamic>) {
      final candidate =
          decoded['message'] ?? decoded['detail'] ?? decoded['error'];
      if (candidate is String && candidate.trim().isNotEmpty) {
        return candidate.trim();
      }
    }
    return fallback;
  }
}
