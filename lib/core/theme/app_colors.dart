import 'package:flutter/material.dart';

/// Colour tokens ported 1:1 from the Claude Design `Safini.dc.html` artboards.
///
/// Hex values are the design's own - do not invent new ones. When a screen
/// needs a shade that is not here, add it here first with the artboard it
/// came from.
class AppColors {
  // ── brand ──
  static const Color primary = Color(0xFF8100D1);
  static const Color primaryDeep = Color(0xFF2D005F);
  static const Color primaryTint = Color(0xFFF3E9FD);
  static const Color primaryBar = Color(0xFFC77BFF);
  static const Color primaryPale = Color(0xFFC9A6E8);

  // ── text ──
  static const Color ink = Color(0xFF17151C);
  static const Color inkSoft = Color(0xFF3A3745);
  static const Color textSecondary = Color(0xFF6C6A75);
  static const Color textTertiary = Color(0xFFA09EAA);
  static const Color textMuted = Color(0xFF8A8794);
  static const Color textOnPrimary = Color(0xFFFFFFFF);
  static const Color chevron = Color(0xFFC9C6D2);
  static const Color tabInactive = Color(0xFF8E8B99);

  // ── surfaces ──
  static const Color surface = Color(0xFFFFFFFF);
  static const Color bgParent = Color(0xFFF5F4F8);
  static const Color bgChild = Color(0xFFFBF8FF);
  static const Color fill = Color(0xFFF2F0F6);
  static const Color fillAlt = Color(0xFFF8F7FB);
  static const Color fillPressed = Color(0xFFE4E1EC);
  static const Color fillDeep = Color(0xFFEDEAF3);
  static const Color fillDeeper = Color(0xFFE0DCE8);
  static const Color track = Color(0xFFF0EDF5);
  static const Color trackAlt = Color(0xFFE7E4EE);
  static const Color strokeQuiet = Color(0xFFD9D5E2);

  // ── lines ──  rgba(23,21,28,.07) etc.
  static const Color divider = Color(0x1217151C);
  static const Color hairline = Color(0x1717151C);
  static const Color chipRest = Color(0x0D17151C);
  static const Color segmentTrack = Color(0x0F17151C);
  static const Color scrim = Color(0x6B17151C);

  // ── coins ──
  static const Color coin = Color(0xFFFFB300);
  static const Color coinInk = Color(0xFF4A3000);
  static const Color coinPillBg = Color(0xFFFFF6E0);
  static const Color coinPillFg = Color(0xFF8A5A00);

  // ── status ──
  static const Color success = Color(0xFF00C566);
  static const Color successDeep = Color(0xFF00844A);
  static const Color successBg = Color(0xFFE8F9F0);
  static const Color danger = Color(0xFFFF3B30);
  static const Color dangerDeep = Color(0xFFD92B20);
  static const Color warnBg = Color(0xFFFFF0E4);
  static const Color warnFg = Color(0xFFB45309);
  static const Color info = Color(0xFF00A6C5);

  /// Palette offered when a parent creates a child (Add a child artboard).
  static const List<Color> kidPalette = [
    Color(0xFF8100D1),
    Color(0xFFEE4FA2),
    Color(0xFFF09A77),
    Color(0xFF00A6C5),
    Color(0xFF00C566),
  ];

  /// Palette behind the child avatar (Avatar artboard).
  static const List<Color> avatarPalette = [
    Color(0xFF2D005F),
    Color(0xFF8100D1),
    Color(0xFFEE4FA2),
    Color(0xFFF09A77),
    Color(0xFF00A6C5),
    Color(0xFF00844A),
  ];

  // ── transitional aliases ──
  // Old names still referenced by screens that have not been ported yet. They
  // point at the new palette so those screens already shift colour, and they
  // go away as each screen is rewritten.
  static const Color background = bgParent;
  static const Color border = strokeQuiet;
  static const Color error = danger;
  static const Color primaryLight = primaryTint;
  static const Color textPrimary = ink;

  static const LinearGradient brandGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [primaryDeep, primary],
  );

  /// Stable per-child colour so the same kid keeps the same dot everywhere.
  static Color kidColor(Object? seed) {
    final key = seed?.toString() ?? '';
    if (key.isEmpty) return primary;
    var hash = 0;
    for (final unit in key.codeUnits) {
      hash = (hash * 31 + unit) & 0x7FFFFFFF;
    }
    return kidPalette[hash % kidPalette.length];
  }

  const AppColors._();
}
