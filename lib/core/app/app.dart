import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:safini/core/app/app_router.dart';
import 'package:safini/core/app/locale_cubit.dart';
import 'package:safini/core/di/injection.dart';
import 'package:safini/core/theme/app_theme.dart';
import 'package:safini/core/translation/generated/l10n.dart';
import 'package:safini/core/utils/constants/app_constants.dart';
import 'package:safini/features/child/presentation/cubit/coins_cubit.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final appRouter = getIt<AppRouter>();
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => CoinsCubit()),
        BlocProvider(create: (_) => LocaleCubit()),
      ],
      child: MaterialApp.router(
        debugShowCheckedModeBanner: false,
        title: AppConstants.appName,
        theme: AppTheme.light,
        localizationsDelegates: const [
          S.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: S.delegate.supportedLocales,
        localeListResolutionCallback: (locales, supportedLocales) {
          // This is where we handle independent locales for different parts of the app
          // However, MaterialApp only takes ONE locale.
          // We will use a Builder in specific pages to override the locale.
          return null;
        },
        routerConfig: appRouter.config(),
      ),
    );
  }
}
