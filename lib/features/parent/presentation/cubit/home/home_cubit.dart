import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:safini/features/parent/presentation/cubit/home/home_state.dart';

class ParentHomeCubit extends Cubit<ParentHomeState> {
  ParentHomeCubit({int initialIndex = 0, String? initialChildId})
    : super(
        ParentHomeState(
          selectedIndex: initialIndex,
          selectedChildId: initialChildId,
        ),
      );

  void selectChild(String? childId) {
    if (childId == state.selectedChildId) return;
    emit(
      ParentHomeState(
        selectedIndex: state.selectedIndex,
        selectedChildId: childId,
        showPrizes: state.showPrizes,
      ),
    );
  }

  void selectTab(int index) => emit(state.copyWith(selectedIndex: index));

  /// Limits, on its Prizes view.
  void openPrizes() => emit(state.copyWith(selectedIndex: 2, showPrizes: true));

  void prizesShown() {
    if (state.showPrizes) emit(state.copyWith(showPrizes: false));
  }
}
