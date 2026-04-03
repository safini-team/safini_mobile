import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:safini/core/theme/app_radius.dart';
import 'package:safini/core/theme/app_spacing.dart';
import 'package:safini/core/utils/extension/theme_extension.dart';
import 'package:safini/features/child/presentation/cubit/coins_cubit.dart';
import 'package:safini/features/child/presentation/cubit/profile_cubit.dart';
import 'package:safini/features/child/presentation/cubit/profile_model.dart';
import 'package:safini/features/child/presentation/cubit/profile_state.dart';
import 'package:safini/features/child/presentation/widgets/utils/avatar_category_tabs.dart';
import 'package:safini/features/child/presentation/widgets/utils/store_coin_badge.dart';

class AvatarCustomizerScreen extends StatelessWidget {
  const AvatarCustomizerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (ctx) => AvatarCubit(ctx.read<CoinsCubit>()),
      child: const _AvatarCustomizerView(),
    );
  }
}

// ─── Root View ────────────────────────────────────────────────────────────────

class _AvatarCustomizerView extends StatelessWidget {
  const _AvatarCustomizerView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF7B2FBE),
      body: Column(
        children: [
          _AvatarHeader(),
          Expanded(child: _AvatarBody()),
        ],
      ),
    );
  }
}

// ─── Header ──────────────────────────────────────────────────────────────────

class _AvatarHeader extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AvatarCubit, AvatarState>(
      builder: (context, state) {
        return Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF6200B3), Color(0xFF9000E0)],
            ),
          ),
          child: SafeArea(
            bottom: false,
            child: Column(
              children: [
                // Top bar
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.lg,
                    vertical: AppSpacing.sm,
                  ),
                  child: Row(
                    children: [
                      GestureDetector(
                        onTap: () => context.router.maybePop(),
                        child: Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: Colors.white.withValues(alpha: 0.4),
                            ),
                          ),
                          child: const Icon(
                            Icons.arrow_back_ios_new_rounded,
                            color: Colors.white,
                            size: 16,
                          ),
                        ),
                      ),
                      Expanded(
                        child: Center(
                          child: Text(
                            'My Avatar',
                            style: context.textTheme.titleLarge?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),
                      const StoreCoinBadge(),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),
                // Avatar preview card
                _AvatarPreview(
                  faceEmoji: state.equippedFaceEmoji,
                  badgeEmoji: state.equippedBadgeEmoji,
                  level: 5,
                ),
                const SizedBox(height: AppSpacing.xl),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _AvatarPreview extends StatelessWidget {
  final String faceEmoji;
  final String badgeEmoji;
  final int level;

  const _AvatarPreview({
    required this.faceEmoji,
    required this.badgeEmoji,
    required this.level,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: 120,
          height: 120,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(AppRadius.xl),
                ),
                child: Center(
                  child: Text(
                    faceEmoji,
                    style: const TextStyle(fontSize: 60),
                  ),
                ),
              ),
              Positioned(
                bottom: -6,
                right: -6,
                child: Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF5A623),
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2),
                  ),
                  child: Center(
                    child: Text(
                      badgeEmoji,
                      style: const TextStyle(fontSize: 16),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        Container(
          width: 36,
          height: 36,
          decoration: const BoxDecoration(
            color: Color(0xFFF5A623),
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(
              '$level',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w800,
                fontSize: 16,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// ─── White Body ───────────────────────────────────────────────────────────────

class _AvatarBody extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(AppRadius.xl),
          topRight: Radius.circular(AppRadius.xl),
        ),
      ),
      child: BlocBuilder<AvatarCubit, AvatarState>(
        builder: (context, state) {
          return Column(
            children: [
              // Category tabs
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                child: AvatarCategoryTabs(
                  selectedCategory: state.selectedCategory,
                  onChanged: (cat) =>
                      context.read<AvatarCubit>().selectCategory(cat),
                ),
              ),
              const Divider(height: 1),
              // Items grid
              Expanded(
                child: GridView.builder(
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  gridDelegate:
                      const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    crossAxisSpacing: AppSpacing.sm,
                    mainAxisSpacing: AppSpacing.sm,
                    childAspectRatio: 1.0,
                  ),
                  itemCount: state.currentItems.length,
                  itemBuilder: (context, index) {
                    final item = state.currentItems[index];
                    return _AvatarGridCard(
                      item: item,
                      canAfford:
                          item.cost == null || context.read<CoinsCubit>().state >= item.cost!,
                      onTap: () =>
                          context.read<AvatarCubit>().equipItem(item.id),
                    );
                  },
                ),
              ),
              // Save button
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.lg,
                  AppSpacing.sm,
                  AppSpacing.lg,
                  AppSpacing.xl,
                ),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => context.router.maybePop(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: context.colorScheme.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        vertical: AppSpacing.md,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppRadius.pill),
                      ),
                      elevation: 0,
                    ),
                    child: Text(
                      'Save My Look!',
                      style: context.textTheme.titleMedium?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

// ─── Grid Card ────────────────────────────────────────────────────────────────

class _AvatarGridCard extends StatelessWidget {
  final AvatarGridItem item;
  final bool canAfford;
  final VoidCallback? onTap;

  const _AvatarGridCard({
    required this.item,
    required this.canAfford,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isEquipped = item.isEquipped;
    final bgColor = isEquipped
        ? context.colorScheme.primary
        : item.isLocked
            ? const Color(0xFFF0F0F0)
            : const Color(0xFFF6F3FB);

    return GestureDetector(
      onTap: item.isLocked ? null : onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(AppRadius.lg),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Opacity(
              opacity: item.isLocked ? 0.35 : 1.0,
              child: Text(
                item.emoji,
                style: const TextStyle(fontSize: 30),
              ),
            ),
            const SizedBox(height: 4),
            _GridItemLabel(item: item, canAfford: canAfford),
          ],
        ),
      ),
    );
  }
}

class _GridItemLabel extends StatelessWidget {
  final AvatarGridItem item;
  final bool canAfford;

  const _GridItemLabel({required this.item, required this.canAfford});

  @override
  Widget build(BuildContext context) {
    if (item.isEquipped) {
      return Text(
        'ON',
        style: context.textTheme.labelLarge?.copyWith(
          color: Colors.white,
          fontWeight: FontWeight.w800,
          fontSize: 10,
          letterSpacing: 0.5,
        ),
      );
    }
    if (item.isFree) {
      return Text(
        'FREE',
        style: context.textTheme.labelLarge?.copyWith(
          color: const Color(0xFF3EBF6A),
          fontWeight: FontWeight.w700,
          fontSize: 10,
        ),
      );
    }
    if (item.isLocked) {
      return Column(
        children: [
          Icon(
            Icons.lock_rounded,
            size: 12,
            color: context.colorScheme.onSurface.withValues(alpha: 0.35),
          ),
          if (item.lockLabel != null)
            Text(
              item.lockLabel!,
              style: context.textTheme.bodyMedium?.copyWith(
                color: context.colorScheme.onSurface.withValues(alpha: 0.4),
                fontSize: 9,
                fontWeight: FontWeight.w600,
              ),
            ),
        ],
      );
    }
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Text('🪙', style: TextStyle(fontSize: 10)),
        const SizedBox(width: 2),
        Text(
          '${item.cost}',
          style: context.textTheme.labelLarge?.copyWith(
            color: canAfford
                ? context.colorScheme.primary
                : context.colorScheme.onSurface.withValues(alpha: 0.4),
            fontWeight: FontWeight.w700,
            fontSize: 10,
          ),
        ),
      ],
    );
  }
}
