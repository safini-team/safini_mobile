import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:safini/core/theme/app_spacing.dart';
import 'package:safini/core/utils/extension/theme_extension.dart';
import 'package:safini/features/child/presentation/cubit/quest_cubit.dart';
import 'package:safini/features/child/presentation/cubit/quest_state.dart';
import 'package:safini/features/child/presentation/widgets/cards/reward_store_card.dart';
import 'package:safini/features/child/presentation/widgets/tiles/quest_tile.dart';

class ChildHomeScreen extends StatelessWidget {
  const ChildHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => QuestCubit(),
      child: const _ChildHomeView(),
    );
  }
}

// ─── Root View ────────────────────────────────────────────────────────────────

class _ChildHomeView extends StatelessWidget {
  const _ChildHomeView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.colorScheme.surface,
      body: Column(
        children: [
          _HomeHeader(),
          Expanded(child: _QuestListBody()),
        ],
      ),
      bottomNavigationBar: _BottomNavBar(),
    );
  }
}

// ─── Purple Header ─────────────────────────────────────────────────────────────

class _HomeHeader extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
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
          padding: const EdgeInsets.only(
            top: AppSpacing.md,
            bottom: AppSpacing.xl,
          ),
          child: RewardStoreCard(
            onTap: () => context.router.push(const NamedRoute('store')),
          ),
        ),
      ),
    );
  }
}

// ─── Quest List ───────────────────────────────────────────────────────────────

class _QuestListBody extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<QuestCubit, QuestState>(
      builder: (context, state) {
        return CustomScrollView(
          slivers: [
            //  "Today's Quests   6/6" header row
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.lg,
                  AppSpacing.xl,
                  AppSpacing.lg,
                  AppSpacing.sm,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Today's Quests",
                      style: context.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: context.colorScheme.onSurface,
                      ),
                    ),
                    _QuestCountBadge(
                      completed: state.completedCount,
                      total: state.totalCount,
                    ),
                  ],
                ),
              ),
            ),

            // Quest tiles
            SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final quest = state.quests[index];
                  return QuestTile(
                    quest: quest,
                    isHighlighted: index == 0,
                    onTap: () =>
                        context.read<QuestCubit>().toggleQuest(quest.id),
                  );
                },
                childCount: state.quests.length,
              ),
            ),

            const SliverToBoxAdapter(
              child: SizedBox(height: AppSpacing.xl),
            ),
          ],
        );
      },
    );
  }
}

// ─── Count Badge ──────────────────────────────────────────────────────────────

class _QuestCountBadge extends StatelessWidget {
  final int completed;
  final int total;

  const _QuestCountBadge({required this.completed, required this.total});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: context.colorScheme.primary.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(AppSpacing.xl),
      ),
      child: Text(
        '$completed/$total',
        style: context.textTheme.labelLarge?.copyWith(
          color: context.colorScheme.primary,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

// ─── Bottom Nav Bar ───────────────────────────────────────────────────────────

class _BottomNavBar extends StatelessWidget {
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
              const _NavItem(icon: Icons.home_rounded, label: 'Home', isSelected: true),
              _NavItem(
                icon: Icons.check_box_rounded,
                label: 'Tasks',
                onTap: () => context.router.push(const NamedRoute('tasks')),
              ),
              _NavItem(
                icon: Icons.shopping_bag_rounded,
                label: 'Store',
                onTap: () => context.router.push(const NamedRoute('store')),
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

// ─── Nav Item ─────────────────────────────────────────────────────────────────

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
