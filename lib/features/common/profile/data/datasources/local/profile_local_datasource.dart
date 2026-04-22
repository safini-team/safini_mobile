import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:safini/core/error/exceptions.dart';
import 'package:safini/features/common/profile/domain/models/profile_model.dart';

class ProfileLocalDataSource {
  static const _key = 'profile_cached';

  final SharedPreferences _prefs;

  ProfileLocalDataSource(this._prefs);

  ProfileModel? getCached() {
    try {
      final jsonString = _prefs.getString(_key);
      if (jsonString == null) return null;
      return ProfileModel.fromJson(
        jsonDecode(jsonString) as Map<String, dynamic>,
      );
    } catch (e) {
      throw CacheException(e.toString());
    }
  }

  Future<void> cache(ProfileModel model) async {
    try {
      await _prefs.setString(_key, jsonEncode(model.toJson()));
    } catch (e) {
      throw CacheException(e.toString());
    }
  }
}