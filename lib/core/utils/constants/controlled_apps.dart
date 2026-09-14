/// The curated catalog's **slugs** (e.g. `youtube-kids`) and their Android
/// **package names** (e.g. `com.google.android.apps.youtube.kids`), as the
/// backend had them before it named a slug for every app itself.
///
/// Only a fallback now. The API sends `app_slug` on every installed app,
/// including the ones outside the catalog, and `package_name` on every rule,
/// which is what the native blocker runs on. This map covers APIs from before
/// either field existed, so it does not need to grow with the catalog.
class ControlledApps {
  const ControlledApps._();

  /// slug → Android package name.
  static const Map<String, String> slugToPackage = {
    'youtube-kids': 'com.google.android.apps.youtube.kids',
    'roblox': 'com.roblox.client',
    'brawl-stars': 'com.supercell.brawlstars',
    'minecraft': 'com.mojang.minecraftpe',
    'youtube': 'com.google.android.youtube',
    'tiktok': 'com.zhiliaoapp.musically',
    'instagram': 'com.instagram.android',
    'telegram': 'org.telegram.messenger',
  };

  /// The Android package for a backend [slug], or `null` when unknown/unmapped.
  static String? packageFor(String slug) => slugToPackage[slug];

  /// The backend slug for an Android [packageName], or `null` when unmapped.
  static String? slugFor(String packageName) {
    for (final entry in slugToPackage.entries) {
      if (entry.value == packageName) return entry.key;
    }
    return null;
  }
}
