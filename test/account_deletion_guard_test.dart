import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:safini/core/network/auth_token_provider.dart';
import 'package:safini/core/network/authenticated_http_client.dart';
import 'package:safini/core/theme/app_motion.dart';
import 'package:safini/core/theme/app_theme.dart';
import 'package:safini/core/translation/generated/l10n.dart';
import 'package:safini/core/utils/constants/app_constants.dart';
import 'package:safini/features/common/auth/data/auth_apple_sign_in_service.dart';
import 'package:safini/features/common/auth/data/auth_email_sign_in_service.dart';
import 'package:safini/features/common/auth/data/auth_google_sign_in_service.dart';
import 'package:safini/features/common/auth/data/user_me_service.dart';
import 'package:safini/features/common/auth/presentation/account_deletion_flow.dart';
import 'package:safini/features/common/auth/presentation/cubit/auth_session_cubit.dart';
import 'package:safini/features/common/auth/presentation/cubit/auth_session_state.dart';

// SAF-171 gates account deletion on the account type the session reports.
// `account_type` is derived from the family, so it is null between sign-in and
// the first `GET /v1/me` that sees one: a parent who just created their family
// carries that null and must still be able to delete their own account. Only a
// confirmed child is sent to ask a parent.
class _FakeTokens implements AuthTokenProvider {
  @override
  bool hasSession = true;

  @override
  String? currentAccessToken;

  @override
  Future<String?> getAccessToken() async => currentAccessToken;

  @override
  Future<String?> refreshAfterUnauthorized(String? rejectedAccessToken) async =>
      currentAccessToken;
}

class _SeededAuthSession extends AuthSessionCubit {
  _SeededAuthSession(AuthTokenProvider tokens)
    : super(
        AuthGoogleSignInService(),
        AuthAppleSignInService(),
        AuthEmailSignInService(),
        UserMeService(AuthenticatedHttpClient(tokens)),
        tokens,
      );

  void seed(String? accountType) => emit(
    AuthSessionState(
      status: AuthSessionStatus.authenticated,
      userId: 'user-1',
      accountType: accountType,
    ),
  );
}

Future<_SeededAuthSession> _host(
  WidgetTester tester,
  String? accountType,
) async {
  final auth = _SeededAuthSession(_FakeTokens())..seed(accountType);
  addTearDown(auth.close);

  await tester.pumpWidget(
    BlocProvider<AuthSessionCubit>.value(
      value: auth,
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
        home: Scaffold(
          body: Builder(
            builder: (context) => TextButton(
              onPressed: () => showAccountDeletionFlow(context),
              child: const Text('delete'),
            ),
          ),
        ),
      ),
    ),
  );
  return auth;
}

void main() {
  setUpAll(() async {
    await S.load(const Locale('en'));
  });

  testWidgets('a child is told to ask a parent, and no sheet opens', (
    tester,
  ) async {
    await _host(tester, AppConstants.accountTypeChild);

    await tester.tap(find.text('delete'));
    await tester.pump();
    await tester.pump(AppMotion.toast);

    expect(find.text(S.current.askParentToDeleteAccount), findsOneWidget);
    expect(find.text(S.current.deleteAccountConfirmTitle), findsNothing);

    await tester.pump(AppMotion.toastDwell);
  });

  testWidgets('a parent still reaches the confirmation sheet', (tester) async {
    await _host(tester, AppConstants.accountTypeParent);

    await tester.tap(find.text('delete'));
    await tester.pumpAndSettle();

    expect(find.text(S.current.deleteAccountConfirmTitle), findsOneWidget);
    expect(find.text(S.current.askParentToDeleteAccount), findsNothing);

    await tester.tap(find.text(S.current.cancel));
    await tester.pumpAndSettle();
  });

  testWidgets('a session that has not resolved a role is treated as a parent', (
    tester,
  ) async {
    await _host(tester, null);

    await tester.tap(find.text('delete'));
    await tester.pumpAndSettle();

    expect(find.text(S.current.deleteAccountConfirmTitle), findsOneWidget);
    expect(find.text(S.current.askParentToDeleteAccount), findsNothing);

    await tester.tap(find.text(S.current.cancel));
    await tester.pumpAndSettle();
  });
}
