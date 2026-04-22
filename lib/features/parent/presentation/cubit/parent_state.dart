import 'package:safini/features/parent/domain/models/parent_user_model.dart';

class ParentState {
  final bool isLoading;
  final ParentUserModel? user;

  const ParentState({
    required this.isLoading,
    this.user,
  });

  const ParentState.initial()
      : isLoading = false,
        user = null;

  ParentState copyWith({
    bool? isLoading,
    ParentUserModel? user,
  }) {
    return ParentState(
      isLoading: isLoading ?? this.isLoading,
      user: user ?? this.user,
    );
  }
}
