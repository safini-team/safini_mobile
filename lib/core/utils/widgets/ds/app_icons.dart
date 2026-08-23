import 'package:flutter/widgets.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:safini/core/theme/app_colors.dart';

/// The design's icon set, kept as the artboards' own SVG so nothing drifts.
///
/// Every glyph is stroke-only at `stroke-width:1.7` (tab bar, 24px grid) or
/// `2 - 2.4` (chevrons, plus, check on a small grid). Colour comes from
/// `currentColor`, applied through a `srcIn` filter.
class AppIcons {
  const AppIcons._();

  static Widget _svg(
    String body, {
    required double width,
    required double height,
    required double size,
    Color? color,
  }) {
    final markup =
        '<svg xmlns="http://www.w3.org/2000/svg" width="$width" height="$height" '
        'viewBox="0 0 $width $height" fill="none">$body</svg>';
    return SvgPicture.string(
      markup,
      width: size * (width / height),
      height: size,
      colorFilter: color == null
          ? null
          : ColorFilter.mode(color, BlendMode.srcIn),
    );
  }

  // ── chevrons ──
  static Widget chevronRight({
    double size = 14,
    Color color = AppColors.chevron,
  }) => _svg(
    '<path d="M1.5 1.5L7.5 8l-6 6.5" stroke="currentColor" stroke-width="2" '
        'stroke-linecap="round" stroke-linejoin="round"/>',
    width: 9,
    height: 16,
    size: size,
    color: color,
  );

  static Widget chevronLeft({
    double size = 16,
    Color color = AppColors.primary,
  }) => _svg(
    '<path d="M7.5 1.5L1.5 8l6 6.5" stroke="currentColor" stroke-width="2" '
        'stroke-linecap="round" stroke-linejoin="round"/>',
    width: 9,
    height: 16,
    size: size,
    color: color,
  );

  // ── glyphs ──
  static Widget plus({double size = 16, Color color = AppColors.primary}) =>
      _svg(
        '<path d="M8 2v12M2 8h12" stroke="currentColor" stroke-width="2.2" '
            'stroke-linecap="round"/>',
        width: 16,
        height: 16,
        size: size,
        color: color,
      );

  static Widget check({
    double size = 13,
    Color color = AppColors.textOnPrimary,
    double strokeWidth = 2.2,
  }) => _svg(
    '<path d="M2.5 7.5l3 3 6-7" stroke="currentColor" stroke-width="$strokeWidth" '
        'stroke-linecap="round" stroke-linejoin="round"/>',
    width: 14,
    height: 14,
    size: size,
    color: color,
  );

  static Widget checkLarge({
    double size = 19,
    Color color = AppColors.successDeep,
  }) => _svg(
    '<path d="M4 10.5l4 4 8-9" stroke="currentColor" stroke-width="2.2" '
        'stroke-linecap="round" stroke-linejoin="round"/>',
    width: 20,
    height: 20,
    size: size,
    color: color,
  );

  static Widget gear({double size = 20, Color color = AppColors.ink}) => _svg(
    '<circle cx="12" cy="12" r="3" stroke="currentColor" stroke-width="1.7"/>'
        '<path d="M19.4 15a1.65 1.65 0 00.33 1.82l.06.06a2 2 0 11-2.83 2.83l-.06-.06a1.65 1.65 0 00-1.82-.33 1.65 1.65 0 00-1 1.51V21a2 2 0 11-4 0v-.09A1.65 1.65 0 008.6 19.4a1.65 1.65 0 00-1.82.33l-.06.06a2 2 0 11-2.83-2.83l.06-.06a1.65 1.65 0 00.33-1.82 1.65 1.65 0 00-1.51-1H3a2 2 0 110-4h.09A1.65 1.65 0 004.6 8.6a1.65 1.65 0 00-.33-1.82l-.06-.06a2 2 0 112.83-2.83l.06.06a1.65 1.65 0 001.82.33H9a1.65 1.65 0 001-1.51V3a2 2 0 114 0v.09a1.65 1.65 0 001 1.51 1.65 1.65 0 001.82-.33l.06-.06a2 2 0 112.83 2.83l-.06.06a1.65 1.65 0 00-.33 1.82V9a1.65 1.65 0 001.51 1H21a2 2 0 110 4h-.09a1.65 1.65 0 00-1.51 1z" '
        'stroke="currentColor" stroke-width="1.7" stroke-linejoin="round"/>',
    width: 24,
    height: 24,
    size: size,
    color: color,
  );

  static Widget copy({
    double size = 14,
    Color color = AppColors.textOnPrimary,
  }) => _svg(
    '<rect x="1" y="1" width="8" height="10" rx="2" stroke="currentColor" stroke-width="1.5"/>'
        '<path d="M4.5 13h6a2 2 0 002-2V4" stroke="currentColor" stroke-width="1.5" stroke-linecap="round"/>',
    width: 14,
    height: 14,
    size: size,
    color: color,
  );

