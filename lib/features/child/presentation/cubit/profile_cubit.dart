import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:safini/core/utils/constants/api_const.dart';
import 'package:safini/core/utils/error/failures.dart';
import 'package:safini/features/child/domain/controllers/child_controller.dart';
import 'package:safini/features/child/domain/models/child_model.dart';
import 'package:safini/features/child/presentation/cubit/coins_cubit.dart';
import 'package:safini/features/child/presentation/cubit/profile_model.dart';
import 'package:safini/features/child/presentation/cubit/profile_state.dart';
import 'package:safini/features/common/profile/data/repositories/profile_repository.dart';
import 'package:safini/features/common/profile/domain/controllers/profile_controller.dart'
    as common_profile;
import 'package:safini/features/models/domain/models/child_model.dart'
    as claimed_child;

// ─── Profile Cubit ────────────────────────────────────────────────────────────

class ProfileCubit extends Cubit<ProfileState> {
  final ChildController _childController;
  final ProfileRepository _profileRepository;
  final CoinsCubit _coinsCubit;
  final Dio _dio;

  ProfileCubit(
    this._childController,
    this._profileRepository,
    this._coinsCubit,
    this._dio,
  ) : super(const ProfileState.initial());

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
          // `/home` is child-accessible and already carries the full child
          // row. Only fall back to the parent-only `/dashboard` chain if it
          // fails (e.g. a parent viewing this screen).
          final loaded = await _loadFromHome(resolvedChildId);
          if (!loaded) {
            await _loadByChildId(resolvedChildId);
          }
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

  /// Loads the child's real profile from `GET /children/{id}/home`.
  ///
  /// `/home` is the child-accessible endpoint and already returns the full
  /// child row (level, xp, streak, tasks completed, coins, avatar_state).
  /// `/dashboard` is parent-only and returns 403 for a child.
  /// Returns true when the profile was applied.
  Future<bool> _loadFromHome(String childId) async {
    try {
      final response = await _dio.get(ApiConst.childHome(childId));
      final data = _asMapDynamic(response.data);
      final child = _asMapDynamic(data['child']);
      if (child.isEmpty || isClosed) return false;

      final coins = _asInt(child['coins_balance']);
      _coinsCubit.set(coins);

      final xp = _asInt(child['xp']);
      final nickname = (child['nickname'] ?? '').toString().trim();

      emit(
        state.copyWith(
          name: nickname.isEmpty ? state.name : nickname,
          questsDone: _asInt(child['tasks_completed_count']),
          dayStreak: _asInt(child['current_streak_days']),
          level: _asInt(child['level']),
          xpProgress: (xp % 100) / 100.0,
          equippedFaceEmoji:
              _avatarEmoji(_asMapDynamic(child['avatar_state']), 'face') ?? '😊',
        ),
      );
      return true;
    } catch (e) {
      debugPrint('[ProfileCubit] /home load failed: $e');
      return false;
    }
  }

  Map<String, dynamic> _asMapDynamic(dynamic raw) {
    if (raw is Map) return raw.map((k, v) => MapEntry(k.toString(), v));
    return const {};
  }

  int _asInt(dynamic raw) => raw is num ? raw.toInt() : 0;

