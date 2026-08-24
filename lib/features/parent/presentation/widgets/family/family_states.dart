import 'package:flutter/material.dart';
import 'package:safini/core/theme/app_colors.dart';
import 'package:safini/core/theme/app_radius.dart';
import 'package:safini/core/theme/app_shadows.dart';
import 'package:safini/core/theme/app_typography.dart';
import 'package:safini/core/translation/generated/l10n.dart';
import 'package:safini/core/utils/widgets/ds/ds.dart';

/// No family on the account: the two doors from the Welcome artboard, as a
/// card rather than a full screen.
class FamilyEmptyState extends StatelessWidget {
  const FamilyEmptyState({
    super.key,
    required this.onCreate,
    required this.onJoin,
  });

  final VoidCallback onCreate;
  final VoidCallback onJoin;

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);

    return DsCard(
      shadow: AppShadows.flat,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 26),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            s.noFamilySetupYet,
            style: AppText.headline,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 6),
          Text(
            s.createOrJoinFamily,
            style: AppText.meta,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          DsPrimaryButton(label: s.createFamilyAction, onTap: onCreate),
          const SizedBox(height: 9),
          DsPrimaryButton.secondary(label: s.joinFamilyAction, onTap: onJoin),
        ],
      ),
    );
  }
}

class EmptyChildrenState extends StatelessWidget {
  const EmptyChildrenState({super.key, required this.onAddChild});

  final VoidCallback onAddChild;

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);

    return DsCard(
      shadow: AppShadows.flat,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 26),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            s.noChildrenFoundYet,
            style: AppText.rowTitleStrong,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
          Text(
            s.inviteChildOrRefresh,
            style: AppText.meta,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 18),
          DsPrimaryButton(label: s.addChild, onTap: onAddChild),
        ],
      ),
    );
  }
}

/// Refresh failed but the cached family is still on screen.
class InlineErrorBanner extends StatelessWidget {
  const InlineErrorBanner({super.key, required this.message, this.onRetry});

  final String message;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.warnBg,
        borderRadius: BorderRadius.circular(AppRadius.card),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              message,
              style: AppText.metaSm.copyWith(color: AppColors.warnFg),
            ),
          ),
          if (onRetry != null) ...[
            const SizedBox(width: 12),
            Pressable(
              onTap: onRetry,
              scale: 0.96,
              child: Text(
                S.of(context).retry,
                style: AppText.link.copyWith(color: AppColors.warnFg),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class FamilyErrorState extends StatelessWidget {
  const FamilyErrorState({
    super.key,
    required this.message,
    required this.canRetry,
    required this.onRetry,
    required this.onCreate,
    required this.onJoin,
  });

  final String message;
  final bool canRetry;
  final VoidCallback onRetry;
  final VoidCallback onCreate;
  final VoidCallback onJoin;

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);

    return DsCard(
      shadow: AppShadows.flat,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 26),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            message,
            style: AppText.rowTitleStrong,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          if (canRetry) ...[
            DsPrimaryButton(label: s.tryAgain, onTap: onRetry),
            const SizedBox(height: 9),
          ],
          DsPrimaryButton.secondary(label: s.createFamilyAction, onTap: onCreate),
          const SizedBox(height: 9),
          DsPrimaryButton.secondary(label: s.joinFamilyAction, onTap: onJoin),
        ],
      ),
    );
  }
}
