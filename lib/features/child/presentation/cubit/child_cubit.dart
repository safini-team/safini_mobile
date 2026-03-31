import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:safini/features/child/presentation/cubit/child_state.dart';

class ChildCubit extends Cubit<ChildState> {
  ChildCubit() : super(const ChildState.initial());
}
