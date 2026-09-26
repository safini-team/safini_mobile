import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:safini/core/theme/app_colors.dart';
import 'package:safini/core/theme/app_shadows.dart';
import 'package:safini/core/theme/app_typography.dart';

/// Fini, the penguin from the splash screen, as the guide through setup.
///
/// Pops in once, then floats a few pixels up and down. Both motions are off
/// when the platform asks for reduced motion.
class Fini extends StatefulWidget {
  const Fini({super.key, this.size = 72, this.cheer = false});

  final double size;

  /// A few quick hops instead of the slow float, for a finished step.
  final bool cheer;

  static const asset = 'assets/logo/safini-mascot.png';

  @override
  State<Fini> createState() => _FiniState();
}

class _FiniState extends State<Fini> with TickerProviderStateMixin {
  late final AnimationController _pop = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 520),
  );
  late final AnimationController _idle = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 2600),
  );

  bool _still = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _still = MediaQuery.maybeDisableAnimationsOf(context) ?? false;
    if (_still) {
      _pop.value = 1;
      _idle.stop();
    } else {
      if (!_pop.isAnimating && _pop.value == 0) _pop.forward();
      _setIdle();
    }
  }

  @override
  void didUpdateWidget(Fini oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.cheer != widget.cheer && !_still) _setIdle();
  }

  void _setIdle() {
    _idle.duration = widget.cheer
        ? const Duration(milliseconds: 700)
        : const Duration(milliseconds: 2600);
    _idle.repeat();
  }

  @override
  void dispose() {
    _pop.dispose();
    _idle.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final image = Image.asset(
      Fini.asset,
      width: widget.size,
      height: widget.size,
      fit: BoxFit.contain,
      excludeFromSemantics: true,
    );
    return AnimatedBuilder(
      animation: Listenable.merge([_pop, _idle]),
      child: image,
      builder: (context, child) {
        final t = _idle.value * 2 * math.pi;
        final dy = widget.cheer
            ? -(math.sin(t).abs()) * widget.size * 0.10
            : math.sin(t) * widget.size * 0.03;
        final tilt = widget.cheer ? math.sin(t) * 0.06 : 0.0;
        return Transform.translate(
          offset: Offset(0, _still ? 0 : dy),
          child: Transform.rotate(
            angle: _still ? 0 : tilt,
            child: Transform.scale(
              scale: Curves.elasticOut.transform(_pop.value).clamp(0.0, 1.2),
              alignment: Alignment.bottomCenter,
              child: child,
            ),
          ),
        );
      },
    );
  }
}

/// Fini with a speech bubble on its right. One line, two at most: Fini says
/// the next thing to do, not how the app works.
class FiniSays extends StatelessWidget {
  const FiniSays({
    super.key,
    required this.text,
    this.size = 64,
    this.cheer = false,
    this.bubbleColor = AppColors.surface,
  });

  final String text;
  final double size;
  final bool cheer;
  final Color bubbleColor;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Fini(size: size, cheer: cheer),
        const SizedBox(width: 6),
        Expanded(
          child: Padding(
            padding: EdgeInsets.only(bottom: size * 0.32),
            child: FiniBubble(text: text, color: bubbleColor),
          ),
        ),
      ],
    );
  }
}

/// The bubble alone, tail on its lower left pointing at Fini.
class FiniBubble extends StatelessWidget {
  const FiniBubble({
    super.key,
    required this.text,
    this.color = AppColors.surface,
  });

  final String text;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 220),
      transitionBuilder: (child, animation) => FadeTransition(
        opacity: animation,
        child: ScaleTransition(
          scale: Tween(begin: 0.96, end: 1.0).animate(animation),
          alignment: Alignment.bottomLeft,
          child: child,
        ),
      ),
      child: CustomPaint(
        key: ValueKey(text),
        painter: _BubblePainter(color),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 11, 14, 12),
          child: Text(text, style: AppText.body),
        ),
      ),
    );
  }
}

class _BubblePainter extends CustomPainter {
  const _BubblePainter(this.color);

  final Color color;

  static const _tail = 8.0;
  static const _radius = 16.0;

