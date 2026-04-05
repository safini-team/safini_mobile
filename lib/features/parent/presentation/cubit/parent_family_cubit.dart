import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:safini/features/child/domain/models/child_model.dart';
import 'package:safini/features/parent/domain/controllers/parent_controller.dart';
import 'package:safini/features/parent/domain/models/parent_user_model.dart';
import 'package:safini/features/parent/presentation/cubit/parent_family_state.dart';

class ParentFamilyCubit extends Cubit<ParentFamilyState> {
  final ParentController _controller;

  ParentFamilyCubit(this._controller) : super(const ParentFamilyInitial());

  Future<void> loadFamilyData() async {
    emit(const ParentFamilyLoading());
    
    await Future.delayed(const Duration(milliseconds: 500));
    
    emit(ParentFamilyLoaded(
      children: [
        const ChildModel(id: "child1", name: "Alex"),
      ],
      parent: ParentUserModel(
        userId: "parent1",
        displayName: "Parent",
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
    ));
  }

  void addAnotherChild() {
    // Logic to add child
  }
}
