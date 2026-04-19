import 'package:get_it/get_it.dart';
import 'package:safini/features/common/auth/data/auth_google_sign_in_service.dart';
import 'package:safini/features/common/auth/presentation/cubit/login_cubit.dart';

void registerCommonDependencies(GetIt sl) {
  sl.registerLazySingleton<AuthGoogleSignInService>(
    AuthGoogleSignInService.new,
  );
  sl.registerFactory<LoginCubit>(() => LoginCubit(sl<AuthGoogleSignInService>()));
}