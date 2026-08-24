import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:safini/core/theme/app_typography.dart';
import 'package:safini/core/translation/generated/l10n.dart';
import 'package:safini/core/utils/widgets/app_snack_bar.dart';
import 'package:safini/core/utils/widgets/ds/ds.dart';
import 'package:safini/features/child/presentation/cubit/coins_cubit.dart';
import 'package:safini/features/child/presentation/cubit/reward_store_cubit.dart';
import 'package:safini/features/child/presentation/cubit/reward_store_model.dart';
import 'package:safini/features/child/presentation/cubit/reward_store_state.dart';
import 'package:safini/features/child/presentation/screens/store/child_store_view.dart';
import 'package:safini/features/child/presentation/widgets/dialogs/reward_sheet.dart';

class ChildRewardStoreScreen extends StatelessWidget {
  const ChildRewardStoreScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocListener<RewardStoreCubit, RewardStoreState>(
      listenWhen: (prev, curr) =>
          (curr.missingCoins != null &&
              curr.missingCoins != prev.missingCoins) ||
          (curr.purchaseError != null &&
              curr.purchaseError != prev.purchaseError),
      listener: (ctx, state) {
        if (state.missingCoins case final missing?) {
          AppSnackBar.error(ctx, S.of(ctx).moreCoinsNeeded(missing));
          ctx.read<RewardStoreCubit>().clearInsufficientCoinsError();
        }
        if (state.purchaseError case final error?) {
          AppSnackBar.error(ctx, error);
          ctx.read<RewardStoreCubit>().clearPurchaseError();
        }
      },
      child: const _ChildStoreScreen(),
    );
  }
}

class _ChildStoreScreen extends StatelessWidget {
  const _ChildStoreScreen();

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);

    return BlocBuilder<RewardStoreCubit, RewardStoreState>(
      builder: (context, state) {
        final coins = context.watch<CoinsCubit>().state;
        final cubit = context.read<RewardStoreCubit>();

        if (state.isLoading) {
          return const ChildStoreSkeleton();
        }
        if (state.hasLoadError) {
          return ChildStoreError(onRetry: cubit.loadStore);
        }
        if (state.appTimeItems.isEmpty && state.avatarItems.isEmpty) {
          return ChildStoreEmpty(onRetry: cubit.loadStore);
        }

        final onAppTime = state.selectedTab == StoreTab.appTime;
        final cards = onAppTime
            ? [
                for (final item in state.appTimeItems)
                  StoreCardData(
                    id: item.id,
                    emoji: '⏱️',
                    name: s.appTimeItem(item.title, item.minutes),
                    cost: item.cost,
                    affordable: item.isEnabled && coins >= item.cost,
                    toGo: (item.cost - coins).clamp(0, item.cost),
                    badge: item.remainingMinutes > 0
                        ? s.minutesLeftShort(item.remainingMinutes)
                        : null,
                  ),
              ]
            : [
                for (final item in state.avatarItems)
                  StoreCardData(
                    id: item.id,
                    emoji: item.emoji,
                    // The API sends the real name ("Cosmic Cape"); only fall
                    // back to the generic label when it omitted one. Being worn
                    // is a state, so it belongs on the badge, not the name.
                    name: item.name.isNotEmpty ? item.name : s.avatarItem,
                    cost: item.cost ?? 0,
                    owned: item.isEquipped || item.isFree,
                    affordable: item.cost == null || coins >= (item.cost ?? 0),
                    toGo: ((item.cost ?? 0) - coins).clamp(0, item.cost ?? 0),
                    badge: item.isEquipped
                        ? s.wornLabel
                        : (item.isLocked ? item.lockLabel : null),
                  ),
              ];

        return ChildStoreView(
          data: ChildStoreData(
            coins: coins,
            tabs: [s.storeAppTimeTab, s.storeAvatarTab],
            selectedTab: onAppTime ? 0 : 1,
            cards: cards,
            subtitle: s.storeSubtitle,
            footnote: s.askForSomethingNew,
          ),
          onSelectTab: (index) => cubit.selectTab(
            index == 0 ? StoreTab.appTime : StoreTab.avatarItems,
          ),
          onOpenCard: (card) => _open(context, state, card, coins, s),
          onRefresh: () => cubit.loadStore(),
        );
      },
    );
  }

  Future<void> _open(
    BuildContext context,
    RewardStoreState state,
    StoreCardData card,
    int coins,
    S s,
  ) async {
    final cubit = context.read<RewardStoreCubit>();
    final onAppTime = state.selectedTab == StoreTab.appTime;

    final blurb = onAppTime ? s.rewardBlurbAppTime : s.rewardBlurbAvatar;

    final confirmed = await showRewardSheet(
      context,
      emoji: card.emoji,
      name: card.name,
      cost: card.cost,
      coins: coins,
      blurb: blurb,
    );
    if (confirmed != true) return;

    if (onAppTime) {
      await cubit.purchaseAppTimeItem(card.id);
    } else {
      await cubit.purchaseAvatarItem(card.id);
    }
  }
}

/// Shown when the store has nothing configured at all.
class ChildStoreEmpty extends StatelessWidget {
  const ChildStoreEmpty({super.key, required this.onRetry});

  final Future<void> Function() onRetry;

  @override
  Widget build(BuildContext context) {
    return _StoreStatus(
      message: S.of(context).nothingInStore,
      onRetry: onRetry,
    );
  }
}

class ChildStoreError extends StatelessWidget {
  const ChildStoreError({super.key, required this.onRetry});

  final Future<void> Function() onRetry;

  @override
  Widget build(BuildContext context) {
    return _StoreStatus(message: S.of(context).networkError, onRetry: onRetry);
  }
}

class _StoreStatus extends StatelessWidget {
  const _StoreStatus({required this.message, required this.onRetry});

  final String message;
  final Future<void> Function() onRetry;

  @override
  Widget build(BuildContext context) {
    return DsScreen(
      slivers: [
        SliverToBoxAdapter(child: DsLargeTitle(title: S.of(context).tabStore)),
        SliverFillRemaining(
          hasScrollBody: false,
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    message,
                    style: AppText.meta,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  DsPrimaryButton.secondary(
                    label: S.of(context).retry,
                    onTap: onRetry,
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
