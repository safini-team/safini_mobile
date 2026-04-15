import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:safini/features/child/presentation/cubit/home/home_state.dart';

class ChildHomeCubit extends Cubit<ChildHomeState> {
  ChildHomeCubit() : super(const ChildHomeState());

  void selectTab(int index) => emit(state.copyWith(selectedIndex: index));
}
