import 'package:flutter/material.dart';
import 'package:safini/core/theme/app_colors.dart';
import 'package:safini/core/theme/app_radius.dart';

/// Round initial badge - the design's stand-in for a photo everywhere a person
/// appears. White bold initial on the child's own colour.
class DsInitialAvatar extends StatelessWidget {
  const DsInitialAvatar({
    super.key,
    required this.name,
    this.color,
    this.size = 38,
    this.fontSize,
    this.label,
  });

  final String name;
  final Color? color;
  final double size;
  final double? fontSize;

  /// Rendered verbatim instead of the derived initial - the "Everyone" entry
  /// in the kid picker uses a middot.
  final String? label;

  static String initialOf(String name) {
    final trimmed = name.trim();
    if (trimmed.isEmpty) return '?';
    return trimmed.characters.first.toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: color ?? AppColors.kidColor(name),
        shape: BoxShape.circle,
      ),
      child: Text(
        label ?? initialOf(name),
        style: TextStyle(
          fontSize: fontSize ?? size * 0.395,
          fontWeight: FontWeight.w700,
          color: AppColors.textOnPrimary,
          height: 1,
        ),
      ),
    );
  }
}

/// The rounded emoji tile that leads a task or app row:
/// `34-46px;border-radius:9-16px;background:#F2F0F6 | #F3E9FD`.
class DsEmojiTile extends StatelessWidget {
  const DsEmojiTile({
    super.key,
    required this.emoji,
    this.size = 34,
    this.radius = AppRadius.sm,
    this.background = AppColors.fill,
    this.fontSize,
    this.opacity = 1,
  });

  final String emoji;
  final double size;
  final double radius;
  final Color background;
  final double? fontSize;
  final double opacity;

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: opacity,
      child: Container(
        width: size,
        height: size,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: background,
          borderRadius: BorderRadius.circular(radius),
        ),
        child: Text(
          emoji,
          style: TextStyle(fontSize: fontSize ?? size * 0.5, height: 1.15),
        ),
      ),
    );
  }
}

/// The 6-7px presence dot next to a child's status line.
class DsStatusDot extends StatelessWidget {
  const DsStatusDot({
    super.key,
    required this.online,
    this.size = 6,
    this.color,
  });

  const DsStatusDot.tinted({super.key, required this.color, this.size = 7})
    : online = false;

  final bool online;
  final double size;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color ?? (online ? AppColors.success : AppColors.chevron),
        shape: BoxShape.circle,
      ),
    );
  }
}
