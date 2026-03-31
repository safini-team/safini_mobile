class ParentState {
  final bool isLoading;

  const ParentState({required this.isLoading});

  const ParentState.initial() : isLoading = false;

  ParentState copyWith({bool? isLoading}) {
    return ParentState(isLoading: isLoading ?? this.isLoading);
  }
}
