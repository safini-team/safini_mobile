import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:safini/core/theme/app_colors.dart';
import 'package:safini/core/theme/app_radius.dart';
import 'package:safini/core/theme/app_shadows.dart';
import 'package:safini/core/theme/app_spacing.dart';
import 'package:safini/core/theme/app_typography.dart';
import 'package:safini/core/translation/generated/l10n.dart';
import 'package:safini/core/utils/widgets/ds/ds.dart';
import 'package:safini/core/version_gate/hard_update_gate.dart';
import 'package:safini/core/version_gate/version_gate_cubit.dart';
import 'package:safini/core/version_gate/version_gate_state.dart';

/// Persistent dismissible banner. Not a modal; stays until Update or Not now.
class SoftUpdateBanner extends StatelessWidget {
  const SoftUpdateBanner({super.key});

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    return BlocBuilder<VersionGateCubit, VersionGateState>(
      builder: (context, state) {
        final message = state.policy?.message;
        final locale = Localizations.localeOf(context);
        final title = versionGateCopy(
          message?.softTitle,
          s.updateSoftTitle,
          locale,
        );
        final body = versionGateCopy(
          message?.softBody,
          s.updateSoftBody,
          locale,
        );

        return Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.gutter,
            8,
            AppSpacing.gutter,
            0,
          ),
          child: Material(
            color: Colors.transparent,
            child: Container(
              key: const ValueKey('version-gate-soft-banner'),
              padding: const EdgeInsets.fromLTRB(16, 14, 10, 14),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(AppRadius.card),
                boxShadow: AppShadows.card,
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(title, style: AppText.rowTitleStrong),
                        const SizedBox(height: 2),
                        Text(body, style: AppText.meta),
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            DsInlineButton(
                              key: const ValueKey('version-gate-soft-update'),
                              label: s.updateCta,
                              onTap: state.openingStore
                                  ? null
                                  : () => context
                                        .read<VersionGateCubit>()
                                        .openStore(),
                            ),
                            const SizedBox(width: 8),
                            DsInlineButton.quiet(
                              key: const ValueKey('version-gate-soft-dismiss'),
                              label: s.updateDismiss,
                              onTap: () => context
                                  .read<VersionGateCubit>()
                                  .dismissSoft(),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Pressable(
                    onTap: () => context.read<VersionGateCubit>().dismissSoft(),
                    child: Padding(
                      padding: const EdgeInsets.all(6),
                      child: Semantics(
                        label: s.updateDismiss,
                        button: true,
                        child: AppIcons.close(size: 14),
                      ),
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
}
