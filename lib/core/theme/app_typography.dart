import 'package:flutter/material.dart';
import 'package:safini/core/theme/app_colors.dart';

/// Type scale ported from the design artboards.
///
/// The design uses SF Pro variable weights (560 / 640 / 660 / 680). Flutter can
/// only pick real cuts, so they collapse: 460→w400, 560→w500, 600/620/640→w600,
/// 660/680/700→w700, 800→w800. Letter-spacing is CSS `em × fontSize`.
///
/// `fontFamily` stays null on purpose - that resolves to SF Pro on iOS, which
/// is what the artboards were drawn in.
class AppText {
  const AppText._();

  // ── display / large titles ──
  /// 40 / 700 / -.028em - Welcome wordmark.
  static const TextStyle display = TextStyle(
    fontSize: 40,
    fontWeight: FontWeight.w700,
    letterSpacing: -1.12,
    height: 1.02,
    color: AppColors.ink,
  );

  /// 34 / 700 / -.024em - the large title on every tab root.
  static const TextStyle largeTitle = TextStyle(
    fontSize: 34,
    fontWeight: FontWeight.w700,
    letterSpacing: -0.816,
    height: 1.05,
    color: AppColors.ink,
  );

  /// 32 / 700 / -.022em - pushed-screen headline.
  static const TextStyle title1 = TextStyle(
    fontSize: 32,
    fontWeight: FontWeight.w700,
    letterSpacing: -0.704,
    height: 1.08,
    color: AppColors.ink,
  );

  /// 28 / 700 / -.02em.
  static const TextStyle title2 = TextStyle(
    fontSize: 28,
    fontWeight: FontWeight.w700,
    letterSpacing: -0.56,
    height: 1.12,
    color: AppColors.ink,
  );

  /// 26 / 700 / -.02em - sheet headline, big stat.
  static const TextStyle title3 = TextStyle(
    fontSize: 26,
    fontWeight: FontWeight.w700,
    letterSpacing: -0.52,
    height: 1.15,
    color: AppColors.ink,
  );

