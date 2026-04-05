import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:safini/features/parent/domain/controllers/parent_controller.dart';
import 'package:safini/features/parent/domain/models/parent_task_model.dart';
import 'package:safini/features/parent/presentation/cubit/parent_tasks_state.dart';

class ParentTasksCubit extends Cubit<ParentTasksState> {
  final ParentController _controller;

  ParentTasksCubit(this._controller) : super(const ParentTasksInitial());

  Future<void> loadTasks() async {
    emit(const ParentTasksLoading());
    
    // Simulate API call
    await Future.delayed(const Duration(milliseconds: 800));
    
    emit(const ParentTasksLoaded(
      pendingApproval: [
        ParentTaskModel(id: "1", title: "Read for 20 mins", durationMinutes: 20, isCompleted: true, assignedToChildId: "child1"),
      ],
      activeTasks: [
        ParentTaskModel(id: "2", title: "Clean the room", durationMinutes: 15, isCompleted: false, assignedToChildId: "child1"),
        ParentTaskModel(id: "3", title: "Practice piano", durationMinutes: 30, isCompleted: false, assignedToChildId: "child1"),
      ],
      completedTasks: [
        ParentTaskModel(id: "4", title: "Do homework", durationMinutes: 60, isCompleted: true, assignedToChildId: "child1"),
      ],
    ));
  }

  void approveTask(String taskId) {
    // Logic to approve task via controller
  }

  void addNewTask() {
    // Logic to trigger add task dialog/screen
  }
}
