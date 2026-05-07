import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:safini/features/common/auth/data/auth_google_sign_in_service.dart';
import 'package:safini/features/common/auth/data/user_me_service.dart';
import 'package:safini/features/common/auth/presentation/cubit/auth_session_cubit.dart';
import 'package:safini/features/common/auth/presentation/cubit/child_claim_cubit.dart';
import 'package:safini/features/common/auth/presentation/cubit/login_cubit.dart';
import 'package:safini/features/common/profile/data/datasources/local/profile_local_datasource.dart';
import 'package:safini/features/common/profile/data/datasources/remote/profile_remote_datasource.dart';
import 'package:safini/features/common/profile/data/repositories/profile_repository.dart';
import 'package:safini/features/common/profile/domain/controllers/profile_controller.dart';
import 'package:safini/features/common/profile/presentation/cubit/profile_cubit.dart';
import 'package:safini/features/models/data/repositories/child_repository_impl.dart'
    as models_child;
import 'package:safini/features/models/domain/controllers/child_controller.dart'
    as models_child;
import 'package:safini/features/models/domain/repositories/i_child_repository.dart'
    as models_child;

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
  sl.registerLazySingleton<UserMeService>(UserMeService.new);
  sl.registerLazySingleton<AuthSessionCubit>(
    () => AuthSessionCubit(sl<AuthGoogleSignInService>(), sl<UserMeService>()),
  );
  sl.registerLazySingleton<models_child.IChildRepository>(
    () => models_child.ChildRepositoryImpl(),
  );
  sl.registerLazySingleton<models_child.ChildController>(
    () => models_child.ChildController(sl<models_child.IChildRepository>()),
  );
  sl.registerLazySingleton<ChildClaimCubit>(
    () => ChildClaimCubit(
      sl<models_child.ChildController>(),
      sl<AuthSessionCubit>(),
    ),
  );

  // ── Profile ────────────────────────────────────────────────────────────────
  sl.registerLazySingleton<ProfileRemoteDataSource>(
    () => ProfileRemoteDataSource(sl()),
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
