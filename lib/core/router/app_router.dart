import 'package:go_router/go_router.dart';
import 'package:safini/features/common/auth/presentation/pages/auth_splash_page.dart';
import 'package:safini/features/common/auth/presentation/pages/parent_home_page.dart';

final GoRouter appRouter = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(path: '/', builder: (context, state) => const AuthSplashScreen()),

    GoRoute(
      path: '/parent',
      builder: (context, state) => const ParentHomeScreen(),
    ),
  ],
);
