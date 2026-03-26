import 'package:get_it/get_it.dart';
import 'package:safini/data/repositories/task_repository_impl.dart';
import 'package:safini/features/tasks/controller/task_controller.dart';
import 'package:safini/features/tasks/cubit/task_cubit.dart';
import 'package:safini/features/tasks/repository/task_repository.dart';

final GetIt getIt = GetIt.instance;

void configureDependencies() {
  if (!getIt.isRegistered<TaskRepository>()) {
    getIt.registerLazySingleton<TaskRepository>(TaskRepositoryImpl.new);
  }

  if (!getIt.isRegistered<TaskController>()) {
    getIt.registerFactory<TaskController>(() => TaskController(getIt()));
  }

  if (!getIt.isRegistered<TaskCubit>()) {
    getIt.registerFactory<TaskCubit>(() => TaskCubit(getIt()));
  }
}
