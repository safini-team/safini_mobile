import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:dio/dio.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:safini/core/app/app_router.dart';
import 'package:safini/core/app_icons/app_icon_cache.dart';
import 'package:safini/core/network/dio_network.dart';
import 'package:safini/core/notifications/parent_push_service.dart';
import 'package:safini/core/notifications/push_deep_links.dart';
import 'package:safini/core/utils/constants/app_constants.dart';
import 'package:safini/features/child/child_injection.dart';
import 'package:safini/features/child/data/services/app_block_service.dart';
import 'package:safini/features/common/common_injection.dart';
import 'package:safini/features/parent/parent_injection.dart';

final GetIt getIt = GetIt.instance;

bool _sharedPreferencesPluginAvailable = false;

/// Whether the native `shared_preferences` plugin responded (used by Supabase bootstrap).
bool get isSharedPreferencesPluginAvailable =>
    _sharedPreferencesPluginAvailable;

/// Awaits [SharedPreferences.getInstance], registers it when available, then registers all dependencies.
Future<void> configureDependencies({bool firebaseReady = false}) async {
  try {
    final preferences = await SharedPreferences.getInstance();
    _sharedPreferencesPluginAvailable = true;
    // SAF-150 migration: Supabase persists the complete rotating session.
    // Delete the app's obsolete second access-token copy without touching the
    // real Supabase session, so stale bearer tokens cannot survive upgrades.
    await preferences.remove(AppConstants.accessToken);
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

  // Shared Dio setup for feature data sources that rely on API base options
  // and auth interceptors.
  if (!getIt.isRegistered<Dio>()) {
    DioNetwork.initDio();
    getIt.registerLazySingleton<Dio>(() => DioNetwork.appAPI);
  }

  // App icons for both shells: the launcher's own on a child's Android phone,
  // the child's uploaded copies everywhere else.
  if (!getIt.isRegistered<AppIconCache>()) {
    getIt.registerLazySingleton<AppIconCache>(
      () => AppIconCache.api(
        getIt<Dio>(),
        loadLocal: (packageName) =>
            getIt<AppBlockService>().appIcon(packageName),
      ),
    );
  }

  if (!getIt.isRegistered<PushDeepLinks>()) {
    getIt.registerLazySingleton<PushDeepLinks>(PushDeepLinks.new);
  }

  // Only registered when Firebase actually came up. Everything that uses it
  // checks isRegistered first, so a build without the config files behaves
  // exactly as it did before push existed.
  if (firebaseReady && !getIt.isRegistered<ParentPushService>()) {
    getIt.registerLazySingleton<ParentPushService>(
      () => ParentPushService(
        getIt<Dio>(),
        FirebaseMessaging.instance,
        getIt<PushDeepLinks>(),
      ),
    );
  }

  registerCommonDependencies(getIt);
  registerChildDependencies(getIt);
  registerParentDependencies(getIt);
}
