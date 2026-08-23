/// Corner radii used by the artboards. The design is radius-rich - every value
/// here appears in `Safini.dc.html`, so pick the nearest one rather than
/// rounding to a "scale".
class AppRadius {
  /// Emoji tile inside a compact row.
  static const double xs = 9;

  /// App icon tile, segmented-control thumb.
  static const double sm = 10;

  /// Stepper track, small emoji tile.
  static const double md = 12;

  /// Inline Approve / Look closer buttons.
  static const double action = 13;

  /// Kid stat tile, code digit box.
  static const double tile = 14;

  /// Sheet icon tile.
  static const double icon = 15;

  /// Hold-to-complete pill on a card, avatar face tile.
  static const double control = 16;

  /// Inset panel inside a sheet.
  static const double panel = 18;

  /// Primary button.
  static const double button = 18;

  /// Settings card, form card.
  static const double card = 20;

  /// Grouped list card - the most common one.
  static const double group = 22;

  /// Feature card (screen-time ring, next task).
  static const double feature = 24;

  /// Pairing-code panel.
  static const double code = 26;

  /// Kid hero card, avatar stage.
  static const double hero = 28;

  /// Bottom sheet top corners.
  static const double sheet = 30;

  /// Fully round.
  static const double pill = 100;

  // ── transitional aliases ──
  // Still referenced by screens not yet ported; both land on a real design
  // value so nothing regresses in the meantime.
  static const double lg = control;
  static const double xl = feature;

  const AppRadius._();
}
