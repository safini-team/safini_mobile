import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:safini/core/error/exceptions.dart';
import 'package:safini/core/utils/constants/api_const.dart';
import 'package:safini/features/child/data/dto/child_dto.dart';
import 'package:safini/features/child/domain/models/child_home_response.dart';
import 'package:safini/features/child/domain/models/child_model.dart';
import 'package:safini/features/child/domain/models/child_today_response.dart';
import 'package:safini/features/child/domain/models/task_proof_upload.dart';

class ChildRemoteDataSource {
  final Dio _dio;

  /// Storage uploads go out on a bare client: the signed URL carries its own
  /// token, and the dio instance would attach our API bearer to a request that
  /// is not going to our API.
  final http.Client _uploadClient;

  ChildRemoteDataSource(this._dio, {http.Client? uploadClient})
    : _uploadClient = uploadClient ?? http.Client();

  /// Fetches the current family and returns the list of children.
  Future<List<ChildModel>> fetchChildren() async {
    debugPrint(
      '[ChildRemoteDataSource] GET ${ApiConst.baseUrl}${ApiConst.currentFamily}',
    );
    try {
      final response = await _dio.get(ApiConst.currentFamily);
      debugPrint(
        '[ChildRemoteDataSource] Response ${response.statusCode}: ${response.data}',
      );

      final data = response.data as Map<String, dynamic>;
      final rawChildren = data['children'] as List<dynamic>? ?? [];

      final children = rawChildren
          .map((e) => ChildDto.fromJson(e as Map<String, dynamic>).toDomain())
          .toList();

      debugPrint('[ChildRemoteDataSource] Parsed ${children.length} children');
      return children;
    } on DioException catch (e) {
      debugPrint(
        '[ChildRemoteDataSource] DioException ${e.response?.statusCode}: ${e.message}',
      );
      throw ServerException(e.message ?? 'Server error');
    } catch (e) {
      debugPrint('[ChildRemoteDataSource] Unexpected error: $e');
      throw ServerException(e.toString());
    }
  }

  /// Fetches a specific child by ID.
  Future<ChildModel> fetchChild(String childId) async {
    final path = ApiConst.childById(childId);
    debugPrint('[ChildRemoteDataSource] GET ${ApiConst.baseUrl}$path');
    try {
      final response = await _dio.get(path);
      debugPrint(
        '[ChildRemoteDataSource] Response ${response.statusCode}: ${response.data}',
      );

      final data = response.data as Map<String, dynamic>;
      return ChildDto.fromJson(data).toDomain();
    } on DioException catch (e) {
      debugPrint(
        '[ChildRemoteDataSource] DioException ${e.response?.statusCode}: ${e.message}',
      );
      throw ServerException(e.message ?? 'Server error');
    } catch (e) {
      debugPrint('[ChildRemoteDataSource] Unexpected error: $e');
      throw ServerException(e.toString());
    }
  }

  /// Fetches the child home summary (nickname + done_today count).
  Future<ChildHomeResponse> fetchChildHome(String childId) async {
    final path = ApiConst.childHome(childId);
    debugPrint('[ChildRemoteDataSource] GET ${ApiConst.baseUrl}$path');
    try {
      final response = await _dio.get(path);
      debugPrint(
        '[ChildRemoteDataSource] Response ${response.statusCode}: ${response.data}',
      );
      final data = response.data as Map<String, dynamic>;
      return ChildHomeResponse.fromJson(data);
    } on DioException catch (e) {
      debugPrint(
        '[ChildRemoteDataSource] DioException ${e.response?.statusCode}: ${e.message}',
      );
      final code = e.response?.statusCode;
      if (code == 403) throw const ServerException('Access denied.');
      if (code == 404) throw const ServerException('Child not found.');
      if (code == 422) throw const ServerException('Invalid request.');
      if (code == 503) {
        throw const ServerException(
          'Service unavailable. Please try again later.',
        );
      }
      throw ServerException(e.message ?? 'Server error');
    } catch (e) {
      debugPrint('[ChildRemoteDataSource] Unexpected error: $e');
      throw ServerException(e.toString());
    }
  }

  /// Fetches today's task list for the child along with remaining_today count.
  Future<ChildTodayResponse> fetchChildToday(
    String childId, {
    String? date,
  }) async {
    final path = ApiConst.childToday(childId);
    final queryParams = date != null ? {'date': date} : null;
    debugPrint('[ChildRemoteDataSource] GET ${ApiConst.baseUrl}$path');
    try {
      final response = await _dio.get(
        path,
        queryParameters: queryParams,
      );
      debugPrint(
        '[ChildRemoteDataSource] Response ${response.statusCode}: ${response.data}',
      );
      final data = response.data as Map<String, dynamic>;
      return ChildTodayResponse.fromJson(data);
    } on DioException catch (e) {
      debugPrint(
        '[ChildRemoteDataSource] DioException ${e.response?.statusCode}: ${e.message}',
      );
      final code = e.response?.statusCode;
      if (code == 403) throw const ServerException('Access denied.');
      if (code == 404) throw const ServerException('Child not found.');
      if (code == 422) throw const ServerException('Invalid request.');
      if (code == 503) {
        throw const ServerException(
          'Service unavailable. Please try again later.',
        );
      }
      throw ServerException(e.message ?? 'Server error');
    } catch (e) {
      debugPrint('[ChildRemoteDataSource] Unexpected error: $e');
      throw ServerException(e.toString());
    }
  }

