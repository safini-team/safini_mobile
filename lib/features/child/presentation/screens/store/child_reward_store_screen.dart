import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:safini/core/di/injection.dart';
import 'package:safini/core/theme/app_radius.dart';
import 'package:safini/core/theme/app_spacing.dart';
import 'package:safini/core/utils/extension/theme_extension.dart';
import 'package:safini/features/child/presentation/cubit/coins_cubit.dart';
import 'package:safini/features/child/presentation/cubit/reward_store_cubit.dart';
import 'package:safini/features/child/presentation/cubit/reward_store_model.dart';
import 'package:safini/features/child/presentation/cubit/reward_store_state.dart';
import 'package:safini/features/child/presentation/widgets/cards/app_time_item_card.dart';
import 'package:safini/features/child/presentation/widgets/cards/avatar_item_card.dart';
import 'package:safini/features/child/presentation/widgets/dialogs/confirm_purchase_dialog.dart';
import 'package:safini/features/child/presentation/widgets/dialogs/not_enough_coins_dialog.dart';
import 'package:safini/features/child/presentation/widgets/utils/earn_more_coins_banner.dart';
import 'package:safini/features/child/presentation/widgets/utils/store_coin_badge.dart';
import 'package:safini/features/child/presentation/widgets/utils/store_tab_toggle.dart';
import 'package:safini/core/translation/generated/l10n.dart';
import 'package:safini/features/child/presentation/cubit/home/home_cubit.dart';

class ChildRewardStoreScreen extends StatelessWidget {
  const ChildRewardStoreScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (ctx) => getIt<RewardStoreCubit>(),
      child: const _RewardStoreView(),
    );
  }
}

// ─── Root View ────────────────────────────────────────────────────────────────

class _RewardStoreView extends StatelessWidget {
  const _RewardStoreView();

  @override
  Widget build(BuildContext context) {
    return BlocListener<RewardStoreCubit, RewardStoreState>(
      listenWhen: (prev, curr) =>
          curr.missingCoins != null && curr.missingCoins != prev.missingCoins,
      listener: (ctx, state) {
        if (state.missingCoins case final missing?) {
          NotEnoughCoinsDialog.show(
            ctx,
            missingCoins: missing,
            onDismiss: () =>
                ctx.read<RewardStoreCubit>().clearInsufficientCoinsError(),
          );
        }
      },
      child: Scaffold(
        backgroundColor: context.colorScheme.surface,
        body: Column(
          children: [
            _StoreHeader(),
            Expanded(child: _StoreBody()),
          ],
        ),
      ),
    );
  }
}

// ─── Purple Header ─────────────────────────────────────────────────────────────

class _StoreHeader extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    return BlocBuilder<RewardStoreCubit, RewardStoreState>(
      builder: (context, state) {
        return Container(
          width: double.infinity,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                context.colorScheme.primary.withValues(alpha: 0.9),
                context.colorScheme.primary,
              ],
            ),
          ),
          child: SafeArea(
            bottom: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.lg,
                AppSpacing.md,
                AppSpacing.lg,
                AppSpacing.xl,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        s.rewardStore,
                        style: context.textTheme.headlineSmall?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const StoreCoinBadge(),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  StoreTabToggle(
                    selectedTab: state.selectedTab,
                    onTabChanged: (tab) =>
                        context.read<RewardStoreCubit>().selectTab(tab),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

// ─── Main Body ────────────────────────────────────────────────────────────────

class _StoreBody extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // BlocBuilder<CoinsCubit> ensures the whole body rebuilds whenever coins
    // change, so canAfford is always up-to-date after a purchase.
    return BlocBuilder<CoinsCubit, int>(
      builder: (context, coins) {
        return BlocBuilder<RewardStoreCubit, RewardStoreState>(
          builder: (context, state) {
            return Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(AppRadius.xl),
                  topRight: Radius.circular(AppRadius.xl),
                ),
              ),
              child: state.selectedTab == StoreTab.appTime
                  ? _AppTimeContent(state: state, coins: coins)
                  : _AvatarContent(state: state, coins: coins),
            );
          },
        );
      },
    );
  }
}

// ─── App Time Tab ─────────────────────────────────────────────────────────────

class _AppTimeContent extends StatelessWidget {
  final RewardStoreState state;
  final int coins;

  const _AppTimeContent({required this.state, required this.coins});

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.lg,
            AppSpacing.xl,
            AppSpacing.lg,
            AppSpacing.sm,
          ),
          child: Row(
            children: [
              const Text('🔓', style: TextStyle(fontSize: 16)),
              const SizedBox(width: AppSpacing.xs),
              Text(
                s.unlockExtraTime,
                style: context.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.only(bottom: AppSpacing.sm),
            itemCount: state.appTimeItems.length,
            itemBuilder: (context, index) {
              final item = state.appTimeItems[index];
              return AppTimeItemCard(
                item: item,
                canAfford: coins >= item.cost,
                onTap: () async {
                  final confirmed = await ConfirmPurchaseDialog.show(
                    context,
                    title: item.title,
                    emoji: '⏱️',
                    cost: item.cost,
                  );
                  if (confirmed && context.mounted) {
                    context.read<RewardStoreCubit>().purchaseAppTimeItem(
                      item.id,
                    );
                  }
                },
              );
            },
          ),
        ),
        EarnMoreCoinsBanner(
          onGoToTasks: () => context.read<ChildHomeCubit>().selectTab(1),
        ),
      ],
    );
  }
}

// ─── Avatar Tab ───────────────────────────────────────────────────────────────

class _AvatarContent extends StatelessWidget {
  final RewardStoreState state;
  final int coins;

  const _AvatarContent({required this.state, required this.coins});

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.lg,
            AppSpacing.xl,
            AppSpacing.lg,
            AppSpacing.sm,
          ),
          child: Row(
            children: [
              const Text('👕', style: TextStyle(fontSize: 16)),
              const SizedBox(width: AppSpacing.xs),
              Text(
                s.outfitsAndItems,
                style: context.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: GridView.builder(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.lg,
              vertical: AppSpacing.sm,
            ),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: AppSpacing.md,
              mainAxisSpacing: AppSpacing.md,
              childAspectRatio: 1.0,
            ),
            itemCount: state.avatarItems.length,
            itemBuilder: (context, index) {
              final item = state.avatarItems[index];
              return AvatarItemCard(
                item: item,
                canAfford: item.cost != null && coins >= item.cost!,
                onTap: () async {
                  if (item.isEquipped || item.isFree || item.isLocked) return;
                  final confirmed = await ConfirmPurchaseDialog.show(
                    context,
                    title: item.emoji,
                    emoji: item.emoji,
                    cost: item.cost ?? 0,
                  );
                  if (confirmed && context.mounted) {
                    context.read<RewardStoreCubit>().purchaseAvatarItem(
                      item.id,
                    );
                  }
                },
              );
            },
          ),
        ),
      ],
    );
  }
}

// ─── Bottom Nav ───────────────────────────────────────────────────────────────
