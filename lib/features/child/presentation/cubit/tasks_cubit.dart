import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:safini/features/child/presentation/cubit/coins_cubit.dart';
import 'package:safini/features/child/presentation/cubit/tasks_model.dart';
import 'package:safini/features/child/presentation/cubit/tasks_state.dart';

class TasksCubit extends Cubit<TasksState> {
  final CoinsCubit _coins;

  TasksCubit(this._coins) : super(const TasksState.initial()) {
    _loadHardcodedData();
  }

  void _loadHardcodedData() {
    emit(state.copyWith(
      tasks: const [
        TaskItem(
          id: 'duolingo',
          title: 'Complete Duolingo',
          subtitle: 'Daily streak bonus!',
          icon: Icons.language_rounded,
          iconColor: Color(0xFF4A90D9),
          iconBackground: Color(0xFFDEEEFB),
          category: TaskCategory.learn,
          coins: 20,
          xp: 30,
          isCompleted: true,
        ),
        TaskItem(
          id: 'steps',
          title: 'Walk 5,000 Steps',
          subtitle: 'Keep it moving!',
          icon: Icons.directions_walk_rounded,
          iconColor: Color(0xFFE89B4B),
          iconBackground: Color(0xFFFDF1E1),
          category: TaskCategory.fitness,
          coins: 10,
          xp: 15,
          isCompleted: true,
        ),
        TaskItem(
          id: 'puzzle',
          title: 'Logical Puzzle',
          subtitle: 'Brain power boost',
          icon: Icons.extension_rounded,
          iconColor: Color(0xFF7B6EF6),
          iconBackground: Color(0xFFEEECFD),
          category: TaskCategory.logic,
          coins: 15,
          xp: 20,
          isCompleted: true,
        ),
        TaskItem(
          id: 'chess',
          title: 'Chess Lesson',
          subtitle: 'Master the board',
          icon: Icons.sports_esports_rounded,
          iconColor: Color(0xFF8A9BB0),
          iconBackground: Color(0xFFEDF0F4),
          category: TaskCategory.logic,
          coins: 25,
          xp: 35,
          isCompleted: true,
        ),
        TaskItem(
          id: 'reading',
          title: 'Read for 20 mins',
          subtitle: 'Expand your mind',
          icon: Icons.menu_book_rounded,
          iconColor: Color(0xFFE05FA2),
          iconBackground: Color(0xFFFCEAF3),
          category: TaskCategory.learn,
          coins: 15,
          xp: 20,
          isCompleted: true,
        ),
        TaskItem(
          id: 'room',
          title: 'Clean your room',
          subtitle: 'Daily chore',
          icon: Icons.cleaning_services_rounded,
          iconColor: Color(0xFFC8A97E),
          iconBackground: Color(0xFFF7EFE4),
          category: TaskCategory.fitness,
          coins: 30,
          xp: 10,
          isCompleted: true,
        ),
      ],
    ));
  }

  void selectCategory(TaskCategory category) =>
      emit(state.copyWith(selectedCategory: category));

  void toggleTask(String id) {
    final task = state.tasks.firstWhere((t) => t.id == id);
    final updated = state.tasks
        .map((t) => t.id == id ? t.copyWith(isCompleted: !t.isCompleted) : t)
        .toList();
    // Sync wallet: add coins on complete, subtract on un-complete
    if (task.isCompleted) {
      _coins.subtract(task.coins);
    } else {
      _coins.add(task.coins);
    }
    emit(state.copyWith(tasks: updated));
  }
}
