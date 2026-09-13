import 'package:flutter/widgets.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// Country flags for the three app languages, drawn as SVG rather than emoji:
/// emoji flags look different on every Android skin and on iPhone, and some
/// launchers render them as two letters.
///
/// English is the Union flag, Russian the tricolour, Uzbek the national flag
/// with its crescent and twelve stars. All share a 3:2 box.
class AppFlag extends StatelessWidget {
  const AppFlag(this.languageCode, {super.key, this.width = 24});

  final String languageCode;
  final double width;

  static const String _gb =
      '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 60 40">'
      '<clipPath id="t"><path d="M30 20h30v20zv20h-30zh-30v-20zv-20h30z"/></clipPath>'
      '<rect width="60" height="40" fill="#012169"/>'
      '<path d="M0 0L60 40M60 0L0 40" stroke="#fff" stroke-width="8"/>'
      '<path d="M0 0L60 40M60 0L0 40" clip-path="url(#t)" stroke="#C8102E" stroke-width="5"/>'
      '<path d="M30 0v40M0 20h60" stroke="#fff" stroke-width="13"/>'
      '<path d="M30 0v40M0 20h60" stroke="#C8102E" stroke-width="8"/>'
      '</svg>';

  static const String _ru =
      '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 30 20">'
      '<rect width="30" height="20" fill="#fff"/>'
      '<rect y="6.67" width="30" height="6.67" fill="#0039A6"/>'
      '<rect y="13.33" width="30" height="6.67" fill="#D52B1E"/>'
      '</svg>';

  static const String _uz =
      '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 30 20">'
      '<rect width="30" height="20" fill="#fff"/>'
      '<rect width="30" height="6.33" fill="#0099B5"/>'
      '<rect y="13.67" width="30" height="6.33" fill="#1EB53A"/>'
      '<rect y="6.33" width="30" height="0.6" fill="#CE1126"/>'
      '<rect y="13.07" width="30" height="0.6" fill="#CE1126"/>'
      '<circle cx="4.6" cy="3.3" r="2.35" fill="#fff"/>'
      '<circle cx="5.45" cy="3.3" r="2.05" fill="#0099B5"/>'
      '<path fill="#fff" d="'
      'M12.60 1.15L12.72 1.53L13.12 1.53L12.80 1.76L12.92 2.14L12.60 1.91L12.28 2.14L12.40 1.76L12.08 1.53L12.48 1.53Z'
      'M14.40 1.15L14.52 1.53L14.92 1.53L14.60 1.76L14.72 2.14L14.40 1.91L14.08 2.14L14.20 1.76L13.88 1.53L14.28 1.53Z'
      'M16.20 1.15L16.32 1.53L16.72 1.53L16.40 1.76L16.52 2.14L16.20 1.91L15.88 2.14L16.00 1.76L15.68 1.53L16.08 1.53Z'
      'M10.80 2.95L10.92 3.33L11.32 3.33L11.00 3.56L11.12 3.94L10.80 3.71L10.48 3.94L10.60 3.56L10.28 3.33L10.68 3.33Z'
      'M12.60 2.95L12.72 3.33L13.12 3.33L12.80 3.56L12.92 3.94L12.60 3.71L12.28 3.94L12.40 3.56L12.08 3.33L12.48 3.33Z'
      'M14.40 2.95L14.52 3.33L14.92 3.33L14.60 3.56L14.72 3.94L14.40 3.71L14.08 3.94L14.20 3.56L13.88 3.33L14.28 3.33Z'
      'M16.20 2.95L16.32 3.33L16.72 3.33L16.40 3.56L16.52 3.94L16.20 3.71L15.88 3.94L16.00 3.56L15.68 3.33L16.08 3.33Z'
      'M9.00 4.75L9.12 5.13L9.52 5.13L9.20 5.36L9.32 5.74L9.00 5.51L8.68 5.74L8.80 5.36L8.48 5.13L8.88 5.13Z'
      'M10.80 4.75L10.92 5.13L11.32 5.13L11.00 5.36L11.12 5.74L10.80 5.51L10.48 5.74L10.60 5.36L10.28 5.13L10.68 5.13Z'
      'M12.60 4.75L12.72 5.13L13.12 5.13L12.80 5.36L12.92 5.74L12.60 5.51L12.28 5.74L12.40 5.36L12.08 5.13L12.48 5.13Z'
      'M14.40 4.75L14.52 5.13L14.92 5.13L14.60 5.36L14.72 5.74L14.40 5.51L14.08 5.74L14.20 5.36L13.88 5.13L14.28 5.13Z'
      'M16.20 4.75L16.32 5.13L16.72 5.13L16.40 5.36L16.52 5.74L16.20 5.51L15.88 5.74L16.00 5.36L15.68 5.13L16.08 5.13Z'
      '"/>'
      '</svg>';

  static String svgFor(String languageCode) => switch (languageCode) {
    'uz' => _uz,
    'ru' => _ru,
    _ => _gb,
  };

  @override
  Widget build(BuildContext context) {
    final height = width * 2 / 3;
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(width / 8),
        // A hairline so the white stripes of RU and UZ don't dissolve into a
        // white row.
        border: Border.all(color: const Color(0x1F0C231C), width: 0.5),
      ),
      clipBehavior: Clip.antiAlias,
      child: SvgPicture.string(
        svgFor(languageCode),
        width: width,
        height: height,
        fit: BoxFit.cover,
      ),
    );
  }
}
