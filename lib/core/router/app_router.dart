import 'package:go_router/go_router.dart';
import 'package:safini/core/utils/app_constants.dart';
import 'package:safini/features/auth/view/auth_splash_screen.dart';
import 'package:safini/features/tasks/view/task_list_screen.dart';

final GoRouter appRouter = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const AuthSplashScreen(),
    ),
    GoRoute(
      path: '/tasks',
      builder: (context, state) => const TaskListScreen(
        childId: AppConstants.defaultChildId,
      ),
    ),
    GoRoute(
      path: '/parent',
      builder: (context, state) => const ParentHomeScreen(),
    ),
  ],
);
