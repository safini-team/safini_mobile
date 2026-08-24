import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:safini/core/network/auth_token_provider.dart';
import 'package:safini/core/network/authenticated_http_client.dart';
import 'package:safini/features/common/auth/data/auth_email_sign_in_service.dart';
import 'package:safini/features/common/auth/data/auth_google_sign_in_service.dart';
import 'package:safini/features/common/auth/data/account_deletion_service.dart';
import 'package:safini/features/common/auth/data/user_me_service.dart';
import 'package:safini/features/common/auth/presentation/cubit/auth_session_cubit.dart';
import 'package:safini/features/common/auth/presentation/cubit/child_claim_cubit.dart';
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
import 'package:supabase_flutter/supabase_flutter.dart';

void registerCommonDependencies(GetIt sl) {
  // ── Auth ───────────────────────────────────────────────────────────────────
  sl.registerLazySingleton<AuthSessionGateway>(() {
    try {
      return SupabaseAuthSessionGateway(Supabase.instance.client);
    } catch (_) {
      // Widget previews/tests intentionally render without bootstrapping a
      // remote Supabase project. They should behave as signed out.
      return const UnavailableAuthSessionGateway();
    }
  });
  sl.registerLazySingleton<AuthTokenProvider>(
    () => SupabaseAuthTokenProvider(sl<AuthSessionGateway>()),
  );
  sl.registerLazySingleton<AuthenticatedHttpClient>(
    () => AuthenticatedHttpClient(sl<AuthTokenProvider>()),
  );
  sl.registerLazySingleton<AccountDeletionService>(
    () => AccountDeletionService(sl()),
  );
  sl.registerLazySingleton<AuthGoogleSignInService>(
    AuthGoogleSignInService.new,
  );
  sl.registerLazySingleton<AuthEmailSignInService>(AuthEmailSignInService.new);
  sl.registerLazySingleton<UserMeService>(
    () => UserMeService(sl<AuthenticatedHttpClient>()),
  );
  sl.registerLazySingleton<AuthSessionCubit>(
    () => AuthSessionCubit(
      sl<AuthGoogleSignInService>(),
      sl<AuthEmailSignInService>(),
      sl<UserMeService>(),
      sl<AuthTokenProvider>(),
    ),
  );
  sl.registerLazySingleton<models_child.IChildRepository>(
    () => models_child.ChildRepositoryImpl(sl<AuthenticatedHttpClient>()),
  );
  sl.registerLazySingleton<models_child.ChildController>(
    () => models_child.ChildController(sl<models_child.IChildRepository>()),
  );
  sl.registerLazySingleton<ChildClaimCubit>(
    () => ChildClaimCubit(sl<models_child.ChildController>()),
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
  sl.registerFactory<ProfileCubit>(() => ProfileCubit(sl<ProfileController>()));
}
