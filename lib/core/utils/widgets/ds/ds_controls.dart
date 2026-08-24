import 'package:flutter/material.dart';
import 'package:safini/core/theme/app_colors.dart';
import 'package:safini/core/theme/app_motion.dart';
import 'package:safini/core/theme/app_radius.dart';
import 'package:safini/core/theme/app_typography.dart';
import 'package:safini/core/utils/widgets/ds/pressable.dart';

/// `padding:3px;background:rgba(23,21,28,.06);border-radius:12px` with a white
/// 9px-radius thumb carrying `0 1px 3px rgba(23,21,28,.12)`.
class DsSegmentedControl extends StatelessWidget {
  const DsSegmentedControl({
    super.key,
    required this.labels,
    required this.selectedIndex,
    required this.onChanged,
  });

  final List<String> labels;
  final int selectedIndex;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: AppColors.segmentTrack,
        borderRadius: BorderRadius.circular(AppRadius.md),
      ),
      child: Row(
        children: [
          for (var i = 0; i < labels.length; i++) ...[
            if (i > 0) const SizedBox(width: 4),
            Expanded(
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () => onChanged(i),
                child: AnimatedContainer(
                  duration: AppMotion.tint,
                  curve: AppMotion.spring,
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  decoration: BoxDecoration(
                    color: i == selectedIndex
                        ? AppColors.surface
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(AppRadius.xs),
                    boxShadow: i == selectedIndex
                        ? const [
                            BoxShadow(
                              color: Color(0x1F17151C),
                              offset: Offset(0, 1),
                              blurRadius: 3,
                            ),
                          ]
                        : const [],
                  ),
                  child: Text(
                    labels[i],
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 13.5,
                      fontWeight: FontWeight.w600,
                      letterSpacing: -0.04,
                      height: 1.2,
                      color: i == selectedIndex
                          ? AppColors.ink
                          : AppColors.textSecondary,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// iOS toggle at the design's exact geometry: 50×31 track, 27px knob,
/// `translateX(19px)` on 240ms spring.
class DsSwitch extends StatelessWidget {
  const DsSwitch({
    super.key,
    required this.value,
    this.onChanged,
    this.activeColor = AppColors.primary,
  });

  final bool value;
  final ValueChanged<bool>? onChanged;
  final Color activeColor;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onChanged == null ? null : () => onChanged!(!value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        curve: AppMotion.ease,
        width: 50,
        height: 31,
        padding: const EdgeInsets.all(2),
        decoration: BoxDecoration(
          color: value ? activeColor : AppColors.fillPressed,
          borderRadius: BorderRadius.circular(AppRadius.pill),
        ),
        child: AnimatedAlign(
          duration: AppMotion.toggle,
          curve: AppMotion.spring,
          alignment: value ? Alignment.centerRight : Alignment.centerLeft,
          child: Container(
            width: 27,
            height: 27,
            decoration: const BoxDecoration(
              color: AppColors.surface,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Color(0x33000000),
                  offset: Offset(0, 1),
                  blurRadius: 3,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// The −/+ stepper. Three skins in the design: light on a white card, deep on
/// the purple panel, and inset on a sheet's grey panel.
class DsStepper extends StatelessWidget {
  const DsStepper({
    super.key,
    this.onLess,
    this.onMore,
    this.width = 42,
    this.height = 32,
    this.radius = AppRadius.xs,
    this.background = AppColors.fill,
    this.pressedBackground = AppColors.fillPressed,
    this.foreground = AppColors.ink,
    this.dividerColor = const Color(0x1417151C),
    this.fontSize = 19,
  });

  /// On the deep-purple allowance panel: `rgba(255,255,255,.14)`, 44×38.
  const DsStepper.onDeep({super.key, this.onLess, this.onMore})
    : width = 44,
      height = 38,
      radius = AppRadius.md,
      background = const Color(0x24FFFFFF),
      pressedBackground = const Color(0x1AFFFFFF),
      foreground = AppColors.textOnPrimary,
      dividerColor = const Color(0x2EFFFFFF),
      fontSize = 20;

  /// Inside a sheet's `#F8F7FB` panel: `#EDEAF3`, 40×32.
  const DsStepper.onPanel({
    super.key,
    this.onLess,
    this.onMore,
    this.width = 40,
    this.height = 32,
  }) : radius = AppRadius.sm,
       background = AppColors.fillDeep,
       pressedBackground = AppColors.fillDeeper,
       foreground = AppColors.ink,
       dividerColor = const Color(0x1417151C),
       fontSize = 19;

  final VoidCallback? onLess;
  final VoidCallback? onMore;
  final double width;
  final double height;
  final double radius;
  final Color background;
  final Color pressedBackground;
  final Color foreground;
  final Color dividerColor;
  final double fontSize;

  @override
  Widget build(BuildContext context) {
    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(radius),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _Key(
            glyph: '−',
            onTap: onLess,
            width: width,
            height: height,
            foreground: foreground,
            pressedBackground: pressedBackground,
            fontSize: fontSize,
          ),
          Container(width: 1, height: height, color: dividerColor),
          _Key(
            glyph: '+',
            onTap: onMore,
            width: width,
            height: height,
            foreground: foreground,
            pressedBackground: pressedBackground,
            fontSize: fontSize,
          ),
        ],
      ),
    );
  }
}

class _Key extends StatefulWidget {
  const _Key({
    required this.glyph,
    required this.onTap,
    required this.width,
    required this.height,
    required this.foreground,
    required this.pressedBackground,
    required this.fontSize,
  });

  final String glyph;
  final VoidCallback? onTap;
  final double width;
  final double height;
  final Color foreground;
  final Color pressedBackground;
  final double fontSize;

  @override
  State<_Key> createState() => _KeyState();
}

class _KeyState extends State<_Key> {
  bool _down = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: widget.onTap,
      onTapDown: (_) => setState(() => _down = true),
      onTapUp: (_) => setState(() => _down = false),
      onTapCancel: () => setState(() => _down = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 90),
        width: widget.width,
        height: widget.height,
        alignment: Alignment.center,
        color: _down ? widget.pressedBackground : Colors.transparent,
        child: Text(
          widget.glyph,
          style: TextStyle(
            fontSize: widget.fontSize,
            color: widget.onTap == null
                ? widget.foreground.withValues(alpha: 0.4)
                : widget.foreground,
            height: 1,
          ),
        ),
      ),
    );
  }
}

/// The single-line grouped-list row: optional leading tile, title + meta, then
/// a pill and/or a chevron. `padding:14-15px 0`, press dims to `.5`.
class DsRow extends StatelessWidget {
  const DsRow({
    super.key,
    required this.title,
    this.subtitle,
    this.leading,
    this.trailing,
    this.onTap,
    this.titleStyle,
    this.subtitleStyle,
    this.verticalPadding = 14,
    this.gap = 13,
    this.titleColor,
  });

  final String title;
  final String? subtitle;
  final Widget? leading;
  final Widget? trailing;
  final VoidCallback? onTap;
  final TextStyle? titleStyle;
  final TextStyle? subtitleStyle;
  final double verticalPadding;
  final double gap;
  final Color? titleColor;

  @override
  Widget build(BuildContext context) {
    final row = Padding(
      padding: EdgeInsets.symmetric(vertical: verticalPadding),
      child: Row(
        children: [
          if (leading != null) ...[leading!, SizedBox(width: gap)],
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  title,
                  style: (titleStyle ?? AppText.rowTitle).copyWith(
                    color: titleColor,
                  ),
                ),
                if (subtitle != null) ...[
                  const SizedBox(height: 3),
                  Text(subtitle!, style: subtitleStyle ?? AppText.metaSm),
                ],
              ],
            ),
          ),
          if (trailing != null) ...[const SizedBox(width: 10), trailing!],
        ],
      ),
    );

    if (onTap == null) return row;
    return Pressable.row(onTap: onTap, child: row);
  }
}

/// A labelled field row inside a card or sheet panel:
/// `"Name"` at a fixed width, then the input filling the rest.
class DsFieldRow extends StatelessWidget {
  const DsFieldRow({
    super.key,
    required this.label,
    required this.child,
    this.labelWidth = 70,
    this.alignTop = false,
    this.verticalPadding = 14,
  });

  final String label;
  final Widget child;
  final double labelWidth;
  final bool alignTop;
  final double verticalPadding;

  /// The bare input styling the design uses inside these rows: no fill, no
  /// border, purple caret.
  static InputDecoration decoration(String hint) => InputDecoration(
    filled: false,
    isDense: true,
    border: InputBorder.none,
    enabledBorder: InputBorder.none,
    focusedBorder: InputBorder.none,
    contentPadding: EdgeInsets.zero,
    hintText: hint,
    hintStyle: AppText.rowTitleLg.copyWith(
      fontWeight: FontWeight.w400,
      color: AppColors.textTertiary,
    ),
  );

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: verticalPadding),
      child: Row(
        // Baseline, not centre. A row whose input carries a suffix button is
        // taller than one without, and centring put the label ~40px below the
        // text it labels - visible on the sign-in sheet, where Email lined up
        // and Password did not.
        crossAxisAlignment: alignTop
            ? CrossAxisAlignment.start
            : CrossAxisAlignment.baseline,
        textBaseline: TextBaseline.alphabetic,
        children: [
          Padding(
            padding: EdgeInsets.only(top: alignTop ? 2 : 0),
            child: SizedBox(
              width: labelWidth,
              child: Text(label, style: AppText.field),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(child: child),
        ],
      ),
    );
  }
}
