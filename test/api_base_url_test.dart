import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:safini/core/config/supabase_config.dart';
import 'package:safini/core/utils/constants/api_const.dart';

/// Set when the suite runs as
/// `flutter test --dart-define=API_BASE_URL=... test/api_base_url_test.dart`.
/// Const on purpose: `String.fromEnvironment` only reads a define in a const
/// context, which is the bug this file guards.
const String _define = String.fromEnvironment('API_BASE_URL');

void main() {
  tearDown(() => dotenv.testLoad(fileInput: ''));

  test('both entry points resolve to the same host', () {
    dotenv.testLoad(fileInput: 'API_BASE_URL=https://from-file.test');
    expect(ApiConst.baseUrl, SupabaseConfig.apiBaseUrl);
    expect(
      ApiConst.baseUrl,
      _define.isNotEmpty ? _define : 'https://from-file.test',
    );
  });

  test('falls back to production when nothing is configured', () {
    dotenv.testLoad(fileInput: '');
    expect(
      ApiConst.baseUrl,
      _define.isNotEmpty ? _define : SupabaseConfig.productionApiBaseUrl,
    );
    expect(ApiConst.baseUrl, SupabaseConfig.apiBaseUrl);
  });

  test(
    'a dart-define beats the env file',
    () {
      dotenv.testLoad(fileInput: 'API_BASE_URL=https://from-file.test');
      expect(ApiConst.baseUrl, _define);
      expect(SupabaseConfig.apiBaseUrl, _define);
    },
    skip: _define.isEmpty
        ? 'run with --dart-define=API_BASE_URL=... to exercise this'
        : false,
  );
}
