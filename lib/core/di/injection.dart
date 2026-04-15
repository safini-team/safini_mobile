import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:safini/core/app/app_router.dart';
import 'package:safini/features/common/auth/data/auth_google_sign_in_service.dart';
import 'package:safini/features/common/auth/presentation/cubit/login_cubit.dart';
import 'package:safini/features/parent/domain/controllers/parent_controller.dart';
import 'package:safini/features/parent/presentation/cubit/parent_cubit.dart';
import 'package:safini/features/parent/presentation/cubit/parent_monitor_cubit.dart';
import 'package:safini/features/parent/presentation/cubit/parent_apps_cubit.dart';
import 'package:safini/features/parent/presentation/cubit/parent_tasks_cubit.dart';
import 'package:safini/features/parent/presentation/cubit/parent_family_cubit.dart';

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

  if (!getIt.isRegistered<AuthGoogleSignInService>()) {
    getIt.registerLazySingleton<AuthGoogleSignInService>(
      AuthGoogleSignInService.new,
    );
  }
  if (!getIt.isRegistered<LoginCubit>()) {
    getIt.registerFactory<LoginCubit>(
      () => LoginCubit(getIt<AuthGoogleSignInService>()),
    );
  }

  getIt.registerLazySingleton<ParentController>(() => const ParentController());
  getIt.registerFactory<ParentCubit>(() => ParentCubit());
  getIt.registerFactory<ParentMonitorCubit>(
    () => ParentMonitorCubit(getIt<ParentController>()),
  );
  getIt.registerFactory<ParentAppsCubit>(
    () => ParentAppsCubit(getIt<ParentController>()),
  );
  getIt.registerFactory<ParentTasksCubit>(
    () => ParentTasksCubit(getIt<ParentController>()),
  );
  getIt.registerFactory<ParentFamilyCubit>(
    () => ParentFamilyCubit(getIt<ParentController>()),
  );
}
