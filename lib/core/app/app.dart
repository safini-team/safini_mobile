import 'package:flutter/material.dart';
import 'package:safini/core/app/app_router.dart';
import 'package:safini/core/di/injection.dart';
import 'package:safini/core/theme/app_theme.dart';
import 'package:safini/core/utils/app_constants.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final appRouter = getIt<AppRouter>();
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      title: AppConstants.appName,
      theme: AppTheme.light,
      routerConfig: appRouter.config(),
    );
  }
}
