import 'package:get_it/get_it.dart';
import 'package:safini/features/parent/domain/controllers/parent_controller.dart';
import 'package:safini/features/parent/presentation/cubit/parent_cubit.dart';
import 'package:safini/features/parent/presentation/cubit/parent_monitor_cubit.dart';
import 'package:safini/features/parent/presentation/cubit/parent_apps_cubit.dart';
import 'package:safini/features/parent/presentation/cubit/parent_tasks_cubit.dart';
import 'package:safini/features/parent/presentation/cubit/parent_family_cubit.dart';
import 'package:safini/features/parent/presentation/cubit/home/home_cubit.dart';

void registerParentDependencies(GetIt sl) {
  sl.registerLazySingleton<ParentController>(() => const ParentController());

  sl.registerFactory<ParentCubit>(() => ParentCubit());
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
  sl.registerFactory<ParentFamilyCubit>(
    () => ParentFamilyCubit(sl<ParentController>()),
  );
}