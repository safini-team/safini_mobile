/// Spacing tokens. The artboards run on an 18/20/22 gutter system rather than
/// a strict 8pt grid - cards sit at 18 from the edge, text at 20-22.
class AppSpacing {
  static const double xxs = 2;
  static const double xs = 4;
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 24;
  static const double xxl = 32;

  /// Horizontal inset for cards and grouped lists (`padding:0 18px`).
  static const double gutter = 18;

  /// Horizontal inset for bare text that sits above a card (`padding:0 20px`).
  static const double textGutter = 20;

  /// Horizontal inset for section headings (`padding:… 22px …`).
  static const double headingGutter = 22;

  /// Gap above a section heading.
  static const double sectionTop = 30;

  /// Gap between a section heading and its card.
  static const double sectionBottom = 10;

  /// Bottom padding that clears the floating tab bar (`padding-bottom:112px`).
  static const double tabBarClearance = 112;

  const AppSpacing._();
}
