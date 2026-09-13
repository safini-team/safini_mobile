import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:safini/core/theme/app_colors.dart';
import 'package:safini/core/theme/app_radius.dart';
import 'package:safini/core/theme/app_typography.dart';
import 'package:safini/core/utils/widgets/ds/pressable.dart';

/// The status pill that ends almost every row:
/// `height:22-30px;padding:0 10px;border-radius:100px;font-weight:680;tabular`.
///
/// Named constructors carry the exact colour pairs from `renderVals()` so a
/// screen never has to re-derive them.
class DsPill extends StatelessWidget {
  const DsPill({
    super.key,
    required this.label,
    required this.background,
    required this.foreground,
    this.height = 22,
    this.fontSize = 12.5,
    this.leading,
    this.horizontalPadding = 10,
  });

  /// Coins on offer - `#FFF6E0` / `#8A5A00`.
  const DsPill.coins({
    super.key,
    required this.label,
    this.height = 26,
    this.fontSize = 14,
    this.leading,
    this.horizontalPadding = 11,
  }) : background = AppColors.coinPillBg,
       foreground = AppColors.coinPillFg;

  /// Purple tint - the default "worth N coins" pill.
  const DsPill.tint({
    super.key,
    required this.label,
    this.height = 22,
    this.fontSize = 13,
    this.leading,
    this.horizontalPadding = 10,
  }) : background = AppColors.primaryTint,
       foreground = AppColors.primary;

  /// Paid / done - `#E8F9F0` / `#00844A`.
  const DsPill.paid({
    super.key,
    required this.label,
    this.height = 22,
    this.fontSize = 12.5,
    this.leading,
    this.horizontalPadding = 10,
  }) : background = AppColors.successBg,
       foreground = AppColors.successDeep;

  /// Waiting on a parent - `#FFF0E4` / `#B45309`.
  const DsPill.pending({
    super.key,
    required this.label,
    this.height = 22,
    this.fontSize = 12.5,
    this.leading,
    this.horizontalPadding = 10,
  }) : background = AppColors.warnBg,
       foreground = AppColors.warnFg;

  /// Locked / inert - `#EFEBE3` / `#A09EAA`.
  const DsPill.muted({
    super.key,
    required this.label,
    this.height = 22,
    this.fontSize = 12.5,
    this.leading,
    this.horizontalPadding = 10,
  }) : background = AppColors.fill,
       foreground = AppColors.textTertiary;

  final String label;
  final Color background;
  final Color foreground;
  final double height;
  final double fontSize;
  final Widget? leading;
  final double horizontalPadding;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(AppRadius.pill),
      ),
      // No `alignment` on purpose: a Container with one would expand to fill
      // loose constraints, and the design's pills are inline-flex.
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (leading != null) ...[leading!, const SizedBox(width: 5)],
          // Shrinks rather than truncating: "Check…" on a status pill hides
          // the one word the pill exists to say.
          Flexible(
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                label,
                maxLines: 1,
                softWrap: false,
                style: TextStyle(
                  fontSize: fontSize,
                  fontWeight: FontWeight.w700,
                  color: foreground,
                  height: 1,
                  fontFeatures: AppText.tabular,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// The Safini Time Coin: a green-rimmed gold coin with a white tick, redrawn as
/// SVG from the brand artwork so it stays crisp from a 14px price pill up to
/// the reward sheet.
class DsCoinToken extends StatelessWidget {
  const DsCoinToken({super.key, this.size = 22});

  final double size;

  static const String svg =
      '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 100 100">'
      '<defs>'
      '<linearGradient id="rim" x1="0" y1="0" x2="0" y2="1">'
      '<stop offset="0" stop-color="#FFE45A"/><stop offset="1" stop-color="#F9BE1C"/>'
      '</linearGradient>'
      '<linearGradient id="face" x1="0.2" y1="0.1" x2="0.8" y2="0.95">'
      '<stop offset="0" stop-color="#FFD12B"/><stop offset="1" stop-color="#F58C0A"/>'
      '</linearGradient>'
      '<radialGradient id="gloss" cx="0.34" cy="0.24" r="0.3">'
      '<stop offset="0" stop-color="#FFFFFF" stop-opacity="0.28"/>'
      '<stop offset="1" stop-color="#FFFFFF" stop-opacity="0"/>'
      '</radialGradient>'
      '</defs>'
      '<circle cx="50" cy="50" r="50" fill="#0B5E3F"/>'
      '<circle cx="50" cy="50" r="45" fill="url(#rim)"/>'
      '<circle cx="50" cy="50" r="38.6" fill="url(#face)" stroke="#E8850A" stroke-width="1.8"/>'
      '<circle cx="50" cy="50" r="37.5" fill="url(#gloss)"/>'
      '<path d="M30.9 47.9L41.9 62.5L72.2 36.4" fill="none" stroke="#B35A0C" '
      'stroke-width="12.4" stroke-linecap="round" stroke-linejoin="round"/>'
      '<path d="M30.9 47.9L41.9 62.5L72.2 36.4" fill="none" stroke="#FFFFFF" '
      'stroke-width="9.6" stroke-linecap="round" stroke-linejoin="round"/>'
      '</svg>';

  @override
  Widget build(BuildContext context) {
    return SvgPicture.string(svg, width: size, height: size);
  }
}

/// White coin balance pill in the kid header: token + tabular total.
class DsCoinBalance extends StatelessWidget {
  const DsCoinBalance({
    super.key,
    required this.coins,
    this.onTap,
    this.shadow,
  });

  final int coins;
  final VoidCallback? onTap;
  final List<BoxShadow>? shadow;

  @override
  Widget build(BuildContext context) {
    final pill = Container(
      padding: const EdgeInsets.fromLTRB(10, 8, 14, 8),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.pill),
        boxShadow: shadow ?? const [],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const DsCoinToken(),
          const SizedBox(width: 7),
          Text(
            '$coins',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              letterSpacing: -0.16,
              color: AppColors.ink,
              height: 1,
              fontFeatures: AppText.tabular,
            ),
          ),
        ],
      ),
    );

    if (onTap == null) return pill;
    return Pressable(onTap: onTap, scale: 0.96, child: pill);
  }
}
