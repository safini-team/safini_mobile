import 'dart:convert';
import 'dart:io';

import 'package:dartz/dartz.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:injectable/injectable.dart';
import 'package:safini/core/config/supabase_config.dart';
import 'package:safini/core/utils/constants/app_constants.dart';
import 'package:safini/core/utils/error/failures.dart';
import 'package:safini/features/models/domain/models/family_model.dart';
import 'package:safini/features/models/domain/repositories/i_family_repository.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

@Injectable(as: IFamilyRepository)
class FamilyRepositoryImpl implements IFamilyRepository {
  final http.Client _client = http.Client();

  @override
  Future<Either<Failure, FamilyModel>> createFamily(
    String name,
    String timezone,
  ) {
    return _postFamily(
      '/v1/families',
      payload: {'name': name, 'timezone': timezone},
      fallbackName: name,
      fallbackTimezone: timezone,
    );
  }

  @override
  Future<Either<Failure, FamilyModel>> joinFamily(String inviteCode) {
    return _postFamily(
      '/v1/families/join',
      payload: {
        'invite_code': inviteCode,
        'code': inviteCode,
      },
      fallbackName: 'Family',
      fallbackTimezone: 'UTC',
    );
  }

  @override
  Future<Either<Failure, FamilyModel>> getCurrentFamily() {
    return _fetchFamily('/v1/families/current');
  }

  Future<Either<Failure, FamilyModel>> _postFamily(
    String path, {
    required Map<String, dynamic> payload,
    required String fallbackName,
    required String fallbackTimezone,
  }) async {
    final response = await _request(
      () => _client.post(
        _uri(path),
        headers: _headers(),
        body: jsonEncode(payload),
      ),
    );

    return response.fold(
      (failure) => Left(failure),
      (body) => Right(
        _parseFamilyResponse(
          body,
          fallbackName: fallbackName,
          fallbackTimezone: fallbackTimezone,
        ),
      ),
    );
  }

  Future<Either<Failure, FamilyModel>> _fetchFamily(String path) async {
    final response = await _request(
      () => _client.get(
        _uri(path),
        headers: _headers(),
      ),
      treat404AsEmpty: true,
    );

    return response.fold(
      (failure) => Left(failure),
      (body) => Right(
        _parseFamilyResponse(
          body,
          fallbackName: 'Family',
          fallbackTimezone: 'UTC',
        ),
      ),
    );
  }

  Future<Either<Failure, Map<String, dynamic>>> _request(
    Future<http.Response> Function() request, {
    bool treat404AsEmpty = false,
  }) async {
    final session = Supabase.instance.client.auth.currentSession;
    final token = session?.accessToken;
    if (token == null || token.isEmpty) {
      return const Left(
        UnauthorizedFailure('Your session expired. Please sign in again.'),
      );
    }

    late final http.Response response;
    try {
      response = await request().timeout(AppConstants.apiTimeout);
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
        UnauthorizedFailure('Your session expired. Please sign in again.'),
      );
    }

    if (treat404AsEmpty && response.statusCode == 404) {
      return const Left(NotFoundFailure('No family has been created yet.'));
    }

    if (response.statusCode < 200 || response.statusCode >= 300) {
      final message = _extractErrorMessage(
        response.body,
        defaultMessage: 'Something went wrong. Please try again.',
      );
      if (response.statusCode == 400 ||
          response.statusCode == 404 ||
          response.statusCode == 409 ||
          response.statusCode == 422) {
        return Left(ValidationFailure(message));
      }
      return Left(ServerFailure(message));
    }

    final decoded = _decodeBody(response.body);
    if (decoded is Map<String, dynamic>) {
      return Right(decoded);
    }

    return Right(<String, dynamic>{});
  }

  Uri _uri(String path) {
    return Uri.parse('${SupabaseConfig.apiBaseUrl}$path');
  }

  Map<String, String> _headers() {
    final token = Supabase.instance.client.auth.currentSession?.accessToken;
    return {
      'Authorization': 'Bearer $token',
      'Accept': 'application/json',
      'Content-Type': 'application/json',
    };
  }

  dynamic _decodeBody(String body) {
    if (body.trim().isEmpty) {
      return null;
    }
    try {
      return jsonDecode(body);
    } catch (e) {
      debugPrint('Family API JSON parse error: $e');
      return null;
    }
  }

  String _extractErrorMessage(String body, {required String defaultMessage}) {
    final decoded = _decodeBody(body);
    if (decoded is Map<String, dynamic>) {
      final candidates = [
        decoded['message'],
        decoded['error'],
        decoded['detail'],
      ];
      for (final candidate in candidates) {
        if (candidate is String && candidate.trim().isNotEmpty) {
          return candidate.trim();
        }
      }
    }
    return defaultMessage;
  }

  FamilyModel _parseFamilyResponse(
    Map<String, dynamic> json, {
    required String fallbackName,
    required String fallbackTimezone,
  }) {
    final familyJson = _extractFamilyJson(json);
    if (familyJson == null) {
      return FamilyModel(
        id: json['id']?.toString() ?? '',
        ownerUserId: json['ownerUserId']?.toString() ?? '',
        name: json['name']?.toString() ?? fallbackName,
        timezone: json['timezone']?.toString() ?? fallbackTimezone,
        children: const [],
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
    }

    try {
      return FamilyModel.fromJson(familyJson);
    } catch (e) {
      debugPrint('Family parse fallback used: $e');
      return FamilyModel(
        id: familyJson['id']?.toString() ?? '',
        ownerUserId: familyJson['ownerUserId']?.toString() ?? '',
        name: familyJson['name']?.toString() ?? fallbackName,
        timezone: familyJson['timezone']?.toString() ?? fallbackTimezone,
        children: const [],
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
    }
  }

  Map<String, dynamic>? _extractFamilyJson(Map<String, dynamic> json) {
    final candidates = [json['family'], json['data'], json['result'], json];
    for (final candidate in candidates) {
      if (candidate is Map<String, dynamic>) {
        return candidate;
      }
      if (candidate is Map) {
        return candidate.map((key, value) => MapEntry(key.toString(), value));
      }
    }
    return null;
  }
}
