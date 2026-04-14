import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:safini/core/di/injection.dart';
import 'package:safini/core/utils/extension/theme_extension.dart';
import 'package:safini/features/parent/presentation/cubit/parent_apps_cubit.dart';
import 'package:safini/features/parent/presentation/cubit/parent_apps_state.dart';
import 'package:safini/features/parent/presentation/widgets/tiles/parent_app_limit_tile.dart';
import 'package:safini/generated/l10n.dart';

class ParentAppsScreen extends StatelessWidget {
  const ParentAppsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    return BlocProvider(
      create: (context) => getIt<ParentAppsCubit>()..loadAppLimits(),
      child: Scaffold(
        backgroundColor: const Color(0xFF43008F),
        body: Column(
          children: [
            // ── Header ──────────────────────────────────────────
            Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Color(0xFF2D006F), Color(0xFF5A00B4)],
                ),
              ),
              child: SafeArea(
                bottom: false,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(24, 20, 24, 28),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        s.appLimits,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 30,
                          fontWeight: FontWeight.w900,
                          letterSpacing: -0.5,
                        ),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'Set daily screen time limits',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            // ── Content ─────────────────────────────────────────
            Expanded(
              child: Container(
                decoration: const BoxDecoration(
                  color: Color(0xFFF0EEF9),
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(36),
                    topRight: Radius.circular(36),
                  ),
                ),
                child: BlocBuilder<ParentAppsCubit, ParentAppsState>(
                  builder: (context, state) {
                    if (state is ParentAppsLoading) {
                      return const Center(
                        child: CircularProgressIndicator(
                          color: Color(0xFF8B46FF),
                        ),
                      );
                    }

                    if (state is ParentAppsLoaded) {
                      return ListView(
                        padding: const EdgeInsets.fromLTRB(20, 28, 20, 80),
                        children: [
                          // Tip Banner
                          Container(
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.lightbulb_rounded,
                                  color: Color(0xFFFF9500),
                                  size: 26,
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Text(
                                    s.kidsEarnTimeCoins,
                                    style: const TextStyle(
                                      color: Color(0xFF8B46FF),
                                      fontWeight: FontWeight.w700,
                                      fontSize: 14,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 24),
                          ...state.appLimits.map(
                            (app) => ParentAppLimitTile(
                              appName: app['name'],
                              usedMinutes: app['used'],
                              limitMinutes: app['limit'],
                              iconPath: app['icon'],
                              isEnabled: app['isEnabled'] ?? true,
                            ),
                          ),
                          const SizedBox(height: 12),
                          // Add Another App Button
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(vertical: 20),
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: const Color(0xFF8B46FF).withOpacity(0.5),
                                width: 2,
                              ),
                              borderRadius: BorderRadius.circular(24),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(
                                  Icons.add,
                                  color: Color(0xFF8B46FF),
                                  size: 20,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  s.addAnotherApp,
                                  style: context.textTheme.titleMedium
                                      ?.copyWith(
                                        color: const Color(0xFF8100D1),
                                        fontWeight: FontWeight.bold,
                                      ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 60),
                        ],
                      );
                    }
                    return const SizedBox.shrink();
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
