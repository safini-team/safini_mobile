import 'package:flutter/material.dart';
import 'package:safini/core/utils/extension/theme_extension.dart';
import 'package:safini/generated/l10n.dart';

class ParentAppLimitTile extends StatelessWidget {
  final String appName;
  final int usedMinutes;
  final int limitMinutes;
  final String? iconPath;
  final bool isEnabled;
  final ValueChanged<bool>? onToggle;

  const ParentAppLimitTile({
    super.key,
    required this.appName,
    required this.usedMinutes,
    required this.limitMinutes,
    this.iconPath,
    this.isEnabled = true,
    this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    final progress = (usedMinutes / limitMinutes).clamp(0.0, 1.0);
    final remaining = limitMinutes - usedMinutes;
    final Color progressColor =
        progress > 0.8 ? const Color(0xFFFF3B30) : const Color(0xFF00C566);

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
                child: iconPath != null
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.asset(
                          iconPath!,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => const Center(
                            child: Text('🎮', style: TextStyle(fontSize: 24)),
                          ),
                        ),
                      )
                    : const Center(
                        child: Text('🎮', style: TextStyle(fontSize: 24)),
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
                      S.of(context).usedLimit(usedMinutes, limitMinutes),
                      style: TextStyle(
                        color: Colors.grey[500],
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              Switch(
                value: isEnabled,
                onChanged: onToggle,
                activeTrackColor: const Color(0xFF8B46FF),
                activeColor: Colors.white,
              ),
            ],
          ),
          const SizedBox(height: 20),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 12,
              backgroundColor: const Color(0xFFF0F0F0),
              valueColor: AlwaysStoppedAnimation<Color>(progressColor),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                S.of(context).dailyLimit,
                style: const TextStyle(
                  color: Colors.grey,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Flexible(
                child: Text(
                  S.of(context).minutesRemainingLong(remaining),
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
        ],
      ),
    );
  }
}