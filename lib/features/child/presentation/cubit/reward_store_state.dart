import 'package:safini/features/child/presentation/cubit/reward_store_model.dart';
import 'package:safini/features/prizes/prize.dart';

class RewardStoreState {
  final List<AppTimeItem> appTimeItems;
  final List<AvatarItem> avatarItems;
  final StoreTab selectedTab;
  final bool isLoading;
  final bool hasLoadError;
  final int? missingCoins;

  /// Real server-side error message for a failed purchase (not a coins issue).
  final String? purchaseError;

  /// Item ids with a purchase in flight. A second tap on one of these is
  /// ignored, and its tile renders as busy rather than tappable (SAF-132).
  final Set<String> pendingPurchases;

  /// Real-world prizes a parent added (SAF-190), and the child's wishes still
  /// waiting on a parent.
  final List<Prize> prizes;
  final List<PrizeRequest> openWishes;

  /// A one-off line to confirm an ask or a wish went through.
  final String? notice;

  const RewardStoreState({
    required this.appTimeItems,
    required this.avatarItems,
    this.prizes = const [],
    this.openWishes = const [],
    this.notice,
    this.selectedTab = StoreTab.appTime,
    this.isLoading = false,
    this.hasLoadError = false,
    this.missingCoins,
    this.purchaseError,
    this.pendingPurchases = const {},
  });

  const RewardStoreState.initial()
    : appTimeItems = const [],
      avatarItems = const [],
      selectedTab = StoreTab.appTime,
      isLoading = true,
      hasLoadError = false,
      missingCoins = null,
      purchaseError = null,
      pendingPurchases = const {},
      prizes = const [],
      openWishes = const [],
      notice = null;

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
    Set<String>? pendingPurchases,
    List<Prize>? prizes,
    List<PrizeRequest>? openWishes,
    String? notice,
    bool clearNotice = false,
  }) {
    return RewardStoreState(
      appTimeItems: appTimeItems ?? this.appTimeItems,
      avatarItems: avatarItems ?? this.avatarItems,
      prizes: prizes ?? this.prizes,
      openWishes: openWishes ?? this.openWishes,
      notice: clearNotice ? null : (notice ?? this.notice),
      selectedTab: selectedTab ?? this.selectedTab,
      isLoading: isLoading ?? this.isLoading,
      hasLoadError: hasLoadError ?? this.hasLoadError,
      missingCoins: clearMissingCoins
          ? null
          : (missingCoins ?? this.missingCoins),
      purchaseError: clearPurchaseError
          ? null
          : (purchaseError ?? this.purchaseError),
      pendingPurchases: pendingPurchases ?? this.pendingPurchases,
    );
  }
}
