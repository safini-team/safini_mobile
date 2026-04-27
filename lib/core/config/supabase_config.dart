import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Supabase and Google OAuth configuration.
///
/// Values are resolved in order:
/// 1. `--dart-define=KEY=value` (CI / release pipelines)
/// 2. `assets/env/app.env` (bundled defaults; safe to commit public client IDs)
///
/// The Google **web client secret** must never be read by this app. Configure it
/// only in [Supabase Dashboard](https://supabase.com/dashboard) → Authentication
/// → Providers → Google, or in server-side code.
class SupabaseConfig {
  SupabaseConfig._();

  static String _env(String key, {String defaultValue = ''}) {
    final fromDefine = String.fromEnvironment(key, defaultValue: '');
    if (fromDefine.isNotEmpty) {
      return fromDefine;
    }
    final fromFile = dotenv.env[key];
    if (fromFile != null && fromFile.trim().isNotEmpty) {
      return fromFile.trim();
    }
    return defaultValue;
  }

  static String get url => _env('SUPABASE_URL');

  static String get anonKey => _env('SUPABASE_ANON_KEY');

  /// OAuth 2.0 **Web application** client ID (also `serverClientId` for native Google Sign-In).
  static String get googleWebClientId => _env('GOOGLE_WEB_CLIENT_ID');

  /// iOS OAuth client ID (`GoogleSignIn.initialize` `clientId` on iOS).
  static String get googleIosClientId => _env('GOOGLE_IOS_CLIENT_ID');

  /// Android OAuth client ID from Google Cloud (package name + SHA-1 must match).
  /// Not always passed to `google_sign_in`; kept for reference and tooling.
  static String get googleAndroidClientId => _env('GOOGLE_ANDROID_CLIENT_ID');

  static bool get isSupabaseConfigured =>
      url.isNotEmpty && anonKey.isNotEmpty;

  static bool get isGoogleConfigured => googleWebClientId.isNotEmpty;

  /// Backend API base URL (e.g. `https://api.safini.fun`).
  static String get apiBaseUrl => _env('API_BASE_URL');

  static bool get isApiConfigured => apiBaseUrl.isNotEmpty;
}
