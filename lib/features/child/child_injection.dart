import 'package:get_it/get_it.dart';
import 'package:safini/features/child/domain/controllers/child_controller.dart';
import 'package:safini/features/child/presentation/cubit/child_cubit.dart';
import 'package:safini/features/child/presentation/cubit/coins_cubit.dart';
import 'package:safini/features/child/presentation/cubit/tasks_cubit.dart';
import 'package:safini/features/child/presentation/cubit/profile_cubit.dart';
import 'package:safini/features/child/presentation/cubit/quest_cubit.dart';
import 'package:safini/features/child/presentation/cubit/reward_store_cubit.dart';
import 'package:safini/features/child/presentation/cubit/home/home_cubit.dart';

void registerChildDependencies(GetIt sl) {
  sl.registerLazySingleton<ChildController>(() => const ChildController());

  sl.registerLazySingleton<CoinsCubit>(() => CoinsCubit());

  sl.registerFactory<ChildCubit>(() => ChildCubit());
  sl.registerFactory<ChildHomeCubit>(() => ChildHomeCubit());
  sl.registerFactory<TasksCubit>(() => TasksCubit(sl<CoinsCubit>()));
  sl.registerFactory<ProfileCubit>(() => ProfileCubit());
  sl.registerFactory<AvatarCubit>(() => AvatarCubit(sl<CoinsCubit>()));
  sl.registerFactory<QuestCubit>(() => QuestCubit());
  sl.registerFactory<RewardStoreCubit>(
    () => RewardStoreCubit(sl<CoinsCubit>()),
  );
}