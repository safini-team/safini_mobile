import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:safini/core/utils/constants/api_const.dart';
import 'package:safini/features/child/presentation/cubit/coins_cubit.dart';
import 'package:safini/features/child/presentation/cubit/reward_store_model.dart';
import 'package:safini/features/child/presentation/cubit/reward_store_state.dart';
import 'package:safini/features/common/profile/domain/controllers/profile_controller.dart';

class RewardStoreCubit extends Cubit<RewardStoreState> {
  final CoinsCubit _coins;
  final Dio _dio;
  final ProfileController _profileController;
  String? _childId;

  RewardStoreCubit(this._coins, this._dio, this._profileController)
    : super(const RewardStoreState.initial()) {
    loadStore();
  }

  Future<void> loadStore() async {
    final childId = await _resolveChildId();
    if (childId == null) {
      emit(state.copyWith(appTimeItems: const [], avatarItems: const []));
      return;
    }

    try {
      final response = await _dio.get(ApiConst.childStore(childId));
      final data = _asMap(response.data);
      final balance = _intValue(data, ['balance', 'coins_balance']);
      if (balance != null) {
        _coins.set(balance);
      }
      emit(
        state.copyWith(
          appTimeItems: _parseAppTimeItems(data['app_time_offers']),
          avatarItems: _parseAvatarItems(data['avatar_items']),
        ),
      );
    } catch (_) {
      emit(state.copyWith(appTimeItems: const [], avatarItems: const []));
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

  List<AppTimeItem> _parseAppTimeItems(dynamic raw) {
    if (raw is! List) return const [];
    return raw
        .whereType<Map>()
        .map((item) {
          final map = item.map((key, value) => MapEntry(key.toString(), value));
          final slug = _stringValue(map, ['app_slug', 'id', 'key']);
          final title = _stringValue(map, ['display_name', 'title', 'name']);
          return AppTimeItem(
            id: slug,
            title: title.isEmpty ? slug : title,
            minutes: _intValue(map, ['redeem_reward_minutes', 'minutes']) ?? 0,
            icon: _iconForApp(slug),
            iconColor: const Color(0xFF4A90D9),
            iconBackground: const Color(0xFFDEEEFB),
            cost:
                _intValue(map, ['redeem_coin_cost', 'coin_cost', 'cost']) ?? 0,
          );
        })
        .where((item) => item.id.isNotEmpty)
        .toList();
  }

  List<AvatarItem> _parseAvatarItems(dynamic raw) {
    if (raw is! List) return const [];
    return raw
        .whereType<Map>()
        .map((item) {
          final map = item.map((key, value) => MapEntry(key.toString(), value));
          final key = _stringValue(map, ['item_key', 'id', 'avatar_item_id']);
          final owned = map['is_owned'] == true || map['owned'] == true;
          final equipped =
              map['is_equipped'] == true || map['equipped'] == true;
          final locked = map['is_locked'] == true || map['locked'] == true;
          return AvatarItem(
            id: key,
            emoji: _emojiForAvatarKey(key),
            cost: owned ? null : _intValue(map, ['coin_cost', 'cost']),
            isEquipped: equipped,
            isLocked: locked,
            lockLabel: map['lock_label']?.toString(),
          );
        })
        .where((item) => item.id.isNotEmpty)
        .toList();
  }

  IconData _iconForApp(String slug) {
    final value = slug.toLowerCase();
    if (value.contains('game') || value.contains('roblox')) {
      return Icons.sports_esports_rounded;
    }
    if (value.contains('video') || value.contains('youtube')) {
      return Icons.play_circle_filled_rounded;
    }
    return Icons.apps_rounded;
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

  void selectTab(StoreTab tab) => emit(state.copyWith(selectedTab: tab));

  Future<void> purchaseAppTimeItem(String id) async {
    final item = state.appTimeItems.firstWhere((i) => i.id == id);
    if (_coins.state < item.cost) {
      emit(state.copyWith(missingCoins: item.cost - _coins.state));
      return;
    }
    final childId = await _resolveChildId();
    if (childId == null) {
      return;
    }

    try {
      final response = await _dio.post(
        ApiConst.redeemAppTime(childId),
        data: {'app_slug': id},
      );
      _applyBalanceAfter(response.data, fallbackCost: item.cost);
    } catch (_) {
      emit(state.copyWith(missingCoins: item.cost - _coins.state));
    }
  }

  Future<void> purchaseAvatarItem(String id) async {
    final item = state.avatarItems.firstWhere((i) => i.id == id);
    if (item.isEquipped || item.isFree || item.isLocked) return;
    final cost = item.cost;
    if (cost == null) return;
    if (_coins.state < cost) {
      emit(state.copyWith(missingCoins: cost - _coins.state));
      return;
    }
    final childId = await _resolveChildId();
    if (childId == null) {
      return;
    }

    try {
      final response = await _dio.post(
        ApiConst.redeemAvatarItem(childId),
        data: {'item_key': id},
      );
      _applyBalanceAfter(response.data, fallbackCost: cost);
      final updated = state.avatarItems
          .map((i) => i.id == id ? i.copyWith(clearCost: true) : i)
          .toList();
      emit(state.copyWith(avatarItems: updated));
    } catch (_) {
      emit(state.copyWith(missingCoins: cost - _coins.state));
    }
  }

  void _applyBalanceAfter(dynamic raw, {required int fallbackCost}) {
    final data = _asMap(raw);
    final balanceAfter = _intValue(data, ['balance_after', 'balance']);
    if (balanceAfter != null) {
      _coins.set(balanceAfter);
    } else {
      _coins.subtract(fallbackCost);
    }
  }

  void clearInsufficientCoinsError() =>
      emit(state.copyWith(clearMissingCoins: true));

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