  /// Submits proof for a task. Only [note] is required for text-mode tasks;
  /// [imageObjectKey] is the key returned by [createProofUploadUrl] once the
  /// photo itself is in Storage.
  Future<void> submitTask(
    String taskId, {
    String? note,
    String? imageObjectKey,
  }) async {
    final path = ApiConst.submitTask(taskId);
    debugPrint('[ChildRemoteDataSource] POST ${ApiConst.baseUrl}$path');
    try {
      final body = <String, dynamic>{};
      if (note != null && note.trim().isNotEmpty) body['note'] = note.trim();
      if (imageObjectKey != null && imageObjectKey.isNotEmpty) {
        body['submission_image_object_key'] = imageObjectKey;
      }
      await _dio.post<dynamic>(path, data: body);
    } on DioException catch (e) {
      debugPrint(
        '[ChildRemoteDataSource] DioException ${e.response?.statusCode}: ${e.message}',
      );
      final code = e.response?.statusCode;
      if (code == 403) throw const ServerException('Access denied.');
      if (code == 404) throw const ServerException('Task not found.');
      if (code == 409) throw const ServerException('Task already submitted.');
      if (code == 422) throw const ServerException('Invalid request.');
      if (code == 503) {
        throw const ServerException('Service unavailable. Please try again later.');
      }
      throw ServerException(e.message ?? 'Server error');
    } catch (e) {
      debugPrint('[ChildRemoteDataSource] Unexpected error: $e');
      throw ServerException(e.toString());
    }
  }

  /// Asks the API to sign an upload slot for a proof photo.
  Future<TaskProofUpload> createProofUploadUrl({
    required String childId,
    required String taskId,
    required String extension,
  }) async {
    final path = ApiConst.taskProofUploadUrl(childId);
    debugPrint('[ChildRemoteDataSource] POST ${ApiConst.baseUrl}$path');
    try {
      final response = await _dio.post<dynamic>(
        path,
        data: {'task_id': taskId, 'extension': extension},
      );
      final data = response.data;
      if (data is! Map) {
        throw const ServerException('Unexpected upload response.');
      }
      final upload = TaskProofUpload.fromJson(
        data.map((k, v) => MapEntry(k.toString(), v)),
      );
      if (!upload.isUsable) {
        throw const ServerException('Unexpected upload response.');
      }
      return upload;
    } on DioException catch (e) {
      final code = e.response?.statusCode;
      if (code == 403) throw const ServerException('Access denied.');
      if (code == 404) throw const ServerException('Task not found.');
      // The API returns 409 when a deployment has no Storage configured, which
      // is a real state on staging - say so rather than "server error".
      if (code == 409) {
        throw const ServerException('Photo proof is not available yet.');
      }
      if (code == 422) throw const ServerException('Invalid request.');
      throw ServerException(e.message ?? 'Server error');
    }
  }

  /// PUTs the bytes to the signed URL. Returns the object key to submit with.
  Future<String> uploadProofPhoto({
    required TaskProofUpload upload,
    required File file,
    required String extension,
  }) async {
    final length = await file.length();
    if (length > upload.maxBytes) {
      throw const ServerException('That photo is too large.');
    }

    late final http.Response response;
    try {
      response = await _uploadClient.put(
        Uri.parse(upload.uploadUrl),
        headers: {'Content-Type': proofContentType(extension)},
        body: await file.readAsBytes(),
      );
    } on http.ClientException catch (e) {
      throw ServerException(e.message);
    } catch (e) {
      throw ServerException(e.toString());
    }

    if (response.statusCode < 200 || response.statusCode >= 300) {
      debugPrint(
        '[ChildRemoteDataSource] proof upload failed ${response.statusCode}',
      );
      throw const ServerException('Could not upload the photo.');
    }
    return upload.objectKey;
  }

  /// Fetches child dashboard summary and returns child identity/progression data.
  Future<ChildModel> fetchChildDashboard(String childId) async {
    final path = ApiConst.childDashboard(childId);
    debugPrint('[ChildRemoteDataSource] GET ${ApiConst.baseUrl}$path');
    try {
      final response = await _dio.get(path);
      debugPrint(
        '[ChildRemoteDataSource] Response ${response.statusCode}: ${response.data}',
      );

      final data = response.data as Map<String, dynamic>;
      final childJson = data['child'];
      if (childJson is! Map<String, dynamic>) {
        throw const ServerException(
          'Invalid dashboard payload: missing child object',
        );
      }
      return ChildDto.fromJson(childJson).toDomain();
    } on DioException catch (e) {
      debugPrint(
        '[ChildRemoteDataSource] DioException ${e.response?.statusCode}: ${e.message}',
      );
      throw ServerException(e.message ?? 'Server error');
    } catch (e) {
      debugPrint('[ChildRemoteDataSource] Unexpected error: $e');
      throw ServerException(e.toString());
    }
  }
}
