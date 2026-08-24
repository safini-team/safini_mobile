import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:safini/features/common/profile/domain/controllers/profile_controller.dart';
import 'package:safini/features/common/profile/domain/models/profile_model.dart';

part 'profile_state.dart';

class ProfileCubit extends Cubit<ProfileState> {
  final ProfileController _controller;

  ProfileCubit(this._controller) : super(const ProfileState());

  Future<void> load() async {
    emit(state.copyWith(status: ProfileStatus.loading));
    final result = await _controller.fetchMe();
    result.fold(
      (failure) => emit(
        state.copyWith(
          status: ProfileStatus.error,
          errorMessage: failure.message,
        ),
      ),
      (data) => emit(state.copyWith(status: ProfileStatus.loaded, data: data)),
    );
  }
}
