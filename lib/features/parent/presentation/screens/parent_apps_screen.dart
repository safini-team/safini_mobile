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