import 'package:flutter/material.dart';

class AppColors {
  static const Color primary = Color(0xFF8100D1);
  static const Color secondary = Color(0xFFB600BA);
  static const Color accentPink = Color(0xFFEE4FA2);
  static const Color accentPeach = Color(0xFFF09A77);

  static const Color textPrimary = Color(0xFF1F1F1F);
  static const Color textOnPrimary = Colors.white;
  static const Color surface = Colors.white;
  static const Color error = Color(0xFFB00020);

  static const LinearGradient brandGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [primary, secondary, accentPink, accentPeach],
  );

  const AppColors._();
}
