import 'package:flutter/material.dart';
import 'package:safini/core/di/injection.dart';
import 'package:safini/core/router/app_router.dart';
import 'package:safini/core/theme/app_theme.dart';

void main() {
  configureDependencies();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Safini',
      theme: AppTheme.light,
      routerConfig: appRouter,
    );
  }
}
