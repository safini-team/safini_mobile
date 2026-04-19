part of 'profile_cubit.dart';

enum ProfileStatus { initial, loading, loaded, error }

class ProfileState {
  final ProfileStatus status;
  final ProfileModel? data;
  final String? errorMessage;

  const ProfileState({
    this.status = ProfileStatus.initial,
    this.data,
    this.errorMessage,
  });

  ProfileState copyWith({
    ProfileStatus? status,
    ProfileModel? data,
    String? errorMessage,
  }) {
    return ProfileState(
      status: status ?? this.status,
      data: data ?? this.data,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}