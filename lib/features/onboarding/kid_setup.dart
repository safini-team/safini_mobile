import 'package:flutter/material.dart';
import 'package:safini/core/theme/app_colors.dart';
import 'package:safini/core/theme/app_radius.dart';
import 'package:safini/core/theme/app_typography.dart';
import 'package:safini/core/translation/generated/l10n.dart';
import 'package:safini/core/utils/widgets/ds/ds.dart';
import 'package:safini/features/child/presentation/cubit/app_block_state.dart';
import 'package:safini/features/onboarding/fini.dart';

enum KidPermission { usage, overlay, admin }

/// The Android permissions a kid's phone needs, one per screen with Fini
/// saying why. Coming back from Settings re-checks (the gate calls
/// `onResumed`), so a granted step just moves on.
class KidSetup extends StatelessWidget {
  const KidSetup({
    super.key,
    required this.state,
    required this.onRequest,
    required this.onCheck,
    required this.onBattery,
  });

  final AppBlockState state;
  final ValueChanged<KidPermission> onRequest;
  final VoidCallback onCheck;
  final VoidCallback onBattery;

  bool _granted(KidPermission p) => switch (p) {
    KidPermission.usage => state.hasUsageAccess,
    KidPermission.overlay => state.hasOverlayPermission,
    KidPermission.admin => state.hasDeviceAdmin,
  };

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final steps = KidPermission.values;
    final current = steps.where((p) => !_granted(p)).firstOrNull;
    final done = steps.where(_granted).length;
    final failed = state.status == AppBlockStatus.error;

    return Scaffold(
      backgroundColor: AppColors.bgChild,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(22, 14, 22, 18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  const _PhoneBadge(),
                  const Spacer(),
                  Text(
                    s.kidSetupStepOf(
                      (current == null ? done : done + 1).clamp(1, 3),
                      steps.length,
                    ),
                    style: AppText.meta,
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  for (final p in steps) ...[
                    if (p != steps.first) const SizedBox(width: 6),
                    Expanded(
                      child: DsProgressBar(
                        progress: _granted(p) ? 1 : (p == current ? 0.35 : 0),
                        height: 6,
                        color: _granted(p)
                            ? AppColors.success
                            : AppColors.primary,
                      ),
                    ),
                  ],
                ],
              ),
              Expanded(
                child: Center(
                  child: SingleChildScrollView(
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 280),
                      child: Column(
                        key: ValueKey('${current?.name}-$failed'),
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          FiniSays(
                            size: 112,
                            cheer: current == null && !failed,
                            text: current == null
                                ? (failed
                                      ? s.limitsSetupError
                                      : s.kidSetupAlmost)
                                : _why(s, current),
                          ),
                          const SizedBox(height: 22),
                          if (current != null) ...[
                            Text(_title(s, current), style: AppText.title1),
                            const SizedBox(height: 8),
                            Text(
                              current == KidPermission.admin
                                  ? s.kidSetupHintAdmin
                                  : s.kidSetupHintList,
                              style: AppText.bodyRegular,
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              if (current != null)
                DsPrimaryButton(
                  key: const ValueKey('kid-setup-go'),
                  label: s.kidSetupGo,
                  onTap: () => onRequest(current),
                ),
              if (current != null) const SizedBox(height: 9),
              DsPrimaryButton.secondary(
                key: const ValueKey('kid-setup-check'),
                label: s.limitsRetry,
                busy: state.isChecking,
                onTap: onCheck,
              ),
              const SizedBox(height: 4),
              TextButton(
                onPressed: onBattery,
                child: Text(
                  s.kidSetupBatteryLink,
                  style: AppText.meta.copyWith(color: AppColors.primary),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  static String _title(S s, KidPermission p) => switch (p) {
    KidPermission.usage => s.limitsUsageAccess,
    KidPermission.overlay => s.limitsOverlayAccess,
    KidPermission.admin => s.limitsDeviceAdmin,
  };

  static String _why(S s, KidPermission p) => switch (p) {
    KidPermission.usage => s.finiWhyUsage,
    KidPermission.overlay => s.finiWhyOverlay,
    KidPermission.admin => s.finiWhyAdmin,
  };
}

/// "Kid's phone" in amber, so a parent setting up both phones at once can
/// tell which one is in their hand.
class _PhoneBadge extends StatelessWidget {
  const _PhoneBadge();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: AppColors.coinPillBg,
        borderRadius: BorderRadius.circular(AppRadius.pill),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.smartphone_rounded,
            size: 14,
            color: AppColors.coinPillFg,
          ),
          const SizedBox(width: 5),
          Text(
            S.of(context).kidSetupBadge,
            style: AppText.chip.copyWith(color: AppColors.coinPillFg),
          ),
        ],
      ),
    );
  }
}

/// Samsung and Xiaomi kill background apps; this is what to change there.
Future<void> showKidBatteryTips(
  BuildContext context, {
  required VoidCallback onOpenSettings,
}) {
  return showDsSheet<void>(
    context: context,
    builder: (sheetContext) {
      final s = S.of(sheetContext);
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          FiniSays(size: 72, text: s.limitsBatteryHint),
          const SizedBox(height: 20),
          DsPrimaryButton(
            label: s.limitsBattery,
            onTap: () {
              Navigator.of(sheetContext).pop();
              onOpenSettings();
            },
          ),
        ],
      );
    },
  );
}
