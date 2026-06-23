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

  static String m1(age) => "Age: ${age}";

  static String m2(name) => "${name}\'s Progress";

  static String m3(count) =>
      "${Intl.plural(count, one: '${count} coin', other: '${count} coins')}";

  static String m4(count) => "${count} coins";

  static String m5(count) =>
      "${Intl.plural(count, one: '${count} coin reward', other: '${count} coins reward')}";

  static String m6(date, time) => "Expires: ${date}, ${time}";

  static String m7(level) => "Level ${level} Hero";

  static String m8(count) =>
      "${Intl.plural(count, one: '${count} minute', other: '${count} minutes')}";

  static String m9(minutes) => "${minutes} minutes remaining";

  static String m10(minutes) => "${minutes}m remaining";

  static String m11(used, limit) => "${used} used / ${limit} limit";

  static String m12(count) => "You need ${count} more coins.";

  final messages = _notInlinedMessages(_notInlinedMessages);
  static Map<String, Function> _notInlinedMessages(_) => <String, Function>{
    "achievements": MessageLookupByLibrary.simpleMessage("Achievements"),
    "activeTasks": MessageLookupByLibrary.simpleMessage("Active Tasks"),
    "addAnotherApp": MessageLookupByLibrary.simpleMessage("Add Another App"),
    "addAnotherChild": MessageLookupByLibrary.simpleMessage(
      "Add Another Child",
    ),
    "addChild": MessageLookupByLibrary.simpleMessage("Add Child"),
    "admin": MessageLookupByLibrary.simpleMessage("Admin"),
    "ageAndGender": m0,
    "ageLabel": m1,
    "appLimits": MessageLookupByLibrary.simpleMessage("App Limits"),
    "appLimitsSubtitle": MessageLookupByLibrary.simpleMessage(
      "Set daily screen time limits",
    ),
    "appName": MessageLookupByLibrary.simpleMessage("SAFINI"),
    "appTimeTab": MessageLookupByLibrary.simpleMessage("App Time"),
    "approve": MessageLookupByLibrary.simpleMessage("Approve"),
    "approvedTaskConflict": MessageLookupByLibrary.simpleMessage(
      "Approved tasks can\'t be edited or deleted.",
    ),
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
    "childInviteCodeTitle": MessageLookupByLibrary.simpleMessage(
      "Child Invite Code",
    ),
    "childProgressTitle": m2,
    "chooseYourRole": MessageLookupByLibrary.simpleMessage("Choose Your Role"),
    "cleanTheRoom": MessageLookupByLibrary.simpleMessage("Clean the room"),
    "close": MessageLookupByLibrary.simpleMessage("Close"),
    "coinCount": m3,
    "coins": MessageLookupByLibrary.simpleMessage("Coins"),
    "coinsCount": m4,
    "coinsReward": m5,
    "coinsText": MessageLookupByLibrary.simpleMessage("Coins"),
    "comingSoon": MessageLookupByLibrary.simpleMessage("Coming soon!"),
    "completeDailyQuests": MessageLookupByLibrary.simpleMessage(
      "Complete your daily quests to earn more coins!",
    ),
    "completed": MessageLookupByLibrary.simpleMessage("Completed"),
    "copy": MessageLookupByLibrary.simpleMessage("Copy"),
    "createChildInviteCode": MessageLookupByLibrary.simpleMessage(
      "Create Child Invite Code",
    ),
    "createOrJoinFamily": MessageLookupByLibrary.simpleMessage(
      "Create a family or join one with an invite code.",
    ),
    "createParentInviteCode": MessageLookupByLibrary.simpleMessage(
      "Create Parent Invite Code",
    ),
    "createTaskAddButton": MessageLookupByLibrary.simpleMessage("Add Task"),
    "createTaskCategoryDailyChore": MessageLookupByLibrary.simpleMessage(
      "Daily Chore",
    ),
    "createTaskCategoryEducational": MessageLookupByLibrary.simpleMessage(
      "Educational",
    ),
    "createTaskCategoryHobby": MessageLookupByLibrary.simpleMessage("Hobby"),
    "createTaskCategoryOther": MessageLookupByLibrary.simpleMessage("Other"),
    "createTaskCategoryTitle": MessageLookupByLibrary.simpleMessage("Category"),
    "createTaskNameHint": MessageLookupByLibrary.simpleMessage(
      "e.g. Clean your room",
    ),
    "createTaskNameLabel": MessageLookupByLibrary.simpleMessage("Task Name"),
    "createTaskPickEmojiLabel": MessageLookupByLibrary.simpleMessage(
      "Pick an Emoji",
    ),
    "createTaskRewardLabel": MessageLookupByLibrary.simpleMessage(
      "Reward (Time Coins)",
    ),
    "createTaskSaveButton": MessageLookupByLibrary.simpleMessage("Save"),
    "createTaskSheetTitle": MessageLookupByLibrary.simpleMessage("New Task"),
    "customizeAvatar": MessageLookupByLibrary.simpleMessage("Customize Avatar"),
    "dailyChore": MessageLookupByLibrary.simpleMessage("Daily Chore"),
    "dailyLimit": MessageLookupByLibrary.simpleMessage("Daily Limit"),
    "dayStreak": MessageLookupByLibrary.simpleMessage("Day Streak"),
    "deleteAccount": MessageLookupByLibrary.simpleMessage("Delete Account"),
    "deleteAccountConfirmBody": MessageLookupByLibrary.simpleMessage(
      "Are you sure you want to delete your account? This action cannot be undone.",
    ),
    "deleteAccountConfirmTitle": MessageLookupByLibrary.simpleMessage(
      "Delete Account?",
    ),
    "deleteTaskBody": MessageLookupByLibrary.simpleMessage(
      "This can\'t be undone.",
    ),
    "deleteTaskButton": MessageLookupByLibrary.simpleMessage("Delete"),
    "deleteTaskTitle": MessageLookupByLibrary.simpleMessage("Delete task?"),
    "doHomework": MessageLookupByLibrary.simpleMessage("Do homework"),
    "doneToday": MessageLookupByLibrary.simpleMessage("Done Today"),
    "earnMoreCoins": MessageLookupByLibrary.simpleMessage("Earn More Coins"),
    "earnedToday": MessageLookupByLibrary.simpleMessage("Earned Today"),
    "edit": MessageLookupByLibrary.simpleMessage("Edit"),
    "editChild": MessageLookupByLibrary.simpleMessage("Edit Child"),
    "editProfile": MessageLookupByLibrary.simpleMessage("Edit Profile"),
    "editTaskSheetTitle": MessageLookupByLibrary.simpleMessage("Edit Task"),
    "educational": MessageLookupByLibrary.simpleMessage("Educational"),
    "english": MessageLookupByLibrary.simpleMessage("English"),
    "equipped": MessageLookupByLibrary.simpleMessage("EQUIPPED"),
    "expiresLabel": m6,
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
    "goodAfternoon": MessageLookupByLibrary.simpleMessage("Good afternoon 👋"),
    "goodEvening": MessageLookupByLibrary.simpleMessage("Good evening 👋"),
    "goodMorning": MessageLookupByLibrary.simpleMessage("Good morning 👋"),
    "goodNight": MessageLookupByLibrary.simpleMessage("Good night 🌙"),
    "googleClientIdMissing": MessageLookupByLibrary.simpleMessage(
      "Google Web Client ID is missing. Set GOOGLE_WEB_CLIENT_ID (OAuth Web client from Google Cloud).",
    ),
    "home": MessageLookupByLibrary.simpleMessage("Home"),
    "imAKid": MessageLookupByLibrary.simpleMessage("I\'m a Kid!"),
    "imAParent": MessageLookupByLibrary.simpleMessage("I\'m a Parent"),
    "inviteChildOrRefresh": MessageLookupByLibrary.simpleMessage(
      "Invite a child or refresh after linking a family member.",
    ),
    "inviteCodeCopied": MessageLookupByLibrary.simpleMessage(
      "Invite code copied",
    ),
    "kazakh": MessageLookupByLibrary.simpleMessage("Kazakh"),
    "kidSubtitle": MessageLookupByLibrary.simpleMessage("Earn coins & play"),
    "kidsEarnTimeCoins": MessageLookupByLibrary.simpleMessage(
      "Kids earn Time Coins to unlock extra minutes for these apps.",
    ),
    "lessons": MessageLookupByLibrary.simpleMessage("Lessons"),
    "lessonsChangeText": MessageLookupByLibrary.simpleMessage("+1 today"),
    "levelHero": m7,
    "loginBack": MessageLookupByLibrary.simpleMessage("Back"),
    "loginSubtitle": MessageLookupByLibrary.simpleMessage(
      "Continue with your Google account",
    ),
    "loginTitle": MessageLookupByLibrary.simpleMessage("Sign in"),
    "loginWithGoogle": MessageLookupByLibrary.simpleMessage(
      "Continue with Google",
    ),
    "logout": MessageLookupByLibrary.simpleMessage("Logout"),
    "logoutConfirmBody": MessageLookupByLibrary.simpleMessage(
      "Are you sure you want to log out?",
    ),
    "logoutConfirmTitle": MessageLookupByLibrary.simpleMessage("Log out?"),
    "manageAll": MessageLookupByLibrary.simpleMessage("Manage All"),
    "minuteCount": m8,
    "minutes": MessageLookupByLibrary.simpleMessage("Minutes"),
    "minutesRemainingLong": m9,
    "mon": MessageLookupByLibrary.simpleMessage("MON"),
    "monitor": MessageLookupByLibrary.simpleMessage("Monitor"),
    "myAvatar": MessageLookupByLibrary.simpleMessage("My Avatar"),
    "myFamily": MessageLookupByLibrary.simpleMessage("My Family"),
    "myProfile": MessageLookupByLibrary.simpleMessage("My Profile"),
    "myQuests": MessageLookupByLibrary.simpleMessage("My Quests"),
    "name": MessageLookupByLibrary.simpleMessage("Name"),
    "networkError": MessageLookupByLibrary.simpleMessage(
      "Network error. Check your connection.",
    ),
    "newBtn": MessageLookupByLibrary.simpleMessage("New"),
    "newTask": MessageLookupByLibrary.simpleMessage("New Task"),
    "noChildrenFoundYet": MessageLookupByLibrary.simpleMessage(
      "No children found yet",
    ),
    "noFamilySetupYet": MessageLookupByLibrary.simpleMessage(
      "No family set up yet",
    ),
    "noQuestsInCategory": MessageLookupByLibrary.simpleMessage(
      "No quests in this category",
    ),
    "noTasksYet": MessageLookupByLibrary.simpleMessage(
      "No tasks for this day yet.",
    ),
    "notEnoughCoins": MessageLookupByLibrary.simpleMessage("Not enough coins!"),
    "ok": MessageLookupByLibrary.simpleMessage("OK"),
    "on": MessageLookupByLibrary.simpleMessage("ON"),
    "outfitsAndItems": MessageLookupByLibrary.simpleMessage("Outfits & Items"),
    "parentAccount": MessageLookupByLibrary.simpleMessage("PARENT ACCOUNT"),
    "parentHomeScreen": MessageLookupByLibrary.simpleMessage(
      "Parent Home Screen",
    ),
    "parentInviteCodeTitle": MessageLookupByLibrary.simpleMessage(
      "Parent Invite Code",
    ),
    "parentName": MessageLookupByLibrary.simpleMessage("Safini Parent"),
    "parentSubtitle": MessageLookupByLibrary.simpleMessage("Monitor & reward"),
    "parents": MessageLookupByLibrary.simpleMessage("Parents"),
    "pendingApproval": MessageLookupByLibrary.simpleMessage("Pending Approval"),
    "profile": MessageLookupByLibrary.simpleMessage("Profile"),
    "questsDone": MessageLookupByLibrary.simpleMessage("Quests Done"),
    "questsText": MessageLookupByLibrary.simpleMessage("Quests"),
    "readFor20Mins": MessageLookupByLibrary.simpleMessage("Read for 20 mins"),
    "readyToSpend": MessageLookupByLibrary.simpleMessage(
      "Ready to spend your coins?",
    ),
    "realWorldTasks": MessageLookupByLibrary.simpleMessage("Real-world Tasks"),
    "reject": MessageLookupByLibrary.simpleMessage("Reject"),
    "remaining": MessageLookupByLibrary.simpleMessage("Remaining"),
    "remainingTime": m10,
    "removeParent": MessageLookupByLibrary.simpleMessage("Remove from Family"),
    "removeParentConfirmBody": MessageLookupByLibrary.simpleMessage(
      "Are you sure you want to remove this parent from the family?",
    ),
    "removeParentConfirmTitle": MessageLookupByLibrary.simpleMessage(
      "Remove Parent?",
    ),
    "retry": MessageLookupByLibrary.simpleMessage("Retry"),
    "reviewNoteHint": MessageLookupByLibrary.simpleMessage(
      "Add a note (optional)",
    ),
    "reviewTaskSheetTitle": MessageLookupByLibrary.simpleMessage("Review Task"),
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
    "settings": MessageLookupByLibrary.simpleMessage("Settings"),
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
    "surname": MessageLookupByLibrary.simpleMessage("Surname"),
    "switchToKidMode": MessageLookupByLibrary.simpleMessage(
      "Switch to Kid Mode / Logout",
    ),
    "tagline": MessageLookupByLibrary.simpleMessage("Learn. Earn. Play."),
    "taskApprovedMessage": MessageLookupByLibrary.simpleMessage(
      "Task approved!",
    ),
    "taskChessSub": MessageLookupByLibrary.simpleMessage("Master the board"),
    "taskChessTitle": MessageLookupByLibrary.simpleMessage("Chess Lesson"),
    "taskCreatedMessage": MessageLookupByLibrary.simpleMessage("Task created!"),
    "taskDeletedMessage": MessageLookupByLibrary.simpleMessage("Task deleted."),
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
    "taskRejectedMessage": MessageLookupByLibrary.simpleMessage(
      "Task rejected.",
    ),
    "taskRoomSub": MessageLookupByLibrary.simpleMessage("Daily chore"),
    "taskRoomTitle": MessageLookupByLibrary.simpleMessage("Clean your room"),
    "taskStepsSub": MessageLookupByLibrary.simpleMessage("Keep it moving!"),
    "taskStepsTitle": MessageLookupByLibrary.simpleMessage("Walk 5,000 Steps"),
    "taskUpdatedMessage": MessageLookupByLibrary.simpleMessage("Task updated!"),
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
    "usedLimit": m11,
    "viewAsKid": MessageLookupByLibrary.simpleMessage("View as Kid"),
    "wed": MessageLookupByLibrary.simpleMessage("WED"),
    "weeklyScreenTime": MessageLookupByLibrary.simpleMessage(
      "Weekly Screen Time",
    ),
    "youNeedMoreCoins": m12,
    "yourChildren": MessageLookupByLibrary.simpleMessage("YOUR CHILDREN"),
  };
}
