import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:safini/features/parent/presentation/cubit/parent_state.dart';

class ParentCubit extends Cubit<ParentState> {
  ParentCubit() : super(const ParentState.initial());
}
