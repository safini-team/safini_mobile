import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:safini/core/di/injection.dart';
import 'package:safini/core/app/locale_cubit.dart';
import 'package:safini/core/theme/app_radius.dart';
import 'package:safini/core/theme/app_spacing.dart';
import 'package:safini/core/utils/extension/theme_extension.dart';
import 'package:safini/core/utils/widgets/app_snack_bar.dart';
import 'package:safini/features/common/auth/presentation/cubit/child_claim_cubit.dart';
import 'package:safini/features/common/profile/data/repositories/profile_repository.dart';
import 'package:safini/features/child/domain/controllers/child_controller.dart';
import 'package:safini/features/child/presentation/cubit/coins_cubit.dart';
import 'package:safini/features/child/presentation/cubit/profile_cubit.dart';
import 'package:safini/features/child/presentation/cubit/profile_state.dart';
import 'package:safini/features/child/presentation/widgets/cards/profile_stat_card.dart';
import 'package:safini/features/child/presentation/widgets/dialogs/achievements_dialog.dart';
import 'package:safini/features/child/presentation/widgets/tiles/profile_menu_tile.dart';
import 'package:safini/core/translation/generated/l10n.dart';
import 'package:safini/features/common/auth/data/auth_google_sign_in_service.dart'
    as safini_auth;
import 'package:shared_preferences/shared_preferences.dart' as safini_prefs;

class ChildProfileScreen extends StatelessWidget {
  const ChildProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LocaleCubit, Locale>(
      builder: (context, locale) {
        return Localizations.override(
          context: context,
          locale: locale,
          child: BlocProvider(
            create: (context) =>
                ProfileCubit(
                  getIt<ChildController>(),
                  getIt<ProfileRepository>(),
                  getIt<CoinsCubit>(),
                )..loadProfile(
                  fallbackChild: context.read<ChildClaimCubit>().state.child,
                ),
            child: const _ProfileView(),
          ),
        );
      },
    );
  }
}

// ─── Root View ────────────────────────────────────────────────────────────────

class _ProfileView extends StatelessWidget {
  const _ProfileView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.colorScheme.surface,
      body: Column(
        children: [
          _ProfileHeader(),
          Expanded(child: _ProfileBody()),
        ],
      ),
    );
  }
}

// ─── Purple Header ─────────────────────────────────────────────────────────────

