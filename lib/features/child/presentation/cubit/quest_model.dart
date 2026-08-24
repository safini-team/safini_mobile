import 'package:flutter/material.dart';
import 'package:safini/core/translation/generated/l10n.dart';
import 'package:safini/features/child/presentation/cubit/tasks_model.dart';

class QuestModel {
  final String id;
  final String title;
  final String subtitle;
  final IconData icon;
  final Color iconColor;
  final Color iconBackground;

  /// Emoji the parent picked; shown instead of [icon] when present.
  final String? emoji;

  /// The note the parent left when reviewing (approve/reject).
  final String? reviewNote;
  final bool isCompleted;
  final int coins;
  final int xp;
  final String status;

  /// `text_image` when the parent asked for a photo. The sheet asks for one
  /// and refuses to send without it.
  final String? proofMode;

  bool get needsPhoto => (proofMode ?? '').toLowerCase().contains('image');

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

  const QuestModel({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.iconColor,
    required this.iconBackground,
    this.emoji,
    this.reviewNote,
    this.proofMode,
    this.isCompleted = false,
    this.coins = 0,
    this.xp = 0,
    this.status = 'available',
  });

  QuestModel copyWith({bool? isCompleted, String? status}) {
    return QuestModel(
      id: id,
      title: title,
      subtitle: subtitle,
      icon: icon,
      iconColor: iconColor,
      iconBackground: iconBackground,
      emoji: emoji,
      reviewNote: reviewNote,
      proofMode: proofMode,
      isCompleted: isCompleted ?? this.isCompleted,
      coins: coins,
      xp: xp,
      status: status ?? this.status,
    );
  }
}
