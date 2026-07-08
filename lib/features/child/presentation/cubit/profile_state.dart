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
    required this.equippedFaceEmoji,
    required this.equippedBadgeEmoji,
    required this.isUpdatingName,
  });

  const ProfileState.initial()
    : name = '',
      editingName = '',
      isEditing = false,
      questsDone = 6,
      dayStreak = 5,
      level = 5,
      levelLabel = 'Level 5 Hero',
      xpProgress = 0.45,
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

  /// The child's chosen face emoji (free pick, persisted to the backend).
  final String selectedFaceEmoji;

  const AvatarState({
    required this.avatarItems,
    this.selectedCategory = AvatarCategory.face,
    this.level = 0,
    this.selectedFaceEmoji = '😊',
  });

  const AvatarState.initial()
    : avatarItems = const [],
      selectedCategory = AvatarCategory.face,
      level = 0,
      selectedFaceEmoji = '😊';

  List<AvatarGridItem> get currentItems =>
      avatarItems.where((i) => i.category == selectedCategory).toList();

  String get equippedFaceEmoji => selectedFaceEmoji;

  AvatarState copyWith({
    List<AvatarGridItem>? avatarItems,
    AvatarCategory? selectedCategory,
    int? level,
    String? selectedFaceEmoji,
  }) {
    return AvatarState(
      avatarItems: avatarItems ?? this.avatarItems,
      selectedCategory: selectedCategory ?? this.selectedCategory,
      level: level ?? this.level,
      selectedFaceEmoji: selectedFaceEmoji ?? this.selectedFaceEmoji,
    );
  }
}