class _ProfileHeader extends StatelessWidget {
  Future<void> _showEditNameDialog(
    BuildContext context,
    ProfileState state,
  ) async {
    final profileCubit = context.read<ProfileCubit>();
    final controller = TextEditingController(text: state.name.trim());
    final formKey = GlobalKey<FormState>();

    await showDialog<void>(
      context: context,
      useRootNavigator: false,
      builder: (dialogContext) {
        return BlocProvider.value(
          value: profileCubit,
          child: BlocBuilder<ProfileCubit, ProfileState>(
            builder: (context, profileState) {
              return AlertDialog(
                title: const Text('Edit Profile Name'),
                content: Form(
                  key: formKey,
                  child: TextFormField(
                    controller: controller,
                    autofocus: true,
                    maxLength: 120,
                    decoration: const InputDecoration(labelText: 'Name'),
                    validator: (value) {
                      final name = (value ?? '').trim();
                      if (name.isEmpty) return 'Name is required.';
                      if (name.length > 120) {
                        return 'Name must be at most 120 characters.';
                      }
                      return null;
                    },
                  ),
                ),
                actions: [
                  TextButton(
                    onPressed: profileState.isUpdatingName
                        ? null
                        : () => Navigator.of(dialogContext).pop(),
                    child: Text(S.of(context).cancel),
                  ),
                  ElevatedButton(
                    onPressed: profileState.isUpdatingName
                        ? null
                        : () async {
                            if (!formKey.currentState!.validate()) return;
                            final failure = await context
                                .read<ProfileCubit>()
                                .updateDisplayName(controller.text);
                            if (!dialogContext.mounted) return;
                            if (failure == null) {
                              Navigator.of(dialogContext).pop();
                              AppSnackBar.success(context, 'Profile updated');
                            } else {
                              AppSnackBar.error(context, failure.message);
                            }
                          },
                    child: profileState.isUpdatingName
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : Text(S.of(context).save),
                  ),
                ],
              );
            },
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    return BlocBuilder<ProfileCubit, ProfileState>(
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
                        s.myProfile,
                        style: context.textTheme.headlineSmall?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      GestureDetector(
                        onTap: () async {
                          final confirm = await showDialog<bool>(
                            context: context,
                            builder: (ctx) => AlertDialog(
                              title: const Text('Log Out'),
                              content: const Text(
                                'Are you sure you want to log out?',
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(ctx, false),
                                  child: const Text('Cancel'),
                                ),
                                TextButton(
                                  onPressed: () => Navigator.pop(ctx, true),
                                  child: const Text(
                                    'Log Out',
                                    style: TextStyle(color: Colors.red),
                                  ),
                                ),
                              ],
                            ),
                          );
                          if (confirm == true) {
                            try {
                              await getIt<safini_auth.AuthGoogleSignInService>()
                                  .signOut();
                            } catch (_) {}
                            await getIt<safini_prefs.SharedPreferences>()
                                .remove('access_token');
                            if (context.mounted) {
                              context.router.replaceAll([
                                const NamedRoute('login'),
                              ]);
                            }
                          }
                        },
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
                            Icons.logout_rounded,
                            color: Colors.white,
                            size: 18,
                          ),
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
                TextButton.icon(
                  onPressed: state.isUpdatingName
                      ? null
                      : () => _showEditNameDialog(context, state),
                  icon: const Icon(Icons.edit_rounded, color: Colors.white),
                  label: Text(
                    S.of(context).editProfile,
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                // Level badge
                _LevelBadge(label: S.of(context).levelHero(state.level)),
                const SizedBox(height: AppSpacing.lg),
                // XP progress bar
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.xl,
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: state.xpProgress,
                      backgroundColor: context.colorScheme.onPrimary.withValues(
                        alpha: 0.2,
                      ),
                      valueColor: AlwaysStoppedAnimation<Color>(
                        context.colorScheme.secondary,
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
    return Hero(
      tag: 'child-avatar-hero',
      child: SizedBox(
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
                  border: Border.all(
                    color: context.colorScheme.onPrimary,
                    width: 2,
                  ),
                ),
                child: Center(
                  child: Text(badgeEmoji, style: const TextStyle(fontSize: 14)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _NameSection extends StatelessWidget {
  final ProfileState state;

  const _NameSection({required this.state});

  @override
  Widget build(BuildContext context) {
    final claimedNickname =
        context.watch<ChildClaimCubit>().state.child?.nickname ?? '';
    final profileName = state.name.trim();
    final fallbackName = claimedNickname.trim();
    final displayName = profileName.isNotEmpty
        ? profileName
        : (fallbackName.isNotEmpty ? fallbackName : 'Child');
    debugPrint(
      '[ChildProfileScreen] name render | state.name="$profileName" '
      '| claimedNickname="$fallbackName" | displayName="$displayName"',
    );

    return Text(
      displayName,
      style: context.textTheme.titleLarge?.copyWith(
        color: Colors.white,
        fontWeight: FontWeight.w700,
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
        color: context.colorScheme.secondary.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(
          color: context.colorScheme.secondary.withValues(alpha: 0.5),
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
    final s = S.of(context);
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
                          label: s.coins,
                        ),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: ProfileStatCard(
                        emoji: '⚡',
                        value: '${state.questsDone}',
                        label: s.questsDone,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: ProfileStatCard(
                        emoji: '🔥',
                        value: '${state.dayStreak}',
                        label: s.dayStreak,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.md),
                // Customize Avatar
                ProfileMenuTile(
                  emoji: '🎨',
                  iconBg: context.colorScheme.primary.withValues(alpha: 0.1),
                  title: s.customizeAvatar,
                  subtitle: s.changeOutfit,
                  onTap: () => context.router.push(const NamedRoute('avatar')),
                ),
                const SizedBox(height: AppSpacing.sm),
                // Achievements
                ProfileMenuTile(
                  emoji: '🏆',
                  iconBg: context.colorScheme.secondary.withValues(alpha: 0.1),
                  title: s.achievements,
                  subtitle: '${state.questsDone} ${s.unlocked}',
                  onTap: () => AchievementsDialog.show(context),
                ),
                const SizedBox(height: AppSpacing.sm),
                // Language
                ProfileMenuTile(
                  emoji: '🌍',
                  iconBg: context.colorScheme.primary.withValues(alpha: 0.1),
                  title: s.changeLanguage,
                  subtitle: _getLanguageName(
                    Localizations.localeOf(context).languageCode,
                    s,
                  ),
                  onTap: () => _showLanguageDialog(context),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  String _getLanguageName(String code, S s) {
    switch (code) {
      case 'kk':
        return s.kazakh;
      case 'ru':
        return s.russian;
      default:
        return s.english;
    }
  }

  void _showLanguageDialog(BuildContext context) {
    final s = S.of(context);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(s.selectLanguage),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: Text(s.english),
              onTap: () {
                context.read<LocaleCubit>().setLocale(const Locale('en'));
                Navigator.pop(context);
              },
            ),
            ListTile(
              title: Text(s.russian),
              onTap: () {
                context.read<LocaleCubit>().setLocale(const Locale('ru'));
                Navigator.pop(context);
              },
            ),
            ListTile(
              title: Text(s.kazakh),
              onTap: () {
                context.read<LocaleCubit>().setLocale(const Locale('kk'));
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Bottom Nav ───────────────────────────────────────────────────────────────
