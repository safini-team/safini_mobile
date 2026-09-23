import 'package:flutter/foundation.dart';
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
import 'package:safini/core/notifications/on_push.dart';
import 'package:safini/core/notifications/push_event.dart';
import 'package:safini/features/prizes/widgets/wish_sheet.dart';

class ChildRewardStoreScreen extends StatelessWidget {
  const ChildRewardStoreScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocListener<RewardStoreCubit, RewardStoreState>(
      listenWhen: (prev, curr) =>
          (curr.missingCoins != null &&
              curr.missingCoins != prev.missingCoins) ||
          (curr.purchaseError != null &&
              curr.purchaseError != prev.purchaseError) ||
          (curr.notice != null && curr.notice != prev.notice),
      listener: (ctx, state) {
        if (state.missingCoins case final missing?) {
          AppSnackBar.error(ctx, S.of(ctx).moreCoinsNeeded(missing));
          ctx.read<RewardStoreCubit>().clearInsufficientCoinsError();
        }
        if (state.purchaseError case final error?) {
          AppSnackBar.error(ctx, error);
          ctx.read<RewardStoreCubit>().clearPurchaseError();
        }
        if (state.notice case final notice?) {
          AppSnackBar.success(ctx, notice);
          ctx.read<RewardStoreCubit>().clearNotice();
        }
      },
      // A parent added, handed over or declined a prize.
      child: OnPush(
        types: const {
          PushType.prizeAdded,
          PushType.prizeGiven,
          PushType.prizeDeclined,
        },
        onPush: (_) => context.read<RewardStoreCubit>().reloadPrizes(),
        child: const _ChildStoreScreen(),
      ),
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
        if (state.appTimeItems.isEmpty &&
            state.avatarItems.isEmpty &&
            state.prizes.isEmpty) {
          return ChildStoreEmpty(onRetry: cubit.loadStore);
        }

        final tab = state.selectedTab;
        final onAppTime = tab == StoreTab.appTime;
        final onPrizes = tab == StoreTab.prizes;
        final cards = onPrizes
            ? [
                for (final prize in state.prizes)
                  StoreCardData(
                    id: prize.id,
                    emoji: prize.displayEmoji,
                    name: prize.title,
                    cost: prize.coinCost,
                    affordable: prize.isWaiting || coins >= prize.coinCost,
                    waiting: prize.isWaiting,
                    badge: prize.isWaiting ? s.prizeWaiting : null,
                    pending: state.pendingPurchases.contains(prize.id),
                  ),
                // A wish is not in the store yet, so it has no price to pay;
                // it shows the price the child suggested, waiting.
                for (final wish in state.openWishes)
                  StoreCardData(
                    id: 'wish:${wish.id}',
                    emoji: wish.displayEmoji,
                    name: wish.title,
                    detail: s.wishLabel,
                    cost: wish.coinCost,
                    affordable: true,
                    waiting: true,
                    badge: s.prizeWaiting,
                  ),
              ]
            : onAppTime
            ? [
                for (final item in state.appTimeItems)
                  StoreCardData(
                    id: item.id,
                    emoji: '⏱️',
                    name: item.title,
                    detail: s.appTimeMinutes(item.minutes),
                    fullName: s.appTimeItem(item.title, item.minutes),
                    cost: item.cost,
                    affordable: item.isEnabled && coins >= item.cost,
                    badge:
                        defaultTargetPlatform != TargetPlatform.iOS &&
                            item.remainingMinutes > 0
                        ? s.minutesLeftShort(item.remainingMinutes)
                        : null,
                    pending: state.pendingPurchases.contains(item.id),
                    packageName: item.packageName,
                    iconUrl: item.iconUrl,
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
                    badge: item.isEquipped
                        ? s.wornLabel
                        : (item.isLocked ? item.lockLabel : null),
                    pending: state.pendingPurchases.contains(item.id),
                  ),
              ];

        return ChildStoreView(
          data: ChildStoreData(
            coins: coins,
            tabs: [s.storeAppTimeTab, s.prizesTab, s.storeAvatarTab],
            selectedTab: StoreTab.values.indexOf(tab),
            cards: cards,
            subtitle: s.storeSubtitle,
            footnote: onPrizes ? s.prizesFootnote : s.askForSomethingNew,
            emptyText: onPrizes ? s.noPrizesYet : null,
            actionLabel: onPrizes ? s.wishForSomething : null,
            onAction: onPrizes
                ? () => showWishSheet(
                    context,
                    onSend: ({required title, required coinCost, emoji}) =>
                        cubit.sendWish(
                          title: title,
                          coinCost: coinCost,
                          emoji: emoji,
                          notice: s.wishSent,
                        ),
                  )
                : null,
          ),
          onSelectTab: (index) => cubit.selectTab(StoreTab.values[index]),
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
    if (state.pendingPurchases.contains(card.id)) return;
    final onAppTime = state.selectedTab == StoreTab.appTime;

    if (state.selectedTab == StoreTab.prizes) {
      if (card.waiting) {
        AppSnackBar.info(context, s.prizeWaitingBody);
        return;
      }
      final prize = state.prizes.firstWhere((p) => p.id == card.id);
      final note = prize.note?.trim() ?? '';
      final confirmed = await showRewardSheet(
        context,
        emoji: card.emoji,
        name: card.name,
        cost: card.cost,
        coins: coins,
        blurb: note.isEmpty ? s.prizeBlurb : '$note\n\n${s.prizeBlurb}',
        actionLabel: s.askForPrize,
      );
      if (confirmed == true) {
        await cubit.askForPrize(card.id, notice: s.prizeAsked);
      }
      return;
    }

    final blurb = onAppTime ? s.rewardBlurbAppTime : s.rewardBlurbAvatar;

    final confirmed = await showRewardSheet(
      context,
      emoji: card.emoji,
      packageName: card.packageName,
      iconUrl: card.iconUrl,
      name: card.fullName,
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
