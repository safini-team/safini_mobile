import 'package:flutter/material.dart';
import 'package:safini/core/utils/extension/theme_extension.dart';

class ParentAppLimitTile extends StatelessWidget {
  final String appName;
  final int usedMinutes;
  final int limitMinutes;
  final String iconPath;
  final bool isEnabled;
  final ValueChanged<bool>? onToggle;
  final VoidCallback? onAdjust;

  const ParentAppLimitTile({
    super.key,
    required this.appName,
    required this.usedMinutes,
    required this.limitMinutes,
    required this.iconPath,
    this.isEnabled = true,
    this.onToggle,
    this.onAdjust,
  });

  @override
  Widget build(BuildContext context) {
    final progress = (usedMinutes / limitMinutes).clamp(0.0, 1.0);
    final remaining = limitMinutes - usedMinutes;
    
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
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
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.asset(
                    iconPath,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => const Icon(Icons.apps, color: Colors.grey),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      appName,
                      style: context.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      "$usedMinutes used / $limitMinutes limit",
                      style: context.textTheme.bodySmall?.copyWith(
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
              Switch(
                value: isEnabled,
                onChanged: onToggle,
                activeColor: context.colorScheme.primary,
              ),
            ],
          ),
          const SizedBox(height: 12),
          LinearProgressIndicator(
            value: progress,
            backgroundColor: Colors.grey[200],
            valueColor: AlwaysStoppedAnimation<Color>(
              progress > 0.8 ? Colors.orange : context.colorScheme.primary,
            ),
            minHeight: 6,
            borderRadius: BorderRadius.circular(3),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "$remaining minutes remaining",
                style: context.textTheme.bodySmall?.copyWith(
                  color: progress > 0.8 ? Colors.orange : Colors.grey[600],
                  fontWeight: FontWeight.w500,
                ),
              ),
              if (onAdjust != null)
                IconButton(
                  icon: const Icon(Icons.settings_outlined, size: 20),
                  onPressed: onAdjust,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
