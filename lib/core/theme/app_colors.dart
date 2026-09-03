import 'package:flutter/material.dart';

/// Colour tokens for the Pine & Sand identity.
///
/// Token *names* are stable - screens reference these, not hex values. When a
/// screen needs a shade that is not here, add it here first. Never inline a
/// `Color(0x…)` in a widget: the whole point of this file is that the next
/// palette change is one edit.
///
/// Contrast is measured against `surface` (#FFFFFF) and `bgParent` (#F7F5F0);
/// every pair used for text clears WCAG AA at 4.5:1.
class AppColors {
  // ── brand ── pine. primary means "earned / allowed / safe".
  static const Color primary = Color(0xFF1A5C4A); // 7.9:1 on white
  static const Color primaryDeep = Color(0xFF103B2F);
  static const Color primaryTint = Color(0xFFDCEDE5);
  static const Color primaryBar = Color(0xFF7FAF9C);
  static const Color primaryPale = Color(0xFFA8C9BB);

  // ── text ──
  static const Color ink = Color(0xFF0C231C); // 16.5:1 on white
  static const Color inkSoft = Color(0xFF24403A);
  static const Color textSecondary = Color(0xFF4A5A54); // 7.3:1
  static const Color textTertiary = Color(0xFF64736D); // 5.0:1
  static const Color textMuted = Color(0xFF6E7D76);
  static const Color textOnPrimary = Color(0xFFFFFFFF);
  static const Color chevron = Color(0xFFB5C2BC);
  static const Color tabInactive = Color(0xFF64736D);

  // ── surfaces ── warm sand, green-biased neutrals
  static const Color surface = Color(0xFFFFFFFF);
  static const Color bgParent = Color(0xFFF7F5F0);
  static const Color bgChild = Color(0xFFFBFAF6);
  static const Color fill = Color(0xFFEFEBE3);
  static const Color fillAlt = Color(0xFFF5F2EC);
  static const Color fillPressed = Color(0xFFE4DFD4);
  static const Color fillDeep = Color(0xFFEAE5DB);
  static const Color fillDeeper = Color(0xFFDED8CC);
  static const Color track = Color(0xFFEDE9E0);
  static const Color trackAlt = Color(0xFFE1DCD2);
  static const Color strokeQuiet = Color(0xFFD5CFC3);

  // ── lines ──  alpha over ink
  static const Color divider = Color(0x120C231C);
  static const Color hairline = Color(0x170C231C);
  static const Color chipRest = Color(0x0D0C231C);
  static const Color segmentTrack = Color(0x0F0C231C);
  static const Color scrim = Color(0x6B0C231C);

  // ── coins ── amber is reserved for Time Coins. Nothing else uses it.
  static const Color coin = Color(0xFFE8A33D);
  static const Color coinInk = Color(0xFF3A2A08);
  static const Color coinPillBg = Color(0xFFFBF1DF);
  static const Color coinPillFg = Color(0xFF9A6512); // 5.0:1

  // ── status ── a locked app is a state, not a punishment, so it is slate.
  static const Color locked = Color(0xFF5B6A72);
  static const Color success = Color(0xFF2E8B63); // fills and icons
  static const Color successDeep = Color(0xFF14603F); // success as text
  static const Color successBg = Color(0xFFE4F1EA);
  static const Color danger = Color(0xFFC2452D); // 5.0:1
  static const Color dangerDeep = Color(0xFFA6371F);
  static const Color warnBg = Color(0xFFFBF1DF);
  static const Color warnFg = Color(0xFF9A6512);
  static const Color info = Color(0xFF2E6F8E);

  // ── task categories ── (icon, tint) pairs shared by quests, tasks and the
  // reward store. None of these reuse primary, danger or coin: a category must
  // never be mistaken for a state or for currency.
  static const Color catFitness = Color(0xFF9C4F6B);
  static const Color catFitnessBg = Color(0xFFF2E6EA);
  static const Color catLogic = Color(0xFF6B7F3A);
  static const Color catLogicBg = Color(0xFFEDF0E2);
  static const Color catChore = Color(0xFF9A6512);
  static const Color catChoreBg = Color(0xFFF5EBDA);
  static const Color catLearn = Color(0xFF2E6F8E);
  static const Color catLearnBg = Color(0xFFDFEAF0);

  /// Palette offered when a parent creates a child. Muted and hue-separated so
  /// two children never look alike on a 12px dot.
  static const List<Color> kidPalette = [
    Color(0xFF1A5C4A), // pine
    Color(0xFF2E6F8E), // lagoon
    Color(0xFF9A6512), // bronze
    Color(0xFFC2452D), // terracotta
    Color(0xFF9C4F6B), // mulberry
    Color(0xFF6B7F3A), // olive
  ];

  /// Palette behind the child avatar. Index 1 is the brand colour and is
  /// referenced directly as the default - do not reorder without checking.
  static const List<Color> avatarPalette = [
    Color(0xFF103B2F),
    Color(0xFF1A5C4A),
    Color(0xFF2E6F8E),
    Color(0xFFE8A33D),
    Color(0xFFC2452D),
    Color(0xFF9C4F6B),
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
