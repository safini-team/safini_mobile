class ParentHomeState {
  final int selectedIndex;
  final String? selectedChildId;

  const ParentHomeState({this.selectedIndex = 0, this.selectedChildId});

  ParentHomeState copyWith({int? selectedIndex}) => ParentHomeState(
    selectedIndex: selectedIndex ?? this.selectedIndex,
    selectedChildId: selectedChildId,
  );
}
