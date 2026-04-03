import 'package:get_it/get_it.dart';
import 'package:safini/core/app/app_router.dart';
import 'package:safini/features/parent/domain/controllers/parent_controller.dart';
import 'package:safini/features/parent/presentation/cubit/parent_cubit.dart';
import 'package:safini/features/parent/presentation/cubit/parent_monitor_cubit.dart';
import 'package:safini/features/parent/presentation/cubit/parent_apps_cubit.dart';
import 'package:safini/features/parent/presentation/cubit/parent_tasks_cubit.dart';
import 'package:safini/features/parent/presentation/cubit/parent_family_cubit.dart';

final GetIt getIt = GetIt.instance;

void configureDependencies() {
  // Core
  if (!getIt.isRegistered<AppRouter>()) {
    getIt.registerLazySingleton<AppRouter>(AppRouter.new);
  }

  // Parent feature
  getIt.registerLazySingleton<ParentController>(() => const ParentController());
  getIt.registerFactory<ParentCubit>(() => ParentCubit());
  getIt.registerFactory<ParentMonitorCubit>(() => ParentMonitorCubit(getIt<ParentController>()));
  getIt.registerFactory<ParentAppsCubit>(() => ParentAppsCubit(getIt<ParentController>()));
  getIt.registerFactory<ParentTasksCubit>(() => ParentTasksCubit(getIt<ParentController>()));
  getIt.registerFactory<ParentFamilyCubit>(() => ParentFamilyCubit(getIt<ParentController>()));
}

