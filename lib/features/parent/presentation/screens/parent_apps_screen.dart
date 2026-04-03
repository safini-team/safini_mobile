import 'package:flutter/material.dart';
import 'package:safini/features/parent/presentation/widgets/tiles/parent_app_limit_tile.dart';

class ParentAppsScreen extends StatelessWidget {
  const ParentAppsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FE),
      appBar: AppBar(
        backgroundColor: const Color(0xFF8100D1),
        elevation: 0,
        leading: const Icon(Icons.arrow_back, color: Colors.white),
        title: const Text(
          "App Limits",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 24),

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
                        const Icon(
                          Icons.lightbulb_outline,
                          color: Color(0xFF8100D1),
                        ),
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
                  ...state.appLimits.map(
                    (app) => ParentAppLimitTile(
                      appName: app['name'],
                      usedMinutes: app['used'],
                      limitMinutes: app['limit'],
                      iconPath: app['icon'],
                      isEnabled: app['isEnabled'],
                      onToggle: (val) => context
                          .read<ParentAppsCubit>()
                          .toggleApp(app['name'], val),
                      onAdjust: () {},
                    ),
                  ),
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
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          _buildTipBanner(),
          const SizedBox(height: 24),
          _buildDailyLimitRow(context),
          const SizedBox(height: 24),
          const ParentAppLimitTile(
            appName: "YouTube Kids",
            usedMinutes: 48,
            limitMinutes: 60,
            iconPath: "",
          ),
          const ParentAppLimitTile(
            appName: "Roblox",
            usedMinutes: 15,
            limitMinutes: 60,
            iconPath: "",
          ),
          const ParentAppLimitTile(
            appName: "Brawl Stars",
            usedMinutes: 5,
            limitMinutes: 45,
            iconPath: "",
          ),
          const ParentAppLimitTile(
            appName: "Minecraft",
            usedMinutes: 30,
            limitMinutes: 90,
            iconPath: "",
          ),
          const SizedBox(height: 16),
          _buildAddAnotherAppButton(),
          const SizedBox(height: 100),
          Text(
            "Daily Limit",
            style: context.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const Spacer(),
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.remove_circle_outline, color: Colors.purple),
          ),
          Text(
            "60m",
            style: context.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.add_circle_outline, color: Colors.purple),
          ),
          const SizedBox(width: 8),
          Text(
            "12m remaining",
            style: context.textTheme.bodySmall?.copyWith(
              color: Colors.red,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTipBanner() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFF0E6FF),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Row(
        children: const [
          Icon(Icons.lightbulb_outline, color: Color(0xFF8100D1), size: 24),
          SizedBox(width: 16),
          Expanded(
            child: Text(
              "Kids earn Time Coins to unlock extra minutes for these apps.",
              style: TextStyle(
                color: Color(0xFF8100D1),
                fontSize: 15,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDailyLimitRow(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Row(
        children: [
          const Text(
            "Daily Limit",
            style: TextStyle(
              color: Color(0xFF1A1A1A),
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
          const Spacer(),
          _buildAdjustButton(Icons.remove_circle_outline, () {}),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 12),
            child: Text(
              "60m",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24),
            ),
          ),
          _buildAdjustButton(Icons.add_circle_outline, () {}),
          const SizedBox(width: 16),
          const Text(
            "12m remaining",
            style: TextStyle(
              color: Color(0xFFFF3B30),
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAdjustButton(IconData icon, VoidCallback onPressed) {
    return IconButton(
      icon: Icon(icon, color: const Color(0xFF8100D1), size: 28),
      onPressed: onPressed,
      padding: EdgeInsets.zero,
      constraints: const BoxConstraints(),
    );
  }

  Widget _buildAddAnotherAppButton() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 20),
      decoration: BoxDecoration(
        border: Border.all(color: const Color(0xFF8100D1), width: 1.5),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: const Color(0xFF8100D1),
          style: BorderStyle.solid,
          width: 1.5,
        ),
        borderRadius: BorderRadius.circular(20),
        // Dashed border effect would need a custom painter or a package,
        // using solid for now to match style closely.
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: const [
          Icon(Icons.add, color: Color(0xFF8100D1)),
          SizedBox(width: 8),
          Text(
            "Add Another App",
            style: TextStyle(
              color: Color(0xFF8100D1),
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
        ],
      ),
    );
  }
}