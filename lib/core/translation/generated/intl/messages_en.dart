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

  static String m2(count) =>
      "${Intl.plural(count, one: '${count} coin', other: '${count} coins')}";

  static String m3(count) => "${count} coins";

  static String m4(count) =>
      "${Intl.plural(count, one: '${count} coin reward', other: '${count} coins reward')}";

  static String m5(childName) => "Create Task for ${childName}";

  static String m6(level) => "Level ${level} Hero";

  static String m7(count) =>
      "${Intl.plural(count, one: '${count} minute', other: '${count} minutes')}";

  static String m8(minutes) => "${minutes} minutes remaining";

  static String m9(minutes) => "${minutes}m remaining";

  static String m10(used, limit) => "${used} used / ${limit} limit";

  static String m11(count) => "You need ${count} more coins.";

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
    "appLimitsSubtitle": MessageLookupByLibrary.simpleMessage(
      "Set daily screen time limits",
    ),
    "appName": MessageLookupByLibrary.simpleMessage("SAFINI"),
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
    "chooseYourRole": MessageLookupByLibrary.simpleMessage("Choose Your Role"),
    "cleanTheRoom": MessageLookupByLibrary.simpleMessage("Clean the room"),
    "coinCount": m2,
    "coins": MessageLookupByLibrary.simpleMessage("Coins"),
    "coinsCount": m3,
    "coinsReward": m4,
    "coinsText": MessageLookupByLibrary.simpleMessage("Coins"),
    "comingSoon": MessageLookupByLibrary.simpleMessage("Coming soon!"),
    "completeDailyQuests": MessageLookupByLibrary.simpleMessage(
      "Complete your daily quests to earn more coins!",
    ),
    "completed": MessageLookupByLibrary.simpleMessage("Completed"),
    "createTaskAddButton": MessageLookupByLibrary.simpleMessage("Add Task"),
    "createTaskAddDetails": MessageLookupByLibrary.simpleMessage(
      "+ Add details",
    ),
    "createTaskApprovedByTitle": MessageLookupByLibrary.simpleMessage(
      "Approved by",
    ),
    "createTaskCategoryDailyChore": MessageLookupByLibrary.simpleMessage(
      "Daily Chore",
    ),
    "createTaskCategoryEducational": MessageLookupByLibrary.simpleMessage(
      "Educational",
    ),
    "createTaskCategoryHobby": MessageLookupByLibrary.simpleMessage("Hobby"),
    "createTaskCategoryOther": MessageLookupByLibrary.simpleMessage("Other"),
    "createTaskCategoryTitle": MessageLookupByLibrary.simpleMessage("Category"),
    "createTaskDescriptionLabel": MessageLookupByLibrary.simpleMessage(
      "Description (optional)",
    ),
    "createTaskFieldRequired": MessageLookupByLibrary.simpleMessage("Required"),
    "createTaskForChild": m5,
    "createTaskHideDetails": MessageLookupByLibrary.simpleMessage(
      "Hide details",
    ),
    "createTaskNameHint": MessageLookupByLibrary.simpleMessage(
      "e.g. Clean your room",
    ),
    "createTaskNameLabel": MessageLookupByLibrary.simpleMessage("Task Name"),
    "createTaskPickEmojiLabel": MessageLookupByLibrary.simpleMessage(
      "Pick an Emoji",
    ),
    "createTaskProofMetric": MessageLookupByLibrary.simpleMessage(
      "Enter a number",
    ),
    "createTaskProofNone": MessageLookupByLibrary.simpleMessage(
      "Just mark done",
    ),
    "createTaskProofPhotoText": MessageLookupByLibrary.simpleMessage(
      "Photo + Text",
    ),
    "createTaskProofTitle": MessageLookupByLibrary.simpleMessage("Proof"),
    "createTaskRecurrenceDaily": MessageLookupByLibrary.simpleMessage("Daily"),
    "createTaskRecurrenceManual": MessageLookupByLibrary.simpleMessage(
      "Manual",
    ),
    "createTaskRecurrenceOnce": MessageLookupByLibrary.simpleMessage("Once"),
    "createTaskRepeatsTitle": MessageLookupByLibrary.simpleMessage("Repeats"),
    "createTaskRewardLabel": MessageLookupByLibrary.simpleMessage(
      "Reward (Time Coins)",
    ),
    "createTaskRewardsTitle": MessageLookupByLibrary.simpleMessage("Rewards"),
    "createTaskSheetTitle": MessageLookupByLibrary.simpleMessage("New Task"),
    "createTaskStep1Title": MessageLookupByLibrary.simpleMessage(
      "Step 1 — The basics",
    ),
    "createTaskStep2Title": MessageLookupByLibrary.simpleMessage(
      "Step 2 — How does the child complete it?",
    ),
    "createTaskStep3Title": MessageLookupByLibrary.simpleMessage(
      "Step 3 — Optional details",
    ),
    "createTaskSubmitButton": MessageLookupByLibrary.simpleMessage(
      "Create Task Template",
    ),
    "createTaskTargetNumber": MessageLookupByLibrary.simpleMessage("Number"),
    "createTaskTargetTitle": MessageLookupByLibrary.simpleMessage("Target"),
    "createTaskTargetUnitHint": MessageLookupByLibrary.simpleMessage(
      "Unit (e.g. minutes)",
    ),
    "createTaskTitleLabel": MessageLookupByLibrary.simpleMessage(
      "What\'s the task?",
    ),
    "createTaskTitleMaxChars": MessageLookupByLibrary.simpleMessage(
      "Max 120 characters",
    ),
    "createTaskVerificationAuto": MessageLookupByLibrary.simpleMessage(
      "Auto-approve",
    ),
    "createTaskVerificationParent": MessageLookupByLibrary.simpleMessage(
      "Parent reviews",
    ),
    "createTaskXpLabel": MessageLookupByLibrary.simpleMessage("XP"),
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
    "familyDecisionSubtitle": MessageLookupByLibrary.simpleMessage(
      "Create your family space and invite your kids to start earning screen time.",
    ),
    "footerText": MessageLookupByLibrary.simpleMessage(
      "Safe screen time for smart kids 🌟",
    ),
    "free": MessageLookupByLibrary.simpleMessage("FREE"),
    "fri": MessageLookupByLibrary.simpleMessage("FRI"),
    "goToTasks": MessageLookupByLibrary.simpleMessage("Go to Tasks"),
    "goodMorning": MessageLookupByLibrary.simpleMessage("Good morning 👋"),
    "googleClientIdMissing": MessageLookupByLibrary.simpleMessage(
      "Google Web Client ID is missing. Set GOOGLE_WEB_CLIENT_ID (OAuth Web client from Google Cloud).",
    ),
    "home": MessageLookupByLibrary.simpleMessage("Home"),
    "imAKid": MessageLookupByLibrary.simpleMessage("I\'m a Kid!"),
    "imAParent": MessageLookupByLibrary.simpleMessage("I\'m a Parent"),
    "kazakh": MessageLookupByLibrary.simpleMessage("Kazakh"),
    "kidSubtitle": MessageLookupByLibrary.simpleMessage("Earn coins & play"),
    "kidsEarnTimeCoins": MessageLookupByLibrary.simpleMessage(
      "Kids earn Time Coins to unlock extra minutes for these apps.",
    ),
    "lessons": MessageLookupByLibrary.simpleMessage("Lessons"),
    "lessonsChangeText": MessageLookupByLibrary.simpleMessage("+1 today"),
    "levelHero": m6,
    "loginBack": MessageLookupByLibrary.simpleMessage("Back"),
    "loginSubtitle": MessageLookupByLibrary.simpleMessage(
      "Continue with your Google account",
    ),
    "loginTitle": MessageLookupByLibrary.simpleMessage("Sign in"),
    "loginWithGoogle": MessageLookupByLibrary.simpleMessage(
      "Continue with Google",
    ),
    "manageAll": MessageLookupByLibrary.simpleMessage("Manage All"),
    "minuteCount": m7,
    "minutes": MessageLookupByLibrary.simpleMessage("Minutes"),
    "minutesRemainingLong": m8,
    "mon": MessageLookupByLibrary.simpleMessage("MON"),
    "monitor": MessageLookupByLibrary.simpleMessage("Monitor"),
    "myAvatar": MessageLookupByLibrary.simpleMessage("My Avatar"),
    "myProfile": MessageLookupByLibrary.simpleMessage("My Profile"),
    "myQuests": MessageLookupByLibrary.simpleMessage("My Quests"),
    "networkError": MessageLookupByLibrary.simpleMessage(
      "Network error. Check your connection.",
    ),
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
    "remainingTime": m9,
    "retry": MessageLookupByLibrary.simpleMessage("Retry"),
    "rewardStore": MessageLookupByLibrary.simpleMessage("Reward Store"),
    "roleSelectionSubtitle": MessageLookupByLibrary.simpleMessage(
      "How will you use Safini?",
    ),
    "russian": MessageLookupByLibrary.simpleMessage("Russian"),
    "sat": MessageLookupByLibrary.simpleMessage("SAT"),
    "save": MessageLookupByLibrary.simpleMessage("Save"),
    "saveMyLook": MessageLookupByLibrary.simpleMessage("Save My Look!"),
    "selectLanguage": MessageLookupByLibrary.simpleMessage("Select Language"),
    "setUpANewProfile": MessageLookupByLibrary.simpleMessage(
      "Set up a new profile",
    ),
    "setupYourFamily": MessageLookupByLibrary.simpleMessage(
      "Set Up Your Family",
    ),
    "signInError": MessageLookupByLibrary.simpleMessage(
      "Sign in failed. Please try again.",
    ),
    "signedInSuccess": MessageLookupByLibrary.simpleMessage(
      "Signed in successfully",
    ),
    "signingIn": MessageLookupByLibrary.simpleMessage("Signing in..."),
    "spendYourTimeCoins": MessageLookupByLibrary.simpleMessage(
      "Spend your Time Coins",
    ),
    "statusActive": MessageLookupByLibrary.simpleMessage("ACTIVE"),
    "statusDone": MessageLookupByLibrary.simpleMessage("DONE"),
    "statusPending": MessageLookupByLibrary.simpleMessage("PENDING"),
    "steps": MessageLookupByLibrary.simpleMessage("Steps"),
    "stepsChangeText": MessageLookupByLibrary.simpleMessage(
      "+12% vs yesterday",
    ),
    "stepsToday": MessageLookupByLibrary.simpleMessage("Steps Today"),
    "store": MessageLookupByLibrary.simpleMessage("Store"),
    "streakText": MessageLookupByLibrary.simpleMessage("Streak"),
    "sun": MessageLookupByLibrary.simpleMessage("SUN"),
    "supabaseConfigMissing": MessageLookupByLibrary.simpleMessage(
      "Supabase URL or anon key is missing. Set SUPABASE_URL and SUPABASE_ANON_KEY when running the app.",
    ),
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
    "usedLimit": m10,
    "viewAsKid": MessageLookupByLibrary.simpleMessage("View as Kid"),
    "wed": MessageLookupByLibrary.simpleMessage("WED"),
    "weeklyScreenTime": MessageLookupByLibrary.simpleMessage(
      "Weekly Screen Time",
    ),
    "youNeedMoreCoins": m11,
    "yourChildren": MessageLookupByLibrary.simpleMessage("YOUR CHILDREN"),
  };
}
