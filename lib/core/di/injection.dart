import 'package:get_it/get_it.dart';
import 'package:safini/core/app/app_router.dart';
import 'package:safini/features/parent/domain/controllers/parent_controller.dart';
import 'package:safini/features/parent/presentation/cubit/parent_monitor_cubit.dart';
import 'package:safini/features/parent/presentation/cubit/parent_tasks_cubit.dart';
import 'package:safini/features/parent/presentation/cubit/parent_apps_cubit.dart';
import 'package:safini/features/parent/presentation/cubit/parent_family_cubit.dart';

final GetIt getIt = GetIt.instance;

void configureDependencies() {
  if (!getIt.isRegistered<AppRouter>()) {
    getIt.registerLazySingleton<AppRouter>(AppRouter.new);
  }

  // Parent Feature
  if (!getIt.isRegistered<ParentController>()) {
    getIt.registerLazySingleton<ParentController>(ParentController.new);
  }
  if (!getIt.isRegistered<ParentMonitorCubit>()) {
    getIt.registerFactory<ParentMonitorCubit>(() => ParentMonitorCubit(getIt<ParentController>()));
  }
  if (!getIt.isRegistered<ParentTasksCubit>()) {
    getIt.registerFactory<ParentTasksCubit>(() => ParentTasksCubit(getIt<ParentController>()));
  }
  if (!getIt.isRegistered<ParentAppsCubit>()) {
    getIt.registerFactory<ParentAppsCubit>(() => ParentAppsCubit(getIt<ParentController>()));
  }
  if (!getIt.isRegistered<ParentFamilyCubit>()) {
    getIt.registerFactory<ParentFamilyCubit>(() => ParentFamilyCubit(getIt<ParentController>()));
  }
}
