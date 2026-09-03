import 'package:flutter/material.dart';
import 'package:safini/core/theme/app_colors.dart';
import 'package:safini/core/theme/app_radius.dart';
import 'package:safini/core/theme/app_shadows.dart';
import 'package:safini/core/utils/widgets/ds/pressable.dart';

/// White card: `background:#fff;border-radius:22px;box-shadow:card`.
class DsCard extends StatelessWidget {
  const DsCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(18),
    this.radius = AppRadius.group,
    this.color = AppColors.surface,
    this.shadow = AppShadows.card,
    this.onTap,
    this.pressScale = 0.985,
    this.clip = false,
  });

  /// The deep-purple panel used for the pairing code, the daily allowance and
  /// the kid hero card: `background:#103B2F` with its own glow.
  const DsCard.deep({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(20),
    this.radius = AppRadius.feature,
    this.onTap,
    this.pressScale = 0.985,
    this.clip = false,
  }) : color = AppColors.primaryDeep,
       shadow = AppShadows.deep;

  final Widget child;
  final EdgeInsets padding;
  final double radius;
  final Color color;
  final List<BoxShadow> shadow;
  final VoidCallback? onTap;
  final double pressScale;
  final bool clip;

  @override
  Widget build(BuildContext context) {
    final card = Container(
      padding: padding,
      clipBehavior: clip ? Clip.antiAlias : Clip.none,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(radius),
        boxShadow: shadow,
      ),
      child: child,
    );

    if (onTap == null) return card;
    return Pressable(onTap: onTap, scale: pressScale, child: card);
  }
}

/// A hairline row divider: `1px solid rgba(23,21,28,.07)`.
class DsDivider extends StatelessWidget {
  const DsDivider({super.key, this.indent = 0, this.color = AppColors.divider});

  final double indent;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(left: indent),
      child: Container(height: 1, color: color),
    );
  }
}

/// The grouped list card: a white rounded container whose rows are separated by
/// hairlines that stop at the card's inner padding.
///
/// The artboards give the container a tiny vertical padding (2-6px) and let the
/// rows carry their own 14-16px - that is what keeps the first and last rows
/// from touching the corner radius.
class DsGroup extends StatelessWidget {
  const DsGroup({
    super.key,
    required this.children,
    this.horizontalPadding = 18,
    this.verticalPadding = 2,
    this.radius = AppRadius.group,
    this.shadow = AppShadows.card,
    this.color = AppColors.surface,
    this.dividerIndent = 0,
  });

  final List<Widget> children;
  final double horizontalPadding;
  final double verticalPadding;
  final double radius;
  final List<BoxShadow> shadow;
  final Color color;
  final double dividerIndent;

  @override
  Widget build(BuildContext context) {
    final rows = <Widget>[];
    for (var i = 0; i < children.length; i++) {
      if (i > 0) rows.add(DsDivider(indent: dividerIndent));
      rows.add(children[i]);
    }

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: horizontalPadding,
        vertical: verticalPadding,
      ),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(radius),
        boxShadow: shadow,
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: rows),
    );
  }
}
