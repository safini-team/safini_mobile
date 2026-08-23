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

  /// `SAFINI`
  String get appName {
    return Intl.message('SAFINI', name: 'appName', desc: '', args: []);
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

  /// `Uzbek`
  String get uzbek {
    return Intl.message('Uzbek', name: 'uzbek', desc: '', args: []);
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

  /// `Minutes`
  String get minutes {
    return Intl.message('Minutes', name: 'minutes', desc: '', args: []);
  }

  /// `{count, plural, =1{{count} coin} other{{count} coins}}`
  String coinCount(int count) {
    return Intl.plural(
      count,
      one: '$count coin',
      other: '$count coins',
      name: 'coinCount',
      desc: '',
      args: [count],
    );
  }

  /// `{count, plural, =1{{count} minute} other{{count} minutes}}`
  String minuteCount(int count) {
    return Intl.plural(
      count,
      one: '$count minute',
      other: '$count minutes',
      name: 'minuteCount',
      desc: '',
      args: [count],
    );
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

  /// `Good afternoon 👋`
  String get goodAfternoon {
    return Intl.message(
      'Good afternoon 👋',
      name: 'goodAfternoon',
      desc: '',
      args: [],
    );
  }

  /// `Good evening 👋`
  String get goodEvening {
    return Intl.message(
      'Good evening 👋',
      name: 'goodEvening',
      desc: '',
      args: [],
    );
  }

  /// `Good night 🌙`
  String get goodNight {
    return Intl.message('Good night 🌙', name: 'goodNight', desc: '', args: []);
  }

  /// `Safini Parent`
  String get parentName {
    return Intl.message(
      'Safini Parent',
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

  /// `Set daily screen time limits`
  String get appLimitsSubtitle {
    return Intl.message(
      'Set daily screen time limits',
      name: 'appLimitsSubtitle',
      desc: '',
      args: [],
    );
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

  /// `{count, plural, =1{{count} coin reward} other{{count} coins reward}}`
  String coinsReward(int count) {
    return Intl.plural(
      count,
      one: '$count coin reward',
      other: '$count coins reward',
      name: 'coinsReward',
      desc: '',
      args: [count],
    );
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

  /// `Ready when you are`
  String get readyWhenYouAre {
    return Intl.message(
      'Ready when you are',
      name: 'readyWhenYouAre',
      desc: '',
      args: [],
    );
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

  /// `Sign in with email (Test)`
  String get loginWithEmailTest {
    return Intl.message(
      'Sign in with email (Test)',
      name: 'loginWithEmailTest',
      desc: '',
      args: [],
    );
  }

  /// `Test account sign-in`
  String get emailSignInTitle {
    return Intl.message(
      'Test account sign-in',
      name: 'emailSignInTitle',
      desc: '',
      args: [],
    );
  }

  /// `For debug and App Review accounts only.`
  String get emailSignInDescription {
    return Intl.message(
      'For debug and App Review accounts only.',
      name: 'emailSignInDescription',
      desc: '',
      args: [],
    );
  }

  /// `Email`
  String get emailLabel {
    return Intl.message('Email', name: 'emailLabel', desc: '', args: []);
  }

  /// `reviewer@example.com`
  String get emailHint {
    return Intl.message(
      'reviewer@example.com',
      name: 'emailHint',
      desc: '',
      args: [],
    );
  }

  /// `Password`
  String get passwordLabel {
    return Intl.message('Password', name: 'passwordLabel', desc: '', args: []);
  }

  /// `Enter password`
  String get passwordHint {
    return Intl.message(
      'Enter password',
      name: 'passwordHint',
      desc: '',
      args: [],
    );
  }

  /// `Enter a valid email address`
  String get emailRequired {
    return Intl.message(
      'Enter a valid email address',
      name: 'emailRequired',
      desc: '',
      args: [],
    );
  }

  /// `Enter your password`
  String get passwordRequired {
    return Intl.message(
      'Enter your password',
      name: 'passwordRequired',
      desc: '',
      args: [],
    );
  }

  /// `Sign in`
  String get signInAction {
    return Intl.message('Sign in', name: 'signInAction', desc: '', args: []);
  }

  /// `Signing in...`
  String get signingIn {
    return Intl.message('Signing in...', name: 'signingIn', desc: '', args: []);
  }

  /// `Back`
  String get loginBack {
    return Intl.message('Back', name: 'loginBack', desc: '', args: []);
  }

  /// `Supabase URL or anon key is missing. Set SUPABASE_URL and SUPABASE_ANON_KEY when running the app.`
  String get supabaseConfigMissing {
    return Intl.message(
      'Supabase URL or anon key is missing. Set SUPABASE_URL and SUPABASE_ANON_KEY when running the app.',
      name: 'supabaseConfigMissing',
      desc: '',
      args: [],
    );
  }

  /// `Google Web Client ID is missing. Set GOOGLE_WEB_CLIENT_ID (OAuth Web client from Google Cloud).`
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

  /// `Choose Your Role`
  String get chooseYourRole {
    return Intl.message(
      'Choose Your Role',
      name: 'chooseYourRole',
      desc: '',
      args: [],
    );
  }

  /// `How will you use Safini?`
  String get roleSelectionSubtitle {
    return Intl.message(
      'How will you use Safini?',
      name: 'roleSelectionSubtitle',
      desc: '',
      args: [],
    );
  }

  /// `Set Up Your Family`
  String get setupYourFamily {
    return Intl.message(
      'Set Up Your Family',
      name: 'setupYourFamily',
      desc: '',
      args: [],
    );
  }

  /// `Create your family space and invite your kids to start earning screen time.`
  String get familyDecisionSubtitle {
    return Intl.message(
      'Create your family space and invite your kids to start earning screen time.',
      name: 'familyDecisionSubtitle',
      desc: '',
      args: [],
    );
  }

  /// `Sign in failed. Please try again.`
  String get signInError {
    return Intl.message(
      'Sign in failed. Please try again.',
      name: 'signInError',
      desc: '',
      args: [],
    );
  }

  /// `Network error. Check your connection.`
  String get networkError {
    return Intl.message(
      'Network error. Check your connection.',
      name: 'networkError',
      desc: '',
      args: [],
    );
  }

  /// `Retry`
  String get retry {
    return Intl.message('Retry', name: 'retry', desc: '', args: []);
  }

  /// `Category`
  String get createTaskCategoryTitle {
    return Intl.message(
      'Category',
      name: 'createTaskCategoryTitle',
      desc: '',
      args: [],
    );
  }

  /// `Other`
  String get createTaskCategoryOther {
    return Intl.message(
      'Other',
      name: 'createTaskCategoryOther',
      desc: '',
      args: [],
    );
  }

  /// `New Task`
  String get createTaskSheetTitle {
    return Intl.message(
      'New Task',
      name: 'createTaskSheetTitle',
      desc: '',
      args: [],
    );
  }

  /// `Task Name`
  String get createTaskNameLabel {
    return Intl.message(
      'Task Name',
      name: 'createTaskNameLabel',
      desc: '',
      args: [],
    );
  }

  /// `e.g. Clean your room`
  String get createTaskNameHint {
    return Intl.message(
      'e.g. Clean your room',
      name: 'createTaskNameHint',
      desc: '',
      args: [],
    );
  }

  /// `Pick an Emoji`
  String get createTaskPickEmojiLabel {
    return Intl.message(
      'Pick an Emoji',
      name: 'createTaskPickEmojiLabel',
      desc: '',
      args: [],
    );
  }

  /// `Reward (Time Coins)`
  String get createTaskRewardLabel {
    return Intl.message(
      'Reward (Time Coins)',
      name: 'createTaskRewardLabel',
      desc: '',
      args: [],
    );
  }

  /// `Add Task`
  String get createTaskAddButton {
    return Intl.message(
      'Add Task',
      name: 'createTaskAddButton',
      desc: '',
      args: [],
    );
  }

  /// `Daily Chore`
  String get createTaskCategoryDailyChore {
    return Intl.message(
      'Daily Chore',
      name: 'createTaskCategoryDailyChore',
      desc: '',
      args: [],
    );
  }

  /// `Educational`
  String get createTaskCategoryEducational {
    return Intl.message(
      'Educational',
      name: 'createTaskCategoryEducational',
      desc: '',
      args: [],
    );
  }

  /// `Hobby`
  String get createTaskCategoryHobby {
    return Intl.message(
      'Hobby',
      name: 'createTaskCategoryHobby',
      desc: '',
      args: [],
    );
  }

  /// `Task created!`
  String get taskCreatedMessage {
    return Intl.message(
      'Task created!',
      name: 'taskCreatedMessage',
      desc: '',
      args: [],
    );
  }

  /// `Task updated!`
  String get taskUpdatedMessage {
    return Intl.message(
      'Task updated!',
      name: 'taskUpdatedMessage',
      desc: '',
      args: [],
    );
  }

  /// `Task deleted.`
  String get taskDeletedMessage {
    return Intl.message(
      'Task deleted.',
      name: 'taskDeletedMessage',
      desc: '',
      args: [],
    );
  }

  /// `No tasks for this day yet.`
  String get noTasksYet {
    return Intl.message(
      'No tasks for this day yet.',
      name: 'noTasksYet',
      desc: '',
      args: [],
    );
  }

  /// `Edit Task`
  String get editTaskSheetTitle {
    return Intl.message(
      'Edit Task',
      name: 'editTaskSheetTitle',
      desc: '',
      args: [],
    );
  }

  /// `Save`
  String get createTaskSaveButton {
    return Intl.message(
      'Save',
      name: 'createTaskSaveButton',
      desc: '',
      args: [],
    );
  }

  /// `Delete`
  String get deleteTaskButton {
    return Intl.message('Delete', name: 'deleteTaskButton', desc: '', args: []);
  }

  /// `Delete task?`
  String get deleteTaskTitle {
    return Intl.message(
      'Delete task?',
      name: 'deleteTaskTitle',
      desc: '',
      args: [],
    );
  }

  /// `This can't be undone.`
  String get deleteTaskBody {
    return Intl.message(
      'This can\'t be undone.',
      name: 'deleteTaskBody',
      desc: '',
      args: [],
    );
  }

  /// `Approved tasks can't be edited or deleted.`
  String get approvedTaskConflict {
    return Intl.message(
      'Approved tasks can\'t be edited or deleted.',
      name: 'approvedTaskConflict',
      desc: '',
      args: [],
    );
  }

  /// `Review Task`
  String get reviewTaskSheetTitle {
    return Intl.message(
      'Review Task',
      name: 'reviewTaskSheetTitle',
      desc: '',
      args: [],
    );
  }

  /// `Approve`
  String get approve {
    return Intl.message('Approve', name: 'approve', desc: '', args: []);
  }

  /// `Reject`
  String get reject {
    return Intl.message('Reject', name: 'reject', desc: '', args: []);
  }

  /// `Task approved!`
  String get taskApprovedMessage {
    return Intl.message(
      'Task approved!',
      name: 'taskApprovedMessage',
      desc: '',
      args: [],
    );
  }

  /// `Task rejected.`
  String get taskRejectedMessage {
    return Intl.message(
      'Task rejected.',
      name: 'taskRejectedMessage',
      desc: '',
      args: [],
    );
  }

  /// `Add a note (optional)`
  String get reviewNoteHint {
    return Intl.message(
      'Add a note (optional)',
      name: 'reviewNoteHint',
      desc: '',
      args: [],
    );
  }

  /// `Settings`
  String get settings {
    return Intl.message('Settings', name: 'settings', desc: '', args: []);
  }

  /// `Edit Profile`
  String get editProfile {
    return Intl.message(
      'Edit Profile',
      name: 'editProfile',
      desc: '',
      args: [],
    );
  }

  /// `Logout`
  String get logout {
    return Intl.message('Logout', name: 'logout', desc: '', args: []);
  }

  /// `My Family`
  String get myFamily {
    return Intl.message('My Family', name: 'myFamily', desc: '', args: []);
  }

  /// `Parents`
  String get parents {
    return Intl.message('Parents', name: 'parents', desc: '', args: []);
  }

  /// `Create Parent Invite Code`
  String get createParentInviteCode {
    return Intl.message(
      'Create Parent Invite Code',
      name: 'createParentInviteCode',
      desc: '',
      args: [],
    );
  }

  /// `Edit Child`
  String get editChild {
    return Intl.message('Edit Child', name: 'editChild', desc: '', args: []);
  }

  /// `Age: {age}`
  String ageLabel(int age) {
    return Intl.message('Age: $age', name: 'ageLabel', desc: '', args: [age]);
  }

  /// `Create Child Invite Code`
  String get createChildInviteCode {
    return Intl.message(
      'Create Child Invite Code',
      name: 'createChildInviteCode',
      desc: '',
      args: [],
    );
  }

  /// `Add Child`
  String get addChild {
    return Intl.message('Add Child', name: 'addChild', desc: '', args: []);
  }

  /// `Name`
  String get name {
    return Intl.message('Name', name: 'name', desc: '', args: []);
  }

  /// `Surname`
  String get surname {
    return Intl.message('Surname', name: 'surname', desc: '', args: []);
  }

  /// `No family set up yet`
  String get noFamilySetupYet {
    return Intl.message(
      'No family set up yet',
      name: 'noFamilySetupYet',
      desc: '',
      args: [],
    );
  }

  /// `Create a family or join one with an invite code.`
  String get createOrJoinFamily {
    return Intl.message(
      'Create a family or join one with an invite code.',
      name: 'createOrJoinFamily',
      desc: '',
      args: [],
    );
  }

  /// `Parent Invite Code`
  String get parentInviteCodeTitle {
    return Intl.message(
      'Parent Invite Code',
      name: 'parentInviteCodeTitle',
      desc: '',
      args: [],
    );
  }

  /// `Child Invite Code`
  String get childInviteCodeTitle {
    return Intl.message(
      'Child Invite Code',
      name: 'childInviteCodeTitle',
      desc: '',
      args: [],
    );
  }

  /// `Expires: {date}, {time}`
  String expiresLabel(String date, String time) {
    return Intl.message(
      'Expires: $date, $time',
      name: 'expiresLabel',
      desc: '',
      args: [date, time],
    );
  }

  /// `Invite code copied`
  String get inviteCodeCopied {
    return Intl.message(
      'Invite code copied',
      name: 'inviteCodeCopied',
      desc: '',
      args: [],
    );
  }

  /// `Close`
  String get close {
    return Intl.message('Close', name: 'close', desc: '', args: []);
  }

  /// `Copy`
  String get copy {
    return Intl.message('Copy', name: 'copy', desc: '', args: []);
  }

  /// `No children found yet`
  String get noChildrenFoundYet {
    return Intl.message(
      'No children found yet',
      name: 'noChildrenFoundYet',
      desc: '',
      args: [],
    );
  }

  /// `Invite a child or refresh after linking a family member.`
  String get inviteChildOrRefresh {
    return Intl.message(
      'Invite a child or refresh after linking a family member.',
      name: 'inviteChildOrRefresh',
      desc: '',
      args: [],
    );
  }

  /// `Delete Account`
  String get deleteAccount {
    return Intl.message(
      'Delete Account',
      name: 'deleteAccount',
      desc: '',
      args: [],
    );
  }

  /// `Delete Account?`
  String get deleteAccountConfirmTitle {
    return Intl.message(
      'Delete Account?',
      name: 'deleteAccountConfirmTitle',
      desc: '',
      args: [],
    );
  }

  /// `Are you sure you want to delete your account? This action cannot be undone.`
  String get deleteAccountConfirmBody {
    return Intl.message(
      'Are you sure you want to delete your account? This action cannot be undone.',
      name: 'deleteAccountConfirmBody',
      desc: '',
      args: [],
    );
  }

  /// `Remove from Family`
  String get removeParent {
    return Intl.message(
      'Remove from Family',
      name: 'removeParent',
      desc: '',
      args: [],
    );
  }

  /// `Remove Parent?`
  String get removeParentConfirmTitle {
    return Intl.message(
      'Remove Parent?',
      name: 'removeParentConfirmTitle',
      desc: '',
      args: [],
    );
  }

  /// `Are you sure you want to remove this parent from the family?`
  String get removeParentConfirmBody {
    return Intl.message(
      'Are you sure you want to remove this parent from the family?',
      name: 'removeParentConfirmBody',
      desc: '',
      args: [],
    );
  }

  /// `Log out?`
  String get logoutConfirmTitle {
    return Intl.message(
      'Log out?',
      name: 'logoutConfirmTitle',
      desc: '',
      args: [],
    );
  }

  /// `Are you sure you want to log out?`
  String get logoutConfirmBody {
    return Intl.message(
      'Are you sure you want to log out?',
      name: 'logoutConfirmBody',
      desc: '',
      args: [],
    );
  }

  /// `Create a child profile`
  String get createChildProfileTitle {
    return Intl.message(
      'Create a child profile',
      name: 'createChildProfileTitle',
      desc: '',
      args: [],
    );
  }

  /// `Fill out the details below to add a child to your family.`
  String get createChildProfileSubtitle {
    return Intl.message(
      'Fill out the details below to add a child to your family.',
      name: 'createChildProfileSubtitle',
      desc: '',
      args: [],
    );
  }

  /// `Nickname`
  String get nicknameLabel {
    return Intl.message('Nickname', name: 'nicknameLabel', desc: '', args: []);
  }

  /// `Nickname is required.`
  String get nicknameRequired {
    return Intl.message(
      'Nickname is required.',
      name: 'nicknameRequired',
      desc: '',
      args: [],
    );
  }

  /// `Nickname must be at most 80 characters.`
  String get nicknameTooLong {
    return Intl.message(
      'Nickname must be at most 80 characters.',
      name: 'nicknameTooLong',
      desc: '',
      args: [],
    );
  }

  /// `Age`
  String get ageFieldLabel {
    return Intl.message('Age', name: 'ageFieldLabel', desc: '', args: []);
  }

  /// `Age is required.`
  String get ageRequired {
    return Intl.message(
      'Age is required.',
      name: 'ageRequired',
      desc: '',
      args: [],
    );
  }

  /// `Age must be an integer.`
  String get ageMustBeInteger {
    return Intl.message(
      'Age must be an integer.',
      name: 'ageMustBeInteger',
      desc: '',
      args: [],
    );
  }

  /// `Age must be between 0 and 18.`
  String get ageRange {
    return Intl.message(
      'Age must be between 0 and 18.',
      name: 'ageRange',
      desc: '',
      args: [],
    );
  }

  /// `Gender (optional)`
  String get genderOptional {
    return Intl.message(
      'Gender (optional)',
      name: 'genderOptional',
      desc: '',
      args: [],
    );
  }

  /// `Boy`
  String get genderBoy {
    return Intl.message('Boy', name: 'genderBoy', desc: '', args: []);
  }

  /// `Girl`
  String get genderGirl {
    return Intl.message('Girl', name: 'genderGirl', desc: '', args: []);
  }

  /// `Other`
  String get genderOther {
    return Intl.message('Other', name: 'genderOther', desc: '', args: []);
  }

  /// `Create Child`
  String get createChildButton {
    return Intl.message(
      'Create Child',
      name: 'createChildButton',
      desc: '',
      args: [],
    );
  }

  /// `Update your child's information below.`
  String get editProfileSubtitle {
    return Intl.message(
      'Update your child\'s information below.',
      name: 'editProfileSubtitle',
      desc: '',
      args: [],
    );
  }

  /// `Save Changes`
  String get saveChanges {
    return Intl.message(
      'Save Changes',
      name: 'saveChanges',
      desc: '',
      args: [],
    );
  }

  /// `Child profile updated successfully.`
  String get childUpdatedSuccess {
    return Intl.message(
      'Child profile updated successfully.',
      name: 'childUpdatedSuccess',
      desc: '',
      args: [],
    );
  }

  /// `Today`
  String get tabToday {
    return Intl.message('Today', name: 'tabToday', desc: '', args: []);
  }

  /// `Limits`
  String get tabLimits {
    return Intl.message('Limits', name: 'tabLimits', desc: '', args: []);
  }

  /// `Me`
  String get tabMe {
    return Intl.message('Me', name: 'tabMe', desc: '', args: []);
  }

  /// `Family`
  String get tabFamily {
    return Intl.message('Family', name: 'tabFamily', desc: '', args: []);
  }

  /// `Tasks`
  String get tabTasks {
    return Intl.message('Tasks', name: 'tabTasks', desc: '', args: []);
  }

  /// `Store`
  String get tabStore {
    return Intl.message('Store', name: 'tabStore', desc: '', args: []);
  }

  /// `Create a family`
  String get createFamilyAction {
    return Intl.message(
      'Create a family',
      name: 'createFamilyAction',
      desc: '',
      args: [],
    );
  }

  /// `Join with a code`
  String get joinFamilyAction {
    return Intl.message(
      'Join with a code',
      name: 'joinFamilyAction',
      desc: '',
      args: [],
    );
  }

  /// `Sent to your parent`
  String get taskSubmittedForReview {
    return Intl.message(
      'Sent to your parent',
      name: 'taskSubmittedForReview',
      desc: '',
      args: [],
    );
  }

  /// `Saved`
  String get profileUpdated {
    return Intl.message('Saved', name: 'profileUpdated', desc: '', args: []);
  }

  /// `Your parent approves before it is yours`
  String get storeSubtitle {
    return Intl.message(
      'Your parent approves before it is yours',
      name: 'storeSubtitle',
      desc: '',
      args: [],
    );
  }

  /// `Screen time`
  String get screenTime {
    return Intl.message('Screen time', name: 'screenTime', desc: '', args: []);
  }

  /// `{name} has {time} left today`
  String kidHasLeftToday(Object name, Object time) {
    return Intl.message(
      '$name has $time left today',
      name: 'kidHasLeftToday',
      desc: '',
      args: [name, time],
    );
  }

  /// `{name} used {time} today`
  String kidUsedToday(Object name, Object time) {
    return Intl.message(
      '$name used $time today',
      name: 'kidUsedToday',
      desc: '',
      args: [name, time],
    );
  }

  /// `Most of it in {app}`
  String mostOfItIn(Object app) {
    return Intl.message(
      'Most of it in $app',
      name: 'mostOfItIn',
      desc: '',
      args: [app],
    );
  }

  /// `Tasks done`
  String get statTasksDone {
    return Intl.message(
      'Tasks done',
      name: 'statTasksDone',
      desc: '',
      args: [],
    );
  }

  /// `Day streak`
  String get statDayStreak {
    return Intl.message(
      'Day streak',
      name: 'statDayStreak',
      desc: '',
      args: [],
    );
  }

  /// `Coins`
  String get statCoins {
    return Intl.message('Coins', name: 'statCoins', desc: '', args: []);
  }

  /// `Needs your review`
  String get needsYourReview {
    return Intl.message(
      'Needs your review',
      name: 'needsYourReview',
      desc: '',
      args: [],
    );
  }

  /// `{count, plural, =1{1 waiting} other{{count} waiting}}`
  String waitingCount(num count) {
    return Intl.plural(
      count,
      one: '1 waiting',
      other: '$count waiting',
      name: 'waitingCount',
      desc: '',
      args: [count],
    );
  }

  /// `Look closer`
  String get lookCloser {
    return Intl.message('Look closer', name: 'lookCloser', desc: '', args: []);
  }

  /// `All caught up`
  String get allCaughtUp {
    return Intl.message(
      'All caught up',
      name: 'allCaughtUp',
      desc: '',
      args: [],
    );
  }

  /// `New submissions land here.`
  String get newSubmissionsLandHere {
    return Intl.message(
      'New submissions land here.',
      name: 'newSubmissionsLandHere',
      desc: '',
      args: [],
    );
  }

  /// `Where the time went`
  String get whereTheTimeWent {
    return Intl.message(
      'Where the time went',
      name: 'whereTheTimeWent',
      desc: '',
      args: [],
    );
  }

  /// `Set one up and their day shows here.`
  String get noChildYetBody {
    return Intl.message(
      'Set one up and their day shows here.',
      name: 'noChildYetBody',
      desc: '',
      args: [],
    );
  }

  /// `To review`
  String get laneToReview {
    return Intl.message('To review', name: 'laneToReview', desc: '', args: []);
  }

  /// `Active`
  String get laneActive {
    return Intl.message('Active', name: 'laneActive', desc: '', args: []);
  }

  /// `Done`
  String get laneDone {
    return Intl.message('Done', name: 'laneDone', desc: '', args: []);
  }

  /// `Check`
  String get pillCheck {
    return Intl.message('Check', name: 'pillCheck', desc: '', args: []);
  }

  /// `Paid`
  String get pillPaid {
    return Intl.message('Paid', name: 'pillPaid', desc: '', args: []);
  }

  /// `Waiting`
  String get pillWaiting {
    return Intl.message('Waiting', name: 'pillWaiting', desc: '', args: []);
  }

  /// `Everyone`
  String get scopeEveryone {
    return Intl.message('Everyone', name: 'scopeEveryone', desc: '', args: []);
  }

  /// `{count, plural, =1{1 task} other{{count} tasks}}`
  String taskCount(num count) {
    return Intl.plural(
      count,
      one: '1 task',
      other: '$count tasks',
      name: 'taskCount',
      desc: '',
      args: [count],
    );
  }

  /// `{count, plural, =1{1 coin} other{{count} coins}}`
  String coinCountShort(num count) {
    return Intl.plural(
      count,
      one: '1 coin',
      other: '$count coins',
      name: 'coinCountShort',
      desc: '',
      args: [count],
    );
  }

  /// `{scope} · {tasks}`
  String taskScopeLine(Object scope, Object tasks) {
    return Intl.message(
      '$scope · $tasks',
      name: 'taskScopeLine',
      desc: '',
      args: [scope, tasks],
    );
  }

  /// `{tasks} · {coins}`
  String taskGroupSummary(Object tasks, Object coins) {
    return Intl.message(
      '$tasks · $coins',
      name: 'taskGroupSummary',
      desc: '',
      args: [tasks, coins],
    );
  }

  /// `Coins are paid out only after you approve. Repeating tasks reset at midnight.`
  String get coinsPaidAfterApproval {
    return Intl.message(
      'Coins are paid out only after you approve. Repeating tasks reset at midnight.',
      name: 'coinsPaidAfterApproval',
      desc: '',
      args: [],
    );
  }

  /// `Nothing to review`
  String get emptyNothingToReview {
    return Intl.message(
      'Nothing to review',
      name: 'emptyNothingToReview',
      desc: '',
      args: [],
    );
  }

  /// `No active tasks`
  String get emptyNoActiveTasks {
    return Intl.message(
      'No active tasks',
      name: 'emptyNoActiveTasks',
      desc: '',
      args: [],
    );
  }

  /// `Nothing paid yet`
  String get emptyNothingPaidYet {
    return Intl.message(
      'Nothing paid yet',
      name: 'emptyNothingPaidYet',
      desc: '',
      args: [],
    );
  }

  /// `New submissions land here.`
  String get emptyReviewBody {
    return Intl.message(
      'New submissions land here.',
      name: 'emptyReviewBody',
      desc: '',
      args: [],
    );
  }

  /// `Add one with the button below.`
  String get emptyActiveBody {
    return Intl.message(
      'Add one with the button below.',
      name: 'emptyActiveBody',
      desc: '',
      args: [],
    );
  }

  /// `Approved tasks show up here.`
  String get emptyDoneBody {
    return Intl.message(
      'Approved tasks show up here.',
      name: 'emptyDoneBody',
      desc: '',
      args: [],
    );
  }

  /// `{name}'s phone · today`
  String limitsSubtitle(Object name) {
    return Intl.message(
      '$name\'s phone · today',
      name: 'limitsSubtitle',
      desc: '',
      args: [name],
    );
  }

  /// `{name} · daily allowance`
  String dailyAllowanceFor(Object name) {
    return Intl.message(
      '$name · daily allowance',
      name: 'dailyAllowanceFor',
      desc: '',
      args: [name],
    );
  }

  /// `No limits set`
  String get noLimitsSet {
    return Intl.message(
      'No limits set',
      name: 'noLimitsSet',
      desc: '',
      args: [],
    );
  }

  /// `{time} used`
  String timeUsed(Object time) {
    return Intl.message('$time used', name: 'timeUsed', desc: '', args: [time]);
  }

  /// `{time} left`
  String timeLeft(Object time) {
    return Intl.message('$time left', name: 'timeLeft', desc: '', args: [time]);
  }

  /// `{name}'s apps`
  String kidsApps(Object name) {
    return Intl.message(
      '$name\'s apps',
      name: 'kidsApps',
      desc: '',
      args: [name],
    );
  }

  /// `Add an app`
  String get addAnApp {
    return Intl.message('Add an app', name: 'addAnApp', desc: '', args: []);
  }

  /// `A blocked app disappears from the home screen. Apps with no limit are always allowed.`
  String get limitsFootnote {
    return Intl.message(
      'A blocked app disappears from the home screen. Apps with no limit are always allowed.',
      name: 'limitsFootnote',
      desc: '',
      args: [],
    );
  }

  /// `Always allowed · no redemption`
  String get alwaysAllowedNoRedemption {
    return Intl.message(
      'Always allowed · no redemption',
      name: 'alwaysAllowedNoRedemption',
      desc: '',
      args: [],
    );
  }

  /// `{used} of {limit}`
  String usedOfLimit(Object used, Object limit) {
    return Intl.message(
      '$used of $limit',
      name: 'usedOfLimit',
      desc: '',
      args: [used, limit],
    );
  }

  /// `{used} of {limit} · over`
  String usedOfLimitOver(Object used, Object limit) {
    return Intl.message(
      '$used of $limit · over',
      name: 'usedOfLimitOver',
      desc: '',
      args: [used, limit],
    );
  }

  /// `{used} · no limit`
  String usedNoLimit(Object used) {
    return Intl.message(
      '$used · no limit',
      name: 'usedNoLimit',
      desc: '',
      args: [used],
    );
  }

  /// `Invited`
  String get invited {
    return Intl.message('Invited', name: 'invited', desc: '', args: []);
  }

  /// `Both parents see the same tasks and can approve them.`
  String get bothParentsSee {
    return Intl.message(
      'Both parents see the same tasks and can approve them.',
      name: 'bothParentsSee',
      desc: '',
      args: [],
    );
  }

  /// `Your account`
  String get yourAccount {
    return Intl.message(
      'Your account',
      name: 'yourAccount',
      desc: '',
      args: [],
    );
  }

  /// `Invite a parent`
  String get inviteAParent {
    return Intl.message(
      'Invite a parent',
      name: 'inviteAParent',
      desc: '',
      args: [],
    );
  }

  /// `Add`
  String get addShort {
    return Intl.message('Add', name: 'addShort', desc: '', args: []);
  }

  /// `Level`
  String get levelShort {
    return Intl.message('Level', name: 'levelShort', desc: '', args: []);
  }

  /// `Level {level}`
  String levelValue(Object level) {
    return Intl.message(
      'Level $level',
      name: 'levelValue',
      desc: '',
      args: [level],
    );
  }

  /// `No children yet`
  String get noChildrenYet {
    return Intl.message(
      'No children yet',
      name: 'noChildrenYet',
      desc: '',
      args: [],
    );
  }

  /// `Add one and they get a pairing code.`
  String get noChildrenYetBody {
    return Intl.message(
      'Add one and they get a pairing code.',
      name: 'noChildrenYetBody',
      desc: '',
      args: [],
    );
  }

  /// `Add a child`
  String get addAChild {
    return Intl.message('Add a child', name: 'addAChild', desc: '', args: []);
  }

  /// `Owner`
  String get roleOwner {
    return Intl.message('Owner', name: 'roleOwner', desc: '', args: []);
  }

  /// `Parent`
  String get roleParent {
    return Intl.message('Parent', name: 'roleParent', desc: '', args: []);
  }

  /// `Not recorded`
  String get notRecorded {
    return Intl.message(
      'Not recorded',
      name: 'notRecorded',
      desc: '',
      args: [],
    );
  }

  /// `Paired`
  String get paired {
    return Intl.message('Paired', name: 'paired', desc: '', args: []);
  }

  /// `Not paired yet`
  String get notPairedYet {
    return Intl.message(
      'Not paired yet',
      name: 'notPairedYet',
      desc: '',
      args: [],
    );
  }

  /// `Role`
  String get roleLabel {
    return Intl.message('Role', name: 'roleLabel', desc: '', args: []);
  }

  /// `In the family since`
  String get inTheFamilySince {
    return Intl.message(
      'In the family since',
      name: 'inTheFamilySince',
      desc: '',
      args: [],
    );
  }

  /// `Invite code · valid 24 hours`
  String get inviteCodeValid {
    return Intl.message(
      'Invite code · valid 24 hours',
      name: 'inviteCodeValid',
      desc: '',
      args: [],
    );
  }

  /// `Re-connect code · valid 24 hours`
  String get reconnectCodeValid {
    return Intl.message(
      'Re-connect code · valid 24 hours',
      name: 'reconnectCodeValid',
      desc: '',
      args: [],
    );
  }

  /// `Pairing code`
  String get pairingCodeCaption {
    return Intl.message(
      'Pairing code',
      name: 'pairingCodeCaption',
      desc: '',
      args: [],
    );
  }

  /// `They install Safini and sign in, then enter this code.`
  String get theyInstallSafini {
    return Intl.message(
      'They install Safini and sign in, then enter this code.',
      name: 'theyInstallSafini',
      desc: '',
      args: [],
    );
  }

  /// `Type it on {name}'s phone, under "I'm a kid".`
  String typeItOnPhone(Object name) {
    return Intl.message(
      'Type it on $name\'s phone, under "I\'m a kid".',
      name: 'typeItOnPhone',
      desc: '',
      args: [name],
    );
  }

  /// `Edit my profile`
  String get editMyProfile {
    return Intl.message(
      'Edit my profile',
      name: 'editMyProfile',
      desc: '',
      args: [],
    );
  }

  /// `Remove from family`
  String get removeFromFamily {
    return Intl.message(
      'Remove from family',
      name: 'removeFromFamily',
      desc: '',
      args: [],
    );
  }

  /// `Edit {name}`
  String editName(Object name) {
    return Intl.message('Edit $name', name: 'editName', desc: '', args: [name]);
  }

  /// `Copy code`
  String get copyCode {
    return Intl.message('Copy code', name: 'copyCode', desc: '', args: []);
  }

  /// `Code copied`
  String get codeCopied {
    return Intl.message('Code copied', name: 'codeCopied', desc: '', args: []);
  }

  /// `Not set`
  String get notSet {
    return Intl.message('Not set', name: 'notSet', desc: '', args: []);
  }

  /// `{age} years old`
  String yearsOld(Object age) {
    return Intl.message(
      '$age years old',
      name: 'yearsOld',
      desc: '',
      args: [age],
    );
  }

  /// `Create an invite code`
  String get createAnInviteCode {
    return Intl.message(
      'Create an invite code',
      name: 'createAnInviteCode',
      desc: '',
      args: [],
    );
  }

  /// `Re-connect with a code`
  String get reconnectWithCode {
    return Intl.message(
      'Re-connect with a code',
      name: 'reconnectWithCode',
      desc: '',
      args: [],
    );
  }

  /// `Done`
  String get doneAction {
    return Intl.message('Done', name: 'doneAction', desc: '', args: []);
  }

  /// `Account`
  String get sectionAccount {
    return Intl.message('Account', name: 'sectionAccount', desc: '', args: []);
  }

  /// `App`
  String get sectionApp {
    return Intl.message('App', name: 'sectionApp', desc: '', args: []);
  }

  /// `Who are we setting up?`
  String get whoAreWeSettingUp {
    return Intl.message(
      'Who are we setting up?',
      name: 'whoAreWeSettingUp',
      desc: '',
      args: [],
    );
  }

  /// `Step 1 of 2 - you can add more kids later.`
  String get step1of2 {
    return Intl.message(
      'Step 1 of 2 - you can add more kids later.',
      name: 'step1of2',
      desc: '',
      args: [],
    );
  }

  /// `Step 2 of 2 - the code works for 24 hours.`
  String get step2of2 {
    return Intl.message(
      'Step 2 of 2 - the code works for 24 hours.',
      name: 'step2of2',
      desc: '',
      args: [],
    );
  }

  /// `{name}'s code is ready`
  String codeIsReady(Object name) {
    return Intl.message(
      '$name\'s code is ready',
      name: 'codeIsReady',
      desc: '',
      args: [name],
    );
  }

  /// `Install Safini on {name}'s phone`
  String pairStepInstall(Object name) {
    return Intl.message(
      'Install Safini on $name\'s phone',
      name: 'pairStepInstall',
      desc: '',
      args: [name],
    );
  }

  /// `Tap "I'm a kid" and type the code`
  String get pairStepTap {
    return Intl.message(
      'Tap "I\'m a kid" and type the code',
      name: 'pairStepTap',
      desc: '',
      args: [],
    );
  }

  /// `Allow screen time access when asked`
  String get pairStepAllow {
    return Intl.message(
      'Allow screen time access when asked',
      name: 'pairStepAllow',
      desc: '',
      args: [],
    );
  }

  /// `Waiting for {name}'s phone…`
  String waitingForPhone(Object name) {
    return Intl.message(
      'Waiting for $name\'s phone…',
      name: 'waitingForPhone',
      desc: '',
      args: [name],
    );
  }

  /// `Go to my family`
  String get goToMyFamily {
    return Intl.message(
      'Go to my family',
      name: 'goToMyFamily',
      desc: '',
      args: [],
    );
  }

  /// `Continue`
  String get continueAction {
    return Intl.message('Continue', name: 'continueAction', desc: '', args: []);
  }

  /// `Details`
  String get detailsSection {
    return Intl.message('Details', name: 'detailsSection', desc: '', args: []);
  }

  /// `Type the code from your parent`
  String get typeCodeFromParent {
    return Intl.message(
      'Type the code from your parent',
      name: 'typeCodeFromParent',
      desc: '',
      args: [],
    );
  }

  /// `Type the code from the other parent`
  String get typeCodeFromOtherParent {
    return Intl.message(
      'Type the code from the other parent',
      name: 'typeCodeFromOtherParent',
      desc: '',
      args: [],
    );
  }

  /// `No code? Ask your parent to open Safini, then My family.`
  String get noCodeAskParent {
    return Intl.message(
      'No code? Ask your parent to open Safini, then My family.',
      name: 'noCodeAskParent',
      desc: '',
      args: [],
    );
  }

  /// `No code? Ask them to open Safini, then My family.`
  String get noCodeAskThem {
    return Intl.message(
      'No code? Ask them to open Safini, then My family.',
      name: 'noCodeAskThem',
      desc: '',
      args: [],
    );
  }

  /// `Name it something the whole family recognises. You can invite people once it exists.`
  String get nameYourFamily {
    return Intl.message(
      'Name it something the whole family recognises. You can invite people once it exists.',
      name: 'nameYourFamily',
      desc: '',
      args: [],
    );
  }

  /// `Family`
  String get familyLabel {
    return Intl.message('Family', name: 'familyLabel', desc: '', args: []);
  }

  /// `Start a family space and invite others`
  String get createFamilySubtitle {
    return Intl.message(
      'Start a family space and invite others',
      name: 'createFamilySubtitle',
      desc: '',
      args: [],
    );
  }

  /// `Use an invite code from the other parent`
  String get joinFamilySubtitle {
    return Intl.message(
      'Use an invite code from the other parent',
      name: 'joinFamilySubtitle',
      desc: '',
      args: [],
    );
  }

  /// `All tasks`
  String get allTasks {
    return Intl.message('All tasks', name: 'allTasks', desc: '', args: []);
  }

  /// `Do this next`
  String get doThisNext {
    return Intl.message('Do this next', name: 'doThisNext', desc: '', args: []);
  }

  /// `Nothing left`
  String get nothingLeft {
    return Intl.message(
      'Nothing left',
      name: 'nothingLeft',
      desc: '',
      args: [],
    );
  }

  /// `Almost yours`
  String get almostYours {
    return Intl.message(
      'Almost yours',
      name: 'almostYours',
      desc: '',
      args: [],
    );
  }

  /// `of {total}`
  String ofTotal(Object total) {
    return Intl.message('of $total', name: 'ofTotal', desc: '', args: [total]);
  }

  /// `{tasks} left - {coins} on the table`
  String tasksLeftCoinsOnTable(Object tasks, Object coins) {
    return Intl.message(
      '$tasks left - $coins on the table',
      name: 'tasksLeftCoinsOnTable',
      desc: '',
      args: [tasks, coins],
    );
  }

  /// `Everything is with your parent`
  String get everythingIsWithParent {
    return Intl.message(
      'Everything is with your parent',
      name: 'everythingIsWithParent',
      desc: '',
      args: [],
    );
  }

  /// `{count}-day streak`
  String nDayStreak(Object count) {
    return Intl.message(
      '$count-day streak',
      name: 'nDayStreak',
      desc: '',
      args: [count],
    );
  }

  /// `Hold to mark it done`
  String get holdToMarkDone {
    return Intl.message(
      'Hold to mark it done',
      name: 'holdToMarkDone',
      desc: '',
      args: [],
    );
  }

  /// `Mark it done`
  String get markItDone {
    return Intl.message('Mark it done', name: 'markItDone', desc: '', args: []);
  }

  /// `Keep holding…`
  String get keepHolding {
    return Intl.message(
      'Keep holding…',
      name: 'keepHolding',
      desc: '',
      args: [],
    );
  }

  /// `Everything's sent`
  String get everythingSent {
    return Intl.message(
      'Everything\'s sent',
      name: 'everythingSent',
      desc: '',
      args: [],
    );
  }

  /// `Your parent reviews them next. Coins land after that.`
  String get parentReviewsNext {
    return Intl.message(
      'Your parent reviews them next. Coins land after that.',
      name: 'parentReviewsNext',
      desc: '',
      args: [],
    );
  }

  /// `{count} coins to go`
  String coinsToGo(Object count) {
    return Intl.message(
      '$count coins to go',
      name: 'coinsToGo',
      desc: '',
      args: [count],
    );
  }

  /// `{done} of {total} done today · {coins} coins waiting`
  String childTasksSubtitle(Object done, Object total, Object coins) {
    return Intl.message(
      '$done of $total done today · $coins coins waiting',
      name: 'childTasksSubtitle',
      desc: '',
      args: [done, total, coins],
    );
  }

  /// `Nothing here yet`
  String get nothingHereYet {
    return Intl.message(
      'Nothing here yet',
      name: 'nothingHereYet',
      desc: '',
      args: [],
    );
  }

  /// `Ask for something new and your parent can add it to the store.`
  String get askForSomethingNew {
    return Intl.message(
      'Ask for something new and your parent can add it to the store.',
      name: 'askForSomethingNew',
      desc: '',
      args: [],
    );
  }

  /// `Yours`
  String get yoursLabel {
    return Intl.message('Yours', name: 'yoursLabel', desc: '', args: []);
  }

  /// `{count} to go`
  String toGo(Object count) {
    return Intl.message('$count to go', name: 'toGo', desc: '', args: [count]);
  }

  /// `Nothing in the store yet.`
  String get nothingInStore {
    return Intl.message(
      'Nothing in the store yet.',
      name: 'nothingInStore',
      desc: '',
      args: [],
    );
  }

  /// `App time`
  String get storeAppTimeTab {
    return Intl.message(
      'App time',
      name: 'storeAppTimeTab',
      desc: '',
      args: [],
    );
  }

  /// `Avatar`
  String get storeAvatarTab {
    return Intl.message('Avatar', name: 'storeAvatarTab', desc: '', args: []);
  }

  /// `{app} · {minutes} min`
  String appTimeItem(Object app, Object minutes) {
    return Intl.message(
      '$app · $minutes min',
      name: 'appTimeItem',
      desc: '',
      args: [app, minutes],
    );
  }

  /// `Avatar item`
  String get avatarItem {
    return Intl.message('Avatar item', name: 'avatarItem', desc: '', args: []);
  }

  /// `{minutes} m left`
  String minutesLeftShort(Object minutes) {
    return Intl.message(
      '$minutes m left',
      name: 'minutesLeftShort',
      desc: '',
      args: [minutes],
    );
  }

  /// `Added to today only, once your parent approves.`
  String get rewardBlurbAppTime {
    return Intl.message(
      'Added to today only, once your parent approves.',
      name: 'rewardBlurbAppTime',
      desc: '',
      args: [],
    );
  }

  /// `Wear it on your avatar. Yours to keep.`
  String get rewardBlurbAvatar {
    return Intl.message(
      'Wear it on your avatar. Yours to keep.',
      name: 'rewardBlurbAvatar',
      desc: '',
      args: [],
    );
  }

  /// `Ask for this`
  String get askForThis {
    return Intl.message('Ask for this', name: 'askForThis', desc: '', args: []);
  }

  /// `Not yet`
  String get notYet {
    return Intl.message('Not yet', name: 'notYet', desc: '', args: []);
  }

  /// `{count} more coins needed`
  String moreCoinsNeeded(Object count) {
    return Intl.message(
      '$count more coins needed',
      name: 'moreCoinsNeeded',
      desc: '',
      args: [count],
    );
  }

  /// `This week`
  String get thisWeek {
    return Intl.message('This week', name: 'thisWeek', desc: '', args: []);
  }

  /// `Badges`
  String get badges {
    return Intl.message('Badges', name: 'badges', desc: '', args: []);
  }

  /// `Change avatar`
  String get changeAvatar {
    return Intl.message(
      'Change avatar',
      name: 'changeAvatar',
      desc: '',
      args: [],
    );
  }

  /// `{count} tasks done`
  String badgeTasksDone(Object count) {
    return Intl.message(
      '$count tasks done',
      name: 'badgeTasksDone',
      desc: '',
      args: [count],
    );
  }

  /// `{count} coins`
  String badgeCoins(Object count) {
    return Intl.message(
      '$count coins',
      name: 'badgeCoins',
      desc: '',
      args: [count],
    );
  }

  /// `{percent}% to the next level`
  String percentToNextLevel(Object percent) {
    return Intl.message(
      '$percent% to the next level',
      name: 'percentToNextLevel',
      desc: '',
      args: [percent],
    );
  }

  /// `Your avatar`
  String get yourAvatar {
    return Intl.message('Your avatar', name: 'yourAvatar', desc: '', args: []);
  }

  /// `Face`
  String get faceSection {
    return Intl.message('Face', name: 'faceSection', desc: '', args: []);
  }

  /// `Extras`
  String get extrasSection {
    return Intl.message('Extras', name: 'extrasSection', desc: '', args: []);
  }

  /// `Extras cost coins once. Nothing here changes your tasks.`
  String get extrasFootnote {
    return Intl.message(
      'Extras cost coins once. Nothing here changes your tasks.',
      name: 'extrasFootnote',
      desc: '',
      args: [],
    );
  }

  /// `On`
  String get wornLabel {
    return Intl.message('On', name: 'wornLabel', desc: '', args: []);
  }

  /// `Wear`
  String get wearLabel {
    return Intl.message('Wear', name: 'wearLabel', desc: '', args: []);
  }

  /// `Locked`
  String get lockedLabel {
    return Intl.message('Locked', name: 'lockedLabel', desc: '', args: []);
  }

  /// `Unlock once, keep forever`
  String get unlockOnceKeepForever {
    return Intl.message(
      'Unlock once, keep forever',
      name: 'unlockOnceKeepForever',
      desc: '',
      args: [],
    );
  }

  /// `{count} coins to go`
  String coinsToGoShort(Object count) {
    return Intl.message(
      '$count coins to go',
      name: 'coinsToGoShort',
      desc: '',
      args: [count],
    );
  }

  /// `Outfit`
  String get extraOutfit {
    return Intl.message('Outfit', name: 'extraOutfit', desc: '', args: []);
  }

  /// `Hair`
  String get extraHair {
    return Intl.message('Hair', name: 'extraHair', desc: '', args: []);
  }

  /// `Backpack`
  String get extraBackpack {
    return Intl.message('Backpack', name: 'extraBackpack', desc: '', args: []);
  }

  /// `Note from your parent`
  String get noteFromParent {
    return Intl.message(
      'Note from your parent',
      name: 'noteFromParent',
      desc: '',
      args: [],
    );
  }

  /// `Note for your parent · optional`
  String get noteForParent {
    return Intl.message(
      'Note for your parent · optional',
      name: 'noteForParent',
      desc: '',
      args: [],
    );
  }

  /// `Waiting for your parent to check it`
  String get waitingForParentCheck {
    return Intl.message(
      'Waiting for your parent to check it',
      name: 'waitingForParentCheck',
      desc: '',
      args: [],
    );
  }

  /// `Paid out. Nice one.`
  String get paidOutNice {
    return Intl.message(
      'Paid out. Nice one.',
      name: 'paidOutNice',
      desc: '',
      args: [],
    );
  }

  /// `Their note`
  String get theirNote {
    return Intl.message('Their note', name: 'theirNote', desc: '', args: []);
  }

  /// `Photo proof was asked for`
  String get photoProofAsked {
    return Intl.message(
      'Photo proof was asked for',
      name: 'photoProofAsked',
      desc: '',
      args: [],
    );
  }

  /// `Approve · pay {coins}`
  String approvePayCoins(Object coins) {
    return Intl.message(
      'Approve · pay $coins',
      name: 'approvePayCoins',
      desc: '',
      args: [coins],
    );
  }

  /// `Ask to redo`
  String get askToRedo {
    return Intl.message('Ask to redo', name: 'askToRedo', desc: '', args: []);
  }

  /// `{name} · worth {coins}`
  String worthCoins(Object name, Object coins) {
    return Intl.message(
      '$name · worth $coins',
      name: 'worthCoins',
      desc: '',
      args: [name, coins],
    );
  }

  /// `Home`
  String get catHome {
    return Intl.message('Home', name: 'catHome', desc: '', args: []);
  }

  /// `School`
  String get catSchool {
    return Intl.message('School', name: 'catSchool', desc: '', args: []);
  }

  /// `Health`
  String get catHealth {
    return Intl.message('Health', name: 'catHealth', desc: '', args: []);
  }

  /// `Outdoor`
  String get catOutdoor {
    return Intl.message('Outdoor', name: 'catOutdoor', desc: '', args: []);
  }

  /// `Who`
  String get whoSection {
    return Intl.message('Who', name: 'whoSection', desc: '', args: []);
  }

  /// `Icon`
  String get iconSection {
    return Intl.message('Icon', name: 'iconSection', desc: '', args: []);
  }

  /// `Task`
  String get taskFieldLabel {
    return Intl.message('Task', name: 'taskFieldLabel', desc: '', args: []);
  }

  /// `Details`
  String get detailsFieldLabel {
    return Intl.message(
      'Details',
      name: 'detailsFieldLabel',
      desc: '',
      args: [],
    );
  }

  /// `Reward`
  String get rewardFieldLabel {
    return Intl.message('Reward', name: 'rewardFieldLabel', desc: '', args: []);
  }

  /// `Needs photo proof`
  String get needsPhotoProof {
    return Intl.message(
      'Needs photo proof',
      name: 'needsPhotoProof',
      desc: '',
      args: [],
    );
  }

  /// `Water the plants`
  String get taskTitleHint {
    return Intl.message(
      'Water the plants',
      name: 'taskTitleHint',
      desc: '',
      args: [],
    );
  }

  /// `What counts as done? Optional.`
  String get taskDetailsHint {
    return Intl.message(
      'What counts as done? Optional.',
      name: 'taskDetailsHint',
      desc: '',
      args: [],
    );
  }

  /// `Add to {name}'s list`
  String addToList(Object name) {
    return Intl.message(
      'Add to $name\'s list',
      name: 'addToList',
      desc: '',
      args: [name],
    );
  }

  /// `Add for everyone`
  String get addToEveryonesList {
    return Intl.message(
      'Add for everyone',
      name: 'addToEveryonesList',
      desc: '',
      args: [],
    );
  }

  /// `Limit this app`
  String get limitThisApp {
    return Intl.message(
      'Limit this app',
      name: 'limitThisApp',
      desc: '',
      args: [],
    );
  }

  /// `Off means it is always allowed`
  String get offMeansAlwaysAllowed {
    return Intl.message(
      'Off means it is always allowed',
      name: 'offMeansAlwaysAllowed',
      desc: '',
      args: [],
    );
  }

  /// `{time} today`
  String usedTodayShort(Object time) {
    return Intl.message(
      '$time today',
      name: 'usedTodayShort',
      desc: '',
      args: [time],
    );
  }

  /// `Save for {name}`
  String saveForName(Object name) {
    return Intl.message(
      'Save for $name',
      name: 'saveForName',
      desc: '',
      args: [name],
    );
  }

  /// `Saved for {name}`
  String savedForName(Object name) {
    return Intl.message(
      'Saved for $name',
      name: 'savedForName',
      desc: '',
      args: [name],
    );
  }

  /// `Every app is already set up`
  String get everyAppSetUp {
    return Intl.message(
      'Every app is already set up',
      name: 'everyAppSetUp',
      desc: '',
      args: [],
    );
  }

  /// `Open one from the list to change its limit.`
  String get openOneFromList {
    return Intl.message(
      'Open one from the list to change its limit.',
      name: 'openOneFromList',
      desc: '',
      args: [],
    );
  }

  /// `Add app`
  String get addAppAction {
    return Intl.message('Add app', name: 'addAppAction', desc: '', args: []);
  }

  /// `Costs`
  String get costsLabel {
    return Intl.message('Costs', name: 'costsLabel', desc: '', args: []);
  }

  /// `Buys`
  String get buysLabel {
    return Intl.message('Buys', name: 'buysLabel', desc: '', args: []);
  }

  /// `The child can spend {cost} coins to unlock {time} beyond the daily limit.`
  String redeemExplainer(Object cost, Object time) {
    return Intl.message(
      'The child can spend $cost coins to unlock $time beyond the daily limit.',
      name: 'redeemExplainer',
      desc: '',
      args: [cost, time],
    );
  }

  /// `No limit`
  String get noLimitLabel {
    return Intl.message('No limit', name: 'noLimitLabel', desc: '', args: []);
  }

  /// `Try again`
  String get tryAgain {
    return Intl.message('Try again', name: 'tryAgain', desc: '', args: []);
  }

  /// `Your name`
  String get yourName {
    return Intl.message('Your name', name: 'yourName', desc: '', args: []);
  }

  /// `Amir`
  String get nameHintExample {
    return Intl.message('Amir', name: 'nameHintExample', desc: '', args: []);
  }

  /// `{name} (you)`
  String youSuffix(Object name) {
    return Intl.message(
      '$name (you)',
      name: 'youSuffix',
      desc: '',
      args: [name],
    );
  }

  /// `They install Safini, sign in, then enter this code.`
  String get inviteAParentBody {
    return Intl.message(
      'They install Safini, sign in, then enter this code.',
      name: 'inviteAParentBody',
      desc: '',
      args: [],
    );
  }

  /// `All`
  String get catAll {
    return Intl.message('All', name: 'catAll', desc: '', args: []);
  }

  /// `Learn`
  String get catLearn {
    return Intl.message('Learn', name: 'catLearn', desc: '', args: []);
  }

  /// `Fitness`
  String get catFitness {
    return Intl.message('Fitness', name: 'catFitness', desc: '', args: []);
  }

  /// `Logic`
  String get catLogic {
    return Intl.message('Logic', name: 'catLogic', desc: '', args: []);
  }

  /// `h`
  String get unitHour {
    return Intl.message('h', name: 'unitHour', desc: '', args: []);
  }

  /// `m`
  String get unitMinute {
    return Intl.message('m', name: 'unitMinute', desc: '', args: []);
  }
}

class AppLocalizationDelegate extends LocalizationsDelegate<S> {
  const AppLocalizationDelegate();

  List<Locale> get supportedLocales {
    return const <Locale>[
      Locale.fromSubtags(languageCode: 'en'),
      Locale.fromSubtags(languageCode: 'ru'),
      Locale.fromSubtags(languageCode: 'uz'),
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
