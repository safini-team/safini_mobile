class AppConstants {
  static const String appName = 'Safini';

  /// Mirrors `version:` in pubspec.yaml; shown at the foot of Settings.
  static const String appVersion = '1.0.0';
  static const String buildNumber = '14';
  static const Duration apiTimeout = Duration(seconds: 10);
  static const String accessToken = 'access_token';
  static const String privacyPolicyUrl = 'https://safini.fun/privacy-policy';

  static const String accountTypeParent = 'parent';
  static const String accountTypeChild = 'child';

  /// Whether on-device app blocking (F-05) actually ships in this build.
  ///
  /// While this is false the app counts usage but enforces nothing, so screens
  /// that talk about limits say so out loud rather than implying the block is
  /// already working. Flip it to true with the native enforcement layer and
  /// the caveats disappear on their own.
  static const bool enforcementShipped = false;

  /// Whether the parent "See all apps on this phone" entry point is shown.
  ///
  /// The child device already enumerates and uploads its installed apps, and the
  /// parent read path is built, but the backend endpoint is not live yet (see
  /// `BACKEND_TODO.md` #4). Keep this false so the row stays hidden in
  /// production; flip it to true to preview the screen (it shows an empty state
  /// until real data flows).
  static const bool childInstalledAppsShipped = false;

  const AppConstants._();
}
