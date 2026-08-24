import 'package:flutter/material.dart';
import 'package:safini/core/theme/app_colors.dart';
import 'package:safini/core/theme/app_shadows.dart';
import 'package:safini/core/theme/app_typography.dart';
import 'package:safini/core/translation/generated/l10n.dart';
import 'package:safini/core/utils/widgets/ds/ds.dart';

/// The artboard's reward sheet: big emoji, name, the price pill, a line of
/// blurb, then either "Ask for this" or how many coins are still missing.
Future<bool?> showRewardSheet(
  BuildContext context, {
  required String emoji,
  required String name,
  required int cost,
  required int coins,
  required String blurb,
}) {
  final canBuy = coins >= cost;
  final toGo = (cost - coins).clamp(0, cost);

  return showDsSheet<bool>(
    context: context,
    builder: (context) {
      final s = S.of(context);
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            emoji,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 52),
          ),
          const SizedBox(height: 12),
          Text(name, textAlign: TextAlign.center, style: AppText.title3),
          const SizedBox(height: 12),
          Center(
            child: DsPill.coins(
              label: s.coinCountShort(cost),
              height: 30,
              fontSize: 15,
              horizontalPadding: 14,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            blurb,
            textAlign: TextAlign.center,
            style: AppText.bodyRegular.copyWith(fontSize: 15),
          ),
          const SizedBox(height: 22),
          DsPrimaryButton(
            label: canBuy ? s.askForThis : s.coinsToGo(toGo),
            enabled: canBuy,
            shadow: canBuy ? AppShadows.primaryGlowLg : const [],
            onTap: () => Navigator.of(context).pop(true),
          ),
          const SizedBox(height: 9),
          Pressable(
            onTap: () => Navigator.of(context).pop(false),
            scale: 0.975,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 15),
              child: Text(
                s.notYet,
                textAlign: TextAlign.center,
                style: AppText.rowTitleStrong.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ),
          ),
        ],
      );
    },
  );
}
