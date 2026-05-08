import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:safini/core/utils/error/failures.dart';
import 'package:safini/features/child/domain/controllers/child_controller.dart';
import 'package:safini/features/child/domain/models/child_model.dart';
import 'package:safini/features/child/presentation/cubit/coins_cubit.dart';
import 'package:safini/features/child/presentation/cubit/profile_model.dart';
import 'package:safini/features/child/presentation/cubit/profile_state.dart';
import 'package:safini/features/common/profile/data/repositories/profile_repository.dart';
import 'package:safini/features/models/domain/models/child_model.dart'
    as claimed_child;

// ─── Profile Cubit ────────────────────────────────────────────────────────────

class ProfileCubit extends Cubit<ProfileState> {
  final ChildController _childController;
  final ProfileRepository _profileRepository;
  final CoinsCubit _coinsCubit;

  ProfileCubit(this._childController, this._profileRepository, this._coinsCubit)
    : super(const ProfileState.initial());

  Future<void> loadProfile({claimed_child.ChildModel? fallbackChild}) async {
    debugPrint(
      '[ProfileCubit] loadProfile start | fallbackChild.id=${fallbackChild?.id} '
      '| fallbackChild.nickname=${fallbackChild?.nickname}',
    );
    if (fallbackChild != null) {
      _updateFromClaimedChildModel(fallbackChild);
    }

    // First get the profile to find the childId
    final profileResult = await _profileRepository.fetchMe();

    await profileResult.fold(
      (failure) async {
        debugPrint('[ProfileCubit] fetchMe failed: $failure');
        // If profile fetch fails, we can't find childId, but let's try fetchChildren as fallback
        final fallbackId = fallbackChild?.id;
        if (fallbackId != null && fallbackId.isNotEmpty) {
          debugPrint('[ProfileCubit] using fallback child id: $fallbackId');
          await _loadByChildId(fallbackId);
        } else {
          debugPrint(
            '[ProfileCubit] no fallback child id, loading first child',
          );
          await _loadFirstChildFallback();
        }
      },
      (profile) async {
        debugPrint(
          '[ProfileCubit] fetchMe success | profile.childId=${profile.childId} '
          '| profile.displayName=${profile.displayName} '
          '| accountType=${profile.accountType}',
        );
        if (state.name.trim().isEmpty &&
            profile.displayName.trim().isNotEmpty) {
          debugPrint(
            '[ProfileCubit] applying /me displayName fallback: ${profile.displayName}',
          );
          emit(state.copyWith(name: profile.displayName.trim()));
        }
        final resolvedChildId =
            (profile.childId != null && profile.childId!.isNotEmpty)
            ? profile.childId!
            : fallbackChild?.id;
        if (resolvedChildId != null && resolvedChildId.isNotEmpty) {
          debugPrint('[ProfileCubit] resolved child id: $resolvedChildId');
          await _loadByChildId(resolvedChildId);
        } else {
          // If no childId, try to get the first child from current family
          debugPrint(
            '[ProfileCubit] no resolved child id, loading first child',
          );
          await _loadFirstChildFallback();
        }
      },
    );
  }

  Future<void> _loadByChildId(String childId) async {
    debugPrint('[ProfileCubit] loading dashboard for childId=$childId');
    final childResult = await _childController.fetchChildDashboard(childId);
    await childResult.fold(
      (failure) async {
        debugPrint('[ProfileCubit] dashboard failed: $failure');
        // Fallback when /dashboard is unavailable (404 on some environments).
        debugPrint('[ProfileCubit] loading child by id fallback: $childId');
        final byIdResult = await _childController.fetchChild(childId);
        byIdResult.fold(
          (byIdFailure) {
            debugPrint('[ProfileCubit] child by id failed: $byIdFailure');
            _loadFirstChildFallback();
          },
          (child) {
            debugPrint(
              '[ProfileCubit] child by id success | nickname=${child.nickname} '
              '| level=${child.level} | tasks=${child.tasksCompletedCount} '
              '| streak=${child.currentStreakDays} | coins=${child.coinsBalance}',
            );
            _updateFromChildModel(child);
          },
        );
      },
      (child) async {
        debugPrint(
          '[ProfileCubit] dashboard success | nickname=${child.nickname} '
          '| level=${child.level} | tasks=${child.tasksCompletedCount} '
          '| streak=${child.currentStreakDays} | coins=${child.coinsBalance}',
        );
        _updateFromChildModel(child);
      },
    );
  }

