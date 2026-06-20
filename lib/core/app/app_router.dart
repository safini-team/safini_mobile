import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:safini/features/common/auth/presentation/pages/auth_page.dart';
import 'package:safini/features/common/auth/presentation/pages/create_family_page.dart';
import 'package:safini/features/common/auth/presentation/pages/enter_invite_code_page.dart';
import 'package:safini/features/common/auth/presentation/pages/family_decision_page.dart';
import 'package:safini/features/common/auth/presentation/pages/login_page.dart';
import 'package:safini/features/common/auth/presentation/pages/join_family_page.dart';
import 'package:safini/features/common/auth/presentation/pages/role_selection_page.dart';
import 'package:safini/features/common/profile/presentation/pages/edit_profile_page.dart';
import 'package:safini/features/common/splash/splash_screen.dart';
import 'package:safini/features/child/presentation/screens/main/child_main_screen.dart';
import 'package:safini/features/child/presentation/screens/avatar/child_avatar_customizer_screen.dart';
import 'package:safini/features/parent/presentation/screens/family/add_child_page.dart';
import 'package:safini/features/parent/presentation/screens/main/parent_main_screen.dart';
import 'package:safini/features/parent/presentation/screens/settings/parent_settings_screen.dart';

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
        name: 'createFamily',
        path: '/create-family',
        builder: (context, data) => const CreateFamilyPage(),
      ),
      NamedRouteDef(
        name: 'joinFamily',
        path: '/join-family',
        builder: (context, data) => const JoinFamilyPage(),
      ),
      NamedRouteDef(
        name: 'enterInviteCode',
        path: '/enter-invite-code',
        builder: (context, data) => const EnterInviteCodePage(),
      ),
      NamedRouteDef(
        name: 'editProfile',
        path: '/edit-profile',
        builder: (context, data) => const EditProfilePage(),
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
        name: 'addChild',
        path: '/add-child',
        builder: (context, data) => const AddChildPage(),
      ),
      NamedRouteDef(
        name: 'avatar',
        path: '/avatar',
        builder: (context, data) => const ChildAvatarCustomizerScreen(),
      ),
      NamedRouteDef(
        name: 'parentSettings',
        path: '/parent-settings',
        builder: (context, data) => const ParentSettingsScreen(),
      ),
    ],
  );

  RouterConfig<Object> config() {
    return _router.config();
  }

  void navigateToSplash() => _router.navigatePath('/');
}
