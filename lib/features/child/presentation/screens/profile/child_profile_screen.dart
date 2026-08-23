import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:safini/core/app/locale_cubit.dart';
import 'package:safini/core/theme/app_colors.dart';
import 'package:safini/core/theme/app_radius.dart';
import 'package:safini/core/theme/app_shadows.dart';
import 'package:safini/core/theme/app_spacing.dart';
import 'package:safini/core/theme/app_typography.dart';
import 'package:safini/core/translation/generated/l10n.dart';
import 'package:safini/core/utils/widgets/app_snack_bar.dart';
import 'package:safini/core/utils/widgets/ds/ds.dart';
import 'package:safini/core/utils/widgets/language_sheet.dart';
import 'package:safini/features/child/presentation/cubit/coins_cubit.dart';
import 'package:safini/features/child/presentation/cubit/profile_cubit.dart';
import 'package:safini/features/child/presentation/cubit/profile_state.dart';
import 'package:safini/features/child/presentation/screens/profile/child_me_view.dart';
import 'package:safini/features/common/auth/presentation/cubit/auth_session_cubit.dart';
import 'package:safini/features/common/auth/presentation/cubit/child_claim_cubit.dart';

class ChildProfileScreen extends StatelessWidget {
  const ChildProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LocaleCubit, Locale?>(
      builder: (context, locale) => Localizations.override(
        context: context,
        locale: locale,
        child: const _ChildMeScreen(),
      ),
    );
  }
}

class _ChildMeScreen extends StatelessWidget {
  const _ChildMeScreen();

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);

    return BlocBuilder<ProfileCubit, ProfileState>(
      builder: (context, state) {
        final coins = context.watch<CoinsCubit>().state;

        return ChildMeView(
          footer: const ChildMeSettings(),
          data: ChildMeData(
            name: state.name,
            faceEmoji: state.equippedFaceEmoji,
            avatarColor: AppColors.avatarPalette[1],
            accessoryEmoji: state.equippedBadgeEmoji.isEmpty
                ? null
                : state.equippedBadgeEmoji,
            levelLine: state.levelLabel.isEmpty
                ? s.levelValue(state.level)
                : state.levelLabel,
            xpProgress: state.xpProgress,
            xpCaption: s.percentToNextLevel((state.xpProgress * 100).round()),
            coins: coins,
            questsDone: state.questsDone,
            streakDays: state.dayStreak,
            badges: [
              MeBadge(
                emoji: '✅',
                label: s.badgeTasksDone(state.questsDone),
                earned: state.questsDone > 0,
              ),
              MeBadge(
                emoji: '🔥',
                label: s.nDayStreak(state.dayStreak),
                earned: state.dayStreak > 0,
              ),
              MeBadge(
                emoji: '🪙',
                label: s.badgeCoins(coins),
                earned: coins > 0,
              ),
            ],
          ),
          onChangeAvatar: () => _openAvatar(context),
          onEditName: () => _editName(context, state, s),
          onRefresh: () => context.read<ProfileCubit>().loadProfile(
            fallbackChild: context.read<ChildClaimCubit>().state.child,
          ),
        );
      },
    );
  }

  Future<void> _openAvatar(BuildContext context) async {
    final cubit = context.read<ProfileCubit>();
    final claim = context.read<ChildClaimCubit>();
    await context.router.push(const NamedRoute('avatar'));
    if (context.mounted) {
      cubit.loadProfile(fallbackChild: claim.state.child);
    }
  }

  Future<void> _editName(BuildContext context, ProfileState state, S s) async {
    final cubit = context.read<ProfileCubit>();
    final controller = TextEditingController(text: state.name);

    final name = await showDsSheet<String>(
      context: context,
      builder: (context) => Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(s.editProfile, style: AppText.title3),
          const SizedBox(height: 18),
          DsSheetPanel(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 14),
              child: Row(
                children: [
                  SizedBox(
                    width: 56,
                    child: Text(s.name, style: AppText.field),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: TextField(
                      controller: controller,
                      autofocus: true,
                      textCapitalization: TextCapitalization.words,
                      cursorColor: AppColors.primary,
                      style: AppText.rowTitleLg,
                      decoration: const InputDecoration(
                        filled: false,
                        isDense: true,
                        border: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        focusedBorder: InputBorder.none,
                        contentPadding: EdgeInsets.zero,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 22),
          DsPrimaryButton(
            label: s.save,
            onTap: () => Navigator.of(context).pop(controller.text.trim()),
          ),
        ],
      ),
    );

    controller.dispose();
    if (name == null || name.isEmpty || name == state.name) return;

    final failure = await cubit.updateDisplayName(name);
    if (!context.mounted) return;
    if (failure != null) {
      AppSnackBar.error(context, failure.message);
      return;
    }
    AppSnackBar.success(context, s.profileUpdated);
  }
}

/// Language + sign out for the child, appended under the Me screen.
class ChildMeSettings extends StatelessWidget {
  const ChildMeSettings({super.key});

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.gutter),
      child: DsGroup(
        radius: AppRadius.card,
        shadow: AppShadows.flat,
        children: [
          DsRow(
            title: s.changeLanguage,
            verticalPadding: 15,
            onTap: () => showLanguageSheet(context),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  languageName(Localizations.localeOf(context).languageCode, s),
                  style: AppText.body.copyWith(
                    fontWeight: FontWeight.w400,
                    color: AppColors.textTertiary,
                  ),
                ),
                const SizedBox(width: 8),
                AppIcons.chevronRight(),
              ],
            ),
          ),
          DsRow(
            title: s.logout,
            verticalPadding: 15,
            titleColor: AppColors.danger,
            titleStyle: AppText.rowTitleStrong,
            onTap: () => _signOut(context, s),
          ),
        ],
      ),
    );
  }

  Future<void> _signOut(BuildContext context, S s) async {
    final router = context.router;
    final auth = context.read<AuthSessionCubit>();

    final confirmed = await showDsSheet<bool>(
      context: context,
      builder: (context) => Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(s.logoutConfirmTitle, style: AppText.title3),
          const SizedBox(height: 8),
          Text(s.logoutConfirmBody, style: AppText.bodyRegular),
          const SizedBox(height: 22),
          DsPrimaryButton(
            label: s.logout,
            background: AppColors.danger,
            shadow: const [],
            onTap: () => Navigator.of(context).pop(true),
          ),
          const SizedBox(height: 9),
          DsPrimaryButton.secondary(
            label: s.cancel,
            onTap: () => Navigator.of(context).pop(false),
          ),
        ],
      ),
    );

    if (confirmed != true) return;
    await auth.signOut();
    if (!context.mounted) return;
    router.replaceAll([const NamedRoute('login')]);
  }
}
