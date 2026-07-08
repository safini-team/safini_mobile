import 'package:flutter/material.dart';
import 'package:safini/core/theme/app_radius.dart';
import 'package:safini/core/utils/extension/theme_extension.dart';

/// A single, tappable face-emoji sticker shown in the avatar picker grid.
///
/// Reusable and presentation-only: it renders one emoji and reports taps
/// through [onTap]. The parent decides which sticker is [selected].
class FaceStickerCard extends StatelessWidget {
  /// The emoji rendered inside the card.
  final String emoji;

  /// Whether this sticker is the currently equipped one.
  final bool selected;

  /// Called when the child taps the sticker.
  final VoidCallback onTap;

  const FaceStickerCard({
    super.key,
    required this.emoji,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final primary = context.colorScheme.primary;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        curve: Curves.easeOut,
        decoration: BoxDecoration(
          color: primary.withValues(alpha: selected ? 0.15 : 0.04),
          borderRadius: BorderRadius.circular(AppRadius.lg),
          border: Border.all(
            color: selected ? primary : Colors.transparent,
            width: 2,
          ),
        ),
        child: Center(
          // Sized from the global text theme so emoji scale stays consistent
          // app-wide and can be tuned in one place.
          child: Text(emoji, style: context.textTheme.headlineMedium),
        ),
      ),
    );
  }
}
