import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:safini/features/child/presentation/cubit/quest_model.dart';
import 'package:safini/features/child/presentation/cubit/quest_state.dart';
import 'package:safini/features/common/profile/domain/controllers/profile_controller.dart';
import 'package:safini/features/parent/domain/models/parent_tasks_response_model.dart';
import 'package:safini/features/parent/domain/repositories/i_parent_task_repository.dart';

class QuestCubit extends Cubit<QuestState> {
  final ProfileController _profileController;
  final IParentTaskRepository _taskRepository;

  QuestCubit(this._profileController, this._taskRepository)
    : super(const QuestState.initial()) {
    loadQuests();
  }

  Future<void> loadQuests() async {
    final childId = await _resolveChildId();
    if (childId == null) {
      emit(state.copyWith(quests: const []));
      return;
    }

    final result = await _taskRepository.fetchTasks(childId);
    result.fold(
      (_) => emit(state.copyWith(quests: const [])),
      (response) => emit(
        state.copyWith(
          quests: _sortQuests(response.tasks.map(_questFromTask).toList()),
        ),
      ),
    );
  }

  Future<String?> _resolveChildId() async {
    final profileResult = await _profileController.fetchMe();
    return profileResult.fold((_) => null, (profile) {
      final childId = profile.childId?.trim();
      return childId == null || childId.isEmpty ? null : childId;
    });
  }

  List<QuestModel> _sortQuests(List<QuestModel> quests) {
    return [...quests]..sort((a, b) {
      if (a.isCompleted == b.isCompleted) return 0;
      return a.isCompleted ? 1 : -1;
    });
  }

  QuestModel _questFromTask(ParentTaskInstanceModel task) {
    final category = (task.category ?? task.taskType ?? '').toLowerCase();
    final spec = _visualSpec(category);
    return QuestModel(
      id: task.id,
      title: task.displayTitle,
      subtitle: task.description?.trim().isNotEmpty == true
          ? task.description!.trim()
          : _fallbackSubtitle(task),
      icon: spec.icon,
      iconColor: spec.color,
      iconBackground: spec.background,
      isCompleted: task.isCompleted,
      coins: task.rewardCoins ?? 0,
      xp: task.xpReward ?? 0,
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
    final updated = state.quests.map((q) {
      if (q.id == questId) return q.copyWith(isCompleted: !q.isCompleted);
      return q;
    }).toList();
    emit(state.copyWith(quests: _sortQuests(updated)));
  }
}

class _QuestVisualSpec {
  final IconData icon;
  final Color color;
  final Color background;

  const _QuestVisualSpec(this.icon, this.color, this.background);
}
