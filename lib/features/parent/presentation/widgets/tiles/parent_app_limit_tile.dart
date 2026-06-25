import 'package:flutter/material.dart';
import 'package:safini/core/utils/extension/theme_extension.dart';
import 'package:safini/core/translation/generated/l10n.dart';

String _emojiForApp(String name) {
  final n = name.toLowerCase();
  if (_matches(n, ['game', 'roblox', 'minecraft', 'brawl', 'fortnite', 'pubg', 'clash', 'among', 'gaming', 'steam', 'valorant', 'fifa'])) return '🎮';
  if (_matches(n, ['youtube', 'netflix', 'tiktok', 'video', 'movie', 'twitch', 'hulu', 'disney', 'watch', 'film', 'kino'])) return '📺';
  if (_matches(n, ['instagram', 'facebook', 'snapchat', 'twitter', 'whatsapp', 'telegram', 'vk', 'social', 'chat', 'message', 'discord'])) return '💬';
  if (_matches(n, ['spotify', 'music', 'soundcloud', 'apple music', 'deezer', 'audio', 'podcast'])) return '🎵';
  if (_matches(n, ['book', 'read', 'learn', 'school', 'duolingo', 'education', 'study', 'class', 'math', 'science'])) return '📚';
  if (_matches(n, ['photo', 'camera', 'gallery', 'picture', 'vsco', 'lightroom', 'снимок'])) return '📷';
  if (_matches(n, ['browser', 'chrome', 'safari', 'firefox', 'internet', 'web', 'yandex'])) return '🌐';
  if (_matches(n, ['shop', 'store', 'amazon', 'ebay', 'buy', 'market', 'aliexpress'])) return '🛒';
  return '📱';
}

bool _matches(String name, List<String> keywords) =>
    keywords.any((k) => name.contains(k));

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
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: context.colorScheme.surface,
        borderRadius: BorderRadius.circular(32),
        boxShadow: [
          BoxShadow(
            color: context.colorScheme.shadow.withValues(alpha: 0.04),
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
                  color: context.colorScheme.secondary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: iconPath != null
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.asset(
                          iconPath!,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => Center(
                            child: Text(_emojiForApp(appName), style: const TextStyle(fontSize: 24)),
                          ),
                        ),
                      )
                    : Center(
                        child: Text(_emojiForApp(appName), style: const TextStyle(fontSize: 24)),
                      ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      appName,
                      style: context.textTheme.titleMedium?.copyWith(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        color: context.colorScheme.onSurface,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      S.of(context).usedLimit(usedMinutes, limitMinutes),
                      style: context.textTheme.bodySmall?.copyWith(
                        color: context.colorScheme.onSurface.withValues(alpha: 0.5),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              Switch(
                value: isEnabled,
                onChanged: onToggle,
                activeTrackColor: context.colorScheme.primary,
                activeColor: context.colorScheme.onPrimary,
              ),
            ],
          ),
        ],
      ),
    );
  }
}