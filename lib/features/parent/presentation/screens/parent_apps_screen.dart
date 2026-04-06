import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:safini/core/di/injection.dart'; 
import 'package:safini/features/parent/presentation/cubit/parent_apps_cubit.dart';
import 'package:safini/features/parent/presentation/cubit/parent_apps_state.dart';
import 'package:safini/features/parent/presentation/widgets/tiles/parent_app_limit_tile.dart';

class ParentAppsScreen extends StatelessWidget {
  const ParentAppsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<ParentAppsCubit>(
      create: (context) => getIt<ParentAppsCubit>()..loadAppLimits(),
      child: Scaffold(
        backgroundColor: const Color(0xFFF8F9FE),
        appBar: AppBar(
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: const [
              Text(
                "App Limits",
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w900,
                  fontSize: 26,
                  letterSpacing: -0.5,
                ),
              ),
              Text(
                "Set daily screen time limits",
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
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
              return const Center(child: CircularProgressIndicator(color: Color(0xFF8B46FF)));
            }

            if (state is ParentAppsLoaded) {
              return ListView(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
                children: [
                  _buildTipBanner(),
                  const SizedBox(height: 24),
                  _buildDailyLimitCard(),
                  const SizedBox(height: 24),
                  ...state.appLimits.map((app) => ParentAppLimitTile(
                    appName: app['name'],
                    usedMinutes: app['used'],
                    limitMinutes: app['limit'],
                    isEnabled: app['isEnabled'] ?? true,
                  )),
                  const SizedBox(height: 12),
                  _buildAddAnotherAppButton(),
                  const SizedBox(height: 60),
                ],
              );
            }
            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }

  Widget _buildTipBanner() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFF2F0FF),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: const [
          Icon(Icons.lightbulb_rounded, color: Color(0xFFFF9500), size: 26),
          SizedBox(width: 16),
          Expanded(
            child: Text(
              "Kids earn Time Coins to unlock extra minutes for these apps.",
              style: TextStyle(
                color: Color(0xFF8B46FF),
                fontWeight: FontWeight.w700,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDailyLimitCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(32),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "Daily Screen Limit",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF1A1A1A),
                ),
              ),
              const Text(
                "12m remaining",
                style: TextStyle(
                  color: Color(0xFFFF3B30),
                  fontWeight: FontWeight.w800,
                  fontSize: 13,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildLimitButton(Icons.remove),
              const SizedBox(width: 20),
              const Text(
                "60m",
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                  color: Color(0xFF1A1A1A),
                ),
              ),
              const SizedBox(width: 20),
              _buildLimitButton(Icons.add),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLimitButton(IconData icon) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: const Color(0xFFF2F0FF),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Icon(icon, color: const Color(0xFF8B46FF), size: 18),
    );
  }

  Widget _buildAddAnotherAppButton() {
    // Custom painter for dashed border or use a package (here we'll simulate or use a simple version)
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 20),
      decoration: BoxDecoration(
        border: Border.all(
          color: const Color(0xFF8B46FF).withOpacity(0.5),
          style: BorderStyle.solid, // Flutter doesn't have native dashed border without work
          width: 2,
        ),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: const [
          Icon(Icons.add, color: Color(0xFF8B46FF), size: 20),
          SizedBox(width: 8),
          Text(
            "Add Another App",
            style: TextStyle(
              color: Color(0xFF8B46FF),
              fontWeight: FontWeight.w800,
              fontSize: 18,
            ),
          ),
        ],
      ),
    );
  }
}