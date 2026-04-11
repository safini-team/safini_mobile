// DO NOT EDIT. This is code generated via package:intl/generate_localized.dart
// This is a library that provides messages for a en locale. All the
// messages from the main program should be duplicated here with the same
// function name.

// Ignore issues from commonly used lints in this file.
// ignore_for_file:unnecessary_brace_in_string_interps, unnecessary_new
// ignore_for_file:prefer_single_quotes,comment_references, directives_ordering
// ignore_for_file:annotate_overrides,prefer_generic_function_type_aliases
// ignore_for_file:unused_import, file_names, avoid_escaping_inner_quotes
// ignore_for_file:unnecessary_string_interpolations, unnecessary_string_escapes

import 'package:intl/intl.dart';
import 'package:intl/message_lookup_by_library.dart';

final messages = new MessageLookup();

typedef String MessageIfAbsent(String messageStr, List<dynamic> args);

class MessageLookup extends MessageLookupByLibrary {
  String get localeName => 'en';

  static String m0(age, gender) => "Age ${age} • ${gender}";

  static String m1(name) => "${name}\'s Progress";

  static String m2(count) => "${count} coins";

  static String m3(level) => "Level ${level} Hero";

  static String m4(minutes) => "${minutes} minutes remaining";

  static String m5(minutes) => "${minutes}m remaining";

  static String m6(used, limit) => "${used} used / ${limit} limit";

  static String m7(count) => "You need ${count} more coins.";

