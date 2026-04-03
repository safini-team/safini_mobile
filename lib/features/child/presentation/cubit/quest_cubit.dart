import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:safini/features/child/presentation/cubit/quest_model.dart';
import 'package:safini/features/child/presentation/cubit/quest_state.dart';

class QuestCubit extends Cubit<QuestState> {
  QuestCubit() : super(const QuestState.initial()) {
    _loadHardcodedQuests();
  }

  void _loadHardcodedQuests() {
    emit(
      state.copyWith(
        quests: const [
          QuestModel(
            id: '1',
            title: 'Complete Duolingo',
            subtitle: 'Daily streak bonus!',
            icon: Icons.language_rounded,
            iconColor: Color(0xFF4A90D9),
            iconBackground: Color(0xFFDEEEFB),
            isCompleted: true,
          ),
          QuestModel(
            id: '2',
            title: 'Walk 5,000 Steps',
            subtitle: 'Keep it moving!',
            icon: Icons.directions_walk_rounded,
            iconColor: Color(0xFFE89B4B),
            iconBackground: Color(0xFFFDF1E1),
            isCompleted: true,
          ),
          QuestModel(
            id: '3',
            title: 'Logical Puzzle',
            subtitle: 'Brain power boost',
            icon: Icons.extension_rounded,
            iconColor: Color(0xFF7B6EF6),
            iconBackground: Color(0xFFEEECFD),
            isCompleted: true,
          ),
          QuestModel(
            id: '4',
            title: 'Chess Lesson',
            subtitle: 'Master the board',
            icon: Icons.sports_esports_rounded,
            iconColor: Color(0xFF8A9BB0),
            iconBackground: Color(0xFFEDF0F4),
            isCompleted: true,
          ),
          QuestModel(
            id: '5',
            title: 'Read for 20 mins',
            subtitle: 'Expand your mind',
            icon: Icons.menu_book_rounded,
            iconColor: Color(0xFFE05FA2),
            iconBackground: Color(0xFFFCEAF3),
            isCompleted: true,
          ),
          QuestModel(
            id: '6',
            title: 'Clean your room',
            subtitle: 'Daily chore',
            icon: Icons.cleaning_services_rounded,
            iconColor: Color(0xFFC8A97E),
            iconBackground: Color(0xFFF7EFE4),
            isCompleted: true,
          ),
        ],
      ),
    );
  }

  void toggleQuest(String questId) {
    final updated = state.quests.map((q) {
      if (q.id == questId) return q.copyWith(isCompleted: !q.isCompleted);
      return q;
    }).toList();
    emit(state.copyWith(quests: updated));
  }
}
