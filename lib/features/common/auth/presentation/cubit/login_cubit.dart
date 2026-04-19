import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:safini/core/utils/constants/app_constants.dart';
import 'package:safini/features/common/auth/data/auth_google_sign_in_service.dart';
import 'package:safini/features/common/auth/presentation/cubit/login_state.dart';

class LoginCubit extends Cubit<LoginState> {
  LoginCubit(this._googleAuth, this._prefs) : super(const LoginState.initial());

  final AuthGoogleSignInService _googleAuth;
  final SharedPreferences _prefs;

  Future<void> signInWithGoogle() async {
    emit(state.copyWith(status: LoginStatus.loading, errorMessage: null));

    // Debug mode bypass — no real Supabase session, skip token storage
    if (kDebugMode) {
      await Future.delayed(const Duration(milliseconds: 500));
      emit(state.copyWith(status: LoginStatus.success));
      return;
    }

    try {
      final authResponse = await _googleAuth.signInWithGoogle();
      final token = authResponse.session?.accessToken;
      if (token != null) {
        await _prefs.setString(AppConstants.accessToken, token);
      }
      emit(state.copyWith(status: LoginStatus.success));
    } catch (e) {
      final message = e.toString().replaceFirst('Exception: ', '');
      emit(state.copyWith(status: LoginStatus.failure, errorMessage: message));
    }
  }

  void clearError() {
    if (state.status == LoginStatus.failure) {
      emit(const LoginState.initial());
    }
  }
}