import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:safini/core/di/injection.dart';
import 'package:safini/core/utils/constants/app_constants.dart';
import 'package:safini/features/common/auth/data/auth_email_sign_in_service.dart';
import 'package:safini/features/common/auth/data/auth_google_sign_in_service.dart';
import 'package:safini/features/common/auth/data/user_me_service.dart';
import 'package:safini/features/common/auth/presentation/cubit/auth_session_cubit.dart';
import 'package:safini/features/common/auth/presentation/cubit/auth_session_state.dart';

class _FakeGoogleAuth extends AuthGoogleSignInService {
  bool signOutCalled = false;

  @override
  Future<void> signOut() async {
    signOutCalled = true;
  }
}

class _FakeEmailAuth extends AuthEmailSignInService {
  String? receivedEmail;
  String? receivedPassword;

  @override
  Future<AuthResponse> signIn({
    required String email,
    required String password,
  }) async {
    receivedEmail = email;
    receivedPassword = password;
    throw const AuthEmailSignInFailure('Invalid test credentials');
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  tearDown(() async {
    await getIt.reset();
  });

  test('signOut clears Google, local token, and session state', () async {
    SharedPreferences.setMockInitialValues({
      AppConstants.accessToken: 'stale-token',
    });
    final preferences = await SharedPreferences.getInstance();
    getIt.registerSingleton<SharedPreferences>(preferences);

    final googleAuth = _FakeGoogleAuth();
    final cubit = AuthSessionCubit(
      googleAuth,
      _FakeEmailAuth(),
      UserMeService(),
    );
    addTearDown(cubit.close);

    await cubit.signOut();

    expect(googleAuth.signOutCalled, isTrue);
    expect(preferences.getString(AppConstants.accessToken), isNull);
    expect(cubit.state.status, AuthSessionStatus.unauthenticated);
  });

  test('email sign-in delegates credentials and reports auth errors', () async {
    final emailAuth = _FakeEmailAuth();
    final cubit = AuthSessionCubit(
      _FakeGoogleAuth(),
      emailAuth,
      UserMeService(),
    );
    addTearDown(cubit.close);

    await cubit.signInWithEmail(
      email: '  reviewer@safini.fun  ',
      password: 'review-password',
    );

    expect(emailAuth.receivedEmail, 'reviewer@safini.fun');
    expect(emailAuth.receivedPassword, 'review-password');
    expect(cubit.state.status, AuthSessionStatus.signInError);
    expect(cubit.state.errorMessage, 'Invalid test credentials');
  });
}
