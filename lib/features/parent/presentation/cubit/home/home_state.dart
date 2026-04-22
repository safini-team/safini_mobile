class ParentHomeState {
  final int selectedIndex;

  const ParentHomeState({this.selectedIndex = 0});

  ParentHomeState copyWith({int? selectedIndex}) => ParentHomeState(
        selectedIndex: selectedIndex ?? this.selectedIndex,
      );
}
