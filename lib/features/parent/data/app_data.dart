class AppData {
  static const Map<String, List<String>> emojiKeywords = {
    '🎮': [
      'game',
      'roblox',
      'minecraft',
      'brawl',
      'fortnite',
      'pubg',
      'clash',
      'among',
      'gaming',
      'steam',
      'valorant',
      'fifa',
    ],
    '📺': [
      'youtube',
      'netflix',
      'tiktok',
      'video',
      'movie',
      'twitch',
      'hulu',
      'disney',
      'watch',
      'film',
      'kino',
    ],
    '💬': [
      'instagram',
      'facebook',
      'snapchat',
      'twitter',
      'whatsapp',
      'telegram',
      'vk',
      'social',
      'chat',
      'message',
      'discord',
    ],
    '🎵': [
      'spotify',
      'music',
      'soundcloud',
      'apple music',
      'deezer',
      'audio',
      'podcast',
    ],
    '📚': [
      'book',
      'read',
      'learn',
      'school',
      'duolingo',
      'education',
      'study',
      'class',
      'math',
      'science',
    ],
    '📷': [
      'photo',
      'camera',
      'gallery',
      'picture',
      'vsco',
      'lightroom',
      'снимок',
    ],
    '🌐': [
      'browser',
      'chrome',
      'safari',
      'firefox',
      'internet',
      'web',
      'yandex',
    ],
    '🛒': [
      'shop',
      'store',
      'amazon',
      'ebay',
      'buy',
      'market',
      'aliexpress',
    ],
  };

  static String getEmojiForApp(String name) {
    final n = name.toLowerCase();
    for (final entry in emojiKeywords.entries) {
      if (entry.value.any((k) => n.contains(k))) {
        return entry.key;
      }
    }
    return '📱';
  }
}