  void _updateFromChildModel(ChildModel child) {
    if (isClosed) return;
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
        xpProgress: (child.xp % 100) / 100.0,
        equippedFaceEmoji: _avatarEmoji(child.avatarState, 'face') ?? '😊',
        equippedBadgeEmoji:
            _avatarEmoji(child.avatarState, 'outfit') ??
            _avatarEmoji(child.avatarState, 'outfits') ??
            '🚀',
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
        xpProgress: (child.xp % 100) / 100.0,
        equippedFaceEmoji:
            _avatarEmoji(child.avatarState.toJson(), 'face') ?? '😊',
        equippedBadgeEmoji:
            _avatarEmoji(child.avatarState.toJson(), 'outfit') ??
            _avatarEmoji(child.avatarState.toJson(), 'outfits') ??
            '🚀',
      ),
    );
  }

  String? _avatarEmoji(Map<String, dynamic>? avatarState, String slot) {
    if (avatarState == null) return null;
    final emojis = avatarState['emojis'];
    if (emojis is Map) {
      final emoji = emojis[slot]?.toString().trim();
      if (emoji != null && emoji.isNotEmpty) return emoji;
    }
    final equipped = avatarState['equipped'];
    if (equipped is Map) {
      final key = equipped[slot]?.toString().trim();
      if (key != null && key.isNotEmpty) return _emojiForAvatarKey(key);
    }
    return null;
  }

  String _emojiForAvatarKey(String key) {
    final value = key.toLowerCase();
    if (value.contains('cape') || value.contains('hero')) return '🦸';
    if (value.contains('rocket')) return '🚀';
    if (value.contains('sword')) return '⚔️';
    if (value.contains('robot')) return '🤖';
    if (value.contains('star')) return '🤩';
    if (value.contains('cool')) return '😎';
    if (value.contains('hair')) return '👦';
    if (value.contains('shirt') || value.contains('outfit')) return '👕';
    return '😊';
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
  final Dio _dio;
  final common_profile.ProfileController _profileController;
  String? _childId;

  /// Owned items the child currently has equipped, keyed by slot. Preserved so
  /// saving a face never wipes them (the backend validates this map against the
  /// child's owned inventory).
  Map<String, String> _equipped = const {};

  AvatarCubit(this._coins, this._dio, this._profileController)
    : super(const AvatarState.initial()) {
    loadItems();
  }

  Future<void> loadItems() async {
    final childId = await _resolveChildId();
    if (isClosed) return;
    if (childId == null) {
      emit(state.copyWith(avatarItems: const []));
      return;
    }

    try {
      final response = await _dio.get(ApiConst.childStore(childId));
      final data = _asMap(response.data);
      final level = await _loadLevel(childId);
      if (isClosed) return;
      final balance = _intValue(data, ['balance', 'coins_balance']);
      if (balance != null) {
        _coins.set(balance);
      }
      final equipped = _extractEquipped(data['avatar_state']);
      // Keep the owned/equipped items so saving a face never wipes them — the
      // backend validates `equipped` against the child's owned inventory.
      _equipped = equipped;
      emit(
        state.copyWith(
          avatarItems: _parseAvatarItems(data['avatar_items'], equipped),
          level: level,
          selectedFaceEmoji: _extractFaceEmoji(data['avatar_state']),
        ),
      );
    } catch (_) {
      if (isClosed) return;
      emit(state.copyWith(avatarItems: const []));
    }
  }

  /// Reads the persisted face emoji from `avatar_state.emojis.face`.
  String _extractFaceEmoji(dynamic raw) {
    final state = _asMap(raw);
    final emojis = _asMap(state['emojis']);
    final face = emojis['face']?.toString().trim();
    if (face != null && face.isNotEmpty) return face;
    return this.state.selectedFaceEmoji;
  }

  /// Selects a face emoji and persists it so the parent can see it.
  ///
  /// The face goes into the free-form `emojis` map only. `equipped` is sent
  /// back untouched because the backend validates it against the child's owned
  /// inventory — putting a raw emoji there is rejected with
  /// "Avatar state references items the child does not own".
  Future<void> selectFace(String emoji) async {
    emit(state.copyWith(selectedFaceEmoji: emoji));
    final childId = await _resolveChildId();
    if (childId == null) return;
    try {
      await _dio.patch(
        ApiConst.childAvatar(childId),
        data: {
          'avatar_state': {
            'equipped': _equipped,
            'emojis': {'face': emoji},
          },
        },
      );
    } catch (e) {
      debugPrint('[AvatarCubit] saving face failed: $e');
    }
  }

  /// Reads the child's level from `/home` — the child-accessible endpoint.
  /// `/dashboard` is parent-only and returns 403 for a child.
  Future<int> _loadLevel(String childId) async {
    try {
      final response = await _dio.get(ApiConst.childHome(childId));
      final data = _asMap(response.data);
      final child = _asMap(data['child']);
      return _intValue(child, ['level']) ?? 0;
    } catch (_) {
      return 0;
    }
  }

  Future<String?> _resolveChildId() async {
    if (_childId != null && _childId!.isNotEmpty) return _childId;
    final profileResult = await _profileController.fetchMe();
    _childId = profileResult.fold((_) => null, (profile) {
      final childId = profile.childId?.trim();
      return childId == null || childId.isEmpty ? null : childId;
    });
    return _childId;
  }

  Map<String, String> _extractEquipped(dynamic raw) {
    final state = _asMap(raw);
    final equipped = state['equipped'];
    if (equipped is Map) {
      return equipped.map(
        (key, value) => MapEntry(key.toString(), value.toString()),
      );
    }
    return const {};
  }

  List<AvatarGridItem> _parseAvatarItems(
    dynamic raw,
    Map<String, String> equipped,
  ) {
    if (raw is! List) return const [];
    return raw
        .whereType<Map>()
        .map((item) {
          final map = item.map((key, value) => MapEntry(key.toString(), value));
          final key = _stringValue(map, ['item_key', 'id', 'avatar_item_id']);
          final category = _categoryForKey(key);
          final owned = map['is_owned'] == true || map['owned'] == true;
          final isEquipped =
              map['is_equipped'] == true ||
              equipped[_slotForCategory(category)] == key;
          return AvatarGridItem(
            id: key,
            emoji: _emojiForAvatarKey(key),
            category: category,
            cost: owned || isEquipped
                ? null
                : _intValue(map, ['coin_cost', 'cost']),
            isEquipped: isEquipped,
            isLocked: map['is_locked'] == true || map['locked'] == true,
            lockLabel: map['lock_label']?.toString(),
          );
        })
        .where((item) => item.id.isNotEmpty)
        .toList();
  }

  AvatarCategory _categoryForKey(String key) {
    final value = key.toLowerCase();
    if (value.contains('face') ||
        value.contains('smile') ||
        value.contains('cool')) {
      return AvatarCategory.face;
    }
    if (value.contains('hair')) return AvatarCategory.hair;
    if (value.contains('back') ||
        value.contains('wing') ||
        value.contains('cape')) {
      return AvatarCategory.back;
    }
    return AvatarCategory.outfits;
  }

  String _slotForCategory(AvatarCategory category) {
    switch (category) {
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

  String _emojiForAvatarKey(String key) {
    final value = key.toLowerCase();
    if (value.contains('cape') || value.contains('hero')) return '🦸';
    if (value.contains('rocket')) return '🚀';
    if (value.contains('sword')) return '⚔️';
    if (value.contains('robot')) return '🤖';
    if (value.contains('star')) return '🤩';
    if (value.contains('cool')) return '😎';
    if (value.contains('hair')) return '👦';
    if (value.contains('shirt') || value.contains('outfit')) return '👕';
    return '😊';
  }

  void selectCategory(AvatarCategory category) =>
      emit(state.copyWith(selectedCategory: category));

  Future<void> equipItem(String id) async {
    final target = state.avatarItems.firstWhere((i) => i.id == id);
    if (target.isLocked || target.isEquipped) return;

    final cost = target.cost ?? 0;
    if (cost > 0 && _coins.state < cost) {
      return;
    }

    if (cost > 0) {
      _coins.subtract(cost);
    }
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
    await _saveAvatarState(updated);
  }

  Future<void> _saveAvatarState(List<AvatarGridItem> items) async {
    final childId = await _resolveChildId();
    if (childId == null) {
      return;
    }
    final equipped = <String, String>{};
    final emojis = <String, String>{};
    for (final item in items.where((item) => item.isEquipped)) {
      final slot = _slotForCategory(item.category);
      equipped[slot] = item.id;
      emojis[slot] = item.emoji;
    }
    try {
      await _dio.patch(
        ApiConst.childAvatar(childId),
        data: {
          'avatar_state': {'equipped': equipped, 'emojis': emojis},
        },
      );
    } catch (_) {}
  }

  Map<String, dynamic> _asMap(dynamic raw) {
    if (raw is Map<String, dynamic>) {
      return raw;
    }
    if (raw is Map) {
      return raw.map((key, value) => MapEntry(key.toString(), value));
    }
    return const {};
  }

  String _stringValue(Map<String, dynamic> json, List<String> keys) {
    for (final key in keys) {
      final value = json[key]?.toString().trim();
      if (value != null && value.isNotEmpty) {
        return value;
      }
    }
    return '';
  }

  int? _intValue(Map<String, dynamic> json, List<String> keys) {
    for (final key in keys) {
      final value = json[key];
      if (value is int) {
        return value;
      }
      if (value is num) {
        return value.toInt();
      }
      final parsed = int.tryParse(value?.toString() ?? '');
      if (parsed != null) {
        return parsed;
      }
    }
    return null;
  }
}
