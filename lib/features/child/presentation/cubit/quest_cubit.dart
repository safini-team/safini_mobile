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

  QuestCubit(
    this._profileController,
    this._childRepository,
  ) : super(const QuestState.initial()) {
    loadQuests();
  }

  Future<void> loadQuests() async {
    final childId = await _resolveChildId();
    if (childId == null) {
      emit(state.copyWith(quests: const []));
      return;
    }

    // Fire both requests in parallel.
    final homeFuture = _childRepository.fetchChildHome(childId);
    final tasksFuture = _childRepository.fetchChildToday(childId);
    final homeResult = await homeFuture;
    final tasksResult = await tasksFuture;

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
        ),
      ),
      (response) => emit(
        state.copyWith(
          quests: _sortQuests(response.tasks.map(_questFromTask).toList()),
          childNickname: nickname,
          doneToday: doneToday,
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
      subtitle: (task.description?.trim().isNotEmpty == true &&
              task.description!.trim() != task.displayTitle.trim())
          ? task.description!.trim()
          : _fallbackSubtitle(task),
      icon: spec.icon,
      iconColor: spec.color,
      iconBackground: spec.background,
      emoji: task.emoji,
      reviewNote: task.reviewNote,
      isCompleted: task.isCompleted,
      coins: task.rewardCoins ?? 0,
      xp: task.xpReward ?? 0,
      status: task.status,
    );
  }

  /// Returns an error message on failure, or null on success.
  Future<String?> submitQuest(String questId, {String? note}) async {
    final result = await _childRepository.submitTask(questId, note: note);
    return result.fold(
      (failure) => failure.message,
      (_) {
        final updated = state.quests.map((q) {
          if (q.id == questId) return q.copyWith(status: 'submitted');
          return q;
        }).toList();
        emit(state.copyWith(quests: _sortQuests(updated)));
        return null;
      },
    );
  }

  String _fallbackSubtitle(ParentTaskInstanceModel task) {
    final reward = task.rewardCoins ?? 0;
    if (reward > 0) return '$reward coin reward';
    return task.isCompleted ? 'Completed' : 'Ready when you are';
  }

  _QuestVisualSpec _visualSpec(String category) {
    if (category.contains('fitness') || category.contains('health')) {
      return const _QuestVisualSpec(
        Icons.directions_walk_rounded,
        Color(0xFFE89B4B),
        Color(0xFFFDF1E1),
      );
    }
    if (category.contains('logic') || category.contains('puzzle')) {
      return const _QuestVisualSpec(
        Icons.extension_rounded,
        Color(0xFF7B6EF6),
        Color(0xFFEEECFD),
      );
    }
    if (category.contains('chore') || category.contains('home')) {
      return const _QuestVisualSpec(
        Icons.cleaning_services_rounded,
        Color(0xFFC8A97E),
        Color(0xFFF7EFE4),
      );
    }
    return const _QuestVisualSpec(
      Icons.menu_book_rounded,
      Color(0xFF4A90D9),
      Color(0xFFDEEEFB),
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
