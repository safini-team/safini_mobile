import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:safini/features/common/auth/presentation/pages/auth_page.dart';

class AppRouter {
  late final RootStackRouter _router = RootStackRouter.build(
    routes: [
      NamedRouteDef(
        name: 'auth',
        path: '/',
        builder: (context, data) => const AuthPage(),
      ),
    ],
  );

  RouterConfig<Object> config() {
    return _router.config();
  }
}
