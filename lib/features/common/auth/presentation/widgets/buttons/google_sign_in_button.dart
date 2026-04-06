import 'package:flutter/material.dart';
import 'package:safini/core/utils/extension/theme_extension.dart';

class GoogleSignInButton extends StatelessWidget {
  const GoogleSignInButton({
    required this.label,
    required this.loadingLabel,
    required this.onPressed,
    this.isLoading = false,
    super.key,
  });

  final String label;
  final String loadingLabel;
  final VoidCallback? onPressed;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: OutlinedButton.icon(
        onPressed: isLoading ? null : onPressed,
        style: OutlinedButton.styleFrom(
          backgroundColor: Colors.white,
          foregroundColor: context.colorScheme.onSurface,
          side: BorderSide(
            color: context.colorScheme.outline.withValues(alpha: 0.4),
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        icon: isLoading
            ? SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: context.colorScheme.primary,
                ),
              )
            : Icon(
                Icons.login_rounded,
                color: context.colorScheme.primary,
              ),
        label: Text(
          isLoading ? loadingLabel : label,
          style: context.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
