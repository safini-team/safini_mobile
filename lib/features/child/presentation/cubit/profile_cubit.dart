import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:safini/features/child/presentation/cubit/coins_cubit.dart';
import 'package:safini/features/child/presentation/cubit/profile_model.dart';
import 'package:safini/features/child/presentation/cubit/profile_state.dart';

// ─── Profile Cubit ────────────────────────────────────────────────────────────

class ProfileCubit extends Cubit<ProfileState> {
  ProfileCubit() : super(const ProfileState.initial());

  void startEditing() =>
      emit(state.copyWith(isEditing: true, editingName: state.name));

  void updateEditingName(String value) =>
      emit(state.copyWith(editingName: value));

  void saveName() => emit(state.copyWith(
        name: state.editingName.trim().isEmpty ? state.name : state.editingName,
        isEditing: false,
      ));

  void cancelEditing() => emit(state.copyWith(isEditing: false));

  void updateEquippedEmojis({
    required String faceEmoji,
    required String badgeEmoji,
  }) {
    emit(state.copyWith(
      equippedFaceEmoji: faceEmoji,
      equippedBadgeEmoji: badgeEmoji,
    ));
  }
}

// ─── Avatar Cubit ─────────────────────────────────────────────────────────────

class AvatarCubit extends Cubit<AvatarState> {
  final CoinsCubit _coins;

  AvatarCubit(this._coins) : super(const AvatarState.initial()) {
    _loadItems();
  }

  void _loadItems() {
    emit(state.copyWith(
      avatarItems: const [
        // Outfits
        AvatarGridItem(id: 'outfit_tshirt', emoji: '👕', category: AvatarCategory.outfits),
        AvatarGridItem(id: 'outfit_avatar', emoji: '🧑', category: AvatarCategory.outfits, cost: 450),
        AvatarGridItem(id: 'outfit_rocket', emoji: '🚀', category: AvatarCategory.outfits, isEquipped: true),
        AvatarGridItem(id: 'outfit_hero', emoji: '🦸', category: AvatarCategory.outfits, cost: 300),
        AvatarGridItem(id: 'outfit_swords', emoji: '⚔️', category: AvatarCategory.outfits, isLocked: true, lockLabel: 'LV.25'),
        AvatarGridItem(id: 'outfit_robot', emoji: '🤖', category: AvatarCategory.outfits, cost: 500),
        // Face
        AvatarGridItem(id: 'face_smile', emoji: '😊', category: AvatarCategory.face, isEquipped: true),
        AvatarGridItem(id: 'face_cool', emoji: '😎', category: AvatarCategory.face, cost: 100),
        AvatarGridItem(id: 'face_star', emoji: '🤩', category: AvatarCategory.face, cost: 200),
        AvatarGridItem(id: 'face_think', emoji: '🤔', category: AvatarCategory.face, cost: 150),
        AvatarGridItem(id: 'face_shock', emoji: '😮', category: AvatarCategory.face, cost: 250),
        AvatarGridItem(id: 'face_locked', emoji: '🔒', category: AvatarCategory.face, isLocked: true, lockLabel: 'LV.10'),
        // Hair
        AvatarGridItem(id: 'hair_default', emoji: '👦', category: AvatarCategory.hair, isEquipped: true),
        AvatarGridItem(id: 'hair_blonde', emoji: '👱', category: AvatarCategory.hair, cost: 100),
        AvatarGridItem(id: 'hair_red', emoji: '🧑‍🦰', category: AvatarCategory.hair, cost: 150),
        AvatarGridItem(id: 'hair_curly', emoji: '🧑‍🦱', category: AvatarCategory.hair, cost: 200),
        AvatarGridItem(id: 'hair_locked', emoji: '🔒', category: AvatarCategory.hair, isLocked: true, lockLabel: 'LV.8'),
        // Back
        AvatarGridItem(id: 'back_default', emoji: '🎒', category: AvatarCategory.back, isEquipped: true),
        AvatarGridItem(id: 'back_wings', emoji: '🦋', category: AvatarCategory.back, cost: 200),
        AvatarGridItem(id: 'back_cape', emoji: '🦸', category: AvatarCategory.back, cost: 300),
      ],
    ));
  }

  void selectCategory(AvatarCategory category) =>
      emit(state.copyWith(selectedCategory: category));

  void equipItem(String id) {
    final target = state.avatarItems.firstWhere((i) => i.id == id);
    if (target.isLocked || target.isEquipped) return;

    final cost = target.cost ?? 0;
    if (cost > 0 && _coins.state < cost) return; // not enough coins

    _coins.subtract(cost);
    final updated = state.avatarItems.map((item) {
      if (item.id == id) return item.copyWith(isEquipped: true, clearCost: true);
      if (item.category == target.category && item.isEquipped) {
        return item.copyWith(isEquipped: false);
      }
      return item;
    }).toList();
    emit(state.copyWith(avatarItems: updated));
  }
}