  final messages = _notInlinedMessages(_notInlinedMessages);
  static Map<String, Function> _notInlinedMessages(_) => <String, Function>{
    "achievements": MessageLookupByLibrary.simpleMessage("Achievements"),
    "activeTasks": MessageLookupByLibrary.simpleMessage("Active Tasks"),
    "addAnotherApp": MessageLookupByLibrary.simpleMessage("Add Another App"),
    "addAnotherChild": MessageLookupByLibrary.simpleMessage(
      "Add Another Child",
    ),
    "admin": MessageLookupByLibrary.simpleMessage("Admin"),
    "ageAndGender": m0,
    "appLimits": MessageLookupByLibrary.simpleMessage("App Limits"),
    "appName": MessageLookupByLibrary.simpleMessage("SAFINIO"),
    "appTimeTab": MessageLookupByLibrary.simpleMessage("App Time"),
    "apps": MessageLookupByLibrary.simpleMessage("Apps"),
    "avatarItemsTab": MessageLookupByLibrary.simpleMessage("Avatar Items"),
    "buyIt": MessageLookupByLibrary.simpleMessage("Buy it! 🎉"),
    "cancel": MessageLookupByLibrary.simpleMessage("Cancel"),
    "categoryAll": MessageLookupByLibrary.simpleMessage("All"),
    "categoryFitness": MessageLookupByLibrary.simpleMessage("Fitness"),
    "categoryLearn": MessageLookupByLibrary.simpleMessage("Learn"),
    "categoryLogic": MessageLookupByLibrary.simpleMessage("Logic"),
    "changeLanguage": MessageLookupByLibrary.simpleMessage("Change Language"),
    "changeOutfit": MessageLookupByLibrary.simpleMessage(
      "Change outfit, hair & more",
    ),
    "childProgressTitle": m1,
    "cleanTheRoom": MessageLookupByLibrary.simpleMessage("Clean the room"),
    "coins": MessageLookupByLibrary.simpleMessage("Coins"),
    "coinsCount": m2,
    "coinsText": MessageLookupByLibrary.simpleMessage("Coins"),
    "comingSoon": MessageLookupByLibrary.simpleMessage("Coming soon!"),
    "completeDailyQuests": MessageLookupByLibrary.simpleMessage(
      "Complete your daily quests to earn more coins!",
    ),
    "completed": MessageLookupByLibrary.simpleMessage("Completed"),
    "customizeAvatar": MessageLookupByLibrary.simpleMessage("Customize Avatar"),
    "dailyChore": MessageLookupByLibrary.simpleMessage("Daily Chore"),
    "dailyLimit": MessageLookupByLibrary.simpleMessage("Daily Limit"),
    "dayStreak": MessageLookupByLibrary.simpleMessage("Day Streak"),
    "doHomework": MessageLookupByLibrary.simpleMessage("Do homework"),
    "doneToday": MessageLookupByLibrary.simpleMessage("Done Today"),
    "earnMoreCoins": MessageLookupByLibrary.simpleMessage("Earn More Coins"),
    "earnedToday": MessageLookupByLibrary.simpleMessage("Earned Today"),
    "edit": MessageLookupByLibrary.simpleMessage("Edit"),
    "educational": MessageLookupByLibrary.simpleMessage("Educational"),
    "english": MessageLookupByLibrary.simpleMessage("English"),
    "equipped": MessageLookupByLibrary.simpleMessage("EQUIPPED"),
    "family": MessageLookupByLibrary.simpleMessage("Family"),
    "familyAdmin": MessageLookupByLibrary.simpleMessage("Family Admin"),
    "footerText": MessageLookupByLibrary.simpleMessage(
      "Safe screen time for smart kids 🌟",
    ),
    "free": MessageLookupByLibrary.simpleMessage("FREE"),
    "fri": MessageLookupByLibrary.simpleMessage("FRI"),
    "goToTasks": MessageLookupByLibrary.simpleMessage("Go to Tasks"),
    "googleClientIdMissing": MessageLookupByLibrary.simpleMessage(
      "Google Web Client ID is missing. Set GOOGLE_WEB_CLIENT_ID (OAuth Web client from Google Cloud).",
    ),
    "goodMorning": MessageLookupByLibrary.simpleMessage("Good morning 👋"),
    "home": MessageLookupByLibrary.simpleMessage("Home"),
    "imAKid": MessageLookupByLibrary.simpleMessage("I\'m a Kid!"),
    "imAParent": MessageLookupByLibrary.simpleMessage("I\'m a Parent"),
    "kidSubtitle": MessageLookupByLibrary.simpleMessage("Earn coins & play"),
    "kidsEarnTimeCoins": MessageLookupByLibrary.simpleMessage(
      "Kids earn Time Coins to unlock extra minutes for these apps.",
    ),
    "lessons": MessageLookupByLibrary.simpleMessage("Lessons"),
    "loginBack": MessageLookupByLibrary.simpleMessage("Back"),
    "loginSubtitle": MessageLookupByLibrary.simpleMessage(
      "Continue with your Google account",
    ),
    "loginTitle": MessageLookupByLibrary.simpleMessage("Sign in"),
    "loginWithGoogle": MessageLookupByLibrary.simpleMessage(
      "Continue with Google",
    ),
    "lessonsChangeText": MessageLookupByLibrary.simpleMessage("+1 today"),
    "levelHero": m3,
    "manageAll": MessageLookupByLibrary.simpleMessage("Manage All"),
    "minutesRemainingLong": m4,
    "mon": MessageLookupByLibrary.simpleMessage("MON"),
    "monitor": MessageLookupByLibrary.simpleMessage("Monitor"),
    "myAvatar": MessageLookupByLibrary.simpleMessage("My Avatar"),
    "myProfile": MessageLookupByLibrary.simpleMessage("My Profile"),
    "myQuests": MessageLookupByLibrary.simpleMessage("My Quests"),
    "newBtn": MessageLookupByLibrary.simpleMessage("New"),
    "newTask": MessageLookupByLibrary.simpleMessage("New Task"),
    "noQuestsInCategory": MessageLookupByLibrary.simpleMessage(
      "No quests in this category",
    ),
    "notEnoughCoins": MessageLookupByLibrary.simpleMessage("Not enough coins!"),
    "ok": MessageLookupByLibrary.simpleMessage("OK"),
    "on": MessageLookupByLibrary.simpleMessage("ON"),
    "outfitsAndItems": MessageLookupByLibrary.simpleMessage("Outfits & Items"),
    "parentAccount": MessageLookupByLibrary.simpleMessage("PARENT ACCOUNT"),
    "parentHomeScreen": MessageLookupByLibrary.simpleMessage(
      "Parent Home Screen",
    ),
    "parentName": MessageLookupByLibrary.simpleMessage("Safinio Parent"),
    "parentSubtitle": MessageLookupByLibrary.simpleMessage("Monitor & reward"),
    "pendingApproval": MessageLookupByLibrary.simpleMessage("Pending Approval"),
    "profile": MessageLookupByLibrary.simpleMessage("Profile"),
    "questsDone": MessageLookupByLibrary.simpleMessage("Quests Done"),
    "questsText": MessageLookupByLibrary.simpleMessage("Quests"),
    "readFor20Mins": MessageLookupByLibrary.simpleMessage("Read for 20 mins"),
    "readyToSpend": MessageLookupByLibrary.simpleMessage(
      "Ready to spend your coins?",
    ),
    "realWorldTasks": MessageLookupByLibrary.simpleMessage("Real-world Tasks"),
    "remaining": MessageLookupByLibrary.simpleMessage("Remaining"),
    "remainingTime": m5,
    "rewardStore": MessageLookupByLibrary.simpleMessage("Reward Store"),
    "russian": MessageLookupByLibrary.simpleMessage("Russian"),
    "sat": MessageLookupByLibrary.simpleMessage("SAT"),
    "save": MessageLookupByLibrary.simpleMessage("Save"),
    "saveMyLook": MessageLookupByLibrary.simpleMessage("Save My Look!"),
    "selectLanguage": MessageLookupByLibrary.simpleMessage("Select Language"),
    "signedInSuccess": MessageLookupByLibrary.simpleMessage(
      "Signed in successfully",
    ),
    "signingIn": MessageLookupByLibrary.simpleMessage("Signing in..."),
    "setUpANewProfile": MessageLookupByLibrary.simpleMessage(
      "Set up a new profile",
    ),
    "spendYourTimeCoins": MessageLookupByLibrary.simpleMessage(
      "Spend your Time Coins",
    ),
    "statusActive": MessageLookupByLibrary.simpleMessage("ACTIVE"),
    "statusDone": MessageLookupByLibrary.simpleMessage("DONE"),
    "statusPending": MessageLookupByLibrary.simpleMessage("PENDING"),
    "steps": MessageLookupByLibrary.simpleMessage("Steps"),
    "supabaseConfigMissing": MessageLookupByLibrary.simpleMessage(
      "Supabase URL or anon key is missing. Set SUPABASE_URL and SUPABASE_ANON_KEY when running the app.",
    ),
    "stepsChangeText": MessageLookupByLibrary.simpleMessage(
      "+12% vs yesterday",
    ),
    "stepsToday": MessageLookupByLibrary.simpleMessage("Steps Today"),
    "store": MessageLookupByLibrary.simpleMessage("Store"),
    "streakText": MessageLookupByLibrary.simpleMessage("Streak"),
    "sun": MessageLookupByLibrary.simpleMessage("SUN"),
    "switchToKidMode": MessageLookupByLibrary.simpleMessage(
      "Switch to Kid Mode / Logout",
    ),
    "tagline": MessageLookupByLibrary.simpleMessage("Learn. Earn. Play."),
    "taskChessSub": MessageLookupByLibrary.simpleMessage("Master the board"),
    "taskChessTitle": MessageLookupByLibrary.simpleMessage("Chess Lesson"),
    "taskDuolingoSub": MessageLookupByLibrary.simpleMessage(
      "Daily streak bonus!",
    ),
    "taskDuolingoTitle": MessageLookupByLibrary.simpleMessage(
      "Complete Duolingo",
    ),
    "taskPuzzleSub": MessageLookupByLibrary.simpleMessage("Brain power boost"),
    "taskPuzzleTitle": MessageLookupByLibrary.simpleMessage("Logical Puzzle"),
    "taskReadingSub": MessageLookupByLibrary.simpleMessage("Expand your mind"),
    "taskReadingTitle": MessageLookupByLibrary.simpleMessage(
      "Read for 20 mins",
    ),
    "taskRoomSub": MessageLookupByLibrary.simpleMessage("Daily chore"),
    "taskRoomTitle": MessageLookupByLibrary.simpleMessage("Clean your room"),
    "taskStepsSub": MessageLookupByLibrary.simpleMessage("Keep it moving!"),
    "taskStepsTitle": MessageLookupByLibrary.simpleMessage("Walk 5,000 Steps"),
    "tasks": MessageLookupByLibrary.simpleMessage("Tasks"),
    "tasksAndRewards": MessageLookupByLibrary.simpleMessage("Tasks & Rewards"),
    "thu": MessageLookupByLibrary.simpleMessage("THU"),
    "timeCoins": MessageLookupByLibrary.simpleMessage("Time Coins"),
    "tip1": MessageLookupByLibrary.simpleMessage(
      "Set meaningful tasks that teach responsibility",
    ),
    "tip2": MessageLookupByLibrary.simpleMessage(
      "Balance screen time rewards with outdoor activities",
    ),
    "tip3": MessageLookupByLibrary.simpleMessage(
      "Celebrate achievements with your child",
    ),
    "tip4": MessageLookupByLibrary.simpleMessage(
      "Adjust coin values to match effort levels",
    ),
    "tipsForParents": MessageLookupByLibrary.simpleMessage("Tips for Parents"),
    "todaysQuests": MessageLookupByLibrary.simpleMessage("Today\'s Quests"),
    "tue": MessageLookupByLibrary.simpleMessage("TUE"),
    "unlockExtraTime": MessageLookupByLibrary.simpleMessage(
      "Unlock Extra Time",
    ),
    "unlocked": MessageLookupByLibrary.simpleMessage("unlocked"),
    "usedLimit": m6,
    "viewAsKid": MessageLookupByLibrary.simpleMessage("View as Kid"),
    "wed": MessageLookupByLibrary.simpleMessage("WED"),
    "weeklyScreenTime": MessageLookupByLibrary.simpleMessage(
      "Weekly Screen Time",
    ),
    "youNeedMoreCoins": m7,
    "yourChildren": MessageLookupByLibrary.simpleMessage("YOUR CHILDREN"),
  };
}
