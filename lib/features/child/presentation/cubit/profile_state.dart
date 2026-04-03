import 'package:safini/features/child/presentation/cubit/profile_model.dart';

class ProfileState {
  final String name;
  final String editingName;
  final bool isEditing;
  final int questsDone;
  final int dayStreak;
  final int level;
  final String levelLabel;
  final double xpProgress;
  final String equippedFaceEmoji;
  final String equippedBadgeEmoji;

  const ProfileState({
    required this.name,
    required this.editingName,
    required this.isEditing,
    required this.questsDone,
    required this.dayStreak,
    required this.level,
    required this.levelLabel,
    required this.xpProgress,
    required this.equippedFaceEmoji,
    required this.equippedBadgeEmoji,
  });

  const ProfileState.initial()
      : name = 'Explorer Leo',
        editingName = 'Explorer Leo',
        isEditing = false,
        questsDone = 6,
        dayStreak = 5,
        level = 5,
        levelLabel = 'Level 5 Hero',
        xpProgress = 0.45,
        equippedFaceEmoji = '😊',
        equippedBadgeEmoji = '🚀';

  ProfileState copyWith({
    String? name,
    String? editingName,
    bool? isEditing,
    int? questsDone,
    int? dayStreak,
    String? equippedFaceEmoji,
    String? equippedBadgeEmoji,
  }) {
    return ProfileState(
      name: name ?? this.name,
      editingName: editingName ?? this.editingName,
      isEditing: isEditing ?? this.isEditing,
      questsDone: questsDone ?? this.questsDone,
      dayStreak: dayStreak ?? this.dayStreak,
      level: level,
      levelLabel: levelLabel,
      xpProgress: xpProgress,
      equippedFaceEmoji: equippedFaceEmoji ?? this.equippedFaceEmoji,
      equippedBadgeEmoji: equippedBadgeEmoji ?? this.equippedBadgeEmoji,
    );
  }
}

// ─── Avatar Customizer State ──────────────────────────────────────────────────

class AvatarState {
  final List<AvatarGridItem> avatarItems;
  final AvatarCategory selectedCategory;

  const AvatarState({
    required this.avatarItems,
    this.selectedCategory = AvatarCategory.outfits,
  });

  const AvatarState.initial()
      : avatarItems = const [],
        selectedCategory = AvatarCategory.outfits;

  List<AvatarGridItem> get currentItems =>
      avatarItems.where((i) => i.category == selectedCategory).toList();

  String get equippedFaceEmoji =>
      avatarItems
          .where((i) => i.category == AvatarCategory.face && i.isEquipped)
          .firstOrNull
          ?.emoji ??
      '😊';

  String get equippedBadgeEmoji =>
      avatarItems
          .where((i) => i.category == AvatarCategory.outfits && i.isEquipped)
          .firstOrNull
          ?.emoji ??
      '🚀';

  AvatarState copyWith({
    List<AvatarGridItem>? avatarItems,
    AvatarCategory? selectedCategory,
  }) {
    return AvatarState(
      avatarItems: avatarItems ?? this.avatarItems,
      selectedCategory: selectedCategory ?? this.selectedCategory,
    );
  }
}