  Future<void> _loadFirstChildFallback() async {
    debugPrint('[ProfileCubit] loading first child fallback from family');
    final childrenResult = await _childController.fetchChildren();
    childrenResult.fold(
      (failure) {
        debugPrint('[ProfileCubit] fetchChildren failed: $failure');
      }, // Keep mock data if everything fails
      (children) {
        debugPrint(
          '[ProfileCubit] fetchChildren success count=${children.length}',
        );
        if (children.isNotEmpty) {
          debugPrint(
            '[ProfileCubit] using first child | id=${children.first.id} '
            '| nickname=${children.first.nickname}',
          );
          _updateFromChildModel(children.first);
        }
      },
    );
  }

  void _updateFromChildModel(ChildModel child) {
    debugPrint(
      '[ProfileCubit] apply child model | nickname=${child.nickname} '
      '| level=${child.level} | xp=${child.xp} '
      '| tasks=${child.tasksCompletedCount} | streak=${child.currentStreakDays} '
      '| coins=${child.coinsBalance}',
    );
    _coinsCubit.set(child.coinsBalance);
    emit(
      state.copyWith(
        name: child.nickname,
        questsDone: child.tasksCompletedCount,
        dayStreak: child.currentStreakDays,
        level: child.level,
        xpProgress: (child.xp % 1000) / 1000.0, // Example: 1000 XP per level
      ),
    );
  }

  void _updateFromClaimedChildModel(claimed_child.ChildModel child) {
    debugPrint(
      '[ProfileCubit] apply claimed child fallback | id=${child.id} '
      '| nickname=${child.nickname} | level=${child.level}',
    );
    _coinsCubit.set(child.coinsBalance);
    emit(
      state.copyWith(
        name: child.nickname,
        questsDone: child.tasksCompletedCount,
        dayStreak: child.currentStreakDays,
        level: child.level,
        xpProgress: (child.xp % 1000) / 1000.0,
      ),
    );
  }

  void startEditing() =>
      emit(state.copyWith(isEditing: true, editingName: state.name));

  void updateEditingName(String value) =>
      emit(state.copyWith(editingName: value));

  void saveName() => emit(
    state.copyWith(
      name: state.editingName.trim().isEmpty ? state.name : state.editingName,
      isEditing: false,
    ),
  );

  void cancelEditing() => emit(state.copyWith(isEditing: false));

  void updateEquippedEmojis({
    required String faceEmoji,
    required String badgeEmoji,
  }) {
    emit(
      state.copyWith(
        equippedFaceEmoji: faceEmoji,
        equippedBadgeEmoji: badgeEmoji,
      ),
    );
  }

  Future<Failure?> updateDisplayName(String displayName) async {
    final trimmed = displayName.trim();
    if (trimmed.isEmpty || trimmed.length > 120) {
      return ValidationFailure('Name must be between 1 and 120 characters.');
    }

    if (state.isUpdatingName) return null;

    emit(state.copyWith(isUpdatingName: true));
    final result = await _profileRepository.updateMe(displayName: trimmed);

    Failure? capturedFailure;
    result.fold(
      (failure) {
        capturedFailure = failure;
      },
      (profile) {
        emit(state.copyWith(name: profile.displayName.trim()));
      },
    );

    emit(state.copyWith(isUpdatingName: false));
    return capturedFailure;
  }
}

// ─── Avatar Cubit ─────────────────────────────────────────────────────────────

class AvatarCubit extends Cubit<AvatarState> {
  final CoinsCubit _coins;

  AvatarCubit(this._coins) : super(const AvatarState.initial()) {
    _loadItems();
  }

