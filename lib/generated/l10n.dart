// GENERATED CODE - DO NOT MODIFY BY HAND
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'intl/messages_all.dart';

// **************************************************************************
// Generator: Flutter Intl IDE plugin
// Made by Localizely
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, lines_longer_than_80_chars
// ignore_for_file: join_return_with_assignment, prefer_final_in_for_each
// ignore_for_file: avoid_redundant_argument_values, avoid_escaping_inner_quotes

class S {
  S();

  static S? _current;

  static S get current {
    assert(
      _current != null,
      'No instance of S was loaded. Try to initialize the S delegate before accessing S.current.',
    );
    return _current!;
  }

  static const AppLocalizationDelegate delegate = AppLocalizationDelegate();

  static Future<S> load(Locale locale) {
    final name = (locale.countryCode?.isEmpty ?? false)
        ? locale.languageCode
        : locale.toString();
    final localeName = Intl.canonicalizedLocale(name);
    return initializeMessages(localeName).then((_) {
      Intl.defaultLocale = localeName;
      final instance = S();
      S._current = instance;

      return instance;
    });
  }

  static S of(BuildContext context) {
    final instance = S.maybeOf(context);
    assert(
      instance != null,
      'No instance of S present in the widget tree. Did you add S.delegate in localizationsDelegates?',
    );
    return instance!;
  }

  static S? maybeOf(BuildContext context) {
    return Localizations.of<S>(context, S);
  }

  /// `SAFINIO`
  String get appName {
    return Intl.message('SAFINIO', name: 'appName', desc: '', args: []);
  }

  /// `Learn. Earn. Play.`
  String get tagline {
    return Intl.message(
      'Learn. Earn. Play.',
      name: 'tagline',
      desc: '',
      args: [],
    );
  }

  /// `I'm a Kid!`
  String get imAKid {
    return Intl.message('I\'m a Kid!', name: 'imAKid', desc: '', args: []);
  }

  /// `Earn coins & play`
  String get kidSubtitle {
    return Intl.message(
      'Earn coins & play',
      name: 'kidSubtitle',
      desc: '',
      args: [],
    );
  }

  /// `I'm a Parent`
  String get imAParent {
    return Intl.message('I\'m a Parent', name: 'imAParent', desc: '', args: []);
  }

  /// `Monitor & reward`
  String get parentSubtitle {
    return Intl.message(
      'Monitor & reward',
      name: 'parentSubtitle',
      desc: '',
      args: [],
    );
  }

  /// `Safe screen time for smart kids 🌟`
  String get footerText {
    return Intl.message(
      'Safe screen time for smart kids 🌟',
      name: 'footerText',
      desc: '',
      args: [],
    );
  }

  /// `Today's Quests`
  String get todaysQuests {
    return Intl.message(
      'Today\'s Quests',
      name: 'todaysQuests',
      desc: '',
      args: [],
    );
  }

  /// `Home`
  String get home {
    return Intl.message('Home', name: 'home', desc: '', args: []);
  }

  /// `Tasks`
  String get tasks {
    return Intl.message('Tasks', name: 'tasks', desc: '', args: []);
  }

  /// `Store`
  String get store {
    return Intl.message('Store', name: 'store', desc: '', args: []);
  }

  /// `Profile`
  String get profile {
    return Intl.message('Profile', name: 'profile', desc: '', args: []);
  }

  /// `Monitor`
  String get monitor {
    return Intl.message('Monitor', name: 'monitor', desc: '', args: []);
  }

  /// `Apps`
  String get apps {
    return Intl.message('Apps', name: 'apps', desc: '', args: []);
  }

  /// `Family`
  String get family {
    return Intl.message('Family', name: 'family', desc: '', args: []);
  }

  /// `Parent Home Screen`
  String get parentHomeScreen {
    return Intl.message(
      'Parent Home Screen',
      name: 'parentHomeScreen',
      desc: '',
      args: [],
    );
  }

  /// `Change Language`
  String get changeLanguage {
    return Intl.message(
      'Change Language',
      name: 'changeLanguage',
      desc: '',
      args: [],
    );
  }

  /// `English`
  String get english {
    return Intl.message('English', name: 'english', desc: '', args: []);
  }

  /// `Russian`
  String get russian {
    return Intl.message('Russian', name: 'russian', desc: '', args: []);
  }

