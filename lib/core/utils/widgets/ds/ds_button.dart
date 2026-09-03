import 'package:flutter/material.dart';
import 'package:safini/core/theme/app_colors.dart';
import 'package:safini/core/theme/app_radius.dart';
import 'package:safini/core/theme/app_shadows.dart';
import 'package:safini/core/theme/app_typography.dart';
import 'package:safini/core/utils/widgets/ds/app_icons.dart';
import 'package:safini/core/utils/widgets/ds/pressable.dart';

/// `padding:17px;border-radius:18px;background:#1A5C4A;color:#fff;17/640/-.01em`
/// plus the purple glow. Press scales to `.975`.
class DsPrimaryButton extends StatelessWidget {
  const DsPrimaryButton({
    super.key,
    required this.label,
    this.onTap,
    this.icon,
    this.enabled = true,
    this.background = AppColors.primary,
    this.foreground = AppColors.textOnPrimary,
    this.shadow = AppShadows.primaryGlow,
    this.padding = const EdgeInsets.all(17),
    this.radius = AppRadius.button,
    this.busy = false,
  });

  /// `background:#EFEBE3;color:#0C231C;font-weight:600` - the quiet twin that
  /// always sits under the primary one.
  const DsPrimaryButton.secondary({
    super.key,
    required this.label,
    this.onTap,
    this.icon,
    this.enabled = true,
    this.padding = const EdgeInsets.all(17),
    this.radius = AppRadius.button,
    this.busy = false,
  }) : background = AppColors.fill,
       foreground = AppColors.ink,
       shadow = const <BoxShadow>[];

  final String label;
  final VoidCallback? onTap;
  final Widget? icon;
  final bool enabled;
  final Color background;
  final Color foreground;
  final List<BoxShadow> shadow;
  final EdgeInsets padding;
  final double radius;
  final bool busy;

  @override
  Widget build(BuildContext context) {
    final live = enabled && !busy && onTap != null;
    final bg = live ? background : AppColors.fill;
    final fg = live ? foreground : AppColors.textTertiary;

    return Pressable(
      onTap: live ? onTap : null,
      scale: 0.975,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: padding,
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(radius),
          boxShadow: live ? shadow : const [],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (busy)
              SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2.2, color: fg),
              )
            else ...[
              if (icon != null) ...[icon!, const SizedBox(width: 8)],
              Flexible(
                child: Text(
                  label,
                  textAlign: TextAlign.center,
                  style: AppText.button.copyWith(color: fg),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// The paired inline buttons inside a review row:
/// `flex:1;padding:10px;border-radius:13px;14.5/640`, press `.96`.
class DsInlineButton extends StatelessWidget {
  const DsInlineButton({
    super.key,
    required this.label,
    this.onTap,
    this.background = AppColors.primary,
    this.foreground = AppColors.textOnPrimary,
  });

  const DsInlineButton.quiet({super.key, required this.label, this.onTap})
    : background = AppColors.fill,
      foreground = AppColors.ink;

  final String label;
  final VoidCallback? onTap;
  final Color background;
  final Color foreground;

  @override
  Widget build(BuildContext context) {
    return Pressable(
      onTap: onTap,
      scale: 0.96,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
        decoration: BoxDecoration(
          color: background,
          borderRadius: BorderRadius.circular(AppRadius.action),
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: AppText.chip.copyWith(
            fontSize: 14.5,
            letterSpacing: -0.0725,
            color: foreground,
          ),
        ),
      ),
    );
  }
}

/// The red destructive row inside a settings card ("Sign out",
/// "Remove from family").
class DsDestructiveButton extends StatelessWidget {
  const DsDestructiveButton({
    super.key,
    required this.label,
    this.onTap,
    this.filled = true,
  });

  final String label;
  final VoidCallback? onTap;
  final bool filled;

  @override
  Widget build(BuildContext context) {
    final text = Text(
      label,
      textAlign: TextAlign.center,
      style: AppText.rowTitleStrong.copyWith(color: AppColors.danger),
    );

    if (!filled) {
      return Pressable(
        onTap: onTap,
        scale: 0.975,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 15),
          child: SizedBox(width: double.infinity, child: text),
        ),
      );
    }

    return Pressable(
      onTap: onTap,
      scale: 0.985,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppRadius.card),
          boxShadow: AppShadows.flat,
        ),
        child: text,
      ),
    );
  }
}

/// The floating "New task" pill: `right:18;bottom:104` with the fab glow.
class DsFloatingAction extends StatelessWidget {
  const DsFloatingAction({
    super.key,
    required this.label,
    required this.icon,
    this.onTap,
  });

  final String label;
  final Widget icon;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Pressable(
      onTap: onTap,
      scale: 0.96,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        decoration: BoxDecoration(
          color: AppColors.primary,
          borderRadius: BorderRadius.circular(AppRadius.pill),
          boxShadow: AppShadows.fabGlow,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            icon,
            const SizedBox(width: 8),
            Text(
              label,
              style: AppText.chip.copyWith(
                fontSize: 15.5,
                letterSpacing: -0.124,
                color: AppColors.textOnPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// The two doors on the Welcome artboard: a full-width card with a title, a
/// sub-line and a chevron. `filled` is the purple primary door.
class DsChoiceCard extends StatelessWidget {
  const DsChoiceCard({
    super.key,
    required this.title,
    required this.subtitle,
    this.onTap,
    this.filled = false,
  });

  final String title;
  final String subtitle;
  final VoidCallback? onTap;
  final bool filled;

  @override
  Widget build(BuildContext context) {
    final fg = filled ? AppColors.textOnPrimary : AppColors.ink;
    final subFg = filled
        ? const Color(0xB8FFFFFF)
        : AppColors.textSecondary;

    return Pressable(
      onTap: onTap,
      scale: 0.975,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 19),
        decoration: BoxDecoration(
          color: filled ? AppColors.primary : AppColors.fill,
          borderRadius: BorderRadius.circular(AppRadius.card),
          boxShadow: filled ? AppShadows.primaryGlow : const [],
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(title, style: AppText.button.copyWith(color: fg)),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: AppText.metaSm.copyWith(
                      fontSize: 13.5,
                      letterSpacing: 0.0675,
                      color: subFg,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            AppIcons.chevronRight(
              size: 16,
              color: filled ? const Color(0xD9FFFFFF) : AppColors.textTertiary,
            ),
          ],
        ),
      ),
    );
  }
}
