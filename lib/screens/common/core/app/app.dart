import 'package:flutter/material.dart';
import 'package:safini/screens/common/core/router/app_router.dart';
import 'package:safini/screens/common/core/theme/app_theme.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      title: 'Safini',
      theme: AppTheme.light,
      routerConfig: appRouter,
    );
  }
}
