import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:safini/core/app/app_router.dart';
import 'package:safini/core/app/locale_cubit.dart';
import 'package:safini/core/di/injection.dart';
import 'package:safini/core/theme/app_theme.dart';
import 'package:safini/core/translation/generated/l10n.dart';
import 'package:safini/core/utils/constants/app_constants.dart';
import 'package:safini/features/child/presentation/cubit/coins_cubit.dart';
import 'package:safini/features/common/auth/presentation/cubit/auth_session_cubit.dart';
import 'package:safini/features/common/auth/presentation/cubit/child_claim_cubit.dart';
import 'package:safini/features/parent/presentation/cubit/parent_family_cubit.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  /// Null when the platform plugin is unavailable (widget tests); the locale
  /// then falls back to the system language for the session.
  static SharedPreferences? get _prefs =>
      getIt.isRegistered<SharedPreferences>() ? getIt<SharedPreferences>() : null;

  @override
  Widget build(BuildContext context) {
    final appRouter = getIt<AppRouter>();
    return MultiBlocProvider(
      providers: [
        BlocProvider.value(value: getIt<CoinsCubit>()),
        BlocProvider(create: (_) => LocaleCubit(_prefs)),
        BlocProvider.value(value: getIt<AuthSessionCubit>()),
        BlocProvider.value(value: getIt<ChildClaimCubit>()),
        BlocProvider.value(value: getIt<ParentFamilyCubit>()),
      ],
      child: BlocBuilder<LocaleCubit, Locale?>(
        builder: (context, locale) {
          return MaterialApp.router(
            debugShowCheckedModeBanner: false,
            title: AppConstants.appName,
            theme: AppTheme.light,
            locale: locale,
            localizationsDelegates: const [
              S.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: S.delegate.supportedLocales,
            // `locale` is null until the user picks one, so this decides what
            // the phone's own language maps to - and re-runs if they change it
            // in system settings while the app is open.
            localeListResolutionCallback: (deviceLocales, _) =>
                LocaleCubit.resolve(deviceLocales),
            routerConfig: appRouter.config(),
            builder: (context, child) {
              // Clamp the device text scale so extreme accessibility font
              // sizes can't overflow fixed-height layouts across the app.
              final mediaQuery = MediaQuery.of(context);
              final clampedScaler = mediaQuery.textScaler.clamp(
                minScaleFactor: 1.0,
                maxScaleFactor: 1.3,
              );
              return MediaQuery(
                data: mediaQuery.copyWith(textScaler: clampedScaler),
                child: child!,
              );
            },
          );
        },
      ),
    );
  }
}
