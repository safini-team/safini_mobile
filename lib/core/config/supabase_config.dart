import 'package:flutter/foundation.dart' show kDebugMode;
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

  /// `String.fromEnvironment` only reads a `--dart-define` when it is evaluated
  /// as a constant, and it cannot be constant with a variable key. Calling it
  /// with `key` returned the default every time, so step 1 above silently did
  /// nothing for every value here, including the `ENABLE_EMAIL_SIGN_IN=true`
  /// the README tells you to pass for an App Review build. This map is a const
  /// context, so these do resolve.
  static const Map<String, String> _defines = {
    'API_BASE_URL': String.fromEnvironment('API_BASE_URL'),
    'SUPABASE_URL': String.fromEnvironment('SUPABASE_URL'),
    'SUPABASE_ANON_KEY': String.fromEnvironment('SUPABASE_ANON_KEY'),
    'GOOGLE_WEB_CLIENT_ID': String.fromEnvironment('GOOGLE_WEB_CLIENT_ID'),
    'GOOGLE_IOS_CLIENT_ID': String.fromEnvironment('GOOGLE_IOS_CLIENT_ID'),
    'GOOGLE_ANDROID_CLIENT_ID': String.fromEnvironment('GOOGLE_ANDROID_CLIENT_ID'),
    'ENABLE_EMAIL_SIGN_IN': String.fromEnvironment('ENABLE_EMAIL_SIGN_IN'),
  };

  static String _env(String key, {String defaultValue = ''}) {
    final fromDefine = _defines[key] ?? '';
    if (fromDefine.isNotEmpty) {
      return fromDefine;
    }
    try {
      final fromFile = dotenv.env[key];
      if (fromFile != null && fromFile.trim().isNotEmpty) {
        return fromFile.trim();
      }
    } catch (_) {
      return defaultValue;
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

  static bool get isSupabaseConfigured => url.isNotEmpty && anonKey.isNotEmpty;

  static bool get isGoogleConfigured => googleWebClientId.isNotEmpty;

  /// Enables the non-public email/password login used by local testing and
  /// App Review. It is on by default for debug builds and off for release
  /// builds unless explicitly enabled with `ENABLE_EMAIL_SIGN_IN=true`.
  static bool get isEmailSignInEnabled {
    final configured = _env('ENABLE_EMAIL_SIGN_IN').toLowerCase();
    if (configured.isEmpty) return kDebugMode;
    return configured == 'true' || configured == '1' || configured == 'yes';
  }

  /// Where the API lives when nothing overrides it.
  static const String productionApiBaseUrl = 'https://api.safini.fun';

  /// Backend API base URL, and the only place it is resolved.
  ///
  /// `ApiConst.baseUrl` delegates here. They used to read different sources,
  /// so pointing a debug build at a local API moved the Dio calls but left
  /// `GET /v1/me` on production, and the app routed itself on one server's
  /// answer while talking to another.
  static String get apiBaseUrl =>
      _env('API_BASE_URL', defaultValue: productionApiBaseUrl);
}
