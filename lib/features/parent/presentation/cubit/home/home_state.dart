class ParentHomeState {
  /// [selectedChildId] once the parent picked "Everyone" in the stories row.
  static const everyone = '*';

  final int selectedIndex;

  /// Shared by Today, Tasks, Limits and Fini, so the pick survives a tab
  /// switch. Null until the parent picks; read it through [kidScope].
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

/// Whom a tab shows: a child's id, or null for Everyone.
///
/// Before the parent picks anyone, a family with two or more children opens
/// on Everyone and a family with one child on that child, so the common case
/// keeps its full Today card. A pick of a child who is gone falls back the
/// same way.
String? kidScope(String? selectedChildId, List<String> kidIds) {
  if (selectedChildId == ParentHomeState.everyone) return null;
  if (selectedChildId != null && kidIds.contains(selectedChildId)) {
    return selectedChildId;
  }
  return kidIds.length == 1 ? kidIds.first : null;
}