  /// `My Profile`
  String get myProfile {
    return Intl.message('My Profile', name: 'myProfile', desc: '', args: []);
  }

  /// `Save`
  String get save {
    return Intl.message('Save', name: 'save', desc: '', args: []);
  }

  /// `Coins`
  String get coins {
    return Intl.message('Coins', name: 'coins', desc: '', args: []);
  }

  /// `Quests Done`
  String get questsDone {
    return Intl.message('Quests Done', name: 'questsDone', desc: '', args: []);
  }

  /// `Day Streak`
  String get dayStreak {
    return Intl.message('Day Streak', name: 'dayStreak', desc: '', args: []);
  }

  /// `Customize Avatar`
  String get customizeAvatar {
    return Intl.message(
      'Customize Avatar',
      name: 'customizeAvatar',
      desc: '',
      args: [],
    );
  }

  /// `Change outfit, hair & more`
  String get changeOutfit {
    return Intl.message(
      'Change outfit, hair & more',
      name: 'changeOutfit',
      desc: '',
      args: [],
    );
  }

  /// `Achievements`
  String get achievements {
    return Intl.message(
      'Achievements',
      name: 'achievements',
      desc: '',
      args: [],
    );
  }

  /// `unlocked`
  String get unlocked {
    return Intl.message('unlocked', name: 'unlocked', desc: '', args: []);
  }

  /// `Reward Store`
  String get rewardStore {
    return Intl.message(
      'Reward Store',
      name: 'rewardStore',
      desc: '',
      args: [],
    );
  }

  /// `Unlock Extra Time`
  String get unlockExtraTime {
    return Intl.message(
      'Unlock Extra Time',
      name: 'unlockExtraTime',
      desc: '',
      args: [],
    );
  }

  /// `Outfits & Items`
  String get outfitsAndItems {
    return Intl.message(
      'Outfits & Items',
      name: 'outfitsAndItems',
      desc: '',
      args: [],
    );
  }

  /// `My Quests`
  String get myQuests {
    return Intl.message('My Quests', name: 'myQuests', desc: '', args: []);
  }

  /// `Done Today`
  String get doneToday {
    return Intl.message('Done Today', name: 'doneToday', desc: '', args: []);
  }

  /// `Remaining`
  String get remaining {
    return Intl.message('Remaining', name: 'remaining', desc: '', args: []);
  }

  /// `Earned Today`
  String get earnedToday {
    return Intl.message(
      'Earned Today',
      name: 'earnedToday',
      desc: '',
      args: [],
    );
  }

  /// `No quests in this category`
  String get noQuestsInCategory {
    return Intl.message(
      'No quests in this category',
      name: 'noQuestsInCategory',
      desc: '',
      args: [],
    );
  }

  /// `Select Language`
  String get selectLanguage {
    return Intl.message(
      'Select Language',
      name: 'selectLanguage',
      desc: '',
      args: [],
    );
  }

  /// `Good morning 👋`
  String get goodMorning {
    return Intl.message(
      'Good morning 👋',
      name: 'goodMorning',
      desc: '',
      args: [],
    );
  }

  /// `Safinio Parent`
  String get parentName {
    return Intl.message(
      'Safinio Parent',
      name: 'parentName',
      desc: '',
      args: [],
    );
  }

  /// `{name}'s Progress`
  String childProgressTitle(String name) {
    return Intl.message(
      '$name\'s Progress',
      name: 'childProgressTitle',
      desc: '',
      args: [name],
    );
  }

  /// `Steps`
  String get steps {
    return Intl.message('Steps', name: 'steps', desc: '', args: []);
  }

  /// `Steps Today`
  String get stepsToday {
    return Intl.message('Steps Today', name: 'stepsToday', desc: '', args: []);
  }

  /// `+12% vs yesterday`
  String get stepsChangeText {
    return Intl.message(
      '+12% vs yesterday',
      name: 'stepsChangeText',
      desc: '',
      args: [],
    );
  }

  /// `Lessons`
  String get lessons {
    return Intl.message('Lessons', name: 'lessons', desc: '', args: []);
  }

  /// `+1 today`
  String get lessonsChangeText {
    return Intl.message(
      '+1 today',
      name: 'lessonsChangeText',
      desc: '',
      args: [],
    );
  }

