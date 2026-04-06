import 'package:flutter/material.dart';

class ParentAppLimitTile extends StatelessWidget {
  final String appName;
  final int usedMinutes;
  final int limitMinutes;
  final bool isEnabled;

  const ParentAppLimitTile({
    super.key,
    required this.appName,
    required this.usedMinutes,
    required this.limitMinutes,
    this.isEnabled = true,
  });

  @override
  Widget build(BuildContext context) {
    double progress = usedMinutes / limitMinutes;
    Color progressColor = appName == "YouTube Kids" ? const Color(0xFFFF9500) : const Color(0xFF00C566);

    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(24),
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
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF5E6),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Center(
                  child: Text("🎮", style: TextStyle(fontSize: 24)), // Simplified for now
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      appName,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF1A1A1A),
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      "$usedMinutes used / $limitMinutes limit",
                      style: const TextStyle(
                        color: Color(0xFF00C566),
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
              Switch(
                value: isEnabled,
                onChanged: (val) {},
                activeTrackColor: const Color(0xFF8B46FF),
                activeColor: Colors.white,
              ),
            ],
          ),
          const SizedBox(height: 24),
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 12,
              backgroundColor: const Color(0xFFF0F0F0),
              valueColor: AlwaysStoppedAnimation<Color>(progressColor),
            ),
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "Daily Limit",
                style: TextStyle(
                  color: Colors.grey,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Flexible(
                child: Text(
                  "${limitMinutes - usedMinutes}m remaining",
                  style: TextStyle(
                    color: progressColor,
                    fontWeight: FontWeight.w800,
                    fontSize: 13,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildLimitButton(Icons.remove),
              const SizedBox(width: 16),
              Text(
                "${limitMinutes}m",
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF1A1A1A),
                ),
              ),
              const SizedBox(width: 16),
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
      child: Icon(icon, color: const Color(0xFF8B46FF), size: 20),
    );
  }
}