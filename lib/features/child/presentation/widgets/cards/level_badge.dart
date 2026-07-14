import 'package:flutter/material.dart';
import 'package:safini/core/theme/app_radius.dart';
import 'package:safini/core/utils/extension/theme_extension.dart';

/// A small gold pill that shows the child's level, e.g. "Level 5".
///
/// A value of 0 renders a label without a number. Presentation-only and
/// reusable anywhere a level needs to be shown.
class LevelBadge extends StatelessWidget {
  /// The child's level; 0 hides the number.
  final int level;

  const LevelBadge({super.key, required this.level});

  static const Color _color = Color(0xFFF5A623);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
      decoration: BoxDecoration(
        color: _color,
        borderRadius: BorderRadius.circular(AppRadius.pill),
      ),
      child: Text(
        level > 0 ? 'Level $level' : 'Level',
        style: context.textTheme.labelLarge?.copyWith(
          color: Colors.white,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}
