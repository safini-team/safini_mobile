import 'package:flutter/material.dart';

enum StoreTab { appTime, prizes, avatarItems }

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

  /// The Android package, so the tile can show the launcher's own icon.
  final String? packageName;

  /// The icon this phone uploaded, for when the launcher has none to give.
  final String? iconUrl;

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
    this.packageName,
    this.iconUrl,
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
      packageName: packageName,
      iconUrl: iconUrl,
    );
  }
}

class AvatarItem {
  final String id;

  /// Display name straight from the API (`avatar_items[].name`), e.g.
  /// "Cosmic Cape". Empty only when the payload omitted it.
  final String name;

  /// Stable asset key from the backend (`avatar_items[].asset_key`).
  /// Used to load `assets/avatar/cosmetics/<slot>/<assetKey>.png`.
  /// Null for legacy items that only carry an emoji heuristic.
  final String? assetKey;

  /// Cosmetic slot ('head', 'accessory', 'vehicle', 'outfit', 'back', …).
  /// Populated from `avatar_items[].slot` when present.
  final String? slot;

  final String emoji;
  final int? cost;
  final bool isEquipped;
  final bool isLocked;
  final String? lockLabel;

  const AvatarItem({
    required this.id,
    this.name = '',
    this.assetKey,
    this.slot,
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
      name: name,
      assetKey: assetKey,
      slot: slot,
      emoji: emoji,
      cost: clearCost ? null : cost,
      isEquipped: isEquipped ?? this.isEquipped,
      isLocked: isLocked,
      lockLabel: lockLabel,
    );
  }
}
