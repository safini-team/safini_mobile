import 'package:safini/core/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:safini/core/di/injection.dart';
import 'package:safini/features/child/domain/repositories/i_child_repository.dart';
import 'package:safini/features/child/presentation/cubit/coins_cubit.dart';
import 'package:safini/features/child/presentation/cubit/tasks_model.dart';
import 'package:safini/features/child/presentation/cubit/tasks_state.dart';
import 'package:safini/features/common/auth/presentation/cubit/child_claim_cubit.dart';
import 'package:safini/features/common/profile/domain/controllers/profile_controller.dart';
import 'package:safini/features/parent/domain/models/parent_tasks_response_model.dart';

class TasksCubit extends Cubit<TasksState> {
  final CoinsCubit _coins;
  final ProfileController _profileController;
  final IChildRepository _childRepository;

  TasksCubit(this._coins, this._profileController, this._childRepository)
    : super(const TasksState.initial()) {
    loadTasks();
  }

  Future<void> loadTasks() async {
    emit(state.copyWith(isLoading: true));
    final childId = await _resolveChildId();
    if (isClosed) return;
    if (childId == null) {
      emit(state.copyWith(tasks: const [], isLoading: false));
      return;
    }

    final result = await _childRepository.fetchChildToday(childId);
    if (isClosed) return;
    result.fold(
      (_) => emit(state.copyWith(tasks: const [], isLoading: false)),
      (response) => emit(
        state.copyWith(
          tasks: _sortTasks(response.tasks.map(_taskFromBackend).toList()),
          isLoading: false,
        ),
      ),
    );
  }

  Future<String?> _resolveChildId() async {
    final claimChild = getIt<ChildClaimCubit>().state.child;
    if (claimChild != null) return claimChild.id;

    final profileResult = await _profileController.fetchMe();
    return profileResult.fold((_) => null, (profile) {
      final childId = profile.childId?.trim();
      return childId == null || childId.isEmpty ? null : childId;
    });
  }

  TaskItem _taskFromBackend(ParentTaskInstanceModel task) {
    final category = _categoryFrom(task.category ?? task.taskType);
    final spec = _visualSpec(category);
    final coins = task.rewardCoins ?? 0;
    return TaskItem(
      id: task.id,
      title: task.displayTitle,
      // Show the description only when it differs from the title (parent tasks
      // store the same text in both).
      subtitle:
          (task.description?.trim().isNotEmpty == true &&
              task.description!.trim() != task.displayTitle.trim())
          ? task.description!.trim()
          : '',
      icon: spec.icon,
      iconColor: spec.color,
      iconBackground: spec.background,
      emoji: task.emoji,
      category: category,
      coins: coins,
      xp: task.xpReward ?? 0,
      proofMode: task.proofMode,
      isCompleted: task.isCompleted,
      status: task.status,
    );
  }

  /// Uploads a proof photo and returns its object key, or null if it did not
  /// land. The sheet uploads as soon as the child takes the photo, so a bad
  /// connection surfaces while they are still writing their note rather than
  /// after the hold gesture.
  Future<String?> uploadPhoto(String taskId, String filePath) async {
    final childId = await _resolveChildId();
    if (childId == null) return null;
    final result = await _childRepository.uploadTaskProof(
      childId: childId,
      taskId: taskId,
      filePath: filePath,
    );
    return result.fold((_) => null, (objectKey) => objectKey);
  }

  /// Returns an error message on failure, or null on success.
  Future<String?> submitTask(
    String taskId, {
    String? note,
    String? imageObjectKey,
  }) async {
    final result = await _childRepository.submitTask(
      taskId,
      note: note,
      imageObjectKey: imageObjectKey,
    );
    return result.fold((failure) => failure.message, (_) {
      final updated = state.tasks.map((t) {
        if (t.id == taskId) return t.copyWith(status: 'submitted');
        return t;
      }).toList();
      emit(state.copyWith(tasks: _sortTasks(updated)));
      return null;
    });
  }

  TaskCategory _categoryFrom(String? raw) {
    final value = raw?.toLowerCase() ?? '';
    if (value.contains('fitness') || value.contains('health')) {
      return TaskCategory.fitness;
    }
    if (value.contains('logic') || value.contains('puzzle')) {
      return TaskCategory.logic;
    }
    return TaskCategory.learn;
  }

  _TaskVisualSpec _visualSpec(TaskCategory category) {
    switch (category) {
      case TaskCategory.fitness:
        return const _TaskVisualSpec(
          Icons.directions_walk_rounded,
          AppColors.catFitness,
          AppColors.catFitnessBg,
        );
      case TaskCategory.logic:
        return const _TaskVisualSpec(
          Icons.extension_rounded,
          AppColors.catLogic,
          AppColors.catLogicBg,
        );
      case TaskCategory.all:
      case TaskCategory.learn:
        return const _TaskVisualSpec(
          Icons.menu_book_rounded,
          AppColors.catLearn,
          AppColors.catLearnBg,
        );
    }
  }

  List<TaskItem> _sortTasks(List<TaskItem> tasks) {
    return [...tasks]..sort((a, b) {
      final aRank = a.isCompleted ? 2 : (a.isSubmitted ? 1 : 0);
      final bRank = b.isCompleted ? 2 : (b.isSubmitted ? 1 : 0);
      return aRank.compareTo(bRank);
    });
  }

  void selectCategory(TaskCategory category) =>
      emit(state.copyWith(selectedCategory: category));

  Future<void> toggleTask(String id) async {
    final task = state.tasks.firstWhere((t) => t.id == id);
    final updated = state.tasks
        .map((t) => t.id == id ? t.copyWith(isCompleted: !t.isCompleted) : t)
        .toList();
    if (task.isCompleted) {
      _coins.subtract(task.coins);
    } else {
      _coins.add(task.coins);
    }
    emit(state.copyWith(tasks: _sortTasks(updated)));
  }
}

class _TaskVisualSpec {
  final IconData icon;
  final Color color;
  final Color background;

  const _TaskVisualSpec(this.icon, this.color, this.background);
}
