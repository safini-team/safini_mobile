import 'package:flutter/material.dart';
import 'package:safini/core/theme/app_colors.dart';

class AppTheme {
  const AppTheme._();

  static ThemeData get light {
    final colorScheme = const ColorScheme.light(
      primary: AppColors.primaryPurple,
      secondary: AppColors.secondaryViolet,
      tertiary: AppColors.accentPink,
      surface: Colors.white,
      onPrimary: Colors.white,
      onSecondary: Colors.white,
      onSurface: Color(0xFF1F1F1F),
      error: Color(0xFFB00020),
      onError: Colors.white,
    );

    final baseTextTheme = ThemeData.light(useMaterial3: true).textTheme;
    final textTheme = baseTextTheme.copyWith(
      displayLarge: baseTextTheme.displayLarge?.copyWith(
        fontFamily: 'SF Pro Display',
        fontWeight: FontWeight.w800,
      ),
      displayMedium: baseTextTheme.displayMedium?.copyWith(
        fontFamily: 'SF Pro Display',
        fontWeight: FontWeight.w700,
      ),
      displaySmall: baseTextTheme.displaySmall?.copyWith(
        fontFamily: 'SF Pro Display',
        fontWeight: FontWeight.w700,
      ),
      headlineLarge: baseTextTheme.headlineLarge?.copyWith(
        fontFamily: 'SF Pro Display',
        fontWeight: FontWeight.w700,
      ),
      headlineMedium: baseTextTheme.headlineMedium?.copyWith(
        fontFamily: 'SF Pro Display',
        fontWeight: FontWeight.w700,
      ),
      headlineSmall: baseTextTheme.headlineSmall?.copyWith(
        fontFamily: 'SF Pro Display',
        fontWeight: FontWeight.w600,
      ),
      titleLarge: baseTextTheme.titleLarge?.copyWith(
        fontFamily: 'SF Pro Display',
        fontWeight: FontWeight.w600,
      ),
      titleMedium: baseTextTheme.titleMedium?.copyWith(
        fontFamily: 'SF Pro Text',
        fontWeight: FontWeight.w600,
      ),
      bodyLarge: baseTextTheme.bodyLarge?.copyWith(
        fontFamily: 'SF Pro Text',
        fontWeight: FontWeight.w500,
      ),
      bodyMedium: baseTextTheme.bodyMedium?.copyWith(
        fontFamily: 'SF Pro Text',
        fontWeight: FontWeight.w400,
      ),
      bodySmall: baseTextTheme.bodySmall?.copyWith(
        fontFamily: 'SF Pro Text',
        fontWeight: FontWeight.w400,
      ),
      labelLarge: baseTextTheme.labelLarge?.copyWith(
        fontFamily: 'SF Pro Text',
        fontWeight: FontWeight.w600,
      ),
      labelMedium: baseTextTheme.labelMedium?.copyWith(
        fontFamily: 'SF Pro Text',
        fontWeight: FontWeight.w400,
      ),
      labelSmall: baseTextTheme.labelSmall?.copyWith(
        fontFamily: 'SF Pro Text',
        fontWeight: FontWeight.w400,
      ),
    );

    return ThemeData(
      colorScheme: colorScheme,
      primaryColor: AppColors.primaryPurple,
      scaffoldBackgroundColor: Colors.white,
      fontFamily: 'SF Pro Text',
      textTheme: textTheme,
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        foregroundColor: Color(0xFF1F1F1F),
        elevation: 0,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryPurple,
          foregroundColor: Colors.white,
          textStyle: const TextStyle(
            fontFamily: 'SF Pro Text',
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      useMaterial3: true,
    );
  }
}
