import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:safini/core/network/auth_token_provider.dart';
import 'package:safini/core/network/authenticated_http_client.dart';
import 'package:safini/core/theme/app_theme.dart';
import 'package:safini/core/translation/generated/l10n.dart';
import 'package:safini/core/utils/widgets/ds/ds_toast.dart';
import 'package:safini/features/common/auth/data/auth_apple_sign_in_service.dart';
import 'package:safini/features/common/auth/data/auth_email_sign_in_service.dart';
import 'package:safini/features/common/auth/data/auth_google_sign_in_service.dart';
import 'package:safini/features/common/auth/data/user_me_service.dart';
import 'package:safini/features/common/auth/presentation/cubit/auth_session_cubit.dart';
import 'package:safini/features/common/auth/presentation/cubit/auth_session_state.dart';
import 'package:safini/features/parent/data/datasources/local/parent_app_lock_store.dart';
import 'package:safini/features/parent/domain/parent_pin_hasher.dart';
import 'package:safini/features/parent/presentation/cubit/app_lock/parent_app_lock_cubit.dart';
import 'package:safini/features/parent/presentation/screens/app_lock/parent_app_lock_settings_screen.dart';
import 'package:safini/features/parent/presentation/widgets/app_lock/parent_app_lock_host.dart';

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

class _SeededAuth extends AuthSessionCubit {
  _SeededAuth()
    : super(
        AuthGoogleSignInService(),
        AuthAppleSignInService(),
        AuthEmailSignInService(),
        UserMeService(AuthenticatedHttpClient(_FakeTokens())),
        _FakeTokens(),
      );

  int signOutCalls = 0;
  bool failSignOut = false;

  @override
  Future<void> signOut() async {
    signOutCalls++;
    if (failSignOut) throw StateError('Sign-out unavailable');
    emit(const AuthSessionState(status: AuthSessionStatus.unauthenticated));
  }

  void seed(String? accountType) {
    emit(
      AuthSessionState(
        status: AuthSessionStatus.authenticated,
        userId: 'user-1',
        accountType: accountType,
      ),
    );
  }
}

Future<void> _enterPin(WidgetTester tester, String pin) async {
  for (final digit in pin.split('')) {
    await tester.tap(find.byKey(ValueKey('app-lock-digit-$digit')));
    await tester.pump();
  }
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 100));
}

