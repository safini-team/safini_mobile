import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:safini/core/utils/error/failures.dart';
import 'package:safini/features/parent/domain/repositories/i_parent_task_repository.dart';
import 'package:safini/features/parent/presentation/cubit/parent_family_cubit.dart';
import 'package:safini/features/parent/presentation/cubit/parent_tasks_state.dart';

class ParentTasksCubit extends Cubit<ParentTasksState> {
  final IParentTaskRepository _repository;
  final ParentFamilyCubit _familyCubit;

  ParentTasksCubit(this._repository, this._familyCubit)
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
      (tasks) => emit(
        ParentTasksLoaded(
          childId: child.id,
          childName: child.nickname,
          templates: tasks.templates,
          todayInstances: tasks.todayInstances,
        ),
      ),
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