  static Widget camera({
    double size = 26,
    Color color = AppColors.textTertiary,
  }) => _svg(
    '<rect x="2.5" y="5.5" width="19" height="14" rx="3" stroke="currentColor" stroke-width="1.7"/>'
        '<circle cx="12" cy="12.5" r="3.6" stroke="currentColor" stroke-width="1.7"/>',
    width: 24,
    height: 24,
    size: size,
    color: color,
  );

  /// Streak flame - the one filled glyph in the set.
  static Widget flame({double size = 14, Color color = AppColors.coin}) => _svg(
    '<path d="M6 1c2.5 2.5 4.5 4 4.5 7A4.5 4.5 0 016 12.5 4.5 4.5 0 011.5 8C1.5 5.5 3 3.5 6 1z" fill="currentColor"/>',
    width: 12,
    height: 14,
    size: size,
    color: color,
  );

  // ── parent tab bar ──
  static Widget tabHome({double size = 25, required Color color}) => _svg(
    '<path d="M3.5 10.2L12 3.5l8.5 6.7V20a1 1 0 01-1 1h-15a1 1 0 01-1-1v-9.8z" '
        'stroke="currentColor" stroke-width="1.7" stroke-linejoin="round"/>'
        '<path d="M9.2 21v-6.3h5.6V21" stroke="currentColor" stroke-width="1.7" stroke-linejoin="round"/>',
    width: 24,
    height: 24,
    size: size,
    color: color,
  );

  static Widget tabTasksParent({double size = 25, required Color color}) =>
      _svg(
        '<rect x="4" y="3.5" width="16" height="17" rx="3.5" stroke="currentColor" stroke-width="1.7"/>'
            '<path d="M8.3 11.6l2.4 2.4 4.9-5.4" stroke="currentColor" stroke-width="1.7" stroke-linecap="round" stroke-linejoin="round"/>',
        width: 24,
        height: 24,
        size: size,
        color: color,
      );

  static Widget tabLimits({double size = 25, required Color color}) => _svg(
    '<rect x="6.5" y="2.8" width="11" height="18.4" rx="3" stroke="currentColor" stroke-width="1.7"/>'
        '<path d="M10.6 18.4h2.8" stroke="currentColor" stroke-width="1.7" stroke-linecap="round"/>',
    width: 24,
    height: 24,
    size: size,
    color: color,
  );

  static Widget tabFamily({double size = 25, required Color color}) => _svg(
    '<circle cx="9" cy="8.5" r="3.4" stroke="currentColor" stroke-width="1.7"/>'
        '<path d="M2.8 20c.5-3.4 3-5.4 6.2-5.4s5.7 2 6.2 5.4" stroke="currentColor" stroke-width="1.7" stroke-linecap="round"/>'
        '<path d="M16 5.6a3 3 0 010 5.8M17.6 14.9c2 .7 3.3 2.5 3.6 5.1" stroke="currentColor" stroke-width="1.7" stroke-linecap="round"/>',
    width: 24,
    height: 24,
    size: size,
    color: color,
  );

  // ── child tab bar ──
  static Widget tabTasksChild({double size = 25, required Color color}) => _svg(
    '<path d="M4 6.8l2.4 2.4L10.6 5" stroke="currentColor" stroke-width="1.7" stroke-linecap="round" stroke-linejoin="round"/>'
        '<path d="M4 17.4l2.4 2.4 4.2-4.2M13.6 7h6.6M13.6 17.6h6.6" stroke="currentColor" stroke-width="1.7" stroke-linecap="round" stroke-linejoin="round"/>',
    width: 24,
    height: 24,
    size: size,
    color: color,
  );

  static Widget tabStore({double size = 25, required Color color}) => _svg(
    '<path d="M4.6 8.5h14.8l-1.2 11.2a1.5 1.5 0 01-1.5 1.3H7.3a1.5 1.5 0 01-1.5-1.3L4.6 8.5z" '
        'stroke="currentColor" stroke-width="1.7" stroke-linejoin="round"/>'
        '<path d="M9 8.5V6.8a3 3 0 116 0v1.7" stroke="currentColor" stroke-width="1.7" stroke-linecap="round"/>',
    width: 24,
    height: 24,
    size: size,
    color: color,
  );

  static Widget tabMe({double size = 25, required Color color}) => _svg(
    '<circle cx="12" cy="8" r="3.8" stroke="currentColor" stroke-width="1.7"/>'
        '<path d="M4.6 20.4c.7-3.8 3.6-6 7.4-6s7 2.2 7.4 6" stroke="currentColor" stroke-width="1.7" stroke-linecap="round"/>',
    width: 24,
    height: 24,
    size: size,
    color: color,
  );
}
