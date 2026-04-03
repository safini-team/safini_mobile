import 'package:flutter/material.dart';

class QuestModel {
  final String id;
  final String title;
  final String subtitle;
  final IconData icon;
  final Color iconColor;
  final Color iconBackground;
  final bool isCompleted;

  const QuestModel({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.iconColor,
    required this.iconBackground,
    this.isCompleted = false,
  });

  QuestModel copyWith({bool? isCompleted}) {
    return QuestModel(
      id: id,
      title: title,
      subtitle: subtitle,
      icon: icon,
      iconColor: iconColor,
      iconBackground: iconBackground,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }
}
