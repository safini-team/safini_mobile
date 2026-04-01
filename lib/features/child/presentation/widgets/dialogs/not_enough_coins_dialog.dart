import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:safini/core/theme/app_radius.dart';
import 'package:safini/core/utils/extension/theme_extension.dart';

class NotEnoughCoinsDialog extends StatelessWidget {
  final int missingCoins;
  final VoidCallback onDismiss;

  const NotEnoughCoinsDialog({
    super.key,
    required this.missingCoins,
    required this.onDismiss,
  });

  static Future<void> show(
    BuildContext context, {
    required int missingCoins,
    required VoidCallback onDismiss,
  }) {
    return showDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (_) => NotEnoughCoinsDialog(
        missingCoins: missingCoins,
        onDismiss: onDismiss,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: context.colorScheme.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.xl),
      ),
      title: Text(
        'Not enough coins!',
        style: context.textTheme.headlineSmall?.copyWith(
          fontWeight: FontWeight.w700,
          color: context.colorScheme.onSurface,
        ),
      ),
      content: Text(
        'You need $missingCoins more coins.',
        style: context.textTheme.bodyMedium?.copyWith(
          color: context.colorScheme.onSurface.withValues(alpha: 0.65),
        ),
      ),
      actions: [
        const Divider(height: 1),
        TextButton(
          onPressed: () {
            context.router.maybePop();
            onDismiss();
          },
          child: Center(
            child: Text(
              'OK',
              style: context.textTheme.labelLarge?.copyWith(
                color: context.colorScheme.onSurface.withValues(alpha: 0.7),
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ),
      ],
      actionsAlignment: MainAxisAlignment.center,
      actionsPadding: EdgeInsets.zero,
    );
  }
}
