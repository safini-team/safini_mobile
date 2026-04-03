import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:safini/core/theme/app_radius.dart';
import 'package:safini/core/theme/app_spacing.dart';
import 'package:safini/core/utils/extension/theme_extension.dart';
import 'package:safini/features/child/presentation/cubit/coins_cubit.dart';
import 'package:safini/features/child/presentation/cubit/profile_cubit.dart';
import 'package:safini/features/child/presentation/cubit/profile_state.dart';
import 'package:safini/features/child/presentation/widgets/cards/profile_stat_card.dart';
import 'package:safini/features/child/presentation/widgets/dialogs/achievements_dialog.dart';
import 'package:safini/features/child/presentation/widgets/tiles/profile_menu_tile.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => ProfileCubit(),
      child: const _ProfileView(),
    );
  }
}

// ─── Root View ────────────────────────────────────────────────────────────────

class _ProfileView extends StatelessWidget {
  const _ProfileView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0EAF8),
      body: Column(
        children: [
          _ProfileHeader(),
          Expanded(child: _ProfileBody()),
        ],
      ),
      bottomNavigationBar: _ProfileBottomNavBar(),
    );
  }
}

// ─── Purple Header ─────────────────────────────────────────────────────────────

class _ProfileHeader extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ProfileCubit, ProfileState>(
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
            child: Column(
              children: [
                // Top bar
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.lg,
                    vertical: AppSpacing.sm,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'My Profile',
                        style: context.textTheme.headlineSmall?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.4),
                          ),
                        ),
                        child: const Icon(
                          Icons.logout_rounded,
                          color: Colors.white,
                          size: 18,
                        ),
                      ),
                    ],
                  ),
                ),
                // Avatar circle
                _AvatarCircle(
                  faceEmoji: state.equippedFaceEmoji,
                  badgeEmoji: state.equippedBadgeEmoji,
                  level: state.level,
                ),
                const SizedBox(height: AppSpacing.md),
                // Name row
                _NameSection(state: state),
                const SizedBox(height: AppSpacing.sm),
                // Level badge
                _LevelBadge(label: state.levelLabel),
                const SizedBox(height: AppSpacing.lg),
                // XP progress bar
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: state.xpProgress,
                      backgroundColor: Colors.white.withValues(alpha: 0.2),
                      valueColor: const AlwaysStoppedAnimation<Color>(
                        Color(0xFFF5A623),
                      ),
                      minHeight: 6,
                    ),
                  ),
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

class _AvatarCircle extends StatelessWidget {
  final String faceEmoji;
  final String badgeEmoji;
  final int level;

  const _AvatarCircle({
    required this.faceEmoji,
    required this.badgeEmoji,
    required this.level,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 96,
      height: 96,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            width: 96,
            height: 96,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white,
              border: Border.all(color: Colors.white, width: 3),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.15),
                  blurRadius: 12,
                ),
              ],
            ),
            child: Center(
              child: Text(faceEmoji, style: const TextStyle(fontSize: 48)),
            ),
          ),
          // Badge at bottom right
          Positioned(
            bottom: -4,
            right: -4,
            child: Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                color: const Color(0xFFF5A623),
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 2),
              ),
              child: Center(
                child: Text(badgeEmoji, style: const TextStyle(fontSize: 14)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _NameSection extends StatelessWidget {
  final ProfileState state;

  const _NameSection({required this.state});

  @override
  Widget build(BuildContext context) {
    if (state.isEditing) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
        child: Row(
          children: [
            Expanded(
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.md,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(AppRadius.pill),
                ),
                child: TextField(
                  autofocus: true,
                  controller: TextEditingController(text: state.editingName)
                    ..selection = TextSelection.fromPosition(
                      TextPosition(offset: state.editingName.length),
                    ),
                  onChanged: (v) =>
                      context.read<ProfileCubit>().updateEditingName(v),
                  style: context.textTheme.bodyLarge?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                  decoration: const InputDecoration(
                    isDense: true,
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.zero,
                  ),
                  cursorColor: Colors.white,
                ),
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            GestureDetector(
              onTap: () => context.read<ProfileCubit>().saveName(),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.md,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFF5A623),
                  borderRadius: BorderRadius.circular(AppRadius.pill),
                ),
                child: Text(
                  'Save',
                  style: context.textTheme.labelLarge?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    }
    return GestureDetector(
      onTap: () => context.read<ProfileCubit>().startEditing(),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            state.name,
            style: context.textTheme.titleLarge?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(width: 6),
          Icon(
            Icons.edit_rounded,
            color: Colors.white.withValues(alpha: 0.8),
            size: 16,
          ),
        ],
      ),
    );
  }
}

class _LevelBadge extends StatelessWidget {
  final String label;

  const _LevelBadge({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFFF5A623).withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(
          color: const Color(0xFFF5A623).withValues(alpha: 0.5),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('⭐', style: TextStyle(fontSize: 13)),
          const SizedBox(width: 5),
          Text(
            label,
            style: context.textTheme.labelLarge?.copyWith(
              color: const Color(0xFFF5A623),
              fontWeight: FontWeight.w700,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── White Body ───────────────────────────────────────────────────────────────

class _ProfileBody extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ProfileCubit, ProfileState>(
      builder: (context, state) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(AppRadius.xl),
              topRight: Radius.circular(AppRadius.xl),
            ),
          ),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Column(
              children: [
                const SizedBox(height: AppSpacing.sm),
                // Stat cards
                Row(
                  children: [
                    Expanded(
                      child: BlocBuilder<CoinsCubit, int>(
                        builder: (context, coins) => ProfileStatCard(
                          emoji: '🪙',
                          value: '$coins',
                          label: 'Coins',
                        ),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: ProfileStatCard(
                        emoji: '⚡',
                        value: '${state.questsDone}',
                        label: 'Quests Done',
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: ProfileStatCard(
                        emoji: '🔥',
                        value: '${state.dayStreak}',
                        label: 'Day Streak',
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.md),
                // Customize Avatar
                ProfileMenuTile(
                  emoji: '🎨',
                  iconBg: const Color(0xFFF5EEFF),
                  title: 'Customize Avatar',
                  subtitle: 'Change outfit, hair & more',
                  onTap: () =>
                      context.router.push(const NamedRoute('avatar')),
                ),
                const SizedBox(height: AppSpacing.sm),
                // Achievements
                ProfileMenuTile(
                  emoji: '🏆',
                  iconBg: const Color(0xFFFFF3D6),
                  title: 'Achievements',
                  subtitle: '${state.questsDone} unlocked',
                  onTap: () => AchievementsDialog.show(context),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

// ─── Bottom Nav ───────────────────────────────────────────────────────────────

class _ProfileBottomNavBar extends StatelessWidget {
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
                onTap: () => context.router.push(const NamedRoute('store')),
              ),
              const _NavItem(
                icon: Icons.person_rounded,
                label: 'Profile',
                isSelected: true,
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
