enum AvatarCategory { outfits, face, hair, back }

extension AvatarCategoryX on AvatarCategory {
  String get label {
    switch (this) {
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
}

class AvatarGridItem {
  final String id;
  final String emoji;
  final AvatarCategory category;
  final int? cost;
  final bool isEquipped;
  final bool isLocked;
  final String? lockLabel;

  const AvatarGridItem({
    required this.id,
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
      emoji: emoji,
      category: category,
      cost: clearCost ? null : cost,
      isEquipped: isEquipped ?? this.isEquipped,
      isLocked: isLocked,
      lockLabel: lockLabel,
    );
  }
}
