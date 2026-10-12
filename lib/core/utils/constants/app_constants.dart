class AppConstants {
  static const String appName = 'Safini';
  static const Duration apiTimeout = Duration(seconds: 10);
  static const String accessToken = 'access_token';
  static const String privacyPolicyUrl = 'https://safini.fun/privacy-policy';
  static const String termsOfUseUrl = 'https://safini.fun/terms-of-service';
  static const Set<String> _legalPageLanguages = {'ru', 'uz', 'ky', 'kk'};

  /// [url] on safini.fun in the app's language; English lives at the root.
  static String localizedLegalUrl(String url, String languageCode) {
    if (!_legalPageLanguages.contains(languageCode)) return url;
    final uri = Uri.parse(url);
    return uri.replace(path: '/$languageCode${uri.path}').toString();
  }

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
