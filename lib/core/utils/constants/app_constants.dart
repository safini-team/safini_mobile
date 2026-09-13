class AppConstants {
  static const String appName = 'Safini';
  static const Duration apiTimeout = Duration(seconds: 10);
  static const String accessToken = 'access_token';
  static const String privacyPolicyUrl = 'https://safini.fun/privacy-policy';

  static const String accountTypeParent = 'parent';
  static const String accountTypeChild = 'child';

  /// Whether the parent "See all apps on this phone" entry point is shown.
  ///
  /// The child device enumerates and uploads its installed apps
  /// (`PUT /v1/children/{id}/installed-apps`) and the parent reads them back
  /// (`GET`). Both are live (see `BACKEND_TODO.md` #4), so the row is shown.
  /// Android-only in practice — iOS cannot enumerate installed apps.
  static const bool childInstalledAppsShipped = true;

  const AppConstants._();
}
