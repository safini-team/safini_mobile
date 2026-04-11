import 'package:gotrue/gotrue.dart';

/// PKCE/code-verifier storage in memory — used when the native
/// `shared_preferences` plugin is unavailable ([MissingPluginException]).
class MemoryGotrueAsyncStorage extends GotrueAsyncStorage {
  MemoryGotrueAsyncStorage();

  final Map<String, String> _data = <String, String>{};

  @override
  Future<String?> getItem({required String key}) async => _data[key];

  @override
  Future<void> setItem({
    required String key,
    required String value,
  }) async {
    _data[key] = value;
  }

  @override
  Future<void> removeItem({required String key}) async {
    _data.remove(key);
  }
}
