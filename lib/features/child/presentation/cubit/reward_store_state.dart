import 'package:safini/features/child/presentation/cubit/reward_store_model.dart';

class RewardStoreState {
  final List<AppTimeItem> appTimeItems;
  final List<AvatarItem> avatarItems;
  final StoreTab selectedTab;
  final bool isLoading;
  final bool hasLoadError;
  final int? missingCoins;

  /// Real server-side error message for a failed purchase (not a coins issue).
  final String? purchaseError;

  const RewardStoreState({
    required this.appTimeItems,
    required this.avatarItems,
    this.selectedTab = StoreTab.appTime,
    this.isLoading = false,
    this.hasLoadError = false,
    this.missingCoins,
    this.purchaseError,
  });

  const RewardStoreState.initial()
    : appTimeItems = const [],
      avatarItems = const [],
      selectedTab = StoreTab.appTime,
      isLoading = true,
      hasLoadError = false,
      missingCoins = null,
      purchaseError = null;

  RewardStoreState copyWith({
    List<AppTimeItem>? appTimeItems,
    List<AvatarItem>? avatarItems,
    StoreTab? selectedTab,
    bool? isLoading,
    bool? hasLoadError,
    int? missingCoins,
    bool clearMissingCoins = false,
    String? purchaseError,
    bool clearPurchaseError = false,
  }) {
    return RewardStoreState(
      appTimeItems: appTimeItems ?? this.appTimeItems,
      avatarItems: avatarItems ?? this.avatarItems,
      selectedTab: selectedTab ?? this.selectedTab,
      isLoading: isLoading ?? this.isLoading,
      hasLoadError: hasLoadError ?? this.hasLoadError,
      missingCoins: clearMissingCoins
          ? null
          : (missingCoins ?? this.missingCoins),
      purchaseError: clearPurchaseError
          ? null
          : (purchaseError ?? this.purchaseError),
    );
  }
}
