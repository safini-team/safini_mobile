import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:safini/core/theme/app_colors.dart';
import 'package:safini/core/utils/constants/app_constants.dart';
import 'package:safini/features/common/auth/presentation/cubit/auth_session_cubit.dart';
import 'package:safini/features/common/auth/presentation/cubit/auth_session_state.dart';
import 'package:safini/features/parent/presentation/cubit/app_lock/parent_app_lock_cubit.dart';
import 'package:safini/features/parent/presentation/cubit/app_lock/parent_app_lock_state.dart';
import 'package:safini/features/parent/presentation/screens/app_lock/parent_app_lock_gate.dart';

/// Covers every parent route when a PIN is enabled. Lives on
/// [MaterialApp.builder] so settings (a sibling of the tab shell) cannot
/// bypass the gate.
class ParentAppLockHost extends StatefulWidget {
  const ParentAppLockHost({super.key, required this.child});

  final Widget child;

  @override
  State<ParentAppLockHost> createState() => _ParentAppLockHostState();
}

class _ParentAppLockHostState extends State<ParentAppLockHost>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    context.read<ParentAppLockCubit>().load();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.hidden) {
      context.read<ParentAppLockCubit>().lockOnBackground();
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthSessionCubit, AuthSessionState>(
      listenWhen: (previous, next) => previous.status != next.status,
      listener: (context, state) {
        if (state.status == AuthSessionStatus.unauthenticated) {
          context.read<ParentAppLockCubit>().onUnauthenticated();
        }
      },
      child: BlocBuilder<AuthSessionCubit, AuthSessionState>(
        buildWhen: (previous, next) =>
            previous.status != next.status ||
            previous.accountType != next.accountType,
        builder: (context, auth) {
          return BlocBuilder<ParentAppLockCubit, ParentAppLockState>(
            builder: (context, lock) {
              final isParent =
                  auth.status == AuthSessionStatus.authenticated &&
                  auth.accountType == AppConstants.accountTypeParent;
              final showLock = isParent && lock.blocksParent;

              return PopScope(
                canPop: !showLock,
                child: Stack(
                  children: [
                    widget.child,
                    if (isParent && !lock.ready)
                      const Positioned.fill(
                        child: ColoredBox(
                          color: AppColors.bgParent,
                          child: Center(
                            child: CircularProgressIndicator(
                              color: AppColors.primary,
                            ),
                          ),
                        ),
                      ),
                    if (showLock && lock.ready)
                      const Positioned.fill(child: ParentAppLockGate()),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}