  void _loadItems() {
    emit(
      state.copyWith(
        avatarItems: const [
          // Outfits
          AvatarGridItem(
            id: 'outfit_tshirt',
            emoji: '👕',
            category: AvatarCategory.outfits,
          ),
          AvatarGridItem(
            id: 'outfit_avatar',
            emoji: '🧑',
            category: AvatarCategory.outfits,
            cost: 450,
          ),
          AvatarGridItem(
            id: 'outfit_rocket',
            emoji: '🚀',
            category: AvatarCategory.outfits,
            isEquipped: true,
          ),
          AvatarGridItem(
            id: 'outfit_hero',
            emoji: '🦸',
            category: AvatarCategory.outfits,
            cost: 300,
          ),
          AvatarGridItem(
            id: 'outfit_swords',
            emoji: '⚔️',
            category: AvatarCategory.outfits,
            isLocked: true,
            lockLabel: 'LV.25',
          ),
          AvatarGridItem(
            id: 'outfit_robot',
            emoji: '🤖',
            category: AvatarCategory.outfits,
            cost: 500,
          ),
          // Face
          AvatarGridItem(
            id: 'face_smile',
            emoji: '😊',
            category: AvatarCategory.face,
            isEquipped: true,
          ),
          AvatarGridItem(
            id: 'face_cool',
            emoji: '😎',
            category: AvatarCategory.face,
            cost: 100,
          ),
          AvatarGridItem(
            id: 'face_star',
            emoji: '🤩',
            category: AvatarCategory.face,
            cost: 200,
          ),
          AvatarGridItem(
            id: 'face_think',
            emoji: '🤔',
            category: AvatarCategory.face,
            cost: 150,
          ),
          AvatarGridItem(
            id: 'face_shock',
            emoji: '😮',
            category: AvatarCategory.face,
            cost: 250,
          ),
          AvatarGridItem(
            id: 'face_locked',
            emoji: '🔒',
            category: AvatarCategory.face,
            isLocked: true,
            lockLabel: 'LV.10',
          ),
          // Hair
          AvatarGridItem(
            id: 'hair_default',
            emoji: '👦',
            category: AvatarCategory.hair,
            isEquipped: true,
          ),
          AvatarGridItem(
            id: 'hair_blonde',
            emoji: '👱',
            category: AvatarCategory.hair,
            cost: 100,
          ),
          AvatarGridItem(
            id: 'hair_red',
            emoji: '🧑‍🦰',
            category: AvatarCategory.hair,
            cost: 150,
          ),
          AvatarGridItem(
            id: 'hair_curly',
            emoji: '🧑‍🦱',
            category: AvatarCategory.hair,
            cost: 200,
          ),
          AvatarGridItem(
            id: 'hair_locked',
            emoji: '🔒',
            category: AvatarCategory.hair,
            isLocked: true,
            lockLabel: 'LV.8',
          ),
          // Back
          AvatarGridItem(
            id: 'back_default',
            emoji: '🎒',
            category: AvatarCategory.back,
            isEquipped: true,
          ),
          AvatarGridItem(
            id: 'back_wings',
            emoji: '🦋',
            category: AvatarCategory.back,
            cost: 200,
          ),
          AvatarGridItem(
            id: 'back_cape',
            emoji: '🦸',
            category: AvatarCategory.back,
            cost: 300,
          ),
        ],
      ),
    );
  }

  void selectCategory(AvatarCategory category) =>
      emit(state.copyWith(selectedCategory: category));

  void equipItem(String id) {
    final target = state.avatarItems.firstWhere((i) => i.id == id);
    if (target.isLocked || target.isEquipped) return;

    final cost = target.cost ?? 0;
    if (cost > 0 && _coins.state < cost) {
      return; // not enough coins
    }

    _coins.subtract(cost);
    final updated = state.avatarItems.map((item) {
      if (item.id == id) {
        return item.copyWith(isEquipped: true, clearCost: true);
      }
      if (item.category == target.category && item.isEquipped) {
        return item.copyWith(isEquipped: false);
      }
      return item;
    }).toList();
    emit(state.copyWith(avatarItems: updated));
  }
}
