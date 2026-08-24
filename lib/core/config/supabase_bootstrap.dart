import 'package:flutter/foundation.dart';
import 'package:safini/core/config/supabase_config.dart';
import 'package:safini/core/di/injection.dart';
import 'package:safini/core/storage/memory_gotrue_async_storage.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Initializes Supabase when URL/key are set.
///
/// If the shared preferences plugin failed during [configureDependencies], uses
/// in-memory auth storage so the app still runs.
Future<void> initializeSupabaseIfConfigured() async {
  if (!SupabaseConfig.isSupabaseConfigured) {
    return;
  }

  final url = SupabaseConfig.url;
  final anonKey = SupabaseConfig.anonKey;

  if (!isSharedPreferencesPluginAvailable) {
    debugPrint(
      'Supabase: using in-memory auth storage (shared_preferences unavailable). '
      'Run flutter clean and a full rebuild to restore session persistence.',
    );
    await Supabase.initialize(
      url: url,
      anonKey: anonKey,
      authOptions: FlutterAuthClientOptions(
        autoRefreshToken: true,
        localStorage: const EmptyLocalStorage(),
        pkceAsyncStorage: MemoryGotrueAsyncStorage(),
      ),
    );
    return;
  }

  await Supabase.initialize(
    url: url,
    anonKey: anonKey,
    authOptions: const FlutterAuthClientOptions(autoRefreshToken: true),
  );
}
