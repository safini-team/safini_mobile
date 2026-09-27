import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:safini/core/theme/app_colors.dart';
import 'package:safini/core/theme/app_radius.dart';
import 'package:safini/core/theme/app_spacing.dart';
import 'package:safini/core/theme/app_typography.dart';
import 'package:safini/core/translation/generated/l10n.dart';
import 'package:safini/core/utils/widgets/ds/ds.dart';
import 'package:safini/features/common/auth/presentation/cubit/auth_session_cubit.dart';
import 'package:safini/features/parent/presentation/cubit/app_lock/parent_app_lock_cubit.dart';
import 'package:safini/features/parent/presentation/cubit/app_lock/parent_app_lock_state.dart';
import 'package:safini/features/parent/presentation/widgets/app_lock/parent_pin_pad.dart';

String? parentAppLockErrorText(S s, ParentAppLockError? error) {
  return switch (error) {
    ParentAppLockError.wrongPin => s.appLockWrongPin,
    ParentAppLockError.mismatch => s.appLockMismatch,
    ParentAppLockError.invalidPin => s.appLockInvalidPin,
    ParentAppLockError.lockedOut => s.appLockLockout,
    ParentAppLockError.storage => s.appLockStorageError,
    null => null,
  };
}

/// Full-screen PIN gate. Sits above every parent route, including settings.
class ParentAppLockGate extends StatelessWidget {
  const ParentAppLockGate({super.key});

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);

    return BlocConsumer<ParentAppLockCubit, ParentAppLockState>(
      listenWhen: (previous, next) =>
          previous.error != next.error &&
          next.error == ParentAppLockError.wrongPin,
      listener: (context, state) {
        HapticFeedback.heavyImpact();
      },
      builder: (context, state) {
        return PopScope(
          canPop: false,
          child: Material(
            color: AppColors.bgParent,
            child: SafeArea(
              child: Column(
                children: [
                  const SizedBox(height: 28),
                  Container(
                    width: 64,
                    height: 64,
                    decoration: BoxDecoration(
                      color: AppColors.primaryTint,
                      borderRadius: BorderRadius.circular(AppRadius.icon),
                    ),
                    child: const Icon(
                      Icons.lock_rounded,
                      color: AppColors.primary,
                      size: 30,
                    ),
                  ),
                  const SizedBox(height: 22),
                  Expanded(
                    child: SingleChildScrollView(
                      child: ParentPinPad(
                        title: s.appLockEnterPin,
                        error: parentAppLockErrorText(s, state.error),
                        enabled: !state.busy,
                        clearToken: Object.hash(
                          state.error,
                          state.failedAttempts,
                          state.lockoutUntil,
                          state.busy,
                        ),
                        onCompleted: (pin) {
                          context.read<ParentAppLockCubit>().unlock(pin);
                        },
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(
                      AppSpacing.gutter,
                      8,
                      AppSpacing.gutter,
                      8,
                    ),
                    child: Text(
                      s.appLockForgot,
                      textAlign: TextAlign.center,
                      style: AppText.footnote,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(
                      AppSpacing.gutter,
                      0,
                      AppSpacing.gutter,
                      12,
                    ),
                    child: DsDestructiveButton(
                      key: const ValueKey('app-lock-sign-out'),
                      label: s.appLockSignOut,
                      filled: false,
                      onTap: () => _confirmSignOut(context, s),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
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
          Text(s.appLockForgot, style: AppText.bodyRegular),
          const SizedBox(height: 22),
          DsPrimaryButton(
            label: s.appLockSignOut,
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
