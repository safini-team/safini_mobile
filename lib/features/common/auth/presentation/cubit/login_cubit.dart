import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:safini/features/common/auth/data/auth_google_sign_in_service.dart';
import 'package:safini/features/common/auth/presentation/cubit/login_state.dart';

import 'package:flutter/foundation.dart'; // for debug mode bypass

class LoginCubit extends Cubit<LoginState> {
  LoginCubit(this._googleAuth) : super(const LoginState.initial());

  final AuthGoogleSignInService _googleAuth;

  Future<void> signInWithGoogle() async {
    // Debug mode bypass
    if (kDebugMode) {
      await Future.delayed(const Duration(milliseconds: 500));
      emit(state.copyWith(status: LoginStatus.success));
      return;
    }

    emit(state.copyWith(status: LoginStatus.loading, errorMessage: null));
    try {
      await _googleAuth.signInWithGoogle();
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
