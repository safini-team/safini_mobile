import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';
import 'package:safini/features/child/data/datasources/child_remote_datasource.dart';
import 'package:safini/features/child/data/repositories/child_repository_impl.dart';
import 'package:safini/features/child/domain/controllers/child_controller.dart';
import 'package:safini/features/child/domain/repositories/i_child_repository.dart';
import 'package:safini/features/child/presentation/cubit/child_cubit.dart';
import 'package:safini/features/child/presentation/cubit/coins_cubit.dart';
import 'package:safini/features/child/presentation/cubit/tasks_cubit.dart';
import 'package:safini/features/child/presentation/cubit/profile_cubit.dart';
import 'package:safini/features/child/presentation/cubit/quest_cubit.dart';
import 'package:safini/features/child/presentation/cubit/reward_store_cubit.dart';
import 'package:safini/features/child/presentation/cubit/home/home_cubit.dart';
import 'package:safini/features/common/profile/data/repositories/profile_repository.dart';
import 'package:safini/features/common/profile/domain/controllers/profile_controller.dart'
    as safini_profile;

void registerChildDependencies(GetIt sl) {
  // Data sources
  sl.registerLazySingleton<ChildRemoteDataSource>(
    () => ChildRemoteDataSource(sl<Dio>()),
  );

  // Repositories
  sl.registerLazySingleton<IChildRepository>(
    () => ChildRepositoryImpl(sl<ChildRemoteDataSource>()),
  );

  // Controllers
  sl.registerLazySingleton<ChildController>(
    () => ChildController(sl<IChildRepository>()),
  );

  sl.registerLazySingleton<CoinsCubit>(() => CoinsCubit());

  sl.registerFactory<ChildCubit>(() => ChildCubit(sl<ChildController>()));
  sl.registerFactory<ChildHomeCubit>(() => ChildHomeCubit());
  sl.registerFactory<TasksCubit>(
    () => TasksCubit(
      sl<CoinsCubit>(),
      sl<safini_profile.ProfileController>(),
      sl<IChildRepository>(),
    ),
  );
  sl.registerFactory<ProfileCubit>(
    () => ProfileCubit(
      sl<ChildController>(),
      sl<ProfileRepository>(),
      sl<CoinsCubit>(),
    ),
  );
  sl.registerFactory<AvatarCubit>(
    () => AvatarCubit(
      sl<CoinsCubit>(),
      sl<Dio>(),
      sl<safini_profile.ProfileController>(),
    ),
  );
  sl.registerFactory<QuestCubit>(
    () => QuestCubit(
      sl<safini_profile.ProfileController>(),
      sl<IChildRepository>(),
    ),
  );
  sl.registerFactory<RewardStoreCubit>(
    () => RewardStoreCubit(
      sl<CoinsCubit>(),
      sl<Dio>(),
      sl<safini_profile.ProfileController>(),
    ),
  );
}
