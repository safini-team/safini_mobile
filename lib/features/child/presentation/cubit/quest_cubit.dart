import 'package:safini/core/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:safini/core/di/injection.dart';
import 'package:safini/features/child/domain/repositories/i_child_repository.dart';
import 'package:safini/features/child/presentation/cubit/quest_model.dart';
import 'package:safini/features/child/presentation/cubit/quest_state.dart';
import 'package:safini/features/common/auth/presentation/cubit/child_claim_cubit.dart';
import 'package:safini/features/common/profile/domain/controllers/profile_controller.dart';
import 'package:safini/features/parent/domain/models/parent_tasks_response_model.dart';

class QuestCubit extends Cubit<QuestState> {
  final ProfileController _profileController;
  final IChildRepository _childRepository;

  QuestCubit(this._profileController, this._childRepository)
    : super(const QuestState.initial()) {
    loadQuests();
  }

  Future<void> loadQuests() async {
    emit(state.copyWith(isLoading: true));
    final childId = await _resolveChildId();
    if (isClosed) return;
    if (childId == null) {
      emit(state.copyWith(quests: const [], isLoading: false));
      return;
    }

    // Fire both requests in parallel.
    final homeFuture = _childRepository.fetchChildHome(childId);
    final tasksFuture = _childRepository.fetchChildToday(childId);
    final homeResult = await homeFuture;
    final tasksResult = await tasksFuture;
    if (isClosed) return;

    String? nickname;
    int? doneToday;
    homeResult.fold((_) {}, (home) {
      if (home.childNickname.isNotEmpty) nickname = home.childNickname;
      doneToday = home.doneToday;
    });

    tasksResult.fold(
      (_) => emit(
        state.copyWith(
          quests: const [],
          childNickname: nickname,
          doneToday: doneToday,
          isLoading: false,
        ),
      ),
      (response) => emit(
        state.copyWith(
          quests: _sortQuests(response.tasks.map(_questFromTask).toList()),
          childNickname: nickname,
          doneToday: doneToday,
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

  List<QuestModel> _sortQuests(List<QuestModel> quests) {
    return [...quests]..sort((a, b) {
      final aRank = a.isCompleted ? 2 : (a.isSubmitted ? 1 : 0);
      final bRank = b.isCompleted ? 2 : (b.isSubmitted ? 1 : 0);
      return aRank.compareTo(bRank);
    });
  }

  QuestModel _questFromTask(ParentTaskInstanceModel task) {
    final category = (task.category ?? task.taskType ?? '').toLowerCase();
    final spec = _visualSpec(category);
    return QuestModel(
      id: task.id,
      title: task.displayTitle,
      // Show the description as the subtitle only when it differs from the
      // title (parent-created tasks store the same text in both).
      subtitle:
          (task.description?.trim().isNotEmpty == true &&
              task.description!.trim() != task.displayTitle.trim())
          ? task.description!.trim()
          : '',
      icon: spec.icon,
      iconColor: spec.color,
      iconBackground: spec.background,
      emoji: task.emoji,
      reviewNote: task.reviewNote,
      proofMode: task.proofMode,
      isCompleted: task.isCompleted,
      coins: task.rewardCoins ?? 0,
      xp: task.xpReward ?? 0,
      status: task.status,
    );
  }

  /// See `TasksCubit.uploadPhoto` - the photo goes to Storage first, and the
  /// submission carries only its object key.
  Future<String?> uploadPhoto(String questId, String filePath) async {
    final childId = await _resolveChildId();
    if (childId == null) return null;
    final result = await _childRepository.uploadTaskProof(
      childId: childId,
      taskId: questId,
      filePath: filePath,
    );
    return result.fold((_) => null, (objectKey) => objectKey);
  }

  /// Returns an error message on failure, or null on success.
  Future<String?> submitQuest(
    String questId, {
    String? note,
    String? imageObjectKey,
  }) async {
    final result = await _childRepository.submitTask(
      questId,
      note: note,
      imageObjectKey: imageObjectKey,
    );
    return result.fold((failure) => failure.message, (_) {
      final updated = state.quests.map((q) {
        if (q.id == questId) return q.copyWith(status: 'submitted');
        return q;
      }).toList();
      emit(state.copyWith(quests: _sortQuests(updated)));
      return null;
    });
  }

  _QuestVisualSpec _visualSpec(String category) {
    if (category.contains('fitness') || category.contains('health')) {
      return const _QuestVisualSpec(
        Icons.directions_walk_rounded,
        AppColors.catFitness,
        AppColors.catFitnessBg,
      );
    }
    if (category.contains('logic') || category.contains('puzzle')) {
      return const _QuestVisualSpec(
        Icons.extension_rounded,
        AppColors.catLogic,
        AppColors.catLogicBg,
      );
    }
    if (category.contains('chore') || category.contains('home')) {
      return const _QuestVisualSpec(
        Icons.cleaning_services_rounded,
        AppColors.catChore,
        AppColors.catChoreBg,
      );
    }
    return const _QuestVisualSpec(
      Icons.menu_book_rounded,
      AppColors.catLearn,
      AppColors.catLearnBg,
    );
  }

  void toggleQuest(String questId) {
    final quest = state.quests.firstWhere((q) => q.id == questId);
    final wasCompleted = quest.isCompleted;
    final updated = state.quests.map((q) {
      if (q.id == questId) return q.copyWith(isCompleted: !q.isCompleted);
      return q;
    }).toList();

    int? newDoneToday = state.doneToday;
    if (newDoneToday != null) {
      newDoneToday = wasCompleted
          ? (newDoneToday - 1).clamp(0, updated.length)
          : (newDoneToday + 1).clamp(0, updated.length);
    }

    emit(state.copyWith(quests: _sortQuests(updated), doneToday: newDoneToday));
  }
}

class _QuestVisualSpec {
  final IconData icon;
  final Color color;
  final Color background;

  const _QuestVisualSpec(this.icon, this.color, this.background);
}
