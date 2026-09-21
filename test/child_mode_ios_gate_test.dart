import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:safini/core/app/locale_cubit.dart';
import 'package:safini/core/config/platform_support.dart';
import 'package:safini/core/theme/app_theme.dart';
import 'package:safini/core/translation/generated/l10n.dart';
import 'package:safini/features/common/auth/presentation/pages/role_selection_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Child accounts reach the native Screen Time setup after claiming a profile.
Future<void> _pumpRoles(WidgetTester tester) async {
  SharedPreferences.setMockInitialValues({});
  final prefs = await SharedPreferences.getInstance();
  await tester.pumpWidget(
    BlocProvider(
      create: (_) => LocaleCubit(prefs)..setLocale(const Locale('en')),
      child: MaterialApp(
        theme: AppTheme.light,
        locale: const Locale('en'),
        localizationsDelegates: const [
          S.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: S.delegate.supportedLocales,
        home: const RoleSelectionPage(),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  tearDown(() => debugDefaultTargetPlatformOverride = null);

  testWidgets('iOS exposes child mode now that release setup is available', (
    tester,
  ) async {
    debugDefaultTargetPlatformOverride = TargetPlatform.iOS;
    expect(isChildModeAvailable, isTrue);
    await _pumpRoles(tester);
    expect(find.text('Earn coins & play'), findsOneWidget);
    expect(find.text('Back to sign in'), findsOneWidget);
    expect(find.text('Coming soon on iOS'), findsNothing);
    debugDefaultTargetPlatformOverride = null;
  });

  testWidgets('on Android the kid door is unchanged', (tester) async {
    debugDefaultTargetPlatformOverride = TargetPlatform.android;
    expect(isChildModeAvailable, isTrue);

    await _pumpRoles(tester);
    expect(find.text('Earn coins & play'), findsOneWidget);
    expect(find.text('Coming soon on iOS'), findsNothing);
    debugDefaultTargetPlatformOverride = null;
  });
}
