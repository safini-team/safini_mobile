import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:safini/core/theme/app_colors.dart';
import 'package:safini/core/theme/app_radius.dart';
import 'package:safini/core/theme/app_spacing.dart';
import 'package:safini/core/theme/app_typography.dart';
import 'package:safini/core/translation/generated/l10n.dart';
import 'package:safini/core/utils/widgets/ds/ds.dart';
import 'package:safini/core/version_gate/version_gate_cubit.dart';
import 'package:safini/core/version_gate/version_gate_state.dart';

String versionGateCopy(String? remote, String localized) {
  final value = remote?.trim();
  if (value == null || value.isEmpty) return localized;
  return value;
}

/// Non-dismissible full-screen hard gate. Same surface for parent and child.
class HardUpdateGate extends StatelessWidget {
  const HardUpdateGate({super.key});

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    return BlocBuilder<VersionGateCubit, VersionGateState>(
      builder: (context, state) {
        final message = state.policy?.message;
        final title = versionGateCopy(message?.hardTitle, s.updateHardTitle);
        final body = versionGateCopy(message?.hardBody, s.updateHardBody);

        return PopScope(
          canPop: false,
          child: Material(
            color: AppColors.bgParent,
            child: AnnotatedRegion<SystemUiOverlayStyle>(
              value: SystemUiOverlayStyle.dark.copyWith(
                statusBarColor: Colors.transparent,
                statusBarBrightness: Brightness.light,
              ),
              child: SafeArea(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.gutter,
                    28,
                    AppSpacing.gutter,
                    16,
                  ),
                  child: Column(
                    children: [
                      const Spacer(),
                      Container(
                        width: 64,
                        height: 64,
                        decoration: BoxDecoration(
                          color: AppColors.primaryTint,
                          borderRadius: BorderRadius.circular(AppRadius.icon),
                        ),
                        child: const Icon(
                          Icons.system_update_alt_rounded,
                          color: AppColors.primary,
                          size: 30,
                        ),
                      ),
                      const SizedBox(height: 22),
                      Text(
                        title,
                        textAlign: TextAlign.center,
                        style: AppText.title3,
                      ),
                      const SizedBox(height: 10),
                      Text(
                        body,
                        textAlign: TextAlign.center,
                        style: AppText.bodyRegular,
                      ),
                      const Spacer(),
                      DsPrimaryButton(
                        key: const ValueKey('version-gate-hard-update'),
                        label: s.updateCta,
                        busy: state.openingStore,
                        onTap: () =>
                            context.read<VersionGateCubit>().openStore(),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        state.installedVersion.isEmpty
                            ? ''
                            : state.installedVersion,
                        style: AppText.caption.copyWith(
                          color: AppColors.textTertiary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
