import 'package:dio/dio.dart';
import 'package:safini/core/utils/constants/api_const.dart';

/// A child's ask to sign out of Safini, which a parent answers (SAF-191).
///
/// Signing out turns app limits off, so the child's phone asks first. Every
/// parent gets a push with a 4-digit code: a parent approves in their app, or
/// reads the code out and the child types it in.
class SignoutRequest {
  const SignoutRequest({
    required this.id,
    required this.childId,
    required this.status,
    this.attemptsLeft = 5,
    this.code,
    this.childNickname,
    this.expiresAt,
  });

  final String id;
  final String childId;

  /// pending, approved, denied, cancelled, locked or expired.
  final String status;
  final int attemptsLeft;

  /// Only parents get it, and only while the ask is open.
  final String? code;
  final String? childNickname;
  final DateTime? expiresAt;

  bool get isPending => status == 'pending';
  bool get isApproved => status == 'approved';
  bool get isDenied => status == 'denied';

  factory SignoutRequest.fromJson(Map<String, dynamic> json) => SignoutRequest(
    id: json['id'].toString(),
    childId: json['child_id'].toString(),
    status: (json['status'] ?? 'pending').toString(),
    attemptsLeft: (json['attempts_left'] as num?)?.toInt() ?? 5,
    code: json['code'] as String?,
    childNickname: json['child_nickname'] as String?,
    expiresAt: DateTime.tryParse(json['expires_at']?.toString() ?? ''),
  );
}

/// A wrong code (422). [status] turns `locked` on the fifth one.
class WrongSignoutCode implements Exception {
  const WrongSignoutCode({required this.attemptsLeft, required this.status});

  final int attemptsLeft;
  final String status;

  bool get locked => status == 'locked';
}

class SignoutApi {
  SignoutApi(this._dio);

  final Dio _dio;

  /// Opens an ask for [childId], replacing any open one. Null when this
  /// account no longer holds the child profile (403/404): there is nothing
  /// left to protect, so the phone may sign out without asking.
  Future<SignoutRequest?> ask(String childId) async {
    try {
      final response = await _dio.post(ApiConst.childSignoutRequests(childId));
      return SignoutRequest.fromJson(_map(response.data));
    } on DioException catch (error) {
      final code = error.response?.statusCode;
      if (code == 403 || code == 404) return null;
      rethrow;
    }
  }

  Future<SignoutRequest> read(String childId, String requestId) async {
    final response = await _dio.get(
      ApiConst.childSignoutRequest(childId, requestId),
    );
    return SignoutRequest.fromJson(_map(response.data));
  }

  /// Throws [WrongSignoutCode] for a wrong code.
  Future<SignoutRequest> verify(
    String childId,
    String requestId,
    String code,
  ) async {
    try {
      final response = await _dio.post(
        '${ApiConst.childSignoutRequest(childId, requestId)}/verify',
        data: {'code': code},
      );
      return SignoutRequest.fromJson(_map(response.data));
    } on DioException catch (error) {
      final detail = error.response?.data is Map
          ? (error.response!.data as Map)['detail']
          : null;
      if (error.response?.statusCode == 422 && detail is Map) {
        throw WrongSignoutCode(
          attemptsLeft: (detail['attempts_left'] as num?)?.toInt() ?? 0,
          status: (detail['status'] ?? 'pending').toString(),
        );
      }
      rethrow;
    }
  }

  Future<SignoutRequest> answer(
    SignoutRequest request, {
    required bool approve,
  }) async {
    final response = await _dio.post(
      '${ApiConst.childSignoutRequest(request.childId, request.id)}/'
      '${approve ? 'approve' : 'deny'}',
    );
    return SignoutRequest.fromJson(_map(response.data));
  }

  /// Every open ask in the family, for Today.
  Future<List<SignoutRequest>> pending() async {
    final response = await _dio.get(ApiConst.familySignoutRequests);
    final list = _map(response.data)['requests'];
    return list is List
        ? list
              .whereType<Map>()
              .map(
                (row) => SignoutRequest.fromJson(row.cast<String, dynamic>()),
              )
              .toList()
        : const [];
  }

  static Map<String, dynamic> _map(Object? data) =>
      data is Map ? data.cast<String, dynamic>() : const {};
}
