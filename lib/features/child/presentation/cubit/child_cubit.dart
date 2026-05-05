import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:safini/features/child/domain/controllers/child_controller.dart';
import 'package:safini/features/child/presentation/cubit/child_state.dart';

class ChildCubit extends Cubit<ChildState> {
  final ChildController _controller;

  ChildCubit(this._controller) : super(const ChildState.initial());

  Future<void> load() async {
    emit(state.copyWith(status: ChildStatus.loading));
    final result = await _controller.fetchChildren();
    result.fold(
      (failure) => emit(
        state.copyWith(
          status: ChildStatus.error,
          errorMessage: failure.message,
        ),
      ),
      (children) => emit(
        state.copyWith(status: ChildStatus.loaded, children: children),
      ),
    );
  }
}
