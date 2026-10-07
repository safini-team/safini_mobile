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

  /// v2: illustrated character ID ('char_01' … 'char_24'). Non-null once
  /// loaded from the backend; surfaces should fall back to [defaultCharacterId]
  /// from avatar_character_catalog.dart when null.
  final String? characterId;

  /// Legacy: emoji face (kept for parent surfaces not yet on the illustrated renderer).
  final String equippedFaceEmoji;
  final String equippedBadgeEmoji;
  final bool isUpdatingName;

  const ProfileState({
    required this.name,
    required this.editingName,
    required this.isEditing,
    required this.questsDone,
    required this.dayStreak,
    required this.level,
    required this.levelLabel,
    required this.xpProgress,
    this.characterId,
    required this.equippedFaceEmoji,
    required this.equippedBadgeEmoji,
    required this.isUpdatingName,
  });

  /// Empty starting state — every number is filled from the backend
  /// (`GET /children/{id}/home`). Nothing here is placeholder data.
  const ProfileState.initial()
    : name = '',
      editingName = '',
      isEditing = false,
      questsDone = 0,
      dayStreak = 0,
      level = 0,
      levelLabel = '',
      xpProgress = 0,
      characterId = null,
      equippedFaceEmoji = '😊',
      equippedBadgeEmoji = '🚀',
      isUpdatingName = false;

  ProfileState copyWith({
    String? name,
    String? editingName,
    bool? isEditing,
    int? questsDone,
    int? dayStreak,
    int? level,
    double? xpProgress,
    String? characterId,
    String? equippedFaceEmoji,
    String? equippedBadgeEmoji,
    bool? isUpdatingName,
  }) {
    return ProfileState(
      name: name ?? this.name,
      editingName: editingName ?? this.editingName,
      isEditing: isEditing ?? this.isEditing,
      questsDone: questsDone ?? this.questsDone,
      dayStreak: dayStreak ?? this.dayStreak,
      level: level ?? this.level,
      levelLabel: level != null ? 'Level $level Hero' : levelLabel,
      xpProgress: xpProgress ?? this.xpProgress,
      characterId: characterId ?? this.characterId,
      equippedFaceEmoji: equippedFaceEmoji ?? this.equippedFaceEmoji,
      equippedBadgeEmoji: equippedBadgeEmoji ?? this.equippedBadgeEmoji,
      isUpdatingName: isUpdatingName ?? this.isUpdatingName,
    );
  }
}

// ─── Avatar Customizer State ──────────────────────────────────────────────────

class AvatarState {
  final List<AvatarGridItem> avatarItems;
  final AvatarCategory selectedCategory;
  final int level;

  /// v2: stable illustrated character ID ('char_01' … 'char_24').
  /// Null before the child has chosen a character (UI defaults to char_01).
  final String? characterId;

  /// Legacy: emoji face (kept for backward compat with parent surfaces that
  /// have not yet migrated to the illustrated renderer).
  final String selectedFaceEmoji;

  /// Characters the child has unlocked (includes all free chars + purchased ones).
  final Set<String> ownedCharacterIds;

  const AvatarState({
    required this.avatarItems,
    this.selectedCategory = AvatarCategory.character,
    this.level = 0,
    this.characterId,
    this.selectedFaceEmoji = '😊',
    this.ownedCharacterIds = const {},
  });

  const AvatarState.initial()
    : avatarItems = const [],
      selectedCategory = AvatarCategory.character,
      level = 0,
      characterId = null,
      selectedFaceEmoji = '😊',
      ownedCharacterIds = const {};

  List<AvatarGridItem> get currentItems =>
      avatarItems.where((i) => i.category == selectedCategory).toList();

  String get equippedFaceEmoji => selectedFaceEmoji;

  AvatarState copyWith({
    List<AvatarGridItem>? avatarItems,
    AvatarCategory? selectedCategory,
    int? level,
    String? characterId,
    bool clearCharacterId = false,
    String? selectedFaceEmoji,
    Set<String>? ownedCharacterIds,
  }) {
    return AvatarState(
      avatarItems: avatarItems ?? this.avatarItems,
      selectedCategory: selectedCategory ?? this.selectedCategory,
      level: level ?? this.level,
      characterId: clearCharacterId ? null : (characterId ?? this.characterId),
      selectedFaceEmoji: selectedFaceEmoji ?? this.selectedFaceEmoji,
      ownedCharacterIds: ownedCharacterIds ?? this.ownedCharacterIds,
    );
  }
}
