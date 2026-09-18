import 'dart:io';

import 'package:auto_route/auto_route.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:safini/core/di/injection.dart';
import 'package:safini/core/notifications/foreground_notifications.dart';
import 'package:safini/core/notifications/notification_preferences.dart';
import 'package:safini/core/theme/app_colors.dart';
import 'package:safini/core/theme/app_radius.dart';
import 'package:safini/core/theme/app_shadows.dart';
import 'package:safini/core/theme/app_spacing.dart';
import 'package:safini/core/theme/app_typography.dart';
import 'package:safini/core/translation/generated/l10n.dart';
import 'package:safini/core/utils/widgets/app_snack_bar.dart';
import 'package:safini/core/utils/widgets/app_version_label.dart';
import 'package:safini/core/utils/widgets/ds/ds.dart';
import 'package:safini/core/utils/widgets/language_sheet.dart';
import 'package:safini/core/utils/widgets/on_app_resume.dart';
import 'package:safini/features/common/auth/presentation/account_deletion_flow.dart';
import 'package:safini/features/common/auth/presentation/cubit/auth_session_cubit.dart';
import 'package:url_launcher/url_launcher.dart';

/// Parent · Settings, pushed from My family. Follows the artboard, including
/// the Alerts block, whose switches are stored per account on the server.
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
                  const _AlertsSection(),
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
                              LanguageLabel(
                                code: Localizations.localeOf(
                                  context,
                                ).languageCode,
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
                  const AppVersionLabel(),
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

/// New submissions, Limit reached and Weekly digest, as on the artboard. When
/// the phone itself blocks Safini's notifications the switches cannot do
/// anything, so a row above them says so and opens the system setting.
class _AlertsSection extends StatefulWidget {
  const _AlertsSection();

  @override
  State<_AlertsSection> createState() => _AlertsSectionState();
}

class _AlertsSectionState extends State<_AlertsSection> {
  late final AlertsCubit _cubit = AlertsCubit(
    NotificationPreferencesService(getIt<Dio>()),
  )..load();

  @override
  void dispose() {
    _cubit.close();
    super.dispose();
  }

  Future<void> _openSystemSettings() async {
    if (!kIsWeb && Platform.isIOS) {
      await launchUrl(Uri.parse('app-settings:'));
    } else {
      await const ForegroundNotifications().openSettings();
    }
  }

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);

    return OnAppResume(
      // Back from system settings with notifications turned on.
      onResume: _cubit.checkSystem,
      child: BlocConsumer<AlertsCubit, AlertsState>(
        bloc: _cubit,
        listenWhen: (_, state) => state.saveFailed,
        listener: (context, _) => AppSnackBar.error(context, s.alertSaveFailed),
        builder: (context, state) {
          Widget toggle(AlertSwitch key, String title, String subtitle) => DsRow(
            title: title,
            subtitle: subtitle,
            verticalPadding: 14,
            trailing: DsSwitch(
              value: state.preferences[key],
              onChanged: state.loaded
                  ? (value) => _cubit.toggle(key, value)
                  : null,
            ),
          );

          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              DsOverline(s.sectionAlerts, top: 26),
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.gutter,
                ),
                child: DsGroup(
                  radius: AppRadius.card,
                  shadow: AppShadows.flat,
                  children: [
                    if (state.systemEnabled == false)
                      DsRow(
                        onTap: _openSystemSettings,
                        title: s.notificationsOffTitle,
                        subtitle: s.notificationsOffBody,
                        titleColor: AppColors.danger,
                        verticalPadding: 14,
                        trailing: AppIcons.chevronRight(),
                      ),
                    toggle(
                      AlertSwitch.taskSubmissions,
                      s.alertSubmissionsTitle,
                      s.alertSubmissionsSubtitle,
                    ),
                    toggle(
                      AlertSwitch.limitReached,
                      s.alertLimitsTitle,
                      s.alertLimitsSubtitle,
                    ),
                    toggle(
                      AlertSwitch.weeklyDigest,
                      s.alertDigestTitle,
                      s.alertDigestSubtitle,
                    ),
                  ],
                ),
              ),
              DsFootnote(s.alertsAlwaysOn, top: 10),
            ],
          );
        },
      ),
    );
  }
}
