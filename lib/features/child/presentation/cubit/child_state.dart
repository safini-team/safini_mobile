import 'package:safini/features/child/domain/models/child_model.dart';

enum ChildStatus { initial, loading, loaded, error }

class ChildState {
  final ChildStatus status;
  final List<ChildModel> children;
  final String? errorMessage;

  const ChildState({
    this.status = ChildStatus.initial,
    this.children = const [],
    this.errorMessage,
  });

  const ChildState.initial()
      : status = ChildStatus.initial,
        children = const [],
        errorMessage = null;

  ChildState copyWith({
    ChildStatus? status,
    List<ChildModel>? children,
    String? errorMessage,
  }) {
    return ChildState(
      status: status ?? this.status,
      children: children ?? this.children,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}
