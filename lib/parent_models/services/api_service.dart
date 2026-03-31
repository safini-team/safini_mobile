import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:safini/parent_models/user.dart';

import 'package:flutter/foundation.dart';

class ApiService {
  static const baseUrl = kIsWeb ? 'http://localhost:8000' : 'http://10.0.2.2:8000';

  static Future<User> getUser() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/user/1')).timeout(const Duration(seconds: 5));

      if (response.statusCode == 200) {
        return User.fromJson(jsonDecode(response.body));
      } else {
        throw Exception('Failed to load user: Status ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Error fetching user: $e');
      rethrow;
    }
  }
}