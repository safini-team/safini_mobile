import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:safini/core/theme/app_colors.dart';
import 'package:safini/core/theme/app_radius.dart';
import 'package:safini/core/theme/app_shadows.dart';
import 'package:safini/core/theme/app_spacing.dart';
import 'package:safini/core/translation/generated/l10n.dart';
import 'package:safini/core/utils/widgets/app_snack_bar.dart';
import 'package:safini/core/utils/widgets/ds/ds.dart';
import 'package:safini/features/parent/presentation/cubit/app_lock/parent_app_lock_cubit.dart';
import 'package:safini/features/parent/presentation/cubit/app_lock/parent_app_lock_state.dart';
import 'package:safini/features/parent/presentation/screens/app_lock/parent_app_lock_gate.dart';
import 'package:safini/features/parent/presentation/widgets/app_lock/parent_pin_pad.dart';

enum _LockSettingsStep {
  home,
  create,
  confirmCreate,
  currentForChange,
  enterNew,
  confirmNew,
  disable,
}

/// Enable, change, or disable the local 4-digit parent PIN.
class ParentAppLockSettingsScreen extends StatefulWidget {
  const ParentAppLockSettingsScreen({super.key});

  @override
  State<ParentAppLockSettingsScreen> createState() =>
      _ParentAppLockSettingsScreenState();
}

class _ParentAppLockSettingsScreenState
    extends State<ParentAppLockSettingsScreen> {
  _LockSettingsStep _step = _LockSettingsStep.home;
  String _pending = '';

  void _goHome() {
    context.read<ParentAppLockCubit>().clearError();
    setState(() {
      _step = _LockSettingsStep.home;
      _pending = '';
    });
  }

  Future<void> _onPin(String pin) async {
    final cubit = context.read<ParentAppLockCubit>();
    switch (_step) {
      case _LockSettingsStep.home:
        return;
      case _LockSettingsStep.create:
        setState(() {
          _pending = pin;
          _step = _LockSettingsStep.confirmCreate;
        });
        cubit.clearError();
      case _LockSettingsStep.confirmCreate:
        final ok = await cubit.enable(_pending, pin);
        if (ok && mounted) _goHome();
      case _LockSettingsStep.currentForChange:
        final ok = await cubit.verifyPin(pin);
        if (ok && mounted) {
          setState(() {
            _pending = pin;
            _step = _LockSettingsStep.enterNew;
          });
        }
      case _LockSettingsStep.enterNew:
        setState(() {
          _pending = '$_pending|$pin';
          _step = _LockSettingsStep.confirmNew;
        });
        cubit.clearError();
      case _LockSettingsStep.confirmNew:
        final parts = _pending.split('|');
        final current = parts.first;
        final next = parts.length > 1 ? parts[1] : '';
        final ok = await cubit.change(current, next, pin);
        if (ok && mounted) _goHome();
      case _LockSettingsStep.disable:
        final ok = await cubit.disable(pin);
        if (ok && mounted) _goHome();
    }
  }

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);

    return BlocConsumer<ParentAppLockCubit, ParentAppLockState>(
      listenWhen: (previous, next) => previous.notice != next.notice,
      listener: (context, state) {
        final notice = state.notice;
        if (notice == null) return;
        final message = switch (notice) {
          ParentAppLockNotice.enabled => s.appLockEnabled,
          ParentAppLockNotice.disabled => s.appLockDisabled,
          ParentAppLockNotice.changed => s.appLockChanged,
        };
        AppSnackBar.success(context, message);
        context.read<ParentAppLockCubit>().ackNotice();
      },
      builder: (context, state) {
        return Scaffold(
          backgroundColor: AppColors.bgParent,
          body: Column(
            children: [
              DsNavBar(
                title: s.appLock,
                backLabel: s.settings,
                onBack: _step == _LockSettingsStep.home
                    ? () => Navigator.of(context).maybePop()
                    : _goHome,
              ),
              Expanded(
                child: DsScreenEntrance(
                  child: _step == _LockSettingsStep.home
                      ? _Home(
                          enabled: state.enabled,
                          onToggle: (value) {
                            context.read<ParentAppLockCubit>().clearError();
                            setState(() {
                              _pending = '';
                              _step = value
                                  ? _LockSettingsStep.create
                                  : _LockSettingsStep.disable;
                            });
                          },
                          onChange: () {
                            context.read<ParentAppLockCubit>().clearError();
                            setState(() {
                              _pending = '';
                              _step = _LockSettingsStep.currentForChange;
                            });
                          },
                        )
                      // Same layout as the lock gate: the keypad drops toward
                      // the thumb zone; still scrolls on short screens.
                      : LayoutBuilder(
                          builder: (context, constraints) {
                            final padding = EdgeInsets.only(
                              top: 18,
                              bottom:
                                  12 + MediaQuery.of(context).padding.bottom,
                            );
                            return SingleChildScrollView(
                              padding: padding,
                              child: ConstrainedBox(
                                constraints: BoxConstraints(
                                  minHeight:
                                      (constraints.maxHeight - padding.vertical)
                                          .clamp(0.0, double.infinity),
                                ),
                                child: IntrinsicHeight(
                                  child: ParentPinPad(
                                    fillHeight: true,
                                    title: _title(s),
                                    error: parentAppLockErrorText(
                                      s,
                                      state.error,
                                    ),
                                    enabled: !state.busy,
                                    clearToken: Object.hash(_step, state.error),
                                    onCompleted: _onPin,
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  String _title(S s) {
    return switch (_step) {
      _LockSettingsStep.home => s.appLock,
      _LockSettingsStep.create => s.appLockCreatePin,
      _LockSettingsStep.confirmCreate => s.appLockConfirmPin,
      _LockSettingsStep.currentForChange => s.appLockCurrentPin,
      _LockSettingsStep.enterNew => s.appLockNewPin,
      _LockSettingsStep.confirmNew => s.appLockConfirmNewPin,
      _LockSettingsStep.disable => s.appLockCurrentPin,
    };
  }
}

class _Home extends StatelessWidget {
  const _Home({
    required this.enabled,
    required this.onToggle,
    required this.onChange,
  });

  final bool enabled;
  final ValueChanged<bool> onToggle;
  final VoidCallback onChange;

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);

    return ListView(
      physics: const BouncingScrollPhysics(),
      padding: EdgeInsets.only(
        bottom: 40 + MediaQuery.viewPaddingOf(context).bottom,
      ),
      children: [
        DsOverline(s.sectionApp, top: 14),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.gutter),
          child: DsGroup(
            radius: AppRadius.card,
            shadow: AppShadows.flat,
            children: [
              DsRow(
                title: s.appLock,
                subtitle: s.appLockSubtitle,
                verticalPadding: 14,
                trailing: DsSwitch(
                  key: const ValueKey('app-lock-toggle'),
                  value: enabled,
                  onChanged: onToggle,
                ),
              ),
              if (enabled)
                DsRow(
                  onTap: onChange,
                  title: s.appLockChange,
                  verticalPadding: 15,
                  trailing: AppIcons.chevronRight(),
                ),
            ],
          ),
        ),
        DsFootnote(enabled ? s.appLockForgot : s.appLockOffHint, top: 10),
      ],
    );
  }
}
