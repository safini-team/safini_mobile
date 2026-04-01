import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:safini/core/di/injection.dart';
import 'package:safini/core/utils/extension/theme_extension.dart';
import 'package:safini/features/parent/presentation/cubit/parent_apps_cubit.dart';
import 'package:safini/features/parent/presentation/cubit/parent_apps_state.dart';
import 'package:safini/features/parent/presentation/widgets/tiles/parent_app_limit_tile.dart';

class ParentAppsScreen extends StatelessWidget {
  const ParentAppsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => getIt<ParentAppsCubit>()..loadAppLimits(),
      child: Scaffold(
        backgroundColor: const Color(0xFFF8F9FE),
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          title: Text(
            "App Limits",
            style: context.textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          flexibleSpace: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFF43008F), Color(0xFF8100D1)],
              ),
            ),
          ),
        ),
        body: BlocBuilder<ParentAppsCubit, ParentAppsState>(
          builder: (context, state) {
            if (state is ParentAppsLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            if (state is ParentAppsLoaded) {
              return ListView(
                padding: const EdgeInsets.all(20),
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF0E6FF),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.lightbulb_outline, color: Color(0xFF8100D1)),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            "Kids earn Time Coins to unlock extra minutes for these apps.",
                            style: context.textTheme.bodyMedium?.copyWith(
                              color: const Color(0xFF43008F),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  const _DailyLimitHeader(),
                  const SizedBox(height: 12),
                  ...state.appLimits.map((app) => ParentAppLimitTile(
                    appName: app['name'],
                    usedMinutes: app['used'],
                    limitMinutes: app['limit'],
                    iconPath: app['icon'],
                    isEnabled: app['isEnabled'],
                    onToggle: (val) => context.read<ParentAppsCubit>().toggleApp(app['name'], val),
                    onAdjust: () {},
                  )),
                  const SizedBox(height: 16),
                  const _AddAppButton(),
                  const SizedBox(height: 100),
                ],
              );
            }
            
            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }
}

class _DailyLimitHeader extends StatelessWidget {
  const _DailyLimitHeader();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Text("Daily Limit", style: context.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
          const Spacer(),
          IconButton(onPressed: () {}, icon: const Icon(Icons.remove_circle_outline, color: Colors.purple)),
          Text("60m", style: context.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
          IconButton(onPressed: () {}, icon: const Icon(Icons.add_circle_outline, color: Colors.purple)),
          const SizedBox(width: 8),
          Text("12m remaining", style: context.textTheme.bodySmall?.copyWith(color: Colors.red, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}

class _AddAppButton extends StatelessWidget {
  const _AddAppButton();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 20),
      decoration: BoxDecoration(
        border: Border.all(color: const Color(0xFF8100D1), style: BorderStyle.solid, width: 1.5),
        borderRadius: BorderRadius.circular(20),
        // Dashed border effect would need a custom painter or a package, 
        // using solid for now to match style closely.
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.add, color: Color(0xFF8100D1)),
          const SizedBox(width: 8),
          Text(
            "Add Another App",
            style: context.textTheme.titleMedium?.copyWith(
              color: const Color(0xFF8100D1),
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
