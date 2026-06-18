import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:safini/core/di/injection.dart';
import 'package:safini/core/utils/extension/theme_extension.dart';
import 'package:safini/features/parent/presentation/cubit/parent_cubit.dart';
import 'package:safini/features/parent/presentation/cubit/parent_monitor_cubit.dart';
import 'package:safini/features/parent/presentation/cubit/parent_monitor_state.dart';
import 'package:safini/features/parent/presentation/cubit/parent_tasks_cubit.dart';
import 'package:safini/features/parent/presentation/widgets/charts/parent_screen_time_chart.dart';
import 'package:safini/features/parent/presentation/screens/monitor/monitor_header.dart';
import 'package:safini/features/parent/presentation/screens/monitor/monitor_stats_row.dart';
import 'package:safini/features/parent/presentation/screens/monitor/monitor_app_limits_section.dart';
import 'package:safini/core/theme/app_colors.dart';
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.colorScheme.primary,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 340,
            floating: false,
            pinned: true,
            backgroundColor: context.colorScheme.primary,
            elevation: 0,
            scrolledUnderElevation: 0,
            automaticallyImplyLeading: false,
            flexibleSpace: const FlexibleSpaceBar(
              collapseMode: CollapseMode.pin,
              background: MonitorHeader(),
            ),
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(36),
              child: Container(
                height: 36,
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
            child: Transform.translate(
              offset: const Offset(0, -1), // Fix any sub-pixel gap
              child: Container(
                decoration: BoxDecoration(
                  color: context.colorScheme.surface,
                ),
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

                    if (state is ParentMonitorLoaded) {
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          MonitorStatsRow(
                            stepsToday: state.stepsToday,
                            lessonsToday: state.lessonsToday,
                          ),
                          const SizedBox(height: 24),
                          ParentScreenTimeChart(weeklyUsage: state.weeklyUsage),
                          const SizedBox(height: 40),
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
          ),
        ],
      ),
    );
  }
}
