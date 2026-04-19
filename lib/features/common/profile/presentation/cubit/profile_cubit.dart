import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:safini/core/utils/constants/app_constants.dart';
import 'package:safini/features/common/profile/domain/controllers/profile_controller.dart';
import 'package:safini/features/common/profile/domain/models/profile_model.dart';

part 'profile_state.dart';

class ProfileCubit extends Cubit<ProfileState> {
  final ProfileController _controller;
  final SharedPreferences _prefs;

  ProfileCubit(this._controller, this._prefs) : super(const ProfileState());

  Future<void> load() async {
    if (_prefs.getString(AppConstants.accessToken) == null) return;

    emit(state.copyWith(status: ProfileStatus.loading));
    final result = await _controller.fetchMe();
    result.fold(
      (failure) => emit(
        state.copyWith(status: ProfileStatus.error, errorMessage: failure.message),
      ),
      (data) => emit(state.copyWith(status: ProfileStatus.loaded, data: data)),
    );
  }
}