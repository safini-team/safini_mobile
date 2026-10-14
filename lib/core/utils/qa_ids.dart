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
  static const navFini = 'nav.fini';
  static const navFamily = 'nav.family';

  /// The "Everyone" circle of the child selector, and its Add circle.
  static const kidEveryone = 'kid.everyone';
  static const kidAdd = 'kid.add';

  /// Fini onboarding (SAF-272): board A's name and Android option, and the
  /// main button of every board.
  static const obName = 'ob.name';
  static const obPhoneAndroid = 'ob.phone.android';
  static const obContinue = 'ob.continue';

  /// The Fini tab: its first goal, Add a goal, and the two tiles.
  static const finiFirstGoal = 'fini.goal.first';
  static const finiAddGoal = 'fini.goal.add';
  static const finiRules = 'fini.rules';
  static const finiActivity = 'fini.activity';

  static const openSettings = 'settings.open';
  static const settingsLanguage = 'settings.language';

  static String language(String code) => 'lang.$code';

  /// A tile on the goal grid, e.g. `goal.games`.
  static String goalTile(String intent) => 'goal.$intent';

  /// Every fixed id, for the test that keeps the scripts honest.
  static const fixed = [
    loginWithEmail,
    signIn,
    tourSkip,
    navToday,
    navTasks,
    navLimits,
    navFini,
    navFamily,
    kidEveryone,
    kidAdd,
    obName,
    obPhoneAndroid,
    obContinue,
    finiFirstGoal,
    finiAddGoal,
    finiRules,
    finiActivity,
    openSettings,
    settingsLanguage,
  ];
}
