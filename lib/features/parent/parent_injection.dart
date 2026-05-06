import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:safini/features/models/data/repositories/family_repository_impl.dart';
import 'package:safini/features/models/domain/controllers/family_controller.dart';
import 'package:safini/features/models/domain/repositories/i_family_repository.dart';
import 'package:safini/features/parent/data/datasources/parent_remote_datasource.dart';
import 'package:safini/features/parent/data/repositories/parent_user_repository_impl.dart';
import 'package:safini/features/parent/domain/controllers/parent_controller.dart';
import 'package:safini/features/parent/domain/repositories/i_parent_user_repository.dart';
import 'package:safini/features/parent/presentation/cubit/parent_cubit.dart';
import 'package:safini/features/parent/presentation/cubit/parent_monitor_cubit.dart';
import 'package:safini/features/parent/presentation/cubit/parent_apps_cubit.dart';
import 'package:safini/features/parent/presentation/cubit/parent_tasks_cubit.dart';
import 'package:safini/features/parent/presentation/cubit/parent_family_cubit.dart';
import 'package:safini/features/parent/presentation/cubit/home/home_cubit.dart';

void registerParentDependencies(GetIt sl) {
  sl.registerLazySingleton<ParentRemoteDataSource>(
    () => ParentRemoteDataSource(Supabase.instance.client),
  );
  sl.registerLazySingleton<IParentUserRepository>(
    () => ParentUserRepositoryImpl(sl<ParentRemoteDataSource>()),
  );
  sl.registerLazySingleton<ParentController>(
    () => ParentController(sl<IParentUserRepository>()),
  );

  sl.registerLazySingleton<IFamilyRepository>(
    () => FamilyRepositoryImpl(),
  );
  sl.registerLazySingleton<FamilyController>(
    () => FamilyController(sl<IFamilyRepository>()),
  );

  sl.registerFactory<ParentCubit>(
    () => ParentCubit(sl<ParentController>(), Supabase.instance.client),
  );
  sl.registerFactory<ParentHomeCubit>(() => ParentHomeCubit());
  sl.registerFactory<ParentMonitorCubit>(
    () => ParentMonitorCubit(sl<ParentController>()),
  );
  sl.registerFactory<ParentAppsCubit>(
    () => ParentAppsCubit(sl<ParentController>()),
  );
  sl.registerFactory<ParentTasksCubit>(
    () => ParentTasksCubit(sl<ParentController>()),
  );
  sl.registerLazySingleton<ParentFamilyCubit>(
    () => ParentFamilyCubit(sl<FamilyController>(), sl<SharedPreferences>()),
  );
}