  /// `App Limits`
  String get appLimits {
    return Intl.message('App Limits', name: 'appLimits', desc: '', args: []);
  }

  /// `Manage All`
  String get manageAll {
    return Intl.message('Manage All', name: 'manageAll', desc: '', args: []);
  }

  /// `Real-world Tasks`
  String get realWorldTasks {
    return Intl.message(
      'Real-world Tasks',
      name: 'realWorldTasks',
      desc: '',
      args: [],
    );
  }

  /// `New Task`
  String get newTask {
    return Intl.message('New Task', name: 'newTask', desc: '', args: []);
  }

  /// `Clean the room`
  String get cleanTheRoom {
    return Intl.message(
      'Clean the room',
      name: 'cleanTheRoom',
      desc: '',
      args: [],
    );
  }

  /// `Daily Chore`
  String get dailyChore {
    return Intl.message('Daily Chore', name: 'dailyChore', desc: '', args: []);
  }

  /// `Read for 20 mins`
  String get readFor20Mins {
    return Intl.message(
      'Read for 20 mins',
      name: 'readFor20Mins',
      desc: '',
      args: [],
    );
  }

  /// `Educational`
  String get educational {
    return Intl.message('Educational', name: 'educational', desc: '', args: []);
  }

  /// `Do homework`
  String get doHomework {
    return Intl.message('Do homework', name: 'doHomework', desc: '', args: []);
  }

  /// `Kids earn Time Coins to unlock extra minutes for these apps.`
  String get kidsEarnTimeCoins {
    return Intl.message(
      'Kids earn Time Coins to unlock extra minutes for these apps.',
      name: 'kidsEarnTimeCoins',
      desc: '',
      args: [],
    );
  }

  /// `Daily Limit`
  String get dailyLimit {
    return Intl.message('Daily Limit', name: 'dailyLimit', desc: '', args: []);
  }

  /// `{minutes}m remaining`
  String remainingTime(String minutes) {
    return Intl.message(
      '${minutes}m remaining',
      name: 'remainingTime',
      desc: '',
      args: [minutes],
    );
  }

  /// `Add Another App`
  String get addAnotherApp {
    return Intl.message(
      'Add Another App',
      name: 'addAnotherApp',
      desc: '',
      args: [],
    );
  }

  /// `Tasks & Rewards`
  String get tasksAndRewards {
    return Intl.message(
      'Tasks & Rewards',
      name: 'tasksAndRewards',
      desc: '',
      args: [],
    );
  }

  /// `New`
  String get newBtn {
    return Intl.message('New', name: 'newBtn', desc: '', args: []);
  }

  /// `Pending Approval`
  String get pendingApproval {
    return Intl.message(
      'Pending Approval',
      name: 'pendingApproval',
      desc: '',
      args: [],
    );
  }

  /// `Active Tasks`
  String get activeTasks {
    return Intl.message(
      'Active Tasks',
      name: 'activeTasks',
      desc: '',
      args: [],
    );
  }

  /// `Completed`
  String get completed {
    return Intl.message('Completed', name: 'completed', desc: '', args: []);
  }

  /// `YOUR CHILDREN`
  String get yourChildren {
    return Intl.message(
      'YOUR CHILDREN',
      name: 'yourChildren',
      desc: '',
      args: [],
    );
  }

  /// `Add Another Child`
  String get addAnotherChild {
    return Intl.message(
      'Add Another Child',
      name: 'addAnotherChild',
      desc: '',
      args: [],
    );
  }

  /// `Set up a new profile`
  String get setUpANewProfile {
    return Intl.message(
      'Set up a new profile',
      name: 'setUpANewProfile',
      desc: '',
      args: [],
    );
  }

  /// `PARENT ACCOUNT`
  String get parentAccount {
    return Intl.message(
      'PARENT ACCOUNT',
      name: 'parentAccount',
      desc: '',
      args: [],
    );
  }

  /// `Family Admin`
  String get familyAdmin {
    return Intl.message(
      'Family Admin',
      name: 'familyAdmin',
      desc: '',
      args: [],
    );
  }

  /// `Admin`
  String get admin {
    return Intl.message('Admin', name: 'admin', desc: '', args: []);
  }

  /// `Tips for Parents`
  String get tipsForParents {
    return Intl.message(
      'Tips for Parents',
      name: 'tipsForParents',
      desc: '',
      args: [],
    );
  }

