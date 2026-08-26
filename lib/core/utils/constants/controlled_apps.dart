/// Single source of truth mapping the backend's controlled-app **slug**
/// (e.g. `youtube-kids`) to the Android **package name** the native blocking
/// engine needs (e.g. `com.google.android.apps.youtube.kids`).
///
/// The backend keys every app rule by slug (the `GET /v1/apps` catalog and the
/// `app-rules` / `app-usage` endpoints — see `CatalogAppModel`), but
/// `UsageStatsManager` and the overlay service on the child device operate on
/// package names. Keep this map in sync with the backend catalog whenever a new
/// controlled app is added.
class ControlledApps {
  const ControlledApps._();

  /// slug → Android package name.
  static const Map<String, String> slugToPackage = {
    'youtube-kids': 'com.google.android.apps.youtube.kids',
    'roblox': 'com.roblox.client',
    'brawl-stars': 'com.supercell.brawlstars',
    'minecraft': 'com.mojang.minecraftpe',
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
