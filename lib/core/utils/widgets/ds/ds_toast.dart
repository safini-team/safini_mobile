import 'package:flutter/material.dart';
import 'package:safini/core/theme/app_colors.dart';
import 'package:safini/core/theme/app_motion.dart';
import 'package:safini/core/theme/app_radius.dart';
import 'package:safini/core/utils/widgets/ds/ds_blur.dart';

/// The dark capsule toast: `bottom:112px`, `rgba(23,21,28,.9)` + blur(20),
/// a green tick, `toastIn 300ms`, gone after 2.4s.
///
/// One at a time - a second call replaces the first, exactly as
/// `flash()` does in the design (`clearTimeout(this._toast)`).
class DsToast {
  const DsToast._();

  static OverlayEntry? _entry;
  static int _generation = 0;

  static void show(BuildContext context, String message, {bool success = true}) {
    final overlay = Overlay.maybeOf(context, rootOverlay: true);
    if (overlay == null) return;

    _entry?.remove();
    final generation = ++_generation;

    final entry = OverlayEntry(
      builder: (context) => Positioned(
        left: 0,
        right: 0,
        bottom: 112,
        child: IgnorePointer(
          child: Center(child: _Toast(message: message, success: success)),
        ),
      ),
    );

    _entry = entry;
    overlay.insert(entry);

    Future.delayed(AppMotion.toastDwell, () {
      if (generation != _generation) return;
      _entry?.remove();
      _entry = null;
    });
  }

  static void dismiss() {
    _generation++;
    _entry?.remove();
    _entry = null;
  }
}

class _Toast extends StatefulWidget {
  const _Toast({required this.message, required this.success});

  final String message;
  final bool success;

  @override
  State<_Toast> createState() => _ToastState();
}

class _ToastState extends State<_Toast> with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: AppMotion.toast,
  )..forward();
  late final Animation<double> _t = CurvedAnimation(
    parent: _c,
    curve: AppMotion.spring,
  );

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _t,
      builder: (context, child) => Opacity(
        opacity: _t.value,
        child: Transform.translate(
          offset: Offset(0, 12 * (1 - _t.value)),
          child: Transform.scale(scale: 0.97 + 0.03 * _t.value, child: child),
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppRadius.pill),
        child: DsBackdrop(
          blur: 20,
          saturation: 1,
          child: Container(
            constraints: const BoxConstraints(maxWidth: 320),
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 13),
            decoration: const BoxDecoration(
              color: Color(0xE60C231C),
              boxShadow: [
                BoxShadow(
                  color: Color(0x80000000),
                  offset: Offset(0, 16),
                  blurRadius: 34,
                  spreadRadius: -16,
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (widget.success) ...[
                  const _Tick(),
                  const SizedBox(width: 9),
                ],
                Flexible(
                  child: Text(
                    widget.message,
                    style: const TextStyle(
                      fontSize: 14.5,
                      fontWeight: FontWeight.w500,
                      letterSpacing: -0.0725,
                      height: 1.3,
                      color: AppColors.textOnPrimary,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// `M3 8.5l3.2 3.2L13 4.5` in `#5BE59A` - the toast's own tick, brighter than
/// the app's green because it sits on near-black.
class _Tick extends StatelessWidget {
  const _Tick();

  @override
  Widget build(BuildContext context) {
    return const SizedBox(
      width: 15,
      height: 15,
      child: CustomPaint(painter: _TickPainter()),
    );
  }
}

class _TickPainter extends CustomPainter {
  const _TickPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final k = size.width / 16;
    final paint = Paint()
      ..color = const Color(0xFF6FCB9F)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.2 * k
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final path = Path()
      ..moveTo(3 * k, 8.5 * k)
      ..lineTo(6.2 * k, 11.7 * k)
      ..lineTo(13 * k, 4.5 * k);
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(_TickPainter old) => false;
}
