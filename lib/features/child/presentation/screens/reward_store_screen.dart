import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
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

class RewardStoreScreen extends StatelessWidget {
  const RewardStoreScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (ctx) => RewardStoreCubit(ctx.read<CoinsCubit>()),
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
          curr.missingCoins != null &&
          curr.missingCoins != prev.missingCoins,
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
        backgroundColor: const Color(0xFFF0EAF8),
        body: Column(
          children: [
            _StoreHeader(),
            Expanded(child: _StoreBody()),
          ],
        ),
        bottomNavigationBar: _StoreBottomNavBar(),
      ),
    );
  }
}

// ─── Purple Header ─────────────────────────────────────────────────────────────

class _StoreHeader extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<RewardStoreCubit, RewardStoreState>(
      builder: (context, state) {
        return Container(
          width: double.infinity,
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF6200B3), Color(0xFF9000E0)],
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
                        'Reward Store',
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
                'Unlock Extra Time',
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
                    context
                        .read<RewardStoreCubit>()
                        .purchaseAppTimeItem(item.id);
                  }
                },
              );
            },
          ),
        ),
        EarnMoreCoinsBanner(
          onGoToTasks: () => context.router.push(const NamedRoute('tasks')),
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
                'Outfits & Items',
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
                    context
                        .read<RewardStoreCubit>()
                        .purchaseAvatarItem(item.id);
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

class _StoreBottomNavBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: context.colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 12,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _NavItem(
                icon: Icons.home_rounded,
                label: 'Home',
                onTap: () => context.router.maybePop(),
              ),
              _NavItem(
                icon: Icons.check_box_rounded,
                label: 'Tasks',
                onTap: () => context.router.push(const NamedRoute('tasks')),
              ),
              _NavItem(
                icon: Icons.shopping_bag_rounded,
                label: 'Store',
                isSelected: true,
              ),
              _NavItem(
                icon: Icons.person_rounded,
                label: 'Profile',
                onTap: () => context.router.push(const NamedRoute('profile')),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback? onTap;

  const _NavItem({
    required this.icon,
    required this.label,
    this.isSelected = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = isSelected
        ? context.colorScheme.primary
        : context.colorScheme.onSurface.withValues(alpha: 0.4);

    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 26),
          const SizedBox(height: 3),
          Text(
            label,
            style: context.textTheme.bodyMedium?.copyWith(
              color: color,
              fontSize: 11,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }
}
