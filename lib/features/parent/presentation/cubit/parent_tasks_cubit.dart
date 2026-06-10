import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:safini/core/utils/error/failures.dart';
import 'package:safini/features/models/data/dto/task_dto.dart';
import 'package:safini/features/models/domain/controllers/task_controller.dart';
import 'package:safini/features/parent/domain/repositories/i_parent_task_repository.dart';
import 'package:safini/features/parent/presentation/cubit/parent_family_cubit.dart';
import 'package:safini/features/parent/domain/models/parent_tasks_response_model.dart';
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

  void clearCreateOutcome() {
    final current = state;
    if (current is ParentTaskTemplateCreateSucceeded) {
      emit(current.data);
      return;
    }
    if (current is ParentTaskTemplateCreateFailed) {
      emit(current.base);
      return;
    }
  }

  Future<void> createTaskTemplate(
    ParentTaskTemplateCreateRequest request,
  ) async {
    final current = state;
    if (current is! ParentTasksLoaded) return;

    emit(ParentTaskTemplateCreateInFlight(current));

    final dto = TaskTemplateCreateRequestDto(
      title: request.title,
      category: request.category,
      taskType: request.taskType,
      proofMode: request.proofMode,
      recurrenceRule: request.recurrenceRule,
      verificationMode: request.verificationMode,
      coinReward: request.coinReward,
      xpReward: request.xpReward,
      description: request.description,
      targetValue: request.targetValue?.toInt(),
      targetUnit: request.targetUnit,
      contentRef: request.contentRef,
      metadata: request.metadata,
    );

    final result = await _taskController.createTaskTemplate(
      current.childId,
      dto,
    );
    result.fold(
      (failure) {
        if (failure is UnauthorizedFailure) {
          emit(
            ParentTaskTemplateCreateFailed(
              base: current,
              message: failure.message,
              isUnauthorized: true,
            ),
          );
          return;
        }

        if (failure is FieldValidationFailure) {
          emit(
            ParentTaskTemplateCreateFailed(
              base: current,
              message: failure.message,
              fieldErrors: failure.fieldErrors,
            ),
          );
          return;
        }

        emit(
          ParentTaskTemplateCreateFailed(
            base: current,
            message: failure.message,
            isServiceUnavailable:
                failure is ServerFailure &&
                failure.message.toLowerCase().contains('service unavailable'),
          ),
        );
      },
      (created) {
        final newTemplate = ParentTaskTemplateModel(
          id: created.id,
          title: created.title,
          category: created.category,
          rewardCoins: created.coinReward,
          status: created.status,
        );

        final mergedTemplates = [newTemplate, ...current.templates]
            .fold<List<ParentTaskTemplateModel>>(<ParentTaskTemplateModel>[], (
              acc,
              item,
            ) {
              if (acc.any((existing) => existing.id == item.id)) return acc;
              acc.add(item);
              return acc;
            });

        emit(
          ParentTaskTemplateCreateSucceeded(
            ParentTasksLoaded(
              childId: current.childId,
              childName: current.childName,
              templates: mergedTemplates,
              todayInstances: current.todayInstances,
            ),
          ),
        );
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