  /// 24 / 700 / -.02em.
  static const TextStyle title4 = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.w700,
    letterSpacing: -0.48,
    height: 1.15,
    color: AppColors.ink,
  );

  /// 22 / 700 / -.018em - kid name on the Me card.
  static const TextStyle title5 = TextStyle(
    fontSize: 22,
    fontWeight: FontWeight.w700,
    letterSpacing: -0.396,
    height: 1.2,
    color: AppColors.ink,
  );

  /// 20 / 680 / -.016em - "Needs your review" section heading.
  static const TextStyle section = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w700,
    letterSpacing: -0.32,
    height: 1.2,
    color: AppColors.ink,
  );

  /// 19 / 660 / -.016em - hero headline, next-task title.
  static const TextStyle headline = TextStyle(
    fontSize: 19,
    fontWeight: FontWeight.w600,
    letterSpacing: -0.304,
    height: 1.25,
    color: AppColors.ink,
  );

  /// 19 / 400 / -.008em / 1.42 - Welcome sub-copy.
  static const TextStyle lede = TextStyle(
    fontSize: 19,
    fontWeight: FontWeight.w400,
    letterSpacing: -0.152,
    height: 1.42,
    color: AppColors.textSecondary,
  );

  /// 18 / 640 / -.014em - kid card name.
  static const TextStyle cardTitle = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    letterSpacing: -0.252,
    height: 1.2,
    color: AppColors.ink,
  );

  /// 17 / 640 / -.01em - primary button label, nav-bar action.
  static const TextStyle button = TextStyle(
    fontSize: 17,
    fontWeight: FontWeight.w600,
    letterSpacing: -0.17,
    height: 1.2,
    color: AppColors.ink,
  );

  /// 16.5 / 560 / -.01em - sheet row title.
  static const TextStyle rowTitleLg = TextStyle(
    fontSize: 16.5,
    fontWeight: FontWeight.w500,
    letterSpacing: -0.165,
    height: 1.3,
    color: AppColors.ink,
  );

  /// 16 / 560 / -.01em - grouped-list row title.
  static const TextStyle rowTitle = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w500,
    letterSpacing: -0.16,
    height: 1.3,
    color: AppColors.ink,
  );

  /// 16 / 600 / -.01em - emphasised row (review title, "All caught up").
  static const TextStyle rowTitleStrong = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    letterSpacing: -0.16,
    height: 1.3,
    color: AppColors.ink,
  );

  /// 15.5 / 560 / -.008em.
  static const TextStyle body = TextStyle(
    fontSize: 15.5,
    fontWeight: FontWeight.w500,
    letterSpacing: -0.124,
    height: 1.3,
    color: AppColors.ink,
  );

  /// 15.5 / 400 / 1.45 - paragraph copy under a headline.
  static const TextStyle bodyRegular = TextStyle(
    fontSize: 15.5,
    fontWeight: FontWeight.w400,
    letterSpacing: -0.078,
    height: 1.45,
    color: AppColors.textSecondary,
  );

  /// 15 / 400 - form label.
  static const TextStyle field = TextStyle(
    fontSize: 15,
    fontWeight: FontWeight.w400,
    height: 1.3,
    color: AppColors.textSecondary,
  );

  /// 14.5 / 600 / -.005em - chip label, inline action.
  static const TextStyle chip = TextStyle(
    fontSize: 14.5,
    fontWeight: FontWeight.w600,
    letterSpacing: -0.0725,
    height: 1.2,
    color: AppColors.ink,
  );

  /// 14.5 / 400 - subtitle under a large title.
  static const TextStyle subtitle = TextStyle(
    fontSize: 14.5,
    fontWeight: FontWeight.w400,
    height: 1.3,
    color: AppColors.textSecondary,
  );

  /// 14 / 600 - "Full report" style link.
  static const TextStyle link = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    height: 1.2,
    color: AppColors.primary,
  );

  /// 13.5 / 400 - row meta.
  static const TextStyle meta = TextStyle(
    fontSize: 13.5,
    fontWeight: FontWeight.w400,
    height: 1.35,
    color: AppColors.textSecondary,
  );

  /// 13 / 400 / 1.45 - footnote under a card group.
  static const TextStyle footnote = TextStyle(
    fontSize: 13,
    fontWeight: FontWeight.w400,
    height: 1.45,
    color: AppColors.textTertiary,
  );

  /// 13 / 400 - dense row meta.
  static const TextStyle metaSm = TextStyle(
    fontSize: 13,
    fontWeight: FontWeight.w400,
    height: 1.35,
    color: AppColors.textSecondary,
  );

  /// 12.5 / 400 - stat caption.
  static const TextStyle caption = TextStyle(
    fontSize: 12.5,
    fontWeight: FontWeight.w400,
    height: 1.3,
    color: AppColors.textSecondary,
  );

  /// 12 / 640 / .06em uppercase - the overline above every grouped list.
  static const TextStyle overline = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.72,
    height: 1.2,
    color: AppColors.textTertiary,
  );

  /// 11.5 / 640 / .02em - ring sub-label, week-strip day.
  static const TextStyle micro = TextStyle(
    fontSize: 11.5,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.23,
    height: 1.2,
    color: AppColors.textTertiary,
  );

  /// 10.5 / 600 / .01em - tab-bar label.
  static const TextStyle tabLabel = TextStyle(
    fontSize: 10.5,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.105,
    height: 1.2,
  );

  /// Tabular figures - every number in the design uses them.
  static const List<FontFeature> tabular = [FontFeature.tabularFigures()];
}

extension AppTextX on TextStyle {
  /// `font-variant-numeric: tabular-nums`.
  TextStyle get nums => copyWith(fontFeatures: AppText.tabular);

  TextStyle tint(Color color) => copyWith(color: color);

  TextStyle weight(FontWeight w) => copyWith(fontWeight: w);
}
