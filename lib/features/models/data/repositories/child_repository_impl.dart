import 'dart:convert';
import 'dart:io';

import 'package:injectable/injectable.dart';
import 'package:dartz/dartz.dart';
import 'package:http/http.dart' as http;
import 'package:safini/core/config/supabase_config.dart';
import 'package:safini/core/network/authenticated_http_client.dart';
import 'package:safini/core/utils/constants/app_constants.dart';
import '../../domain/models/child_model.dart';
import '../../domain/repositories/i_child_repository.dart';
import '../../../../core/utils/error/failures.dart';

@Injectable(as: IChildRepository)
class ChildRepositoryImpl implements IChildRepository {
  ChildRepositoryImpl(this._client);

  final AuthenticatedHttpClient _client;

  @override
  Future<Either<Failure, ChildModel>> createChild(
    String nickname,
    int age,
    String gender,
  ) async {
    return const Left(ServerFailure('Not implemented'));
  }

  @override
  Future<Either<Failure, ChildModel>> updateChild(
    String childId, {
    String? nickname,
    int? age,
    String? gender,
    AvatarStateModel? avatarState,
  }) async {
    return const Left(ServerFailure('Not implemented'));
  }

  @override
  Future<Either<Failure, ChildModel>> claimChild(String inviteCode) async {
    late final http.Response response;
    try {
      response = await _client
          .post(
            Uri.parse('${SupabaseConfig.apiBaseUrl}/v1/children/claim'),
            headers: {
              'Accept': 'application/json',
              'Content-Type': 'application/json',
            },
            body: jsonEncode({'invite_code': inviteCode}),
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

    if (response.statusCode == 200) {
      final decoded = jsonDecode(response.body);
      if (decoded is Map<String, dynamic>) {
        return Right(ChildModel.fromJson(decoded));
      }
      return const Left(
        ServerFailure('Unexpected response while claiming child profile.'),
      );
    }

    if (response.statusCode == 401) {
      return const Left(
        UnauthorizedFailure('Invalid or expired session token.'),
      );
    }

    final fallback = switch (response.statusCode) {
      409 => 'This child profile is already claimed.',
      422 => 'Invite code must be exactly 4 characters.',
      503 => 'Auth verification or database configuration unavailable.',
      _ => 'Unable to claim child profile right now.',
    };

    final message = _extractErrorMessage(response.body, fallback);
    if (response.statusCode == 409 || response.statusCode == 422) {
      return Left(ValidationFailure(message));
    }
    return Left(ServerFailure(message));
  }

  String _extractErrorMessage(String body, String fallback) {
    if (body.trim().isEmpty) return fallback;
    try {
      final decoded = jsonDecode(body);
      if (decoded is Map<String, dynamic>) {
        final candidate =
            decoded['message'] ?? decoded['detail'] ?? decoded['error'];
        if (candidate is String && candidate.trim().isNotEmpty) {
          return candidate.trim();
        }
      }
    } catch (_) {}
    return fallback;
  }
}
