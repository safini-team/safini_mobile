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
class ParentAppLockGate extends StatefulWidget {
  const ParentAppLockGate({super.key});

  @override
  State<ParentAppLockGate> createState() => _ParentAppLockGateState();
}

class _ParentAppLockGateState extends State<ParentAppLockGate> {
  bool _showRecovery = false;
  bool _signingOut = false;
  bool _signOutFailed = false;

  Future<void> _signOut() async {
    if (_signingOut) return;
    setState(() {
      _signingOut = true;
      _signOutFailed = false;
    });
    try {
      await context.read<AuthSessionCubit>().signOut();
    } catch (error) {
      debugPrint('PIN recovery sign-out failed: $error');
      if (mounted) setState(() => _signOutFailed = true);
    } finally {
      if (mounted) setState(() => _signingOut = false);
    }
  }

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
                  if (_showRecovery) ...[
                    const Spacer(),
                    Text(
                      s.appLockForgotAction,
                      textAlign: TextAlign.center,
                      style: AppText.title2,
                    ),
                    const SizedBox(height: 12),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.gutter,
                      ),
                      child: Text(
                        s.appLockForgot,
                        textAlign: TextAlign.center,
                        style: AppText.bodyRegular,
                      ),
                    ),
                    const Spacer(),
                    if (_signOutFailed)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: Text(
                          s.appLockSignOutFailed,
                          style: AppText.bodyRegular.copyWith(
                            color: AppColors.danger,
                          ),
                        ),
                      ),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.gutter,
                      ),
                      child: DsDestructiveButton(
                        key: const ValueKey('app-lock-sign-out'),
                        label: s.appLockSignOut,
                        onTap: _signingOut ? null : _signOut,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(
                        AppSpacing.gutter,
                        0,
                        AppSpacing.gutter,
                        12,
                      ),
                      child: DsPrimaryButton.secondary(
                        key: const ValueKey('app-lock-recovery-cancel'),
                        label: s.cancel,
                        onTap: _signingOut
                            ? null
                            : () => setState(() => _showRecovery = false),
                      ),
                    ),
                  ] else ...[
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
                        12,
                      ),
                      child: TextButton(
                        key: const ValueKey('app-lock-forgot'),
                        onPressed: () => setState(() => _showRecovery = true),
                        child: Text(
                          s.appLockForgotAction,
                          style: AppText.bodyRegular.copyWith(
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
