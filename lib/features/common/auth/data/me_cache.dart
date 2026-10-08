import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:safini/features/common/auth/data/me_response.dart';

/// The last `GET /v1/me` answer, so a signed-in user who launches offline is
/// routed to their own shell instead of the sign-in screen.
class MeCache {
  MeCache(this._prefs);

  static const key = 'auth.last_me';

  final SharedPreferences? _prefs;
  String? _memory;

  MeResponse? readFor(String? userId) {
    if (userId == null || userId.isEmpty) return null;
    final raw = _prefs != null ? _prefs.getString(key) : _memory;
    if (raw == null || raw.isEmpty) return null;
    try {
      final json = jsonDecode(raw);
      if (json is! Map<String, dynamic>) return null;
      final me = MeResponse.fromJson(json);
      return me.userId == userId ? me : null;
    } catch (_) {
      return null;
    }
  }

  Future<void> save(MeResponse me) async {
    final raw = jsonEncode(me.toJson());
    final prefs = _prefs;
    if (prefs != null) {
      await prefs.setString(key, raw);
    } else {
      _memory = raw;
    }
  }

  Future<void> clear() async {
    _memory = null;
    await _prefs?.remove(key);
  }
}
