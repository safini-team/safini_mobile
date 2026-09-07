import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:safini/features/parent/presentation/cubit/home/home_state.dart';

class ParentHomeCubit extends Cubit<ParentHomeState> {
  ParentHomeCubit({int initialIndex = 0})
      : super(ParentHomeState(selectedIndex: initialIndex));

  void selectTab(int index) => emit(state.copyWith(selectedIndex: index));
}