  /// `Set meaningful tasks that teach responsibility`
  String get tip1 {
    return Intl.message(
      'Set meaningful tasks that teach responsibility',
      name: 'tip1',
      desc: '',
      args: [],
    );
  }

  /// `Balance screen time rewards with outdoor activities`
  String get tip2 {
    return Intl.message(
      'Balance screen time rewards with outdoor activities',
      name: 'tip2',
      desc: '',
      args: [],
    );
  }

  /// `Celebrate achievements with your child`
  String get tip3 {
    return Intl.message(
      'Celebrate achievements with your child',
      name: 'tip3',
      desc: '',
      args: [],
    );
  }

  /// `Adjust coin values to match effort levels`
  String get tip4 {
    return Intl.message(
      'Adjust coin values to match effort levels',
      name: 'tip4',
      desc: '',
      args: [],
    );
  }

  /// `Switch to Kid Mode / Logout`
  String get switchToKidMode {
    return Intl.message(
      'Switch to Kid Mode / Logout',
      name: 'switchToKidMode',
      desc: '',
      args: [],
    );
  }

  /// `Cancel`
  String get cancel {
    return Intl.message('Cancel', name: 'cancel', desc: '', args: []);
  }

  /// `OK`
  String get ok {
    return Intl.message('OK', name: 'ok', desc: '', args: []);
  }

  /// `Ready to spend your coins?`
  String get readyToSpend {
    return Intl.message(
      'Ready to spend your coins?',
      name: 'readyToSpend',
      desc: '',
      args: [],
    );
  }

  /// `Buy it! 🎉`
  String get buyIt {
    return Intl.message('Buy it! 🎉', name: 'buyIt', desc: '', args: []);
  }

  /// `Not enough coins!`
  String get notEnoughCoins {
    return Intl.message(
      'Not enough coins!',
      name: 'notEnoughCoins',
      desc: '',
      args: [],
    );
  }

  /// `You need {count} more coins.`
  String youNeedMoreCoins(int count) {
    return Intl.message(
      'You need $count more coins.',
      name: 'youNeedMoreCoins',
      desc: '',
      args: [count],
    );
  }

  /// `Coming soon!`
  String get comingSoon {
    return Intl.message('Coming soon!', name: 'comingSoon', desc: '', args: []);
  }

  /// `{count} coins`
  String coinsCount(int count) {
    return Intl.message(
      '$count coins',
      name: 'coinsCount',
      desc: '',
      args: [count],
    );
  }

  /// `Earn More Coins`
  String get earnMoreCoins {
    return Intl.message(
      'Earn More Coins',
      name: 'earnMoreCoins',
      desc: '',
      args: [],
    );
  }

  /// `Complete your daily quests to earn more coins!`
  String get completeDailyQuests {
    return Intl.message(
      'Complete your daily quests to earn more coins!',
      name: 'completeDailyQuests',
      desc: '',
      args: [],
    );
  }

  /// `Go to Tasks`
  String get goToTasks {
    return Intl.message('Go to Tasks', name: 'goToTasks', desc: '', args: []);
  }

  /// `My Avatar`
  String get myAvatar {
    return Intl.message('My Avatar', name: 'myAvatar', desc: '', args: []);
  }

  /// `Save My Look!`
  String get saveMyLook {
    return Intl.message(
      'Save My Look!',
      name: 'saveMyLook',
      desc: '',
      args: [],
    );
  }

  /// `ON`
  String get on {
    return Intl.message('ON', name: 'on', desc: '', args: []);
  }

  /// `FREE`
  String get free {
    return Intl.message('FREE', name: 'free', desc: '', args: []);
  }

  /// `EQUIPPED`
  String get equipped {
    return Intl.message('EQUIPPED', name: 'equipped', desc: '', args: []);
  }

  /// `View as Kid`
  String get viewAsKid {
    return Intl.message('View as Kid', name: 'viewAsKid', desc: '', args: []);
  }

  /// `Edit`
  String get edit {
    return Intl.message('Edit', name: 'edit', desc: '', args: []);
  }

  /// `Age {age} • {gender}`
  String ageAndGender(int age, String gender) {
    return Intl.message(
      'Age $age • $gender',
      name: 'ageAndGender',
      desc: '',
      args: [age, gender],
    );
  }

