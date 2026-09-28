import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:safini/core/di/injection.dart';
import 'package:safini/core/theme/app_colors.dart';
import 'package:safini/core/theme/app_typography.dart';
import 'package:safini/core/translation/generated/l10n.dart';
import 'package:safini/features/onboarding/fini.dart';
import 'package:safini/features/onboarding/onboarding_store.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

enum TourRole { parent, child }

/// A short, account-scoped walk through the actual tabs. The parent setup
/// checklist remains on Today; this only explains where things live.
class FirstRunTour extends StatefulWidget {
  const FirstRunTour({
    super.key,
    required this.role,
    required this.userId,
    required this.selectedTab,
    required this.onSelectTab,
    required this.tabBarKey,
    required this.child,
    this.reviewKey,
    this.onOpenGifts,
  });

  final TourRole role;
  final String? userId;
  final int selectedTab;
  final ValueChanged<int> onSelectTab;
  final GlobalKey tabBarKey;
  final GlobalKey? reviewKey;
  final VoidCallback? onOpenGifts;
  final Widget child;

  @override
  State<FirstRunTour> createState() => _FirstRunTourState();
}

class _FirstRunTourState extends State<FirstRunTour> {
  int? _step;
  String? _checkedUserId;

  int get _total => widget.role == TourRole.parent ? 6 : 4;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _startIfNeeded());
  }

  @override
  void didUpdateWidget(FirstRunTour oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.userId != widget.userId || oldWidget.role != widget.role) {
      _step = null;
      _checkedUserId = null;
    }
    if (oldWidget.userId != widget.userId ||
        oldWidget.role != widget.role ||
        (oldWidget.selectedTab != 0 && widget.selectedTab == 0)) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _startIfNeeded());
    }
  }

  void _startIfNeeded() {
    final userId = widget.userId;
    if (!mounted ||
        userId == null ||
        widget.selectedTab != 0 ||
        _step != null ||
        _checkedUserId == userId) {
      return;
    }
    _checkedUserId = userId;
    final saved = getIt<OnboardingStore>().tourStep(widget.role.name, userId);
    if (saved != null && saved >= _total) return;
    if (saved == null && !_recentAccount()) return;
    final step = (saved ?? 0).clamp(0, _total - 1);
    setState(() => _step = step);
    _showStep(step);
  }

  /// Existing accounts should not receive a surprise walkthrough on upgrade.
  /// When auth metadata is unavailable, a once-per-account tour is preferable
  /// to silently missing onboarding for a new account.
  bool _recentAccount() {
    try {
      final created = DateTime.tryParse(
        Supabase.instance.client.auth.currentUser?.createdAt ?? '',
      );
      return created == null || DateTime.now().difference(created).inDays <= 30;
    } catch (_) {
      return true;
    }
  }

  void _showStep(int step) {
    if (widget.role == TourRole.parent && step == 4) {
      widget.onOpenGifts?.call();
    } else {
      widget.onSelectTab(_tabFor(step));
    }
    if (widget.role == TourRole.parent &&
        step == 1 &&
        widget.reviewKey != null) {
      _revealReview();
    }
  }

  Future<void> _revealReview() async {
    // The setup checklist can push review below the fold on a new account.
    // Let the dashboard finish loading, then bring the real section into view.
    for (var attempt = 0; attempt < 12; attempt++) {
      await Future<void>.delayed(const Duration(milliseconds: 300));
      if (!mounted || _step != 1) return;
      final target = widget.reviewKey?.currentContext;
      if (target == null || !target.mounted) continue;
      await Scrollable.ensureVisible(
        target,
        alignment: 0.25,
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeInOut,
      );
      if (mounted && _step == 1) setState(() {});
      return;
    }
  }

  int _tabFor(int step) => widget.role == TourRole.parent
      ? switch (step) {
          0 || 1 => 0,
          2 => 1,
          3 || 4 => 2,
          _ => 3,
        }
      : step;

  void _advance() {
    final next = _step! + 1;
    if (next >= _total) {
      _finish();
      return;
    }
    setState(() => _step = next);
    _save(next);
    _showStep(next);
  }

  void _finish() {
    _save(_total);
    setState(() => _step = null);
  }

  void _save(int step) {
    final userId = widget.userId;
    if (userId != null) {
      getIt<OnboardingStore>().saveTourStep(widget.role.name, userId, step);
    }
  }

  @override
  Widget build(BuildContext context) {
    final step = _step;
    return Stack(
      children: [
        widget.child,
        if (step != null)
          Positioned.fill(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final size = constraints.biggest;
                final bar = _rectFor(widget.tabBarKey, context);
                final review = step == 1 && widget.role == TourRole.parent
                    ? _rectFor(widget.reviewKey, context)
                    : null;
                final tabWidth = (bar?.width ?? size.width) / 4;
                final tab = _tabFor(step);
                final focus =
                    review ??
                    Rect.fromLTWH(
                      (bar?.left ?? 0) + tabWidth * tab + 4,
                      (bar?.top ?? size.height - 88) + 3,
                      tabWidth - 8,
                      math.min((bar?.height ?? 76) - 6, 78),
                    );
                final barHeight = bar == null ? 88.0 : size.height - bar.top;
                return Stack(
                  children: [
                    Positioned.fill(
                      child: CustomPaint(painter: _TourShade(focus.inflate(5))),
                    ),
                    Positioned(
                      left: 18,
                      right: 18,
                      bottom: barHeight + 18,
                      child: ConstrainedBox(
                        constraints: BoxConstraints(
                          maxHeight: math.max(
                            160,
                            size.height - barHeight - 45,
                          ),
                        ),
                        child: SingleChildScrollView(
                          child: _TourCard(
                            step: step,
                            total: _total,
                            role: widget.role,
                            onNext: _advance,
                            onSkip: _finish,
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
      ],
    );
  }

  Rect? _rectFor(GlobalKey? key, BuildContext overlayContext) {
    final target = key?.currentContext?.findRenderObject();
    final overlay = overlayContext.findRenderObject();
    if (target is! RenderBox || overlay is! RenderBox || !target.hasSize) {
      return null;
    }
    // The target lives in the Scaffold, a sibling of this overlay.
    final origin =
        target.localToGlobal(Offset.zero) - overlay.localToGlobal(Offset.zero);
    return origin & target.size;
  }
}

class _TourShade extends CustomPainter {
  const _TourShade(this.focus);

  final Rect focus;

  @override
  void paint(Canvas canvas, Size size) {
    final outer = Path()..addRect(Offset.zero & size);
    final hole = Path()
      ..addRRect(RRect.fromRectAndRadius(focus, const Radius.circular(20)));
    canvas.drawPath(
      Path.combine(PathOperation.difference, outer, hole),
      Paint()..color = const Color(0xB90D3027),
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(focus, const Radius.circular(20)),
      Paint()
        ..color = Colors.white
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    );
  }

  @override
  bool shouldRepaint(_TourShade oldDelegate) => oldDelegate.focus != focus;
}

class _TourCard extends StatelessWidget {
  const _TourCard({
    required this.step,
    required this.total,
    required this.role,
    required this.onNext,
    required this.onSkip,
  });

  final int step;
  final int total;
  final TourRole role;
  final VoidCallback onNext;
  final VoidCallback onSkip;

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final (title, body) = role == TourRole.parent
        ? switch (step) {
            0 => (s.tourParentTodayTitle, s.tourParentTodayBody),
            1 => (s.tourParentReviewTitle, s.tourParentReviewBody),
            2 => (s.tourParentTasksTitle, s.tourParentTasksBody),
            3 => (s.tourParentLimitsTitle, s.tourParentLimitsBody),
            4 => (s.tourParentGiftsTitle, s.tourParentGiftsBody),
            _ => (s.tourParentFamilyTitle, s.tourParentFamilyBody),
          }
        : switch (step) {
            0 => (s.tourChildTodayTitle, s.tourChildTodayBody),
            1 => (s.tourChildTasksTitle, s.tourChildTasksBody),
            2 => (s.tourChildStoreTitle, s.tourChildStoreBody),
            _ => (s.tourChildMeTitle, s.tourChildMeBody),
          };
    return Material(
      color: AppColors.surface,
      elevation: 12,
      shadowColor: Colors.black26,
      borderRadius: BorderRadius.circular(22),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(18, 16, 18, 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Text(s.tourStep(step + 1, total), style: AppText.meta),
                const Spacer(),
                TextButton(onPressed: onSkip, child: Text(s.tourSkip)),
              ],
            ),
            FiniSays(text: body, size: 54),
            const SizedBox(height: 8),
            Text(title, style: AppText.title2),
            const SizedBox(height: 14),
            Align(
              alignment: Alignment.centerRight,
              child: FilledButton(
                key: const ValueKey('tour-next'),
                onPressed: onNext,
                child: Text(step == total - 1 ? s.tourDone : s.tourNext),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
