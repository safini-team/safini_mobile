import 'package:flutter/material.dart';

class AppColors {
  static const Color primary = Color(0xFF8100D1); // Vibrant purple
  static const Color primaryDeep = Color(0xFF2D005F);
  static const Color primaryLight = Color(0xFFF0E6FF);
  
  static const Color secondary = Color(0xFFB600BA);
  static const Color accentPink = Color(0xFFEE4FA2);
  static const Color accentPeach = Color(0xFFF09A77);

  static const Color textPrimary = Color(0xFF1F1F1F);
  static const Color textSecondary = Color(0xFF757575);
  static const Color textOnPrimary = Colors.white;
  
  static const Color surface = Colors.white;
  static const Color background = Color(0xFFF8F9FE);
  static const Color error = Color(0xFFFF3B30);
  static const Color success = Color(0xFF00C566);
  static const Color warning = Color(0xFFFFD54F);
  static const Color info = Color(0xFF007AFF);

  static const Color cardShadow = Color(0x0A000000);
  static const Color border = Color(0xFFE0E0E0);

  static const LinearGradient brandGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF2D005F), Color(0xFF8100D1)],
  );

  const AppColors._();
}
