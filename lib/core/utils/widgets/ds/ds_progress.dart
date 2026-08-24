import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:safini/core/theme/app_colors.dart';
import 'package:safini/core/theme/app_motion.dart';
import 'package:safini/core/theme/app_radius.dart';

/// The screen-time / quest ring. Starts at 12 o'clock, round cap, and the
/// centre slot holds whatever the artboard puts there.
///
/// Parent Today: 104px, r 44, stroke 11, track `#F0EDF5`, fill `#8100D1`.
/// Kid Today: 88px, r 37, stroke 10, track `rgba(255,255,255,.16)`, fill `#C77BFF`.
class DsProgressRing extends StatelessWidget {
  const DsProgressRing({
    super.key,
    required this.progress,
    this.size = 104,
    this.strokeWidth = 11,
    this.trackColor = AppColors.track,
    this.color = AppColors.primary,
    this.child,
    this.animate = true,
    this.radius = 44,
  });

  const DsProgressRing.onDeep({
    super.key,
    required this.progress,
    this.size = 88,
    this.strokeWidth = 10,
    this.child,
    this.animate = true,
    this.radius = 37,
  }) : trackColor = const Color(0x29FFFFFF),
       color = AppColors.primaryBar;

  final double progress;
  final double size;
  final double strokeWidth;
  final Color trackColor;
  final Color color;
  final Widget? child;
  final bool animate;

  /// The SVG's own circle radius - 44 in the 104 box, 37 in the 88 one. Kept
  /// explicit because the inscribed radius would sit 2.5px wider than the
  /// artboard and the ring would touch the card padding.
  final double radius;

  @override
  Widget build(BuildContext context) {
    final clamped = progress.isFinite ? progress.clamp(0.0, 1.0) : 0.0;

    Widget ring = SizedBox(
      width: size,
      height: size,
      child: TweenAnimationBuilder<double>(
        tween: Tween(begin: animate ? 0 : clamped, end: clamped),
        duration: animate ? const Duration(milliseconds: 720) : Duration.zero,
        curve: AppMotion.spring,
        builder: (context, value, _) => CustomPaint(
          painter: _RingPainter(
            progress: value,
            strokeWidth: strokeWidth,
            trackColor: trackColor,
            color: color,
            radius: radius,
          ),
        ),
      ),
    );

    if (child == null) return ring;
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [ring, child!],
      ),
    );
  }
}

class _RingPainter extends CustomPainter {
  const _RingPainter({
    required this.progress,
    required this.strokeWidth,
    required this.trackColor,
    required this.color,
    required this.radius,
  });

  final double progress;
  final double strokeWidth;
  final Color trackColor;
  final Color color;
  final double radius;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final rect = Rect.fromCircle(center: center, radius: radius);

    final track = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..color = trackColor;
    canvas.drawCircle(center, radius, track);

    if (progress <= 0) return;

    final fill = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round
      ..color = color;
    canvas.drawArc(rect, -math.pi / 2, 2 * math.pi * progress, false, fill);
  }

  @override
  bool shouldRepaint(_RingPainter old) =>
      old.progress != progress ||
      old.color != color ||
      old.trackColor != trackColor ||
      old.strokeWidth != strokeWidth ||
      old.radius != radius;
}

/// `height:5-8px;border-radius:100px` track with a rounded fill.
class DsProgressBar extends StatelessWidget {
  const DsProgressBar({
    super.key,
    required this.progress,
    this.height = 5,
    this.trackColor = AppColors.track,
    this.color = AppColors.primary,
    this.animate = true,
  });

  final double progress;
  final double height;
  final Color trackColor;
  final Color color;
  final bool animate;

  @override
  Widget build(BuildContext context) {
    final clamped = progress.isFinite ? progress.clamp(0.0, 1.0) : 0.0;

    return ClipRRect(
      borderRadius: BorderRadius.circular(AppRadius.pill),
      child: Container(
        height: height,
        color: trackColor,
        child: Align(
          alignment: Alignment.centerLeft,
          child: TweenAnimationBuilder<double>(
            tween: Tween(begin: animate ? 0 : clamped, end: clamped),
            duration: animate
                ? const Duration(milliseconds: 620)
                : Duration.zero,
            curve: AppMotion.spring,
            builder: (context, value, _) => FractionallySizedBox(
              widthFactor: value,
              child: Container(
                height: height,
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(AppRadius.pill),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// `repeating-linear-gradient(to right, rgba(129,0,209,.3) 0 3px, transparent 3px 7px)`
/// - the allowance line across the week chart.
class DsDashedLine extends StatelessWidget {
  const DsDashedLine({
    super.key,
    this.color = const Color(0x4D8100D1),
    this.dash = 3,
    this.gap = 4,
    this.thickness = 1,
  });

  final Color color;
  final double dash;
  final double gap;
  final double thickness;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: thickness,
      child: CustomPaint(
        size: Size.infinite,
        painter: _DashPainter(
          color: color,
          dash: dash,
          gap: gap,
          thickness: thickness,
        ),
      ),
    );
  }
}

class _DashPainter extends CustomPainter {
  const _DashPainter({
    required this.color,
    required this.dash,
    required this.gap,
    required this.thickness,
  });

  final Color color;
  final double dash;
  final double gap;
  final double thickness;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = thickness;
    var x = 0.0;
    while (x < size.width) {
      canvas.drawLine(
        Offset(x, thickness / 2),
        Offset(math.min(x + dash, size.width), thickness / 2),
        paint,
      );
      x += dash + gap;
    }
  }

  @override
  bool shouldRepaint(_DashPainter old) => old.color != color;
}
