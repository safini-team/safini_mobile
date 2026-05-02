import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:safini/features/child/domain/controllers/child_controller.dart';
import 'package:safini/features/parent/domain/controllers/parent_controller.dart';
import 'package:safini/features/parent/presentation/cubit/parent_family_state.dart';

class ParentFamilyCubit extends Cubit<ParentFamilyState> {
  final ParentController _parentController;
  final ChildController _childController;

  ParentFamilyCubit(this._parentController, this._childController)
      : super(const ParentFamilyInitial());

  Future<void> loadFamilyData() async {
    emit(const ParentFamilyLoading());

    // Fetch children from backend
    final childrenResult = await _childController.fetchChildren();

    childrenResult.fold(
      (failure) => emit(ParentFamilyError(failure.message)),
      (children) async {
        // Fetch parent profile — use a fallback if it fails
        final parentResult =
            await _parentController.getParentProfile('');
        parentResult.fold(
          (failure) {
            // Emit with children but a placeholder parent if profile fails
            // TODO: replace placeholder once a dedicated getMe method is added
          },
          (parent) => emit(
            ParentFamilyLoaded(children: children, parent: parent),
          ),
        );
      },
    );
  }

  void addAnotherChild() {
    // Logic to add child
  }
}
