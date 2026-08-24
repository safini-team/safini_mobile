import 'package:flutter/material.dart';

enum StoreTab { appTime, avatarItems }

class AppTimeItem {
  final String id;
  final String title;
  final int minutes;
  final IconData icon;
  final Color iconColor;
  final Color iconBackground;
  final int cost;

  /// Whether redemptions are enabled for this app (parent-controlled).
  final bool isEnabled;

  /// Redeemed minutes still available for this app (0 = none active).
  final int remainingMinutes;

  const AppTimeItem({
    required this.id,
    required this.title,
    required this.minutes,
    required this.icon,
    required this.iconColor,
    required this.iconBackground,
    required this.cost,
    this.isEnabled = true,
    this.remainingMinutes = 0,
  });

  AppTimeItem copyWith({int? remainingMinutes}) {
    return AppTimeItem(
      id: id,
      title: title,
      minutes: minutes,
      icon: icon,
      iconColor: iconColor,
      iconBackground: iconBackground,
      cost: cost,
      isEnabled: isEnabled,
      remainingMinutes: remainingMinutes ?? this.remainingMinutes,
    );
  }
}

class AvatarItem {
  final String id;

  /// Display name straight from the API (`avatar_items[].name`), e.g.
  /// "Cosmic Cape". Empty only when the payload omitted it.
  final String name;

  final String emoji;
  final int? cost;
  final bool isEquipped;
  final bool isLocked;
  final String? lockLabel;

  const AvatarItem({
    required this.id,
    this.name = '',
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
