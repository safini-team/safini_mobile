import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:safini/core/app/app_router.dart';
import 'package:safini/features/common/common_injection.dart';
import 'package:safini/features/parent/parent_injection.dart';

final GetIt getIt = GetIt.instance;

bool _sharedPreferencesPluginAvailable = false;

/// Whether the native `shared_preferences` plugin responded (used by Supabase bootstrap).
bool get isSharedPreferencesPluginAvailable =>
    _sharedPreferencesPluginAvailable;

/// Awaits [SharedPreferences.getInstance], registers it when available, then registers all dependencies.
Future<void> configureDependencies() async {
  try {
    final preferences = await SharedPreferences.getInstance();
    _sharedPreferencesPluginAvailable = true;
    if (!getIt.isRegistered<SharedPreferences>()) {
      getIt.registerSingleton<SharedPreferences>(preferences);
    }
  } on MissingPluginException catch (e, st) {
    _sharedPreferencesPluginAvailable = false;
    debugPrint(
      'SharedPreferences plugin missing ($e). Continuing without it — '
      'Supabase will use in-memory auth storage until you do a full native '
      'rebuild (flutter clean; on iOS: cd ios && pod install).\n$st',
    );
  }

  if (!getIt.isRegistered<AppRouter>()) {
    getIt.registerLazySingleton<AppRouter>(AppRouter.new);
  }

  registerCommonDependencies(getIt);
  registerParentDependencies(getIt);
}
