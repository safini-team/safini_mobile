import 'package:flutter/material.dart';
import 'package:safini/core/utils/extension/theme_extension.dart';

class ParentAppLimitTile extends StatelessWidget {
  final String appName;
  final int usedMinutes;
  final int limitMinutes;
  final String iconPath;
  final bool isEnabled;
  final bool isMonitor;
  final ValueChanged<bool>? onToggle;
  final VoidCallback? onAdjust;

  const ParentAppLimitTile({
    super.key,
    required this.appName,
    required this.usedMinutes,
    required this.limitMinutes,
    required this.iconPath,
    this.isEnabled = true,
    this.isMonitor = false,
    this.onToggle,
    this.onAdjust,
  });

  @override
  Widget build(BuildContext context) {
    final progress = (usedMinutes / limitMinutes).clamp(0.0, 1.0);
    final remaining = limitMinutes - usedMinutes;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Center(
                  child: Icon(Icons.grid_view_rounded, color: Colors.grey, size: 24),
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
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                        color: Color(0xFF1A1A1A),
                      ),
                    ),
                    Text(
                      "$usedMinutes used / $limitMinutes limit",
                      style: TextStyle(
                        color: Colors.grey[500],
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              Switch(
                value: isEnabled,
                onChanged: onToggle,
                activeColor: const Color(0xFF8100D1),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: progress,
              backgroundColor: Colors.grey[100],
              color: const Color(0xFF8100D1),
              minHeight: 8,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "$remaining minutes remaining",
                style: TextStyle(
                  color: Colors.grey[500],
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              if (!isMonitor)
                Icon(Icons.settings_outlined, color: Colors.grey[400], size: 20),
            ],
          ),
        ],
      ),
    );
  }
}
