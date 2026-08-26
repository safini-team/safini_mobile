import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:safini/features/models/data/repositories/family_repository_impl.dart';
import 'package:safini/features/models/data/repositories/task_repository_impl.dart';
import 'package:safini/features/models/domain/controllers/family_controller.dart';
import 'package:safini/features/models/domain/controllers/task_controller.dart';
import 'package:safini/features/models/domain/repositories/i_family_repository.dart';
import 'package:safini/features/models/domain/repositories/i_task_repository.dart';
import 'package:safini/features/parent/data/datasources/parent_remote_datasource.dart';
import 'package:safini/features/parent/data/repositories/parent_app_usage_repository_impl.dart';
import 'package:safini/features/parent/data/services/parent_app_blocking_service.dart';
import 'package:safini/features/parent/data/repositories/parent_task_repository_impl.dart';
import 'package:safini/features/parent/data/repositories/parent_user_repository_impl.dart';
import 'package:safini/features/parent/domain/controllers/parent_controller.dart';
import 'package:safini/features/parent/domain/repositories/i_parent_app_usage_repository.dart';
import 'package:safini/features/parent/domain/repositories/i_parent_task_repository.dart';
import 'package:safini/features/parent/domain/repositories/i_parent_user_repository.dart';
import 'package:safini/features/parent/presentation/cubit/parent_cubit.dart';
import 'package:safini/features/parent/presentation/cubit/parent_monitor_cubit.dart';
import 'package:safini/features/parent/presentation/cubit/parent_apps_cubit.dart';
import 'package:safini/features/parent/presentation/cubit/parent_installed_apps_cubit.dart';
import 'package:safini/features/parent/presentation/cubit/parent_tasks_cubit.dart';
import 'package:safini/features/parent/presentation/cubit/parent_family_cubit.dart';
import 'package:safini/features/parent/presentation/cubit/home/home_cubit.dart';
import 'package:safini/core/network/authenticated_http_client.dart';

void registerParentDependencies(GetIt sl) {
  sl.registerLazySingleton<ParentRemoteDataSource>(
    () => ParentRemoteDataSource(sl<Dio>()),
  );
  sl.registerLazySingleton<IParentUserRepository>(
    () => ParentUserRepositoryImpl(sl<ParentRemoteDataSource>()),
  );
  sl.registerLazySingleton<ParentController>(
    () => ParentController(sl<IParentUserRepository>()),
  );

  sl.registerLazySingleton<IFamilyRepository>(
    () => FamilyRepositoryImpl(sl<AuthenticatedHttpClient>()),
  );
  sl.registerLazySingleton<FamilyController>(
    () => FamilyController(sl<IFamilyRepository>()),
  );

  sl.registerLazySingleton<ITaskRepository>(
    () => TaskRepositoryImpl(sl<Dio>()),
  );
  sl.registerLazySingleton<TaskController>(
    () => TaskController(sl<ITaskRepository>()),
  );

  sl.registerFactory<ParentCubit>(
    () => ParentCubit(sl<ParentController>(), Supabase.instance.client),
  );
  sl.registerFactory<ParentHomeCubit>(() => ParentHomeCubit());
  sl.registerLazySingleton<IParentAppUsageRepository>(
    () => ParentAppUsageRepositoryImpl(sl<AuthenticatedHttpClient>()),
  );
  sl.registerLazySingleton<ParentAppBlockingService>(
    () => ParentAppBlockingService(sl<Dio>()),
  );
  sl.registerFactory<ParentInstalledAppsCubit>(
    () => ParentInstalledAppsCubit(sl<ParentAppBlockingService>()),
  );
  sl.registerFactory<ParentMonitorCubit>(
    () => ParentMonitorCubit(
      sl<ParentFamilyCubit>(),
      sl<IParentAppUsageRepository>(),
    ),
  );
  sl.registerFactory<ParentAppsCubit>(
    () => ParentAppsCubit(
      sl<ParentFamilyCubit>(),
      sl<IParentAppUsageRepository>(),
    ),
  );
  sl.registerLazySingleton<IParentTaskRepository>(
    () => ParentTaskRepositoryImpl(sl<AuthenticatedHttpClient>()),
  );
  sl.registerFactory<ParentTasksCubit>(
    () => ParentTasksCubit(
      sl<IParentTaskRepository>(),
      sl<ParentFamilyCubit>(),
      sl<TaskController>(),
    ),
  );
  sl.registerLazySingleton<ParentFamilyCubit>(
    () => ParentFamilyCubit(sl<FamilyController>(), sl<SharedPreferences>()),
  );
}
