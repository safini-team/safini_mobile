import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:safini/core/theme/app_colors.dart';
import 'package:safini/features/child/presentation/cubit/app_block_cubit.dart';
import 'package:safini/features/child/presentation/cubit/app_block_state.dart';

/// Wraps the child shell and, while the two special permissions required for
/// on-device app blocking are missing, replaces it with an onboarding screen
/// that deep-links the user to the relevant system Settings.
///
/// Permissions are re-checked automatically whenever the app returns to the
/// foreground (the user grants them in Settings, then comes back).
///
/// A "Not now" escape hatch keeps the app usable during rollout; remove it once
/// blocking is mandatory.
class ChildAppBlockGate extends StatefulWidget {
  final Widget child;

  const ChildAppBlockGate({super.key, required this.child});

  @override
  State<ChildAppBlockGate> createState() => _ChildAppBlockGateState();
}

class _ChildAppBlockGateState extends State<ChildAppBlockGate>
    with WidgetsBindingObserver {
  bool _dismissedForSession = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState lifecycleState) {
    if (lifecycleState == AppLifecycleState.resumed && mounted) {
      context.read<ChildAppBlockCubit>().onResumed();
    }
  }

  Future<void> _handleRecheck() async {
    final cubit = context.read<ChildAppBlockCubit>();
    await cubit.refreshPermissions();
    if (!mounted) return;

    final state = cubit.state;
    if (state.status == AppBlockStatus.error) {
      _showResultSheet(
        icon: Icons.error_outline_rounded,
        iconColor: AppColors.error,
        title: 'Something went wrong',
        message: state.errorMessage?.isNotEmpty == true
            ? state.errorMessage!
            : "Couldn't turn on app limits. Please try again.",
      );
    } else if (!state.hasAllPermissions) {
      _showResultSheet(
        icon: Icons.info_outline_rounded,
        iconColor: AppColors.primary,
        title: 'Permissions not detected yet',
        message: "Safini still can't see both permissions turned on. Open "
            'Settings, grant them, then come back and tap this button again.',
      );
    }
  }

  void _showResultSheet({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String message,
  }) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (sheetContext) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 24, 24, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Icon(icon, color: iconColor, size: 32),
              const SizedBox(height: 12),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: AppColors.ink,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                message,
                style: const TextStyle(
                  fontSize: 14,
                  height: 1.4,
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                height: 48,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(sheetContext),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: const Text(
                    'Got it',
                    style: TextStyle(fontWeight: FontWeight.w700),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ChildAppBlockCubit, AppBlockState>(
      builder: (context, state) {
        final blocking = state.status == AppBlockStatus.needsPermissions &&
            !_dismissedForSession;
        if (!blocking) return widget.child;

        return _PermissionScreen(
          state: state,
          onGrantUsage: () =>
              context.read<ChildAppBlockCubit>().requestUsageAccess(),
          onGrantOverlay: () =>
              context.read<ChildAppBlockCubit>().requestOverlayPermission(),
          onRecheck: _handleRecheck,
          onSkip: () => setState(() => _dismissedForSession = true),
        );
      },
    );
  }
}

class _PermissionScreen extends StatelessWidget {
  final AppBlockState state;
  final VoidCallback onGrantUsage;
  final VoidCallback onGrantOverlay;
  final Future<void> Function() onRecheck;
  final VoidCallback onSkip;

  const _PermissionScreen({
    required this.state,
    required this.onGrantUsage,
    required this.onGrantOverlay,
    required this.onRecheck,
    required this.onSkip,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgChild,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 32, 24, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 8),
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: AppColors.primaryTint,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Icon(
                  Icons.shield_rounded,
                  color: AppColors.primary,
                  size: 34,
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'Turn on app limits',
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.w900,
                  color: AppColors.ink,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Safini needs two Android permissions to keep app time limits '
                'working. Grant both to continue.',
                style: TextStyle(
                  fontSize: 15,
                  height: 1.4,
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 28),
              _PermissionTile(
                icon: Icons.bar_chart_rounded,
                title: 'Usage Access',
                subtitle:
                    'Lets Safini see which app is open so it can measure time.',
                granted: state.hasUsageAccess,
                onGrant: onGrantUsage,
              ),
              const SizedBox(height: 14),
              _PermissionTile(
                icon: Icons.layers_rounded,
                title: 'Display over other apps',
                subtitle: 'Lets Safini show the block screen on top of apps.',
                granted: state.hasOverlayPermission,
                onGrant: onGrantOverlay,
              ),
              const Spacer(),
              SizedBox(
                height: 54,
                child: ElevatedButton(
                  onPressed: state.isChecking ? null : onRecheck,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    disabledBackgroundColor: AppColors.primary.withValues(
                      alpha: 0.6,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: state.isChecking
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.5,
                            valueColor: AlwaysStoppedAnimation(Colors.white),
                          ),
                        )
                      : Text(
                          state.hasAllPermissions
                              ? 'Continue'
                              : 'I\'ve granted these',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                ),
              ),
              const SizedBox(height: 8),
              TextButton(
                onPressed: state.isChecking ? null : onSkip,
                child: const Text(
                  'Not now',
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PermissionTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final bool granted;
  final VoidCallback onGrant;

  const _PermissionTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.granted,
    required this.onGrant,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: granted ? AppColors.success : AppColors.strokeQuiet,
          width: granted ? 1.5 : 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: AppColors.primaryTint,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, color: AppColors.primary, size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: AppColors.ink,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 13,
                    height: 1.3,
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          if (granted)
            const Icon(Icons.check_circle_rounded, color: AppColors.success)
          else
            TextButton(
              onPressed: onGrant,
              style: TextButton.styleFrom(
                foregroundColor: AppColors.primary,
                padding: const EdgeInsets.symmetric(horizontal: 12),
              ),
              child: const Text(
                'Grant',
                style: TextStyle(fontWeight: FontWeight.w700),
              ),
            ),
        ],
      ),
    );
  }
}
