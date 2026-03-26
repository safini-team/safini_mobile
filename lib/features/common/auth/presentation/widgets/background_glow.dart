import 'package:flutter/material.dart';

class BackgroundGlow extends StatelessWidget {
  final Alignment alignment;
  final double size;
  final double opacity;

  const BackgroundGlow({
    required this.alignment,
    required this.size,
    required this.opacity,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: alignment,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.white.withValues(alpha: opacity),
        ),
      ),
    );
  }
}
