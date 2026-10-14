/// The parent tab bar, in order (SAF-271 put Fini before Family).
abstract final class ParentTab {
  static const today = 0;
  static const tasks = 1;
  static const limits = 2;
  static const fini = 3;
  static const family = 4;
}

class ParentHomeState {
  final int selectedIndex;
  final String? selectedChildId;

  /// Set when something outside Limits asks it to open on its Prizes view,
  /// and cleared by Limits once it has.
  final bool showPrizes;

  const ParentHomeState({
    this.selectedIndex = 0,
    this.selectedChildId,
    this.showPrizes = false,
  });

  ParentHomeState copyWith({int? selectedIndex, bool? showPrizes}) =>
      ParentHomeState(
        selectedIndex: selectedIndex ?? this.selectedIndex,
        selectedChildId: selectedChildId,
        showPrizes: showPrizes ?? this.showPrizes,
      );
}
