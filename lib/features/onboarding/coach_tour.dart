import 'package:flutter/material.dart';
import 'package:safini/core/theme/app_colors.dart';
import 'package:safini/core/theme/app_motion.dart';
import 'package:safini/core/theme/app_typography.dart';
import 'package:safini/core/translation/generated/l10n.dart';
import 'package:safini/features/onboarding/fini.dart';

/// One stop on a coach-mark tour: what to light up and what Fini says.
class CoachStep {
  const CoachStep({required this.target, required this.text});

  final GlobalKey target;
  final String text;
}

/// Dims the screen, cuts a hole around each step's widget in turn, and has
/// Fini say one line next to it. A tap anywhere goes on; Skip ends it.
/// Steps whose widget is not on screen are left out.
Future<void> showCoachTour(BuildContext context, List<CoachStep> steps) {
  final shown = visibleSteps(steps);
  if (shown.isEmpty) return Future.value();
  return Navigator.of(context, rootNavigator: true).push(
    PageRouteBuilder<void>(
      opaque: false,
      barrierDismissible: false,
      transitionDuration: const Duration(milliseconds: 260),
      reverseTransitionDuration: const Duration(milliseconds: 200),
      pageBuilder: (_, _, _) => CoachTour(steps: shown),
      transitionsBuilder: (_, animation, _, child) =>
          FadeTransition(opacity: animation, child: child),
    ),
  );
}

/// The steps whose widget is laid out right now.
List<CoachStep> visibleSteps(List<CoachStep> steps) => [
  for (final step in steps)
    if (_rectOf(step.target) != null) step,
];

Rect? _rectOf(GlobalKey key) {
  final box = key.currentContext?.findRenderObject();
  if (box is! RenderBox || !box.hasSize || !box.attached) return null;
  return box.localToGlobal(Offset.zero) & box.size;
}

class CoachTour extends StatefulWidget {
  const CoachTour({super.key, required this.steps});

  final List<CoachStep> steps;

  @override
  State<CoachTour> createState() => _CoachTourState();
}

class _CoachTourState extends State<CoachTour> {
  int _index = 0;

  bool get _last => _index == widget.steps.length - 1;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _focus());
  }

  void _next() {
    if (_last) {
      Navigator.of(context).pop();
    } else {
      setState(() => _index++);
      _focus();
    }
  }

  /// Scrolls a step below the fold into view (Today's review list sits under
  /// the checklist on a new account), then redraws the hole where it landed.
  Future<void> _focus() async {
    final step = widget.steps[_index];
    final target = step.target.currentContext;
    final rect = _rectOf(step.target);
    if (target == null || rect == null) return;
    // Clear of the status bar and of the floating tab bar (112).
    final size = MediaQuery.sizeOf(context);
    final top = MediaQuery.paddingOf(context).top;
    if (rect.top >= top && rect.bottom <= size.height - 112) return;
    await Scrollable.ensureVisible(
      target,
      alignment: 0.45,
      duration: const Duration(milliseconds: 300),
      curve: AppMotion.spring,
    );
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final size = MediaQuery.sizeOf(context);
    final step = widget.steps[_index];
    final hole = (_rectOf(step.target) ?? Rect.zero).inflate(8);
    final below = hole.center.dy < size.height / 2;

    return Material(
      type: MaterialType.transparency,
      child: GestureDetector(
        key: const ValueKey('coach-scrim'),
        behavior: HitTestBehavior.opaque,
        onTap: _next,
        child: Stack(
          children: [
            Positioned.fill(
              child: TweenAnimationBuilder<Rect?>(
                tween: RectTween(end: hole),
                duration: const Duration(milliseconds: 320),
                curve: AppMotion.spring,
                builder: (context, rect, _) =>
                    CustomPaint(painter: _ScrimPainter(rect ?? hole)),
              ),
            ),
            AnimatedPositioned(
              duration: const Duration(milliseconds: 320),
              curve: AppMotion.spring,
              left: 16,
              right: 16,
              top: below ? hole.bottom + 14 : null,
              bottom: below ? null : size.height - hole.top + 14,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  FiniSays(size: 72, pose: FiniPose.point, text: step.text),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      if (!_last)
                        TextButton(
                          onPressed: () => Navigator.of(context).pop(),
                          child: Text(
                            s.tourSkip,
                            style: AppText.body.copyWith(
                              color: AppColors.textOnPrimary.withValues(
                                alpha: 0.8,
                              ),
                            ),
                          ),
                        ),
                      const Spacer(),
                      for (var i = 0; i < widget.steps.length; i++)
                        Container(
                          width: i == _index ? 16 : 6,
                          height: 6,
                          margin: const EdgeInsets.symmetric(horizontal: 2),
                          decoration: BoxDecoration(
                            color: AppColors.textOnPrimary.withValues(
                              alpha: i == _index ? 1 : 0.45,
                            ),
                            borderRadius: BorderRadius.circular(3),
                          ),
                        ),
                      const SizedBox(width: 12),
                      FilledButton(
                        key: const ValueKey('coach-next'),
                        onPressed: _next,
                        style: FilledButton.styleFrom(
                          backgroundColor: AppColors.surface,
                          foregroundColor: AppColors.primary,
                        ),
                        child: Text(_last ? s.tourDone : s.tourNext),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ScrimPainter extends CustomPainter {
  const _ScrimPainter(this.hole);

  final Rect hole;

  @override
  void paint(Canvas canvas, Size size) {
    final path = Path.combine(
      PathOperation.difference,
      Path()..addRect(Offset.zero & size),
      Path()
        ..addRRect(RRect.fromRectAndRadius(hole, const Radius.circular(22))),
    );
    canvas.drawPath(path, Paint()..color = const Color(0xB30C231C));
  }

  @override
  bool shouldRepaint(_ScrimPainter old) => old.hole != hole;
}
