import 'package:flutter/material.dart';
import 'package:safini/core/theme/app_colors.dart';
import 'package:safini/core/theme/app_motion.dart';
import 'package:safini/core/theme/app_radius.dart';
import 'package:safini/core/theme/app_shadows.dart';
import 'package:safini/core/theme/app_typography.dart';
import 'package:safini/core/utils/widgets/ds/ds_avatar.dart';
import 'package:safini/core/utils/widgets/ds/pressable.dart';

/// The kid scope chip on Parent Today / Tasks / Limits.
///
/// Selected: `background:#fff` with `0 0 0 1.5px #8100D1` ring + lift shadow.
/// Rest: `rgba(23,21,28,.05)`, no ring, `#6C6A75` label.
class DsKidChip extends StatelessWidget {
  const DsKidChip({
    super.key,
    required this.name,
    required this.selected,
    this.color = AppColors.primary,
    this.initial,
    this.showAvatar = true,
    this.onTap,
    this.avatarSize = 28,
  });

  final String name;
  final bool selected;
  final Color color;
  final String? initial;
  final bool showAvatar;
  final VoidCallback? onTap;
  final double avatarSize;

  @override
  Widget build(BuildContext context) {
    return Pressable(
      onTap: onTap,
      scale: 0.97,
      child: AnimatedContainer(
        duration: AppMotion.tint,
        curve: AppMotion.ease,
        padding: EdgeInsets.fromLTRB(showAvatar ? 7 : 15, 7, 15, 7),
        decoration: BoxDecoration(
          color: selected ? AppColors.surface : AppColors.chipRest,
          borderRadius: BorderRadius.circular(AppRadius.pill),
          border: selected
              ? Border.all(color: AppColors.primary, width: 1.5)
              : null,
          boxShadow: selected ? AppShadows.chipSelected : const [],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (showAvatar) ...[
              DsInitialAvatar(
                name: initial ?? name,
                color: color,
                size: avatarSize,
              ),
              const SizedBox(width: 9),
            ],
            Text(
              name,
              style: AppText.chip.copyWith(
                color: selected ? AppColors.ink : AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Category chip on Kid Tasks and the New task sheet:
/// selected fills with purple, rest is `rgba(23,21,28,.05)` / `#F2F0F6`.
class DsCategoryChip extends StatelessWidget {
  const DsCategoryChip({
    super.key,
    required this.label,
    required this.selected,
    this.emoji,
    this.onTap,
    this.restBackground = AppColors.chipRest,
    this.padding = const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
    this.fontSize = 14,
  });

  final String label;
  final bool selected;
  final String? emoji;
  final VoidCallback? onTap;
  final Color restBackground;
  final EdgeInsets padding;
  final double fontSize;

  @override
  Widget build(BuildContext context) {
    return Pressable(
      onTap: onTap,
      scale: 0.96,
      child: AnimatedContainer(
        duration: AppMotion.tint,
        curve: AppMotion.ease,
        padding: padding,
        decoration: BoxDecoration(
          color: selected ? AppColors.primary : restBackground,
          borderRadius: BorderRadius.circular(AppRadius.pill),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (emoji != null) ...[
              Text(emoji!, style: TextStyle(fontSize: fontSize, height: 1.2)),
              const SizedBox(width: 7),
            ],
            Text(
              label,
              style: TextStyle(
                fontSize: fontSize,
                fontWeight: FontWeight.w600,
                letterSpacing: -0.056,
                height: 1.2,
                color: selected
                    ? AppColors.textOnPrimary
                    : AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Horizontally scrolling chip strip: `padding:18px 20px 0;gap:8px`.
class DsChipStrip extends StatelessWidget {
  const DsChipStrip({
    super.key,
    required this.children,
    this.padding = const EdgeInsets.fromLTRB(20, 18, 20, 0),
    this.gap = 8,
  });

  final List<Widget> children;
  final EdgeInsets padding;
  final double gap;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: padding,
      physics: const BouncingScrollPhysics(),
      child: Row(
        children: [
          for (var i = 0; i < children.length; i++) ...[
            if (i > 0) SizedBox(width: gap),
            children[i],
          ],
        ],
      ),
    );
  }
}