Widget _app({
  required AuthSessionCubit auth,
  required ParentAppLockCubit lock,
  required Widget home,
}) {
  return MultiBlocProvider(
    providers: [
      BlocProvider.value(value: auth),
      BlocProvider.value(value: lock),
    ],
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
      builder: (context, child) => RepaintBoundary(
        key: const ValueKey('app-lock-shot'),
        child: child ?? const SizedBox.shrink(),
      ),
      home: home,
    ),
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late MemoryParentAppLockStore store;
  late ParentAppLockCubit lock;
  late _SeededAuth auth;

  setUp(() {
    store = MemoryParentAppLockStore();
    lock = ParentAppLockCubit(store: store, hasher: const ParentPinHasher());
    auth = _SeededAuth()..seed('parent');
  });

  tearDown(() async {
    await lock.close();
    await auth.close();
  });

  testWidgets('lock gate covers parent chrome until the PIN is entered', (
    tester,
  ) async {
    await store.write(const ParentPinHasher().hash('2580'));
    await tester.pumpWidget(
      _app(
        auth: auth,
        lock: lock,
        home: const ParentAppLockHost(
          child: Scaffold(body: Text('PARENT SHELL')),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Enter your PIN'), findsOneWidget);
    expect(find.text('PARENT SHELL').hitTestable(), findsNothing);

    await _enterPin(tester, '0000');
    await tester.pumpAndSettle();
    expect(find.text("That PIN doesn't match"), findsOneWidget);
    expect(find.text('PARENT SHELL').hitTestable(), findsNothing);

    await _enterPin(tester, '2580');
    await tester.pumpAndSettle();
    expect(find.text('Enter your PIN'), findsNothing);
    expect(find.text('PARENT SHELL').hitTestable(), findsOneWidget);
  });

  testWidgets('child accounts never see the parent lock', (tester) async {
    auth.seed('child');
    await store.write(const ParentPinHasher().hash('2580'));
    await tester.pumpWidget(
      _app(
        auth: auth,
        lock: lock,
        home: const ParentAppLockHost(
          child: Scaffold(body: Text('CHILD SHELL')),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('Enter your PIN'), findsNothing);
    expect(find.text('CHILD SHELL'), findsOneWidget);
  });

  testWidgets('forgot PIN reveals a working sign-out with cancel and retry', (
    tester,
  ) async {
    await store.write(const ParentPinHasher().hash('2580'));
    await tester.pumpWidget(
      _app(
        auth: auth,
        lock: lock,
        home: const ParentAppLockHost(
          child: Scaffold(body: Text('PARENT SHELL')),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byKey(const ValueKey('app-lock-forgot')), findsOneWidget);
    expect(find.byKey(const ValueKey('app-lock-sign-out')), findsNothing);

    await tester.tap(find.byKey(const ValueKey('app-lock-forgot')));
    await tester.pumpAndSettle();
    expect(find.text('Forgot password?'), findsOneWidget);
    expect(find.byKey(const ValueKey('app-lock-sign-out')), findsOneWidget);

    await tester.tap(find.byKey(const ValueKey('app-lock-recovery-cancel')));
    await tester.pumpAndSettle();
    expect(find.text('Enter your PIN'), findsOneWidget);
    expect(find.byKey(const ValueKey('app-lock-sign-out')), findsNothing);

    await tester.tap(find.byKey(const ValueKey('app-lock-forgot')));
    await tester.pumpAndSettle();
    auth.failSignOut = true;
    await tester.tap(find.byKey(const ValueKey('app-lock-sign-out')));
    await tester.pumpAndSettle();
    expect(find.text('Could not sign out. Try again.'), findsOneWidget);
    expect(auth.state.status, AuthSessionStatus.authenticated);

    auth.failSignOut = false;
    await tester.tap(find.byKey(const ValueKey('app-lock-sign-out')));
    await tester.pumpAndSettle();
    expect(auth.signOutCalls, 2);
    expect(auth.state.status, AuthSessionStatus.unauthenticated);
    expect(find.byKey(const ValueKey('app-lock-sign-out')), findsNothing);
  });

  testWidgets('locking again covers parent chrome with the PIN gate', (
    tester,
  ) async {
    await store.write(const ParentPinHasher().hash('2580'));
    await tester.pumpWidget(
      _app(
        auth: auth,
        lock: lock,
        home: const ParentAppLockHost(
          child: Scaffold(body: Text('PARENT SHELL')),
        ),
      ),
    );
    await tester.pumpAndSettle();
    await _enterPin(tester, '2580');
    await tester.pumpAndSettle();
    expect(find.text('Enter your PIN'), findsNothing);
    expect(find.text('PARENT SHELL').hitTestable(), findsOneWidget);

    lock.lockOnBackground();
    expect(lock.state.locked, isTrue);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));
    expect(find.text('Enter your PIN'), findsOneWidget);
    expect(find.text('PARENT SHELL').hitTestable(), findsNothing);
    expect(find.text('PARENT SHELL').hitTestable(), findsNothing);
  });

  testWidgets('settings can enable, change, and disable the PIN', (
    tester,
  ) async {
    await lock.load();
    await tester.pumpWidget(
      _app(auth: auth, lock: lock, home: const ParentAppLockSettingsScreen()),
    );
    await tester.pumpAndSettle();

    expect(find.text('Ask for a PIN when you open Safini'), findsOneWidget);
    await tester.tap(find.byKey(const ValueKey('app-lock-toggle')));
    await tester.pumpAndSettle();
    expect(find.text('Choose a 4-digit PIN'), findsOneWidget);

    await _enterPin(tester, '2580');
    await tester.pumpAndSettle();
    expect(find.text('Type it again'), findsOneWidget);

    await _enterPin(tester, '1111');
    await tester.pumpAndSettle();
    expect(find.text("Those PINs didn't match. Try again."), findsOneWidget);

    await _enterPin(tester, '2580');
    await tester.pump();
    DsToast.dismiss();
    expect(lock.state.enabled, isTrue);
    expect(find.text('Change PIN'), findsOneWidget);

    await tester.tap(find.text('Change PIN'));
    await tester.pumpAndSettle();
    expect(find.text('Enter your current PIN'), findsOneWidget);
    await _enterPin(tester, '2580');
    await tester.pumpAndSettle();
    expect(find.text('Choose a new PIN'), findsOneWidget);
    await _enterPin(tester, '1470');
    await tester.pumpAndSettle();
    expect(find.text('Type the new PIN again'), findsOneWidget);
    await _enterPin(tester, '1470');
    await tester.pump();
    DsToast.dismiss();
    expect(lock.state.notice, isNull);

    await tester.tap(find.byKey(const ValueKey('app-lock-toggle')));
    await tester.pumpAndSettle();
    await _enterPin(tester, '1470');
    await tester.pump();
    DsToast.dismiss();
    await tester.pump(const Duration(seconds: 3));
    expect(lock.state.enabled, isFalse);
    expect(find.text('Change PIN'), findsNothing);
  });
}
