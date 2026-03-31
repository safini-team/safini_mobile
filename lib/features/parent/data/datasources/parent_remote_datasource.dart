import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:safini/features/parent/domain/models/parent_user_model.dart';

class ParentRemoteDataSource {
  static const String baseUrl = kIsWeb
      ? 'http://localhost:8000'
      : 'http://10.0.2.2:8000';

  Future<ParentUserModel> getUser() async {
    try {
      final response = await http
          .get(Uri.parse('$baseUrl/user/1'))
          .timeout(const Duration(seconds: 5));

      if (response.statusCode == 200) {
        return ParentUserModel.fromJson(
          jsonDecode(response.body) as Map<String, dynamic>,
        );
      }

      throw Exception('Failed to load user: Status ${response.statusCode}');
    } catch (e) {
      debugPrint('Error fetching user: $e');
      rethrow;
    }
  }
}
