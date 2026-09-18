import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:safini/core/utils/error/failures.dart';
import 'package:safini/features/models/data/dto/task_dto.dart';
import 'package:safini/features/models/domain/controllers/task_controller.dart';
import 'package:safini/features/models/domain/models/task_voice.dart';
import 'package:safini/features/parent/domain/models/parent_tasks_response_model.dart';
import 'package:safini/features/parent/domain/repositories/i_parent_task_repository.dart';
import 'package:safini/features/parent/presentation/cubit/parent_family_cubit.dart';
import 'package:safini/features/parent/presentation/cubit/parent_tasks_state.dart';

class ParentTasksCubit extends Cubit<ParentTasksState> {
  final IParentTaskRepository _repository;
  final ParentFamilyCubit _familyCubit;
  final TaskController _taskController;

  ParentTasksCubit(this._repository, this._familyCubit, this._taskController)
    : super(const ParentTasksInitial());

  // Remembers how the list was last loaded so refreshes after
  // create/edit/delete/review reload in the same mode.
  bool _allChildrenMode = false;
  String? _lastChildId;

  /// Loads tasks for [childId] when given (e.g. the child selected on the
  /// monitor), otherwise for the family's first child.
  Future<void> loadTasks({String? childId}) async {
    _allChildrenMode = false;
    emit(const ParentTasksLoading());

    if (_familyCubit.state.family == null) {
      await _familyCubit.loadCurrentFamily(refresh: true);
    }

    final family = _familyCubit.state.family;
    final children = family?.children.where((c) => c.id.isNotEmpty) ?? const [];
    final child = childId != null
        ? children.where((c) => c.id == childId).firstOrNull
        : children.firstOrNull;
    if (child == null) {
      emit(
        const ParentTasksError(
          'No child profile is available for this parent account.',
          canRetry: false,
        ),
      );
      return;
    }
    _lastChildId = child.id;

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

  /// Loads tasks for every child in the family, tagged with the child's name.
  /// Used by the Tasks screen so the parent sees all tasks at once.
  Future<void> loadAllTasks() async {
    _allChildrenMode = true;
    emit(const ParentTasksLoading());

    if (_familyCubit.state.family == null) {
      await _familyCubit.loadCurrentFamily(refresh: true);
    }

    final children = _familyCubit.state.family?.children
            .where((c) => c.id.isNotEmpty)
            .toList() ??
        const [];
    if (children.isEmpty) {
      emit(
        const ParentTasksError(
          'No child profile is available for this parent account.',
          canRetry: false,
        ),
      );
      return;
    }

    final allTasks = <ParentTaskInstanceModel>[];
    final childNames = <String, String>{};
    Failure? firstFailure;

    for (final child in children) {
      final result = await _repository.fetchTasks(child.id);
      result.fold((failure) => firstFailure ??= failure, (response) {
        for (final task in response.tasks) {
          allTasks.add(task);
          childNames[task.id] = child.nickname;
        }
      });
    }

    if (allTasks.isEmpty && firstFailure != null) {
      emit(_errorFromFailure(firstFailure!));
      return;
    }

    emit(
      ParentTasksLoaded(
        childId: children.first.id,
        childName: children.first.nickname,
        tasks: allTasks,
        childNames: childNames,
      ),
    );
  }

  /// Refreshes the list in whatever mode it was last loaded.
  Future<void> _reload() =>
      _allChildrenMode ? loadAllTasks() : loadTasks(childId: _lastChildId);

  ParentTasksLoaded? get _loaded {
    final current = state;
    if (current is ParentTasksLoaded) return current;
    if (current is ParentTaskSaving) return current.base;
    if (current is ParentTaskSaved) return current.base;
    if (current is ParentTaskDeleting) return current.base;
    if (current is ParentTaskDeleted) return current.base;
    if (current is ParentTaskActionError) return current.base;
    if (current is ParentTaskReviewing) return current.base;
    if (current is ParentTaskReviewed) return current.base;
    return null;
  }

  Future<void> reviewTask(
    String taskId, {
    required bool approve,
    String? note,
  }) async {
    final current = _loaded;
    if (current == null) return;

    emit(ParentTaskReviewing(current));

    final result = await _repository.reviewTask(
      taskId,
      decision: approve ? 'approved' : 'rejected',
      note: note,
    );
    await result.fold(
      (failure) async => emit(_actionError(current, failure)),
      (_) async {
        emit(ParentTaskReviewed(current, isApproved: approve));
        await _reload();
      },
    );
  }

  Future<void> createTask(
    String childId,
    TaskCreateRequestDto request, {
    TaskVoiceSave voice = TaskVoiceSave.unchanged,
  }) async {
    final current = _loaded;
    if (current == null) return;

    emit(ParentTaskSaving(current));

    final result = await _taskController.createTask(childId, request);
    await result.fold(
      (failure) async => emit(_actionError(current, failure)),
      (created) async {
        final attached = await _applyVoice(
          childId: childId,
          taskId: created.id,
          voice: voice,
        );
        if (attached != null) {
          emit(
            _actionError(current, attached, createdTaskId: created.id),
          );
          await _reload();
          return;
        }
        emit(ParentTaskSaved(current, wasCreate: true));
        await _reload();
      },
    );
  }

  /// Creates the same task for several children (e.g. "all children").
  /// Emits one Saving/Saved cycle and reloads once at the end.
  Future<void> createTaskForChildren(
    List<String> childIds,
    TaskCreateRequestDto request, {
    TaskVoiceSave voice = TaskVoiceSave.unchanged,
  }) async {
    final current = _loaded;
    if (current == null || childIds.isEmpty) return;

    if (childIds.length == 1) {
      return createTask(childIds.first, request, voice: voice);
    }

    emit(ParentTaskSaving(current));

    Failure? firstFailure;
    String? createdTaskId;
    for (final childId in childIds) {
      final result = await _taskController.createTask(childId, request);
      await result.fold(
        (failure) async => firstFailure ??= failure,
        (created) async {
          createdTaskId ??= created.id;
          final attached = await _applyVoice(
            childId: childId,
            taskId: created.id,
            voice: voice,
          );
          firstFailure ??= attached;
        },
      );
      if (firstFailure != null && createdTaskId == null) break;
    }

    if (firstFailure != null) {
      emit(
        _actionError(
          current,
          firstFailure!,
          createdTaskId: createdTaskId,
        ),
      );
      if (createdTaskId != null) await _reload();
      return;
    }

    emit(ParentTaskSaved(current, wasCreate: true));
    await _reload();
  }

  Future<void> updateTask(
    String taskId,
    TaskUpdateRequestDto request, {
    String? childId,
    TaskVoiceSave voice = TaskVoiceSave.unchanged,
  }) async {
    final current = _loaded;
    if (current == null) return;

    emit(ParentTaskSaving(current));

    if (!request.isEmpty) {
      final result = await _taskController.updateTask(taskId, request);
      final failed = result.fold<Failure?>((failure) => failure, (_) => null);
      if (failed != null) {
        emit(_actionError(current, failed));
        return;
      }
    }

    final ownerChildId = childId ?? current.childId;
    final attached = await _applyVoice(
      childId: ownerChildId,
      taskId: taskId,
      voice: voice,
    );
    if (attached != null) {
      emit(_actionError(current, attached));
      return;
    }

    emit(ParentTaskSaved(current, wasCreate: false));
    await _reload();
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
        await _reload();
      },
    );
  }

  ParentTaskActionError _actionError(
    ParentTasksLoaded base,
    Failure failure, {
    String? createdTaskId,
  }) {
    return ParentTaskActionError(
      base: base,
      message: failure.message,
      isConflict: failure is ConflictFailure,
      isUnauthorized: failure is UnauthorizedFailure,
      createdTaskId: createdTaskId,
    );
  }

  /// Returns the failure if voice work was requested and did not land.
  Future<Failure?> _applyVoice({
    required String childId,
    required String taskId,
    required TaskVoiceSave voice,
  }) async {
    if (voice.remove) {
      final result = await _taskController.removeVoiceInstruction(taskId);
      return result.fold((failure) => failure, (_) => null);
    }
    final draft = voice.attach;
    if (draft == null) return null;
    final result = await _taskController.attachVoiceFromFile(
      childId: childId,
      taskId: taskId,
      draft: draft,
    );
    return result.fold((failure) => failure, (_) => null);
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
