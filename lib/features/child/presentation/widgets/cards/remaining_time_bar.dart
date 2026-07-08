import 'package:flutter/material.dart';
import 'package:safini/core/utils/countdown_controller.dart';
import 'package:safini/core/utils/extension/theme_extension.dart';

/// Shows how much redeemed app time is left as a live `MM:SS` countdown with a
/// shrinking progress line.
///
/// Responsibilities are split (SRP):
///  - [CountdownController] owns the ticking logic;
///  - this widget owns the controller's lifecycle;
///  - [_CountdownView] is a pure, stateless renderer.
///
/// Note: this counts down by wall-clock time from when the grant is shown.
/// Redeemed minutes are actually consumed only while the child uses the app
/// (tracked server-side); this is a visual indicator, not exact usage.
class RemainingTimeBar extends StatefulWidget {
  /// Total granted minutes to count down from.
  final int minutes;

  const RemainingTimeBar({super.key, required this.minutes});

  @override
  State<RemainingTimeBar> createState() => _RemainingTimeBarState();
}

class _RemainingTimeBarState extends State<RemainingTimeBar> {
  late final CountdownController _countdown = CountdownController(
    total: Duration(minutes: widget.minutes),
  );

  @override
  void didUpdateWidget(RemainingTimeBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.minutes != widget.minutes) {
      _countdown.reset(Duration(minutes: widget.minutes));
    }
  }

  @override
  void dispose() {
    _countdown.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _countdown,
      builder: (context, _) => _CountdownView(
        remaining: _countdown.remaining,
        fraction: _countdown.fraction,
      ),
    );
  }
}

/// Pure renderer for a countdown: it only draws the state it is given.
class _CountdownView extends StatelessWidget {
  final Duration remaining;
  final double fraction;

  const _CountdownView({required this.remaining, required this.fraction});

  String get _label {
    final mm = remaining.inMinutes.toString().padLeft(2, '0');
    final ss = (remaining.inSeconds % 60).toString().padLeft(2, '0');
    return '$mm:$ss';
  }

  @override
  Widget build(BuildContext context) {
    final color = context.successColor;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.timer_outlined, size: 13, color: color),
            const SizedBox(width: 4),
            Text(
              _label,
              style: context.textTheme.labelSmall?.copyWith(
                color: color,
                fontWeight: FontWeight.w800,
                fontFeatures: const [FontFeature.tabularFigures()],
              ),
            ),
          ],
        ),
        const SizedBox(height: 5),
        ClipRRect(
          borderRadius: BorderRadius.circular(999),
          child: LinearProgressIndicator(
            value: fraction,
            minHeight: 5,
            backgroundColor: color.withValues(alpha: 0.15),
            valueColor: AlwaysStoppedAnimation<Color>(color),
          ),
        ),
      ],
    );
  }
}
