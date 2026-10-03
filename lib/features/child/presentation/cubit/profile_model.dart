/// Avatar customizer tabs.
///
/// [character] — choose the base illustrated character (replaces the old
///   emoji face grid).
/// [head]      — hats, crowns, and other head cosmetics.
/// [accessory] — glasses, watches, bags, and held items.
/// [vehicle]   — cars, boards, and rideable cosmetics.
///
/// Legacy categories ([outfits], [face], [hair], [back]) are kept so that
/// existing server responses that reference these slot names still parse.
enum AvatarCategory { character, head, accessory, vehicle, outfits, face, hair, back }

extension AvatarCategoryX on AvatarCategory {
  String get label {
    switch (this) {
      case AvatarCategory.character:
        return 'CHARACTER';
      case AvatarCategory.head:
        return 'HEAD';
      case AvatarCategory.accessory:
        return 'ACCESSORIES';
      case AvatarCategory.vehicle:
        return 'VEHICLES';
      case AvatarCategory.outfits:
        return 'OUTFITS';
      case AvatarCategory.face:
        return 'FACE';
      case AvatarCategory.hair:
        return 'HAIR';
      case AvatarCategory.back:
        return 'BACK';
    }
  }

  /// API/database slot name sent in `equipped` map.
  String get slotKey {
    switch (this) {
      case AvatarCategory.character:
        return 'character';
      case AvatarCategory.head:
        return 'head';
      case AvatarCategory.accessory:
        return 'accessory';
      case AvatarCategory.vehicle:
        return 'vehicle';
      case AvatarCategory.outfits:
        return 'outfit';
      case AvatarCategory.face:
        return 'face';
      case AvatarCategory.hair:
        return 'hair';
      case AvatarCategory.back:
        return 'back';
    }
  }
}

class AvatarGridItem {
  final String id;

  /// Stable asset key — maps to assets/avatar/cosmetics/<slot>/<assetKey>.png
  /// Falls back to [emoji] when absent (legacy items).
  final String? assetKey;

  final String emoji;
  final AvatarCategory category;
  final int? cost;
  final bool isEquipped;
  final bool isLocked;
  final String? lockLabel;

  const AvatarGridItem({
    required this.id,
    this.assetKey,
    required this.emoji,
    required this.category,
    this.cost,
    this.isEquipped = false,
    this.isLocked = false,
    this.lockLabel,
  });

  bool get isFree => cost == null && !isEquipped && !isLocked;

  AvatarGridItem copyWith({bool? isEquipped, bool clearCost = false}) {
    return AvatarGridItem(
      id: id,
      assetKey: assetKey,
      emoji: emoji,
      category: category,
      cost: clearCost ? null : cost,
      isEquipped: isEquipped ?? this.isEquipped,
      isLocked: isLocked,
      lockLabel: lockLabel,
    );
  }
}
