import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:safini/core/di/injection.dart';
import 'package:safini/core/utils/extension/theme_extension.dart';
import 'package:safini/features/parent/presentation/cubit/parent_monitor_cubit.dart';
import 'package:safini/features/parent/presentation/cubit/parent_monitor_state.dart';
import 'package:safini/features/parent/presentation/cubit/parent_tasks_cubit.dart';
import 'package:safini/features/parent/presentation/widgets/charts/parent_screen_time_chart.dart';
import 'package:safini/features/parent/presentation/widgets/layout/parent_no_child_empty_state.dart';
import 'package:safini/features/parent/presentation/screens/monitor/monitor_header.dart';
import 'package:safini/features/parent/presentation/screens/monitor/monitor_stats_row.dart';
import 'package:safini/features/parent/presentation/screens/monitor/monitor_app_limits_section.dart';
import 'package:safini/features/parent/presentation/screens/monitor/monitor_tasks_section.dart';

class ParentMonitorScreen extends StatelessWidget {
  const ParentMonitorScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => getIt<ParentMonitorCubit>()..loadMonitorData(),
        ),
        BlocProvider(
          create: (context) => getIt<ParentTasksCubit>()..loadTasks(),
        ),
      ],
      child: const _ParentMonitorView(),
    );
  }
}

class _ParentMonitorView extends StatelessWidget {
  const _ParentMonitorView();

  // Base height of the progress-card block (padding + a 2-line title layout)
  // at a text scale of 1.0. It grows with the device font-scale factor.
  static const double _toolbarHeight = 80;
  static const double _bottomStripHeight = 36;
  static const double _cardBlockBaseHeight = 224;

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context);
    final topPadding = media.padding.top;
    // Clamp so an extreme system font size can't blow the header height up.
    final textScale = media.textScaler.scale(1.0).clamp(1.0, 1.3);
    final expandedHeight = topPadding +
        _toolbarHeight +
        (_cardBlockBaseHeight * textScale) +
        _bottomStripHeight;

    return Scaffold(
      backgroundColor: context.colorScheme.primary,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            pinned: true,
            floating: false,
            // toolbarHeight covers greeting text + name (no overflow)
            toolbarHeight: _toolbarHeight,
            expandedHeight: expandedHeight,
            backgroundColor: context.colorScheme.primary,
            elevation: 0,
            scrolledUnderElevation: 0,
            automaticallyImplyLeading: false,
            centerTitle: false,
            titleSpacing: 0,
            title: const Padding(
              padding: EdgeInsets.symmetric(horizontal: 24),
              child: MonitorGreetingTitle(),
            ),
            flexibleSpace: const FlexibleSpaceBar(
              collapseMode: CollapseMode.pin,
              background: MonitorFlexBackground(),
            ),
            // This bottom widget is part of the pinned SliverAppBar — it is
            // always visible, keeping the rounded-corner transition in place
            // even when the progress card has scrolled away.
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(_bottomStripHeight),
              child: Container(
                height: _bottomStripHeight,
                decoration: BoxDecoration(
                  color: context.colorScheme.surface,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(36),
                    topRight: Radius.circular(36),
                  ),
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Container(
              color: context.colorScheme.surface,
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 32,
                ),
                child: BlocBuilder<ParentMonitorCubit, ParentMonitorState>(
                  builder: (context, state) {
                    if (state is ParentMonitorLoading) {
                      return const Center(
                        child: Padding(
                          padding: EdgeInsets.all(48),
                          child: CircularProgressIndicator(),
                        ),
                      );
                    }

                    if (state is ParentMonitorNoChild) {
                      return const ParentNoChildEmptyState();
                    }

                    if (state is ParentMonitorLoaded) {
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Steps / lessons / weekly chart are hidden until the
                          // backend exposes real data for them.
                          if (state.hasActivityData) ...[
                            MonitorStatsRow(
                              stepsToday: state.stepsToday,
                              lessonsToday: state.lessonsToday,
                            ),
                            const SizedBox(height: 24),
                            ParentScreenTimeChart(
                              weeklyUsage: state.weeklyUsage,
                            ),
                            const SizedBox(height: 40),
                          ],
                          MonitorAppLimitsSection(appLimits: state.appLimits),
                          const SizedBox(height: 40),
                          const MonitorTasksSection(),
                          const SizedBox(height: 100),
                        ],
                      );
                    }

                    return const SizedBox.shrink();
                  },
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
