import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:safini/features/child/presentation/cubit/coins_cubit.dart';
import 'package:safini/features/child/presentation/cubit/reward_store_model.dart';
import 'package:safini/features/child/presentation/cubit/reward_store_state.dart';

class RewardStoreCubit extends Cubit<RewardStoreState> {
  final CoinsCubit _coins;

  RewardStoreCubit(this._coins) : super(const RewardStoreState.initial()) {
    _loadData();
  }

  void _loadData() {
    emit(state.copyWith(
      appTimeItems: const [
        AppTimeItem(
          id: 'youtube',
          title: 'YouTube Kids',
          subtitle: '+30 Minutes',
          icon: Icons.play_circle_filled_rounded,
          iconColor: Color(0xFF4A90D9),
          iconBackground: Color(0xFFDEEEFB),
          cost: 100,
        ),
        AppTimeItem(
          id: 'roblox',
          title: 'Roblox',
          subtitle: '+20 Minutes',
          icon: Icons.sports_esports_rounded,
          iconColor: Color(0xFFE05555),
          iconBackground: Color(0xFFFCEAE3),
          cost: 150,
        ),
        AppTimeItem(
          id: 'brawlstars',
          title: 'Brawl Stars',
          subtitle: '+15 Minutes',
          icon: Icons.star_rounded,
          iconColor: Color(0xFFFFB800),
          iconBackground: Color(0xFFFFF3CC),
          cost: 80,
        ),
        AppTimeItem(
          id: 'minecraft',
          title: 'Minecraft',
          subtitle: '+45 Minutes',
          icon: Icons.landscape_rounded,
          iconColor: Color(0xFF3EBF6A),
          iconBackground: Color(0xFFE0F5E9),
          cost: 200,
        ),
      ],
      avatarItems: const [
        AvatarItem(id: 'tshirt', emoji: '👕'),
        AvatarItem(id: 'avatar', emoji: '🧑', cost: 450),
        AvatarItem(id: 'rocket', emoji: '🚀', isEquipped: true),
        AvatarItem(id: 'hero', emoji: '🦸', cost: 300),
        AvatarItem(
          id: 'swords',
          emoji: '⚔️',
          isLocked: true,
          lockLabel: 'LV.25',
        ),
      ],
    ));
  }

  void selectTab(StoreTab tab) => emit(state.copyWith(selectedTab: tab));

  void purchaseAppTimeItem(String id) {
    final item = state.appTimeItems.firstWhere((i) => i.id == id);
    if (_coins.state >= item.cost) {
      _coins.subtract(item.cost);
    } else {
      emit(state.copyWith(missingCoins: item.cost - _coins.state));
    }
  }

  void purchaseAvatarItem(String id) {
    final item = state.avatarItems.firstWhere((i) => i.id == id);
    if (item.isEquipped || item.isFree || item.isLocked) return;
    final cost = item.cost;
    if (cost == null) return;
    if (_coins.state >= cost) {
      _coins.subtract(cost);
      final updated = state.avatarItems
          .map(
            (i) => i.id == id
                ? i.copyWith(isEquipped: true, clearCost: true)
                : i,
          )
          .toList();
      emit(state.copyWith(avatarItems: updated));
    } else {
      emit(state.copyWith(missingCoins: cost - _coins.state));
    }
  }

  void clearInsufficientCoinsError() =>
      emit(state.copyWith(clearMissingCoins: true));
}
