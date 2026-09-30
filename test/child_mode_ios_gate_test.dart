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

/// iOS shows the coming-soon message; Android keeps the child entry.
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

  testWidgets('iOS labels kid mode as coming soon', (tester) async {
    debugDefaultTargetPlatformOverride = TargetPlatform.iOS;
    expect(isChildModeAvailable, isFalse);
    await _pumpRoles(tester);
    expect(find.text('Coming soon on iOS'), findsOneWidget);
    expect(find.text('Back to sign in'), findsOneWidget);
    expect(find.text('Earn coins & play'), findsNothing);
    await tester.tap(find.byKey(const ValueKey('role-kid')));
    await tester.pumpAndSettle();
    expect(find.text('Kid mode is coming to iPhone'), findsOneWidget);
    expect(find.textContaining('Kid mode isn\'t available on iPhone yet'), findsOneWidget);
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
