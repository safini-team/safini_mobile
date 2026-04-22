import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:safini/features/common/auth/data/auth_google_sign_in_service.dart';
import 'package:safini/features/common/auth/presentation/cubit/login_cubit.dart';
import 'package:safini/features/common/profile/data/datasources/local/profile_local_datasource.dart';
import 'package:safini/features/common/profile/data/datasources/remote/profile_remote_datasource.dart';
import 'package:safini/features/common/profile/data/repositories/profile_repository.dart';
import 'package:safini/features/common/profile/domain/controllers/profile_controller.dart';
import 'package:safini/features/common/profile/presentation/cubit/profile_cubit.dart';

void registerCommonDependencies(GetIt sl) {
  // ── Auth ───────────────────────────────────────────────────────────────────
  sl.registerLazySingleton<AuthGoogleSignInService>(
    AuthGoogleSignInService.new,
  );
  sl.registerFactory<LoginCubit>(
    () => LoginCubit(
      sl<AuthGoogleSignInService>(),
      sl<SharedPreferences>(),
      sl<ProfileController>(),
    ),
  );

  // ── Profile ────────────────────────────────────────────────────────────────
  sl.registerLazySingleton<ProfileRemoteDataSource>(
    () => ProfileRemoteDataSource(sl<Dio>()),
  );
  sl.registerLazySingleton<ProfileLocalDataSource>(
    () => ProfileLocalDataSource(sl<SharedPreferences>()),
  );
  sl.registerLazySingleton<ProfileRepository>(
    () => ProfileRepository(
      sl<ProfileRemoteDataSource>(),
      sl<ProfileLocalDataSource>(),
    ),
  );
  sl.registerFactory<ProfileController>(
    () => ProfileController(sl<ProfileRepository>()),
  );
  sl.registerFactory<ProfileCubit>(
    () => ProfileCubit(sl<ProfileController>(), sl<SharedPreferences>()),
  );
}