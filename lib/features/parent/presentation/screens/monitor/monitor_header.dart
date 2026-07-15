import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:safini/core/translation/generated/l10n.dart';
import 'package:safini/core/utils/extension/theme_extension.dart';
import 'package:safini/features/parent/presentation/cubit/parent_cubit.dart';
import 'package:safini/features/parent/presentation/cubit/parent_monitor_cubit.dart';
import 'package:safini/features/parent/presentation/cubit/parent_monitor_state.dart';
import 'package:safini/features/parent/presentation/cubit/parent_state.dart';
import 'package:safini/features/parent/presentation/widgets/cards/parent_progress_card.dart';

String getTimeBasedGreeting(S s) {
  final hour = DateTime.now().hour;
  if (hour >= 5 && hour < 12) return s.goodMorning;
  if (hour >= 12 && hour < 17) return s.goodAfternoon;
  if (hour >= 17 && hour < 21) return s.goodEvening;
  return s.goodNight;
}

class MonitorGreetingTitle extends StatelessWidget {
  const MonitorGreetingTitle({super.key});

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          getTimeBasedGreeting(s),
          style: context.textTheme.bodyMedium?.copyWith(
            color: context.colorScheme.onPrimary.withValues(alpha: 0.7),
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 2),
        BlocBuilder<ParentCubit, ParentState>(
          builder: (context, state) {
            return Text(
              state.user?.displayName ?? s.parentName,
              style: context.textTheme.displaySmall?.copyWith(
                color: context.colorScheme.onPrimary,
                fontSize: 28,
                fontWeight: FontWeight.w900,
                letterSpacing: -0.5,
              ),
            );
          },
        ),
      ],
    );
  }
}

class MonitorFlexBackground extends StatefulWidget {
  const MonitorFlexBackground({super.key});

  @override
  State<MonitorFlexBackground> createState() => _MonitorFlexBackgroundState();
}

class _MonitorFlexBackgroundState extends State<MonitorFlexBackground> {
  // viewportFraction < 1 lets the next child's card peek, hinting "swipe".
  final PageController _controller = PageController(viewportFraction: 0.94);
  int _page = 0;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context);
    final topPadding = media.padding.top;
    // Grow the card viewport with the system font scale so a large font can't
    // overflow the fixed-height PageView.
    final textScale = media.textScaler.scale(1.0).clamp(1.0, 1.3);
    final cardHeight = 190.0 * textScale + 12;

    // Collapse progress of the header: 1.0 = fully expanded, 0.0 = collapsed.
    final settings =
        context.dependOnInheritedWidgetOfExactType<FlexibleSpaceBarSettings>();
    var t = 1.0;
    if (settings != null && settings.maxExtent > settings.minExtent) {
      t = ((settings.currentExtent - settings.minExtent) /
              (settings.maxExtent - settings.minExtent))
          .clamp(0.0, 1.0)
          .toDouble();
    }
    // Fade the card out during the first half of the collapse so it never
    // reaches (and overlaps) the pinned greeting above it.
    final cardOpacity = ((t - 0.5) / 0.5).clamp(0.0, 1.0).toDouble();

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            context.colorScheme.primary.withValues(alpha: 0.8),
            context.colorScheme.primary,
          ],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Reserve space for the toolbar area
          SizedBox(height: topPadding + 80),
          Opacity(
            opacity: cardOpacity,
            child: IgnorePointer(
              ignoring: cardOpacity < 0.05,
              child: BlocBuilder<ParentMonitorCubit, ParentMonitorState>(
                builder: (context, state) {
                  if (state is! ParentMonitorLoaded ||
                      state.children.isEmpty) {
                    return const SizedBox.shrink();
                  }
                  final children = state.children;
                  // Keep local page in sync if the list shrinks.
                  if (_page >= children.length) _page = 0;

                  return Column(
                    children: [
                      const SizedBox(height: 16),
                      SizedBox(
                        height: cardHeight,
                        child: PageView.builder(
                          controller: _controller,
                          itemCount: children.length,
                          onPageChanged: (i) {
                            setState(() => _page = i);
                            context.read<ParentMonitorCubit>().selectChild(i);
                          },
                          itemBuilder: (context, i) {
                            final child = children[i];
                            return Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 6),
                              child: ParentProgressCard(
                                name: child.nickname,
                                level: child.level,
                                coins: child.coinsBalance,
                                // Face is loaded for the selected child only.
                                faceEmoji: i == state.selectedIndex
                                    ? (state.faceEmoji ?? '👦')
                                    : '👦',
                              ),
                            );
                          },
                        ),
                      ),
                      if (children.length > 1) ...[
                        const SizedBox(height: 10),
                        _PageDots(count: children.length, active: _page),
                      ],
                      const SizedBox(height: 12),
                    ],
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PageDots extends StatelessWidget {
  final int count;
  final int active;

  const _PageDots({required this.count, required this.active});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(count, (i) {
        final selected = i == active;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          margin: const EdgeInsets.symmetric(horizontal: 3),
          width: selected ? 20 : 7,
          height: 7,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: selected ? 0.95 : 0.4),
            borderRadius: BorderRadius.circular(999),
          ),
        );
      }),
    );
  }
}
