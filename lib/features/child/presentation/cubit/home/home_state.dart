class ChildHomeState {
  final int selectedIndex;

  const ChildHomeState({this.selectedIndex = 0});

  ChildHomeState copyWith({int? selectedIndex}) => ChildHomeState(
        selectedIndex: selectedIndex ?? this.selectedIndex,
      );
}