  @override
  void paint(Canvas canvas, Size size) {
    final body = RRect.fromLTRBR(
      _tail,
      0,
      size.width,
      size.height,
      const Radius.circular(_radius),
    );
    final tail = Path()
      ..moveTo(_tail, size.height - 22)
      ..quadraticBezierTo(_tail - 2, size.height - 6, 0, size.height)
      ..quadraticBezierTo(_tail + 8, size.height - 2, _tail + 14, size.height)
      ..lineTo(_tail + 14, size.height - 22)
      ..close();
    final path = Path.combine(
      PathOperation.union,
      Path()..addRRect(body),
      tail,
    );
    // On a white card a tinted bubble stands out on its own; a white bubble
    // on the tinted kid background needs the lift.
    if (color == AppColors.surface) {
      for (final shadow in AppShadows.cardSoft) {
        canvas.drawPath(
          path.shift(shadow.offset),
          Paint()
            ..color = shadow.color
            ..maskFilter = MaskFilter.blur(BlurStyle.normal, shadow.blurSigma),
        );
      }
    }
    canvas.drawPath(path, Paint()..color = color);
  }

  @override
  bool shouldRepaint(_BubblePainter old) => old.color != color;
}

/// A one-shot burst of coin-and-pine confetti from the top centre.
class FiniConfetti extends StatefulWidget {
  const FiniConfetti({super.key, this.pieces = 36});

  final int pieces;

  @override
  State<FiniConfetti> createState() => _FiniConfettiState();
}

class _FiniConfettiState extends State<FiniConfetti>
    with SingleTickerProviderStateMixin {
  late final AnimationController _t = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1600),
  );
  late final List<_Piece> _pieces;

  @override
  void initState() {
    super.initState();
    final random = math.Random(7);
    const colors = [
      AppColors.coin,
      AppColors.primary,
      AppColors.success,
      AppColors.primaryPale,
      AppColors.catFitness,
    ];
    _pieces = [
      for (var i = 0; i < widget.pieces; i++)
        _Piece(
          angle: -math.pi / 2 + (random.nextDouble() - 0.5) * math.pi * 0.9,
          speed: 0.55 + random.nextDouble() * 0.6,
          spin: (random.nextDouble() - 0.5) * 14,
          color: colors[i % colors.length],
          size: 5 + random.nextDouble() * 4,
        ),
    ];
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (MediaQuery.maybeDisableAnimationsOf(context) ?? false) return;
    if (!_t.isAnimating && _t.value == 0) _t.forward();
  }

  @override
  void dispose() {
    _t.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: AnimatedBuilder(
        animation: _t,
        builder: (context, _) => CustomPaint(
          size: Size.infinite,
          painter: _ConfettiPainter(_pieces, _t.value),
        ),
      ),
    );
  }
}

class _Piece {
  const _Piece({
    required this.angle,
    required this.speed,
    required this.spin,
    required this.color,
    required this.size,
  });

  final double angle;
  final double speed;
  final double spin;
  final Color color;
  final double size;
}

class _ConfettiPainter extends CustomPainter {
  const _ConfettiPainter(this.pieces, this.t);

  final List<_Piece> pieces;
  final double t;

  @override
  void paint(Canvas canvas, Size size) {
    if (t == 0 || t == 1) return;
    final origin = Offset(size.width / 2, size.height * 0.35);
    final reach = size.shortestSide * 0.9;
    final fade = t < 0.7 ? 1.0 : 1 - (t - 0.7) / 0.3;
    for (final piece in pieces) {
      final d = piece.speed * reach * Curves.easeOutCubic.transform(t);
      final gravity = size.height * 0.5 * t * t;
      final position =
          origin +
          Offset(
            math.cos(piece.angle) * d,
            math.sin(piece.angle) * d + gravity,
          );
      canvas
        ..save()
        ..translate(position.dx, position.dy)
        ..rotate(piece.spin * t);
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromCenter(
            center: Offset.zero,
            width: piece.size,
            height: piece.size * 0.55,
          ),
          const Radius.circular(1.5),
        ),
        Paint()..color = piece.color.withValues(alpha: fade),
      );
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(_ConfettiPainter old) => old.t != t;
}
