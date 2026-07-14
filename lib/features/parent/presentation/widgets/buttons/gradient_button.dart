import 'package:flutter/material.dart';
import 'package:safini/core/theme/app_colors.dart';
import 'package:safini/core/theme/app_radius.dart';
import 'package:safini/core/utils/extension/theme_extension.dart';

/// A full-width brand-gradient action button with a built-in loading state.
///
/// Presentation-only: it renders [label] (or a spinner when [isLoading]) and
/// calls [onTap]. Dims itself when not [isEnabled].
class GradientButton extends StatelessWidget {
  final String label;
  final bool isLoading;
  final bool isEnabled;
  final VoidCallback? onTap;

  const GradientButton({
    super.key,
    required this.label,
    required this.isLoading,
    required this.isEnabled,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: isEnabled ? 1.0 : 0.55,
      child: Container(
        decoration: BoxDecoration(
          gradient: AppColors.brandGradient,
          borderRadius: BorderRadius.circular(AppRadius.lg),
        ),
        child: Material(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(AppRadius.lg),
          child: InkWell(
            borderRadius: BorderRadius.circular(AppRadius.lg),
            onTap: onTap,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 16),
              alignment: Alignment.center,
              child: isLoading
                  ? const SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2.5,
                      ),
                    )
                  : Text(
                      label,
                      style: context.textTheme.titleMedium?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.3,
                      ),
                    ),
            ),
          ),
        ),
      ),
    );
  }
}
