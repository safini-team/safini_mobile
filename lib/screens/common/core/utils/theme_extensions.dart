import 'package:flutter/material.dart';

extension ThemeContextX on BuildContext {
  ThemeData get theme => Theme.of(this);
  ColorScheme get colors => theme.colorScheme;
  TextTheme get text => theme.textTheme;

  TextStyle get headingXl {
    return (text.displayMedium ?? const TextStyle()).copyWith(
      fontFamily: 'SF Pro Display',
      fontWeight: FontWeight.w800,
    );
  }

  TextStyle get headingMd {
    return (text.headlineSmall ?? const TextStyle()).copyWith(
      fontFamily: 'SF Pro Display',
      fontWeight: FontWeight.w600,
    );
  }

  TextStyle get bodyLg {
    return (text.bodyLarge ?? const TextStyle()).copyWith(
      fontFamily: 'SF Pro Text',
      fontWeight: FontWeight.w500,
    );
  }

  TextStyle get bodyMd {
    return (text.bodyMedium ?? const TextStyle()).copyWith(
      fontFamily: 'SF Pro Text',
      fontWeight: FontWeight.w400,
    );
  }

  TextStyle onPrimaryStyle(
    TextStyle base, {
    double opacity = 1,
  }) {
    return base.copyWith(
      color: colors.onPrimary.withValues(alpha: opacity),
    );
  }
}
