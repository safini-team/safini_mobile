import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:safini/features/common/auth/presentation/pages/auth_page.dart';
import 'package:safini/features/common/auth/presentation/pages/family_decision_page.dart';
import 'package:safini/features/common/auth/presentation/pages/login_page.dart';
import 'package:safini/features/common/auth/presentation/pages/role_selection_page.dart';
import 'package:safini/features/common/splash/splash_screen.dart';
import 'package:safini/features/child/presentation/screens/main/child_main_screen.dart';
import 'package:safini/features/child/presentation/screens/avatar/child_avatar_customizer_screen.dart';
import 'package:safini/features/parent/presentation/screens/main/parent_main_screen.dart';

class AppRouter {
  late final RootStackRouter _router = RootStackRouter.build(
    routes: [
      NamedRouteDef(
        name: 'splash',
        path: '/',
        builder: (context, data) => const SplashScreen(),
      ),
      NamedRouteDef(
        name: 'login',
        path: '/login',
        builder: (context, data) => const LoginPage(),
      ),
      NamedRouteDef(
        name: 'auth',
        path: '/auth',
        builder: (context, data) => const AuthPage(),
      ),
      NamedRouteDef(
        name: 'roleSelection',
        path: '/role-selection',
        builder: (context, data) => const RoleSelectionPage(),
      ),
      NamedRouteDef(
        name: 'familyDecision',
        path: '/family-decision',
        builder: (context, data) => const FamilyDecisionPage(),
      ),
      NamedRouteDef(
        name: 'childHome',
        path: '/child-home',
        builder: (context, data) => const ChildMainScreen(),
      ),
      NamedRouteDef(
        name: 'parentHome',
        path: '/parent-home',
        builder: (context, data) => const ParentMainScreen(),
      ),
      NamedRouteDef(
        name: 'avatar',
        path: '/avatar',
        builder: (context, data) => const ChildAvatarCustomizerScreen(),
      ),
    ],
  );

  RouterConfig<Object> config() {
    return _router.config();
  }

  void navigateToSplash() => _router.navigatePath('/');
}
