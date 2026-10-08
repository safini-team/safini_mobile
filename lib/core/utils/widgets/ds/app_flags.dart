import 'package:flutter/widgets.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// Country flags for the app languages, drawn as SVG rather than emoji:
/// emoji flags look different on every Android skin and on iPhone, and some
/// launchers render them as two letters.
///
/// English is the Union flag, Russian the tricolour, Uzbek the national flag
/// with its crescent and twelve stars. Kyrgyz and Kazakh are simplified to
/// read at 21px: the sun and tunduk, and the sun, eagle and hoist ornament.
/// All share a 3:2 box.
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

  static const String _kg =
      '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 30 20">'
      '<rect width="30" height="20" fill="#E8112D"/>'
      '<path fill="#FFEF00" d="'
      'M21.10 10.00L18.29 9.74L18.29 10.26ZM21.02 10.95L18.29 10.26L18.21 10.77Z'
      'M20.80 11.89L18.21 10.77L18.05 11.26ZM20.44 12.77L18.05 11.26L17.81 11.72Z'
      'M19.94 13.59L17.81 11.72L17.51 12.14ZM19.31 14.31L17.51 12.14L17.14 12.51Z'
      'M18.59 14.94L17.14 12.51L16.72 12.81ZM17.77 15.44L16.72 12.81L16.26 13.05Z'
      'M16.89 15.80L16.26 13.05L15.77 13.21ZM15.95 16.02L15.77 13.21L15.26 13.29Z'
      'M15.00 16.10L15.26 13.29L14.74 13.29ZM14.05 16.02L14.74 13.29L14.23 13.21Z'
      'M13.11 15.80L14.23 13.21L13.74 13.05ZM12.23 15.44L13.74 13.05L13.28 12.81Z'
      'M11.41 14.94L13.28 12.81L12.86 12.51ZM10.69 14.31L12.86 12.51L12.49 12.14Z'
      'M10.06 13.59L12.49 12.14L12.19 11.72ZM9.56 12.77L12.19 11.72L11.95 11.26Z'
      'M9.20 11.89L11.95 11.26L11.79 10.77ZM8.98 10.95L11.79 10.77L11.71 10.26Z'
      'M8.90 10.00L11.71 10.26L11.71 9.74ZM8.98 9.05L11.71 9.74L11.79 9.23Z'
      'M9.20 8.11L11.79 9.23L11.95 8.74ZM9.56 7.23L11.95 8.74L12.19 8.28Z'
      'M10.06 6.41L12.19 8.28L12.49 7.86ZM10.69 5.69L12.49 7.86L12.86 7.49Z'
      'M11.41 5.06L12.86 7.49L13.28 7.19ZM12.23 4.56L13.28 7.19L13.74 6.95Z'
      'M13.11 4.20L13.74 6.95L14.23 6.79ZM14.05 3.98L14.23 6.79L14.74 6.71Z'
      'M15.00 3.90L14.74 6.71L15.26 6.71ZM15.95 3.98L15.26 6.71L15.77 6.79Z'
      'M16.89 4.20L15.77 6.79L16.26 6.95ZM17.77 4.56L16.26 6.95L16.72 7.19Z'
      'M18.59 5.06L16.72 7.19L17.14 7.49ZM19.31 5.69L17.14 7.49L17.51 7.86Z'
      'M19.94 6.41L17.51 7.86L17.81 8.28ZM20.44 7.23L17.81 8.28L18.05 8.74Z'
      'M20.80 8.11L18.05 8.74L18.21 9.23ZM21.02 9.05L18.21 9.23L18.29 9.74Z'
      '"/>'
      '<circle cx="15" cy="10" r="3.4" fill="#FFEF00"/>'
      '<circle cx="15" cy="10" r="2.55" fill="#E8112D"/>'
      '<circle cx="15" cy="10" r="2.05" fill="#FFEF00"/>'
      '<path d="M13.1 9.1Q15 7.6 16.9 9.1M12.95 10.2Q15 8.6 17.05 10.2M13.1 11.3Q15 9.7 16.9 11.3" '
      'fill="none" stroke="#E8112D" stroke-width="0.32"/>'
      '</svg>';

  static const String _kz =
      '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 30 20">'
      '<rect width="30" height="20" fill="#00AFCA"/>'
      '<path fill="#FEC50C" d="'
      'M19.40 8.40L17.99 8.11L17.99 8.69ZM19.32 9.26L17.99 8.69L17.87 9.27Z'
      'M19.07 10.08L17.87 9.27L17.65 9.81ZM18.66 10.84L17.65 9.81L17.32 10.30Z'
      'M18.11 11.51L17.32 10.30L16.90 10.72ZM17.44 12.06L16.90 10.72L16.41 11.05Z'
      'M16.68 12.47L16.41 11.05L15.87 11.27ZM15.86 12.72L15.87 11.27L15.29 11.39Z'
      'M15.00 12.80L15.29 11.39L14.71 11.39ZM14.14 12.72L14.71 11.39L14.13 11.27Z'
      'M13.32 12.47L14.13 11.27L13.59 11.05ZM12.56 12.06L13.59 11.05L13.10 10.72Z'
      'M11.89 11.51L13.10 10.72L12.68 10.30ZM11.34 10.84L12.68 10.30L12.35 9.81Z'
      'M10.93 10.08L12.35 9.81L12.13 9.27ZM10.68 9.26L12.13 9.27L12.01 8.69Z'
      'M10.60 8.40L12.01 8.69L12.01 8.11ZM10.68 7.54L12.01 8.11L12.13 7.53Z'
      'M10.93 6.72L12.13 7.53L12.35 6.99ZM11.34 5.96L12.35 6.99L12.68 6.50Z'
      'M11.89 5.29L12.68 6.50L13.10 6.08ZM12.56 4.74L13.10 6.08L13.59 5.75Z'
      'M13.32 4.33L13.59 5.75L14.13 5.53ZM14.14 4.08L14.13 5.53L14.71 5.41Z'
      'M15.00 4.00L14.71 5.41L15.29 5.41ZM15.86 4.08L15.29 5.41L15.87 5.53Z'
      'M16.68 4.33L15.87 5.53L16.41 5.75ZM17.44 4.74L16.41 5.75L16.90 6.08Z'
      'M18.11 5.29L16.90 6.08L17.32 6.50ZM18.66 5.96L17.32 6.50L17.65 6.99Z'
      'M19.07 6.72L17.65 6.99L17.87 7.53ZM19.32 7.54L17.87 7.53L17.99 8.11Z'
      '"/>'
      '<circle cx="15" cy="8.4" r="2.6" fill="#FEC50C"/>'
      '<path fill="#FEC50C" d="M8.6 12.6Q11.8 11.2 15 13.6Q18.2 11.2 21.4 12.6Q18.6 13.4 15 15.4Q11.4 13.4 8.6 12.6Z"/>'
      '<rect x="1.6" y="1.4" width="1.3" height="17.2" fill="#FEC50C"/>'
      '<path fill="#00AFCA" d="M2.25 2.6l0.4 0.9-0.4 0.9-0.4-0.9ZM2.25 6.4l0.4 0.9-0.4 0.9-0.4-0.9Z'
      'M2.25 10.2l0.4 0.9-0.4 0.9-0.4-0.9ZM2.25 14l0.4 0.9-0.4 0.9-0.4-0.9Z"/>'
      '</svg>';

  static String svgFor(String languageCode) => switch (languageCode) {
    'uz' => _uz,
    'ky' => _kg,
    'kk' => _kz,
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
