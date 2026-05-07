import 'package:safini/features/models/domain/models/child_model.dart';

enum ChildClaimStatus { initial, loading, success, error }

class ChildClaimState {
  final ChildClaimStatus status;
  final ChildModel? child;
  final String? errorMessage;

  const ChildClaimState({required this.status, this.child, this.errorMessage});

  const ChildClaimState.initial()
    : status = ChildClaimStatus.initial,
      child = null,
      errorMessage = null;

  ChildClaimState copyWith({
    ChildClaimStatus? status,
    ChildModel? child,
    String? errorMessage,
    bool clearChild = false,
  }) {
    return ChildClaimState(
      status: status ?? this.status,
      child: clearChild ? null : (child ?? this.child),
      errorMessage: errorMessage,
    );
  }
}
