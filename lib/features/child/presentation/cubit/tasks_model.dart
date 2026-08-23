import 'package:flutter/material.dart';
import 'package:safini/core/translation/generated/l10n.dart';

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

  /// Emoji the parent picked; shown instead of [icon] when present.
  final String? emoji;
  final TaskCategory category;
  final int coins;
  final int xp;
  final bool isCompleted;
  final String status;

  bool get isSubmitted {
    final s = status.toLowerCase();
    return s == 'submitted' ||
        s == 'pending' ||
        s == 'pending_approval' ||
        s == 'awaiting_approval';
  }

  String localizedSubtitle(S s) => localizedTaskSubtitle(
    s,
    customSubtitle: subtitle,
    coins: coins,
    isCompleted: isCompleted,
  );

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
    this.emoji,
    this.isCompleted = false,
    this.status = 'available',
  });

  TaskItem copyWith({bool? isCompleted, String? status}) {
    return TaskItem(
      id: id,
      title: title,
      subtitle: subtitle,
      icon: icon,
      iconColor: iconColor,
      iconBackground: iconBackground,
      emoji: emoji,
      category: category,
      coins: coins,
      xp: xp,
      isCompleted: isCompleted ?? this.isCompleted,
      status: status ?? this.status,
    );
  }
}

String localizedTaskSubtitle(
  S s, {
  required String customSubtitle,
  required int coins,
  required bool isCompleted,
}) {
  if (customSubtitle.trim().isNotEmpty) return customSubtitle.trim();
  if (coins > 0) return s.coinsReward(coins);
  return isCompleted ? s.completed : s.readyWhenYouAre;
}
