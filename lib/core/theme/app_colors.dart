import 'package:flutter/material.dart';

class AppColors {
  static const Color primaryPurple = Color(0xFF8100D1);
  static const Color secondaryViolet = Color(0xFFB600BA);
  static const Color accentPink = Color(0xFFEE4FA2);
  static const Color accentPeach = Color(0xFFF09A77);

  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      primaryPurple,
      secondaryViolet,
      accentPink,
      accentPeach,
    ],
  );

  const AppColors._();
}
