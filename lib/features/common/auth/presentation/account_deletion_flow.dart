import 'dart:async';

import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:safini/core/di/injection.dart';
import 'package:safini/core/theme/app_colors.dart';
import 'package:safini/core/theme/app_typography.dart';
import 'package:safini/core/translation/generated/l10n.dart';
import 'package:safini/core/utils/constants/app_constants.dart';
import 'package:safini/core/utils/widgets/app_snack_bar.dart';
import 'package:safini/core/utils/widgets/ds/ds.dart';
import 'package:safini/features/common/auth/data/account_deletion_service.dart';
import 'package:safini/features/common/auth/presentation/cubit/auth_session_cubit.dart';
import 'package:url_launcher/url_launcher.dart';

Future<void> openPrivacyPolicy(BuildContext context) async {
  final s = S.of(context);
  var opened = false;
  try {
    opened = await launchUrl(
      Uri.parse(AppConstants.privacyPolicyUrl),
      mode: LaunchMode.externalApplication,
    );
  } catch (_) {
    opened = false;
  }
  if (!opened && context.mounted) {
    AppSnackBar.error(context, s.privacyPolicyOpenFailed);
  }
}

Future<void> showAccountDeletionFlow(BuildContext context) async {
  final s = S.of(context);
  final auth = context.read<AuthSessionCubit>();
  final router = context.router;
  final isParent = auth.state.accountType == AppConstants.accountTypeParent;

  final confirmed = await showDsSheet<bool>(
    context: context,
    builder: (sheetContext) => Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(s.deleteAccountConfirmTitle, style: AppText.title3),
        const SizedBox(height: 8),
        Text(
          isParent
              ? s.deleteAccountParentConfirmBody
              : s.deleteAccountChildConfirmBody,
          style: AppText.bodyRegular,
        ),
        const SizedBox(height: 22),
        DsPrimaryButton(
          label: s.deleteAccount,
          background: AppColors.danger,
          shadow: const [],
          onTap: () => Navigator.of(sheetContext).pop(true),
        ),
        const SizedBox(height: 9),
        DsPrimaryButton.secondary(
          label: s.cancel,
          onTap: () => Navigator.of(sheetContext).pop(false),
        ),
      ],
    ),
  );
  if (confirmed != true || !context.mounted) return;

  final navigator = Navigator.of(context, rootNavigator: true);
  final progressRoute = DialogRoute<void>(
    context: context,
    barrierDismissible: false,
    builder: (_) => PopScope(
      canPop: false,
      child: AlertDialog(
        content: Row(
          children: [
            const SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(strokeWidth: 2.5),
            ),
            const SizedBox(width: 16),
            Expanded(child: Text(s.deletingAccount)),
          ],
        ),
      ),
    ),
  );
  unawaited(navigator.push(progressRoute));

  try {
    await getIt<AccountDeletionService>().deleteAccount();
    if (progressRoute.isActive) navigator.removeRoute(progressRoute);
    await auth.signOut();
    if (!context.mounted) return;
    router.replaceAll([const NamedRoute('login')]);
  } on AccountDeletionException catch (error) {
    if (progressRoute.isActive) navigator.removeRoute(progressRoute);
    if (!context.mounted) return;
    AppSnackBar.error(
      context,
      error.isRetryable ? s.deleteAccountRetry : s.deleteAccountFailed,
    );
  } catch (_) {
    if (progressRoute.isActive) navigator.removeRoute(progressRoute);
    if (!context.mounted) return;
    AppSnackBar.error(context, s.deleteAccountRetry);
  }
}
