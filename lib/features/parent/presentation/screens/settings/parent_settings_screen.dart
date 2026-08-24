import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:safini/core/theme/app_colors.dart';
import 'package:safini/core/theme/app_radius.dart';
import 'package:safini/core/theme/app_shadows.dart';
import 'package:safini/core/theme/app_spacing.dart';
import 'package:safini/core/theme/app_typography.dart';
import 'package:safini/core/translation/generated/l10n.dart';
import 'package:safini/core/utils/constants/app_constants.dart';
import 'package:safini/core/utils/widgets/ds/ds.dart';
import 'package:safini/core/utils/widgets/language_sheet.dart';
import 'package:safini/features/common/auth/presentation/account_deletion_flow.dart';
import 'package:safini/features/common/auth/presentation/cubit/auth_session_cubit.dart';

/// Parent · Settings, pushed from My family.
///
/// The artboard's "Alerts" block (three push toggles) is not here: there is no
/// notification-preference endpoint yet, and switches that persist nowhere are
/// worse than an honest gap. Everything else follows the artboard.
class ParentSettingsScreen extends StatelessWidget {
  const ParentSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);

    return Scaffold(
      backgroundColor: AppColors.bgParent,
      body: Column(
        children: [
          DsNavBar(
            title: s.settings,
            backLabel: s.myFamily,
            onBack: () => context.router.maybePop(),
          ),
          Expanded(
            child: DsScreenEntrance(
              child: ListView(
                physics: const BouncingScrollPhysics(),
                padding: EdgeInsets.only(
                  bottom: 40 + MediaQuery.viewPaddingOf(context).bottom,
                ),
                children: [
                  DsOverline(s.sectionAccount, top: 14),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.gutter,
                    ),
                    child: DsGroup(
                      radius: AppRadius.card,
                      shadow: AppShadows.flat,
                      children: [
                        DsRow(
                          onTap: () => _editProfile(context),
                          title: s.editProfile,
                          verticalPadding: 15,
                          trailing: AppIcons.chevronRight(),
                        ),
                      ],
                    ),
                  ),
                  DsOverline(s.sectionApp, top: 26),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.gutter,
                    ),
                    child: DsGroup(
                      radius: AppRadius.card,
                      shadow: AppShadows.flat,
                      children: [
                        DsRow(
                          onTap: () => showLanguageSheet(context),
                          title: s.changeLanguage,
                          verticalPadding: 15,
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                languageName(
                                  Localizations.localeOf(context).languageCode,
                                  s,
                                ),
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
                          onTap: () => openPrivacyPolicy(context),
                          title: s.privacyPolicy,
                          subtitle: s.privacyPolicySubtitle,
                          verticalPadding: 15,
                          trailing: AppIcons.chevronRight(),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(
                      AppSpacing.gutter,
                      22,
                      AppSpacing.gutter,
                      0,
                    ),
                    child: DsDestructiveButton(
                      label: s.logout,
                      onTap: () => _confirmSignOut(context, s),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(
                      AppSpacing.gutter,
                      12,
                      AppSpacing.gutter,
                      0,
                    ),
                    child: DsDestructiveButton(
                      label: s.deleteAccount,
                      onTap: () => showAccountDeletionFlow(context),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    '${AppConstants.appName} '
                    '${AppConstants.appVersion} (${AppConstants.buildNumber})',
                    textAlign: TextAlign.center,
                    style: AppText.caption.copyWith(
                      color: AppColors.textTertiary,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _editProfile(BuildContext context) async {
    final router = context.router;
    final saved = await router.push<bool>(const NamedRoute('editProfile'));
    if (saved == true) router.maybePop(true);
  }

  Future<void> _confirmSignOut(BuildContext context, S s) async {
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

    if (confirmed == true) await auth.signOut();
  }
}
