/// Semantics identifiers for the screenshot scripts in `tool/screenshots/`.
///
/// They reach the platform as the Android `resource-id` and the iOS
/// `accessibilityIdentifier`, so Maestro (`id:`) and uiautomator find the
/// same element in every language. Renaming one breaks the scripts: grep
/// `tool/screenshots` first.
abstract final class QaIds {
  static const loginWithEmail = 'auth.email.open';
  static const signIn = 'auth.email.submit';
  static const tourSkip = 'tour.skip';

  static const navToday = 'nav.today';
  static const navTasks = 'nav.tasks';
  static const navLimits = 'nav.limits';
  static const navFamily = 'nav.family';

  static const openSettings = 'settings.open';
  static const settingsLanguage = 'settings.language';

  static String language(String code) => 'lang.$code';

  /// Every fixed id, for the test that keeps the scripts honest.
  static const fixed = [
    loginWithEmail,
    signIn,
    tourSkip,
    navToday,
    navTasks,
    navLimits,
    navFamily,
    openSettings,
    settingsLanguage,
  ];
}
