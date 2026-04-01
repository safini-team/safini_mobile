import 'package:safini/features/child/presentation/cubit/reward_store_model.dart';

class RewardStoreState {
  final List<AppTimeItem> appTimeItems;
  final List<AvatarItem> avatarItems;
  final StoreTab selectedTab;
  final int? missingCoins;

  const RewardStoreState({
    required this.appTimeItems,
    required this.avatarItems,
    this.selectedTab = StoreTab.appTime,
    this.missingCoins,
  });

  const RewardStoreState.initial()
      : appTimeItems = const [],
        avatarItems = const [],
        selectedTab = StoreTab.appTime,
        missingCoins = null;

  RewardStoreState copyWith({
    List<AppTimeItem>? appTimeItems,
    List<AvatarItem>? avatarItems,
    StoreTab? selectedTab,
    int? missingCoins,
    bool clearMissingCoins = false,
  }) {
    return RewardStoreState(
      appTimeItems: appTimeItems ?? this.appTimeItems,
      avatarItems: avatarItems ?? this.avatarItems,
      selectedTab: selectedTab ?? this.selectedTab,
      missingCoins:
          clearMissingCoins ? null : (missingCoins ?? this.missingCoins),
    );
  }
}
