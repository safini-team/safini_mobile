import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:safini/features/parent/presentation/screens/parent_main_screen.dart';

class AppRouter {
  late final RootStackRouter _router = RootStackRouter.build(
    routes: [
      NamedRouteDef(
        name: 'home',
        path: '/',
        builder: (context, data) => const ParentMainScreen(),
      ),
    ],
  );

  RouterConfig<Object> config() {
    return _router.config();
  }
}

class _HomePage extends StatelessWidget {
  const _HomePage();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Text('SAFINIO'),
      ),
    );
  }
}
