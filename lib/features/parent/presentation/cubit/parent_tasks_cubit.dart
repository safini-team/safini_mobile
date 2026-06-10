import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:safini/core/utils/error/failures.dart';
import 'package:safini/features/models/data/dto/task_dto.dart';
import 'package:safini/features/models/domain/controllers/task_controller.dart';
import 'package:safini/features/parent/domain/repositories/i_parent_task_repository.dart';
import 'package:safini/features/parent/presentation/cubit/parent_family_cubit.dart';
import 'package:safini/features/parent/presentation/cubit/parent_tasks_state.dart';

class ParentTasksCubit extends Cubit<ParentTasksState> {
  final IParentTaskRepository _repository;
  final ParentFamilyCubit _familyCubit;
  final TaskController _taskController;

  ParentTasksCubit(this._repository, this._familyCubit, this._taskController)
    : super(const ParentTasksInitial());

  Future<void> loadTasks() async {
    emit(const ParentTasksLoading());

    if (_familyCubit.state.family == null) {
      await _familyCubit.loadCurrentFamily(refresh: true);
    }

    final family = _familyCubit.state.family;
    final child = family?.children
        .where((child) => child.id.isNotEmpty)
        .firstOrNull;
    if (child == null) {
      emit(
        const ParentTasksError(
          'No child profile is available for this parent account.',
          canRetry: false,
        ),
      );
      return;
    }

    final result = await _repository.fetchTasks(child.id);
    result.fold(
      (failure) => emit(_errorFromFailure(failure)),
      (response) => emit(
        ParentTasksLoaded(
          childId: child.id,
          childName: child.nickname,
          tasks: response.tasks,
        ),
      ),
    );
  }

  Future<void> createTask(String childId, TaskCreateRequestDto request) async {
    final current = state;
    if (current is! ParentTasksLoaded) return;

    emit(ParentTaskCreating(current));

    final result = await _taskController.createTask(childId, request);
    await result.fold(
      (failure) async {
        emit(
          ParentTaskCreateError(
            base: current,
            message: failure.message,
            isUnauthorized: failure is UnauthorizedFailure,
          ),
        );
      },
      (created) async {
        emit(ParentTaskCreated(current));
        await loadTasks();
      },
    );
  }

  ParentTasksError _errorFromFailure(Failure failure) {
    if (failure is UnauthorizedFailure) {
      return ParentTasksError(failure.message, isUnauthorized: true);
    }
    if (failure is ValidationFailure) {
      return ParentTasksError(failure.message, canRetry: false);
    }
    return ParentTasksError(failure.message);
  }
}