  /// `Quests`
  String get questsText {
    return Intl.message('Quests', name: 'questsText', desc: '', args: []);
  }

  /// `Streak`
  String get streakText {
    return Intl.message('Streak', name: 'streakText', desc: '', args: []);
  }

  /// `Coins`
  String get coinsText {
    return Intl.message('Coins', name: 'coinsText', desc: '', args: []);
  }

  /// `Spend your Time Coins`
  String get spendYourTimeCoins {
    return Intl.message(
      'Spend your Time Coins',
      name: 'spendYourTimeCoins',
      desc: '',
      args: [],
    );
  }

  /// `All`
  String get categoryAll {
    return Intl.message('All', name: 'categoryAll', desc: '', args: []);
  }

  /// `Learn`
  String get categoryLearn {
    return Intl.message('Learn', name: 'categoryLearn', desc: '', args: []);
  }

  /// `Fitness`
  String get categoryFitness {
    return Intl.message('Fitness', name: 'categoryFitness', desc: '', args: []);
  }

  /// `Logic`
  String get categoryLogic {
    return Intl.message('Logic', name: 'categoryLogic', desc: '', args: []);
  }

  /// `Complete Duolingo`
  String get taskDuolingoTitle {
    return Intl.message(
      'Complete Duolingo',
      name: 'taskDuolingoTitle',
      desc: '',
      args: [],
    );
  }

  /// `Daily streak bonus!`
  String get taskDuolingoSub {
    return Intl.message(
      'Daily streak bonus!',
      name: 'taskDuolingoSub',
      desc: '',
      args: [],
    );
  }

  /// `Walk 5,000 Steps`
  String get taskStepsTitle {
    return Intl.message(
      'Walk 5,000 Steps',
      name: 'taskStepsTitle',
      desc: '',
      args: [],
    );
  }

  /// `Keep it moving!`
  String get taskStepsSub {
    return Intl.message(
      'Keep it moving!',
      name: 'taskStepsSub',
      desc: '',
      args: [],
    );
  }

  /// `Logical Puzzle`
  String get taskPuzzleTitle {
    return Intl.message(
      'Logical Puzzle',
      name: 'taskPuzzleTitle',
      desc: '',
      args: [],
    );
  }

  /// `Brain power boost`
  String get taskPuzzleSub {
    return Intl.message(
      'Brain power boost',
      name: 'taskPuzzleSub',
      desc: '',
      args: [],
    );
  }

  /// `Chess Lesson`
  String get taskChessTitle {
    return Intl.message(
      'Chess Lesson',
      name: 'taskChessTitle',
      desc: '',
      args: [],
    );
  }

  /// `Master the board`
  String get taskChessSub {
    return Intl.message(
      'Master the board',
      name: 'taskChessSub',
      desc: '',
      args: [],
    );
  }

  /// `Read for 20 mins`
  String get taskReadingTitle {
    return Intl.message(
      'Read for 20 mins',
      name: 'taskReadingTitle',
      desc: '',
      args: [],
    );
  }

  /// `Expand your mind`
  String get taskReadingSub {
    return Intl.message(
      'Expand your mind',
      name: 'taskReadingSub',
      desc: '',
      args: [],
    );
  }

  /// `Clean your room`
  String get taskRoomTitle {
    return Intl.message(
      'Clean your room',
      name: 'taskRoomTitle',
      desc: '',
      args: [],
    );
  }

  /// `Daily chore`
  String get taskRoomSub {
    return Intl.message('Daily chore', name: 'taskRoomSub', desc: '', args: []);
  }

  /// `App Time`
  String get appTimeTab {
    return Intl.message('App Time', name: 'appTimeTab', desc: '', args: []);
  }

  /// `Avatar Items`
  String get avatarItemsTab {
    return Intl.message(
      'Avatar Items',
      name: 'avatarItemsTab',
      desc: '',
      args: [],
    );
  }

  /// `Level {level} Hero`
  String levelHero(int level) {
    return Intl.message(
      'Level $level Hero',
      name: 'levelHero',
      desc: '',
      args: [level],
    );
  }

  /// `Time Coins`
  String get timeCoins {
    return Intl.message('Time Coins', name: 'timeCoins', desc: '', args: []);
  }

