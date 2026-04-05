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

  static String m1(count) => "${count} coins";

  static String m2(level) => "Level ${level} Hero";

  static String m3(minutes) => "${minutes}m remaining";

  static String m4(count) => "You need ${count} more coins.";

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
    "cleanTheRoom": MessageLookupByLibrary.simpleMessage("Clean the room"),
    "coins": MessageLookupByLibrary.simpleMessage("Coins"),
    "coinsCount": m1,
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
    "goToTasks": MessageLookupByLibrary.simpleMessage("Go to Tasks"),
    "goodMorning": MessageLookupByLibrary.simpleMessage("Good morning 👋"),
    "home": MessageLookupByLibrary.simpleMessage("Home"),
    "imAKid": MessageLookupByLibrary.simpleMessage("I\'m a Kid!"),
    "imAParent": MessageLookupByLibrary.simpleMessage("I\'m a Parent"),
    "kidSubtitle": MessageLookupByLibrary.simpleMessage("Earn coins & play"),
    "kidsEarnTimeCoins": MessageLookupByLibrary.simpleMessage(
      "Kids earn Time Coins to unlock extra minutes for these apps.",
    ),
    "lessons": MessageLookupByLibrary.simpleMessage("Lessons"),
    "levelHero": m2,
    "manageAll": MessageLookupByLibrary.simpleMessage("Manage All"),
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
    "remainingTime": m3,
    "rewardStore": MessageLookupByLibrary.simpleMessage("Reward Store"),
    "russian": MessageLookupByLibrary.simpleMessage("Russian"),
    "save": MessageLookupByLibrary.simpleMessage("Save"),
    "saveMyLook": MessageLookupByLibrary.simpleMessage("Save My Look!"),
    "selectLanguage": MessageLookupByLibrary.simpleMessage("Select Language"),
    "setUpANewProfile": MessageLookupByLibrary.simpleMessage(
      "Set up a new profile",
    ),
    "spendYourTimeCoins": MessageLookupByLibrary.simpleMessage(
      "Spend your Time Coins",
    ),
    "steps": MessageLookupByLibrary.simpleMessage("Steps"),
    "stepsToday": MessageLookupByLibrary.simpleMessage("Steps Today"),
    "store": MessageLookupByLibrary.simpleMessage("Store"),
    "streakText": MessageLookupByLibrary.simpleMessage("Streak"),
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
    "unlockExtraTime": MessageLookupByLibrary.simpleMessage(
      "Unlock Extra Time",
    ),
    "unlocked": MessageLookupByLibrary.simpleMessage("unlocked"),
    "viewAsKid": MessageLookupByLibrary.simpleMessage("View as Kid"),
    "youNeedMoreCoins": m4,
    "yourChildren": MessageLookupByLibrary.simpleMessage("YOUR CHILDREN"),
  };
}
