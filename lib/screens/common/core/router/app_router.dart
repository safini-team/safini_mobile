import 'package:go_router/go_router.dart';
import 'package:safini/screens/common/auth/presentation/pages/parent_home_page.dart';
import 'package:safini/screens/parent/main_screen.dart';

final GoRouter appRouter = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(path: '/', builder: (context, state) => const MainScreen()),

    GoRoute(
      path: '/parent',
      builder: (context, state) => const ParentHomeScreen(),
    ),
  ],
);
