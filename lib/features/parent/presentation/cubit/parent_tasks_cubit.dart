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

  ParentTasksLoaded? get _loaded {
    final current = state;
    if (current is ParentTasksLoaded) return current;
    if (current is ParentTaskSaving) return current.base;
    if (current is ParentTaskSaved) return current.base;
    if (current is ParentTaskDeleting) return current.base;
    if (current is ParentTaskDeleted) return current.base;
    if (current is ParentTaskActionError) return current.base;
    return null;
  }

  Future<void> createTask(String childId, TaskCreateRequestDto request) async {
    final current = _loaded;
    if (current == null) return;

    emit(ParentTaskSaving(current));

    final result = await _taskController.createTask(childId, request);
    await result.fold(
      (failure) async => emit(_actionError(current, failure)),
      (created) async {
        emit(ParentTaskSaved(current, wasCreate: true));
        await loadTasks();
      },
    );
  }

  Future<void> updateTask(String taskId, TaskUpdateRequestDto request) async {
    final current = _loaded;
    if (current == null) return;

    emit(ParentTaskSaving(current));

    final result = await _taskController.updateTask(taskId, request);
    await result.fold(
      (failure) async => emit(_actionError(current, failure)),
      (updated) async {
        emit(ParentTaskSaved(current, wasCreate: false));
        await loadTasks();
      },
    );
  }

  Future<void> deleteTask(String taskId) async {
    final current = _loaded;
    if (current == null) return;

    emit(ParentTaskDeleting(current));

    final result = await _taskController.deleteTask(taskId);
    await result.fold(
      (failure) async => emit(_actionError(current, failure)),
      (_) async {
        emit(ParentTaskDeleted(current));
        await loadTasks();
      },
    );
  }

  ParentTaskActionError _actionError(ParentTasksLoaded base, Failure failure) {
    return ParentTaskActionError(
      base: base,
      message: failure.message,
      isConflict: failure is ConflictFailure,
      isUnauthorized: failure is UnauthorizedFailure,
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
