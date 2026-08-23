import 'package:flutter/animation.dart';

/// Motion tokens from the artboards. Every transition in the design uses one of
/// these four curves - nothing else.
class AppMotion {
  const AppMotion._();

  /// `cubic-bezier(.23,1,.32,1)` - the house curve. Presses, chips, toggles,
  /// screen entrances, everything that snaps and settles.
  static const Curve spring = Cubic(0.23, 1.0, 0.32, 1.0);

  /// `cubic-bezier(.32,.72,0,1)` - sheet presentation only. Longer tail so the
  /// sheet lands rather than bounces.
  static const Curve sheet = Cubic(0.32, 0.72, 0.0, 1.0);

  /// `ease` - colour and opacity crossfades.
  static const Curve ease = Curves.ease;

  /// `linear` - the hold-to-complete fill.
  static const Curve linear = Curves.linear;

  // ── durations ──
  /// Press feedback (`transform 140ms`).
  static const Duration press = Duration(milliseconds: 140);

  /// Card press, slightly slower because the travel is smaller.
  static const Duration pressSlow = Duration(milliseconds: 160);

  /// Colour swap on chips and segmented controls.
  static const Duration tint = Duration(milliseconds: 200);

  /// Toggle knob travel.
  static const Duration toggle = Duration(milliseconds: 240);

  /// Scrim fade-in behind a sheet.
  static const Duration scrim = Duration(milliseconds: 260);

  /// Toast in.
  static const Duration toast = Duration(milliseconds: 300);

  /// Screen entrance (`scrIn`): 8px rise + fade.
  static const Duration screen = Duration(milliseconds: 320);

  /// Sheet presentation.
  static const Duration sheetIn = Duration(milliseconds: 400);

  /// Hold-to-complete dwell before the task is sent.
  static const Duration hold = Duration(milliseconds: 1150);

  /// How long a toast stays up.
  static const Duration toastDwell = Duration(milliseconds: 2400);
}
