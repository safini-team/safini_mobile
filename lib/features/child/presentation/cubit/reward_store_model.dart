import 'package:flutter/material.dart';

enum StoreTab { appTime, avatarItems }

class AppTimeItem {
  final String id;
  final String title;
  final String subtitle;
  final IconData icon;
  final Color iconColor;
  final Color iconBackground;
  final int cost;

  const AppTimeItem({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.iconColor,
    required this.iconBackground,
    required this.cost,
  });
}

class AvatarItem {
  final String id;
  final String emoji;
  final int? cost;
  final bool isEquipped;
  final bool isLocked;
  final String? lockLabel;

  const AvatarItem({
    required this.id,
    required this.emoji,
    this.cost,
    this.isEquipped = false,
    this.isLocked = false,
    this.lockLabel,
  });

  bool get isFree => cost == null && !isEquipped && !isLocked;

  AvatarItem copyWith({bool? isEquipped, bool clearCost = false}) {
    return AvatarItem(
      id: id,
      emoji: emoji,
      cost: clearCost ? null : cost,
      isEquipped: isEquipped ?? this.isEquipped,
      isLocked: isLocked,
      lockLabel: lockLabel,
    );
  }
}
