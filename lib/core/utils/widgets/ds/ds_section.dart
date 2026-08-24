import 'package:flutter/material.dart';
import 'package:safini/core/theme/app_colors.dart';
import 'package:safini/core/theme/app_spacing.dart';
import 'package:safini/core/theme/app_typography.dart';
import 'package:safini/core/utils/widgets/ds/pressable.dart';

/// `padding:30px 22px 10px` with a 20/w700 heading on the left and an optional
/// purple action or count on the right, baseline-aligned.
class DsSectionHeader extends StatelessWidget {
  const DsSectionHeader({
    super.key,
    required this.title,
    this.trailing,
    this.trailingText,
    this.onTrailingTap,
    this.top = AppSpacing.sectionTop,
    this.bottom = AppSpacing.sectionBottom,
  });

  final String title;
  final Widget? trailing;
  final String? trailingText;
  final VoidCallback? onTrailingTap;
  final double top;
  final double bottom;

  @override
  Widget build(BuildContext context) {
    Widget? side = trailing;
    if (side == null && trailingText != null) {
      final label = Text(
        trailingText!,
        style: onTrailingTap == null
            ? AppText.metaSm.copyWith(
                fontWeight: FontWeight.w600,
                color: AppColors.primary,
              ).nums
            : AppText.link,
      );
      side = onTrailingTap == null
          ? label
          : Pressable(onTap: onTrailingTap, scale: 0.96, child: label);
    }

    return Padding(
      padding: EdgeInsets.fromLTRB(
        AppSpacing.headingGutter,
        top,
        AppSpacing.headingGutter,
        bottom,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.baseline,
        textBaseline: TextBaseline.alphabetic,
        children: [
          Expanded(child: Text(title, style: AppText.section)),
          if (side != null) ...[const SizedBox(width: 12), side],
        ],
      ),
    );
  }
}

/// `font-size:12px;font-weight:640;letter-spacing:.06em;text-transform:uppercase`
/// - the quiet label above a grouped list.
class DsOverline extends StatelessWidget {
  const DsOverline(
    this.text, {
    super.key,
    this.trailing,
    this.top = 28,
    this.bottom = 10,
    this.color = AppColors.textTertiary,
  });

  final String text;
  final Widget? trailing;
  final double top;
  final double bottom;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final label = Text(
      text.toUpperCase(),
      style: AppText.overline.copyWith(color: color),
    );

    return Padding(
      padding: EdgeInsets.fromLTRB(
        AppSpacing.headingGutter,
        top,
        AppSpacing.headingGutter,
        bottom,
      ),
      child: trailing == null
          ? label
          : Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [Flexible(child: label), trailing!],
            ),
    );
  }
}

/// The same overline without the screen-level gutter padding, for use inside a
/// card or sheet panel.
class DsOverlineText extends StatelessWidget {
  const DsOverlineText(
    this.text, {
    super.key,
    this.color = AppColors.textTertiary,
  });

  final String text;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Text(
      text.toUpperCase(),
      style: AppText.overline.copyWith(color: color),
    );
  }
}

/// The grey explanatory line that sits under a card: 13/1.45/#A09EAA at the
/// card gutter plus 6.
class DsFootnote extends StatelessWidget {
  const DsFootnote(this.text, {super.key, this.top = 14, this.bottom = 0});

  final String text;
  final double top;
  final double bottom;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
        AppSpacing.gutter + 6,
        top,
        AppSpacing.gutter + 6,
        bottom,
      ),
      child: Text(text, style: AppText.footnote),
    );
  }
}
