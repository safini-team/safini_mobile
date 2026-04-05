import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:safini/features/common/auth/presentation/pages/auth_page.dart';
import 'package:safini/features/child/presentation/screens/avatar_customizer_screen.dart';
import 'package:safini/features/child/presentation/screens/child_home_screen.dart';
import 'package:safini/features/child/presentation/screens/profile_screen.dart';
import 'package:safini/features/child/presentation/screens/reward_store_screen.dart';
import 'package:safini/features/child/presentation/screens/tasks_screen.dart';

class AppRouter {
  late final RootStackRouter _router = RootStackRouter.build(
    routes: [
      NamedRouteDef(
        name: 'auth',
        path: '/',
        builder: (context, data) => const AuthPage(),
      ),
      NamedRouteDef(
        name: 'store',
        path: '/store',
        builder: (context, data) => const RewardStoreScreen(),
      ),
      NamedRouteDef(
        name: 'tasks',
        path: '/tasks',
        builder: (context, data) => const TasksScreen(),
      ),
      NamedRouteDef(
        name: 'profile',
        path: '/profile',
        builder: (context, data) => const ProfileScreen(),
      ),
      NamedRouteDef(
        name: 'avatar',
        path: '/avatar',
        builder: (context, data) => const AvatarCustomizerScreen(),
      ),
    ],
  );

  RouterConfig<Object> config() {
    return _router.config();
  }
}