  /// `Weekly Screen Time`
  String get weeklyScreenTime {
    return Intl.message(
      'Weekly Screen Time',
      name: 'weeklyScreenTime',
      desc: '',
      args: [],
    );
  }

  /// `MON`
  String get mon {
    return Intl.message('MON', name: 'mon', desc: '', args: []);
  }

  /// `TUE`
  String get tue {
    return Intl.message('TUE', name: 'tue', desc: '', args: []);
  }

  /// `WED`
  String get wed {
    return Intl.message('WED', name: 'wed', desc: '', args: []);
  }

  /// `THU`
  String get thu {
    return Intl.message('THU', name: 'thu', desc: '', args: []);
  }

  /// `FRI`
  String get fri {
    return Intl.message('FRI', name: 'fri', desc: '', args: []);
  }

  /// `SAT`
  String get sat {
    return Intl.message('SAT', name: 'sat', desc: '', args: []);
  }

  /// `SUN`
  String get sun {
    return Intl.message('SUN', name: 'sun', desc: '', args: []);
  }

  /// `{used} used / {limit} limit`
  String usedLimit(int used, int limit) {
    return Intl.message(
      '$used used / $limit limit',
      name: 'usedLimit',
      desc: '',
      args: [used, limit],
    );
  }

  /// `{minutes} minutes remaining`
  String minutesRemainingLong(int minutes) {
    return Intl.message(
      '$minutes minutes remaining',
      name: 'minutesRemainingLong',
      desc: '',
      args: [minutes],
    );
  }

  /// `PENDING`
  String get statusPending {
    return Intl.message('PENDING', name: 'statusPending', desc: '', args: []);
  }

  /// `DONE`
  String get statusDone {
    return Intl.message('DONE', name: 'statusDone', desc: '', args: []);
  }

  /// `ACTIVE`
  String get statusActive {
    return Intl.message('ACTIVE', name: 'statusActive', desc: '', args: []);
  }

  /// `Sign in`
  String get loginTitle {
    return Intl.message('Sign in', name: 'loginTitle', desc: '', args: []);
  }

  /// `Continue with your Google account`
  String get loginSubtitle {
    return Intl.message(
      'Continue with your Google account',
      name: 'loginSubtitle',
      desc: '',
      args: [],
    );
  }

  /// `Continue with Google`
  String get loginWithGoogle {
    return Intl.message(
      'Continue with Google',
      name: 'loginWithGoogle',
      desc: '',
      args: [],
    );
  }

  /// `Signing in...`
  String get signingIn {
    return Intl.message('Signing in...', name: 'signingIn', desc: '', args: []);
  }

  /// `Back`
  String get loginBack {
    return Intl.message('Back', name: 'loginBack', desc: '', args: []);
  }

  /// `Supabase URL or anon key is missing...`
  String get supabaseConfigMissing {
    return Intl.message(
      'Supabase URL or anon key is missing. Set SUPABASE_URL and SUPABASE_ANON_KEY when running the app.',
      name: 'supabaseConfigMissing',
      desc: '',
      args: [],
    );
  }

  /// `Google Web Client ID is missing...`
  String get googleClientIdMissing {
    return Intl.message(
      'Google Web Client ID is missing. Set GOOGLE_WEB_CLIENT_ID (OAuth Web client from Google Cloud).',
      name: 'googleClientIdMissing',
      desc: '',
      args: [],
    );
  }

  /// `Signed in successfully`
  String get signedInSuccess {
    return Intl.message(
      'Signed in successfully',
      name: 'signedInSuccess',
      desc: '',
      args: [],
    );
  }
}

class AppLocalizationDelegate extends LocalizationsDelegate<S> {
  const AppLocalizationDelegate();

  List<Locale> get supportedLocales {
    return const <Locale>[
      Locale.fromSubtags(languageCode: 'en'),
      Locale.fromSubtags(languageCode: 'ru'),
    ];
  }

  @override
  bool isSupported(Locale locale) => _isSupported(locale);
  @override
  Future<S> load(Locale locale) => S.load(locale);
  @override
  bool shouldReload(AppLocalizationDelegate old) => false;

  bool _isSupported(Locale locale) {
    for (var supportedLocale in supportedLocales) {
      if (supportedLocale.languageCode == locale.languageCode) {
        return true;
      }
    }
    return false;
  }
}
