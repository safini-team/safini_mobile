import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:safini/core/utils/constants/app_constants.dart';
import 'package:safini/features/common/auth/data/auth_google_sign_in_service.dart';
import 'package:safini/features/common/auth/presentation/cubit/login_state.dart';
import 'package:safini/features/common/profile/domain/controllers/profile_controller.dart';

class LoginCubit extends Cubit<LoginState> {
  LoginCubit(this._googleAuth, this._prefs, this._profileController)
      : super(const LoginState.initial());

  final AuthGoogleSignInService _googleAuth;
  final SharedPreferences _prefs;
  final ProfileController _profileController;

  Future<void> signInWithGoogle() async {
    emit(state.copyWith(status: LoginStatus.loading, errorMessage: null));

    try {
      debugPrint('[LoginCubit] Starting Google sign-in…');
      final authResponse = await _googleAuth.signInWithGoogle();

      final token = authResponse.session?.accessToken;
      debugPrint('[LoginCubit] Access token received: ${token != null ? '✓ (${token.length} chars)' : '✗ null'}');

      if (token != null) {
        await _prefs.setString(AppConstants.accessToken, token);
        debugPrint('[LoginCubit] Token saved to SharedPreferences');
      }

      debugPrint('[LoginCubit] Fetching profile…');
      final profileResult = await _profileController.fetchMe();

      profileResult.fold(
        (failure) {
          debugPrint('[LoginCubit] Profile fetch FAILED: ${failure.message}');
        },
        (profile) {
          debugPrint('[LoginCubit] Profile fetch SUCCESS — accountType: ${profile.accountType}');
        },
      );

      final accountType = profileResult.fold((_) => null, (p) => p.accountType);
      debugPrint('[LoginCubit] Emitting success with accountType: $accountType');
      emit(state.copyWith(status: LoginStatus.success, accountType: accountType));
    } catch (e) {
      debugPrint('[LoginCubit] Unexpected error: $e');
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