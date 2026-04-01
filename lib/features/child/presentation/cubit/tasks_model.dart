import 'package:flutter/material.dart';

enum TaskCategory { all, learn, fitness, logic }

extension TaskCategoryX on TaskCategory {
  String get label {
    switch (this) {
      case TaskCategory.all:
        return 'All';
      case TaskCategory.learn:
        return 'Learn';
      case TaskCategory.fitness:
        return 'Fitness';
      case TaskCategory.logic:
        return 'Logic';
    }
  }

  String get emoji {
    switch (this) {
      case TaskCategory.all:
        return '✨';
      case TaskCategory.learn:
        return '🌱';
      case TaskCategory.fitness:
        return '🔥';
      case TaskCategory.logic:
        return '🧩';
    }
  }
}

class TaskItem {
  final String id;
  final String title;
  final String subtitle;
  final IconData icon;
  final Color iconColor;
  final Color iconBackground;
  final TaskCategory category;
  final int coins;
  final int xp;
  final bool isCompleted;

  const TaskItem({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.iconColor,
    required this.iconBackground,
    required this.category,
    required this.coins,
    required this.xp,
    this.isCompleted = false,
  });

  TaskItem copyWith({bool? isCompleted}) {
    return TaskItem(
      id: id,
      title: title,
      subtitle: subtitle,
      icon: icon,
      iconColor: iconColor,
      iconBackground: iconBackground,
      category: category,
      coins: coins,
      xp: xp,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }
}
