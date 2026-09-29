import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:safini/core/version_gate/version_policy.dart';

/// Last-good policy plus the recommended version the user already dismissed.
class VersionPolicyStore {
  VersionPolicyStore(this._prefs);

  static const policyKey = 'version_gate.policy_json';
  static const dismissedKey = 'version_gate.dismissed_recommended';

  final SharedPreferences? _prefs;
  final Map<String, String> _memory = {};

  VersionPolicy? readPolicy() {
    final raw = _read(policyKey);
    if (raw == null || raw.isEmpty) return null;
    try {
      return VersionPolicy.tryParse(jsonDecode(raw));
    } catch (_) {
      return null;
    }
  }

  Future<void> savePolicy(VersionPolicy policy) async {
    await _write(policyKey, jsonEncode(policy.toJson()));
  }

  String? dismissedRecommended() => _read(dismissedKey);

  bool isDismissed(String recommended) {
    final value = dismissedRecommended();
    return value != null && value == recommended;
  }

  Future<void> dismissRecommended(String recommended) async {
    await _write(dismissedKey, recommended);
  }

  String? _read(String key) {
    final prefs = _prefs;
    if (prefs != null) return prefs.getString(key);
    return _memory[key];
  }

  Future<void> _write(String key, String value) async {
    final prefs = _prefs;
    if (prefs != null) {
      await prefs.setString(key, value);
    } else {
      _memory[key] = value;
    }
  }
}
