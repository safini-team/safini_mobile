import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:safini/core/utils/constants/api_const.dart';
import 'package:safini/core/version_gate/version_policy.dart';

/// `GET /v1/system/version-policy`. Returns null on any failure so the gate
/// can fail open.
class VersionPolicyClient {
  VersionPolicyClient(this._dio, {this.timeout = const Duration(seconds: 5)});

  final Dio _dio;
  final Duration timeout;

  Future<VersionPolicy?> fetch() async {
    try {
      final response = await _dio.get<dynamic>(
        ApiConst.versionPolicy,
        options: Options(sendTimeout: timeout, receiveTimeout: timeout),
      );
      return VersionPolicy.tryParse(response.data);
    } catch (error) {
      debugPrint('Version policy fetch failed: $error');
      return null;
    }
  }
}
