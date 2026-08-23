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

  static String m0(name) => "Add to ${name}\'s list";

  static String m1(age, gender) => "Age ${age} • ${gender}";

  static String m2(age) => "Age: ${age}";

  static String m3(app, minutes) => "${app} · ${minutes} min";

  static String m4(coins) => "Approve · pay ${coins}";

  static String m5(count) => "${count} coins";

  static String m6(count) => "${count} tasks done";

  static String m7(name) => "${name}\'s Progress";

  static String m8(done, total, coins) =>
      "${done} of ${total} done today · ${coins} coins waiting";

  static String m9(name) => "${name}\'s code is ready";

  static String m10(count) =>
      "${Intl.plural(count, one: '${count} coin', other: '${count} coins')}";

  static String m11(count) =>
      "${Intl.plural(count, one: '1 coin', other: '${count} coins')}";

  static String m12(count) => "${count} coins";

  static String m13(count) =>
      "${Intl.plural(count, one: '${count} coin reward', other: '${count} coins reward')}";

  static String m14(count) => "${count} coins to go";

  static String m15(count) => "${count} coins to go";

  static String m16(name) => "${name} · daily allowance";

  static String m17(name) => "Edit ${name}";

  static String m18(date, time) => "Expires: ${date}, ${time}";

  static String m19(name, time) => "${name} has ${time} left today";

  static String m20(name, time) => "${name} used ${time} today";

  static String m21(name) => "${name}\'s apps";

  static String m22(level) => "Level ${level} Hero";

  static String m23(level) => "Level ${level}";

  static String m24(name) => "${name}\'s phone · today";

  static String m25(count) =>
      "${Intl.plural(count, one: '${count} minute', other: '${count} minutes')}";

  static String m26(minutes) => "${minutes} m left";

  static String m27(minutes) => "${minutes} minutes remaining";

  static String m28(count) => "${count} more coins needed";

  static String m29(app) => "Most of it in ${app}";

  static String m30(count) => "${count}-day streak";

  static String m31(total) => "of ${total}";

  static String m32(name) => "Install Safini on ${name}\'s phone";

  static String m33(percent) => "${percent}% to the next level";

  static String m34(cost, time) =>
      "The child can spend ${cost} coins to unlock ${time} beyond the daily limit.";

  static String m35(minutes) => "${minutes}m remaining";

  static String m36(name) => "Save for ${name}";

  static String m37(name) => "Saved for ${name}";

  static String m38(count) =>
      "${Intl.plural(count, one: '1 task', other: '${count} tasks')}";

  static String m39(tasks, coins) => "${tasks} · ${coins}";

  static String m40(scope, tasks) => "${scope} · ${tasks}";

  static String m41(tasks, coins) => "${tasks} left - ${coins} on the table";

  static String m42(time) => "${time} left";

  static String m43(time) => "${time} used";

  static String m44(count) => "${count} to go";

  static String m45(name) =>
      "Type it on ${name}\'s phone, under \"I\'m a kid\".";

  static String m46(used, limit) => "${used} used / ${limit} limit";

  static String m47(used) => "${used} · no limit";

  static String m48(used, limit) => "${used} of ${limit}";

  static String m49(used, limit) => "${used} of ${limit} · over";

  static String m50(time) => "${time} today";

  static String m51(count) =>
      "${Intl.plural(count, one: '1 waiting', other: '${count} waiting')}";

  static String m52(name) => "Waiting for ${name}\'s phone…";

  static String m53(name, coins) => "${name} · worth ${coins}";

  static String m54(age) => "${age} years old";

  static String m55(count) => "You need ${count} more coins.";

  static String m56(name) => "${name} (you)";

  final messages = _notInlinedMessages(_notInlinedMessages);
  static Map<String, Function> _notInlinedMessages(_) => <String, Function>{
    "achievements": MessageLookupByLibrary.simpleMessage("Achievements"),
    "activeTasks": MessageLookupByLibrary.simpleMessage("Active Tasks"),
    "addAChild": MessageLookupByLibrary.simpleMessage("Add a child"),
    "addAnApp": MessageLookupByLibrary.simpleMessage("Add an app"),
    "addAnotherApp": MessageLookupByLibrary.simpleMessage("Add Another App"),
    "addAnotherChild": MessageLookupByLibrary.simpleMessage(
      "Add Another Child",
    ),
    "addAppAction": MessageLookupByLibrary.simpleMessage("Add app"),
    "addChild": MessageLookupByLibrary.simpleMessage("Add Child"),
    "addShort": MessageLookupByLibrary.simpleMessage("Add"),
    "addToEveryonesList": MessageLookupByLibrary.simpleMessage(
      "Add for everyone",
    ),
    "addToList": m0,
    "admin": MessageLookupByLibrary.simpleMessage("Admin"),
    "ageAndGender": m1,
    "ageFieldLabel": MessageLookupByLibrary.simpleMessage("Age"),
    "ageLabel": m2,
    "ageMustBeInteger": MessageLookupByLibrary.simpleMessage(
      "Age must be an integer.",
    ),
    "ageRange": MessageLookupByLibrary.simpleMessage(
      "Age must be between 0 and 18.",
    ),
    "ageRequired": MessageLookupByLibrary.simpleMessage("Age is required."),
    "allCaughtUp": MessageLookupByLibrary.simpleMessage("All caught up"),
    "allTasks": MessageLookupByLibrary.simpleMessage("All tasks"),
    "almostYours": MessageLookupByLibrary.simpleMessage("Almost yours"),
    "alwaysAllowedNoRedemption": MessageLookupByLibrary.simpleMessage(
      "Always allowed · no redemption",
    ),
    "appLimits": MessageLookupByLibrary.simpleMessage("App Limits"),
    "appLimitsSubtitle": MessageLookupByLibrary.simpleMessage(
      "Set daily screen time limits",
    ),
    "appName": MessageLookupByLibrary.simpleMessage("SAFINI"),
    "appTimeItem": m3,
    "appTimeTab": MessageLookupByLibrary.simpleMessage("App Time"),
    "approve": MessageLookupByLibrary.simpleMessage("Approve"),
    "approvePayCoins": m4,
    "approvedTaskConflict": MessageLookupByLibrary.simpleMessage(
      "Approved tasks can\'t be edited or deleted.",
    ),
    "apps": MessageLookupByLibrary.simpleMessage("Apps"),
    "askForSomethingNew": MessageLookupByLibrary.simpleMessage(
      "Ask for something new and your parent can add it to the store.",
    ),
    "askForThis": MessageLookupByLibrary.simpleMessage("Ask for this"),
    "askToRedo": MessageLookupByLibrary.simpleMessage("Ask to redo"),
    "avatarItem": MessageLookupByLibrary.simpleMessage("Avatar item"),
    "avatarItemsTab": MessageLookupByLibrary.simpleMessage("Avatar Items"),
    "badgeCoins": m5,
    "badgeTasksDone": m6,
    "badges": MessageLookupByLibrary.simpleMessage("Badges"),
    "bothParentsSee": MessageLookupByLibrary.simpleMessage(
      "Both parents see the same tasks and can approve them.",
    ),
    "buyIt": MessageLookupByLibrary.simpleMessage("Buy it! 🎉"),
    "buysLabel": MessageLookupByLibrary.simpleMessage("Buys"),
    "cancel": MessageLookupByLibrary.simpleMessage("Cancel"),
    "catAll": MessageLookupByLibrary.simpleMessage("All"),
    "catFitness": MessageLookupByLibrary.simpleMessage("Fitness"),
    "catHealth": MessageLookupByLibrary.simpleMessage("Health"),
    "catHome": MessageLookupByLibrary.simpleMessage("Home"),
    "catLearn": MessageLookupByLibrary.simpleMessage("Learn"),
    "catLogic": MessageLookupByLibrary.simpleMessage("Logic"),
    "catOutdoor": MessageLookupByLibrary.simpleMessage("Outdoor"),
    "catSchool": MessageLookupByLibrary.simpleMessage("School"),
    "categoryAll": MessageLookupByLibrary.simpleMessage("All"),
    "categoryFitness": MessageLookupByLibrary.simpleMessage("Fitness"),
    "categoryLearn": MessageLookupByLibrary.simpleMessage("Learn"),
    "categoryLogic": MessageLookupByLibrary.simpleMessage("Logic"),
    "changeAvatar": MessageLookupByLibrary.simpleMessage("Change avatar"),
    "changeLanguage": MessageLookupByLibrary.simpleMessage("Change Language"),
    "changeOutfit": MessageLookupByLibrary.simpleMessage(
      "Change outfit, hair & more",
    ),
    "childInviteCodeTitle": MessageLookupByLibrary.simpleMessage(
      "Child Invite Code",
    ),
    "childProgressTitle": m7,
    "childTasksSubtitle": m8,
    "childUpdatedSuccess": MessageLookupByLibrary.simpleMessage(
      "Child profile updated successfully.",
    ),
    "chooseYourRole": MessageLookupByLibrary.simpleMessage("Choose Your Role"),
    "cleanTheRoom": MessageLookupByLibrary.simpleMessage("Clean the room"),
    "close": MessageLookupByLibrary.simpleMessage("Close"),
    "codeCopied": MessageLookupByLibrary.simpleMessage("Code copied"),
    "codeIsReady": m9,
    "coinCount": m10,
    "coinCountShort": m11,
    "coins": MessageLookupByLibrary.simpleMessage("Coins"),
    "coinsCount": m12,
    "coinsPaidAfterApproval": MessageLookupByLibrary.simpleMessage(
      "Coins are paid out only after you approve. Repeating tasks reset at midnight.",
    ),
    "coinsReward": m13,
    "coinsText": MessageLookupByLibrary.simpleMessage("Coins"),
    "coinsToGo": m14,
    "coinsToGoShort": m15,
    "comingSoon": MessageLookupByLibrary.simpleMessage("Coming soon!"),
    "completeDailyQuests": MessageLookupByLibrary.simpleMessage(
      "Complete your daily quests to earn more coins!",
    ),
    "completed": MessageLookupByLibrary.simpleMessage("Completed"),
    "continueAction": MessageLookupByLibrary.simpleMessage("Continue"),
    "copy": MessageLookupByLibrary.simpleMessage("Copy"),
    "copyCode": MessageLookupByLibrary.simpleMessage("Copy code"),
    "costsLabel": MessageLookupByLibrary.simpleMessage("Costs"),
    "createAnInviteCode": MessageLookupByLibrary.simpleMessage(
      "Create an invite code",
    ),
    "createChildButton": MessageLookupByLibrary.simpleMessage("Create Child"),
    "createChildInviteCode": MessageLookupByLibrary.simpleMessage(
      "Create Child Invite Code",
    ),
    "createChildProfileSubtitle": MessageLookupByLibrary.simpleMessage(
      "Fill out the details below to add a child to your family.",
    ),
    "createChildProfileTitle": MessageLookupByLibrary.simpleMessage(
      "Create a child profile",
    ),
    "createFamilyAction": MessageLookupByLibrary.simpleMessage(
      "Create a family",
    ),
    "createFamilySubtitle": MessageLookupByLibrary.simpleMessage(
      "Start a family space and invite others",
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
    "dailyAllowanceFor": m16,
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
    "detailsFieldLabel": MessageLookupByLibrary.simpleMessage("Details"),
    "detailsSection": MessageLookupByLibrary.simpleMessage("Details"),
    "doHomework": MessageLookupByLibrary.simpleMessage("Do homework"),
    "doThisNext": MessageLookupByLibrary.simpleMessage("Do this next"),
    "doneAction": MessageLookupByLibrary.simpleMessage("Done"),
    "doneToday": MessageLookupByLibrary.simpleMessage("Done Today"),
    "earnMoreCoins": MessageLookupByLibrary.simpleMessage("Earn More Coins"),
    "earnedToday": MessageLookupByLibrary.simpleMessage("Earned Today"),
    "edit": MessageLookupByLibrary.simpleMessage("Edit"),
    "editChild": MessageLookupByLibrary.simpleMessage("Edit Child"),
    "editMyProfile": MessageLookupByLibrary.simpleMessage("Edit my profile"),
    "editName": m17,
    "editProfile": MessageLookupByLibrary.simpleMessage("Edit Profile"),
    "editProfileSubtitle": MessageLookupByLibrary.simpleMessage(
      "Update your child\'s information below.",
    ),
    "editTaskSheetTitle": MessageLookupByLibrary.simpleMessage("Edit Task"),
    "educational": MessageLookupByLibrary.simpleMessage("Educational"),
    "emailHint": MessageLookupByLibrary.simpleMessage("reviewer@example.com"),
    "emailLabel": MessageLookupByLibrary.simpleMessage("Email"),
    "emailRequired": MessageLookupByLibrary.simpleMessage(
      "Enter a valid email address",
    ),
    "emailSignInDescription": MessageLookupByLibrary.simpleMessage(
      "For debug and App Review accounts only.",
    ),
    "emailSignInTitle": MessageLookupByLibrary.simpleMessage(
      "Test account sign-in",
    ),
    "emptyActiveBody": MessageLookupByLibrary.simpleMessage(
      "Add one with the button below.",
    ),
    "emptyDoneBody": MessageLookupByLibrary.simpleMessage(
      "Approved tasks show up here.",
    ),
    "emptyNoActiveTasks": MessageLookupByLibrary.simpleMessage(
      "No active tasks",
    ),
    "emptyNothingPaidYet": MessageLookupByLibrary.simpleMessage(
      "Nothing paid yet",
    ),
    "emptyNothingToReview": MessageLookupByLibrary.simpleMessage(
      "Nothing to review",
    ),
    "emptyReviewBody": MessageLookupByLibrary.simpleMessage(
      "New submissions land here.",
    ),
    "english": MessageLookupByLibrary.simpleMessage("English"),
    "equipped": MessageLookupByLibrary.simpleMessage("EQUIPPED"),
    "everyAppSetUp": MessageLookupByLibrary.simpleMessage(
      "Every app is already set up",
    ),
    "everythingIsWithParent": MessageLookupByLibrary.simpleMessage(
      "Everything is with your parent",
    ),
    "everythingSent": MessageLookupByLibrary.simpleMessage(
      "Everything\'s sent",
    ),
    "expiresLabel": m18,
    "extraBackpack": MessageLookupByLibrary.simpleMessage("Backpack"),
    "extraHair": MessageLookupByLibrary.simpleMessage("Hair"),
    "extraOutfit": MessageLookupByLibrary.simpleMessage("Outfit"),
    "extrasFootnote": MessageLookupByLibrary.simpleMessage(
      "Extras cost coins once. Nothing here changes your tasks.",
    ),
    "extrasSection": MessageLookupByLibrary.simpleMessage("Extras"),
    "faceSection": MessageLookupByLibrary.simpleMessage("Face"),
    "family": MessageLookupByLibrary.simpleMessage("Family"),
    "familyAdmin": MessageLookupByLibrary.simpleMessage("Family Admin"),
    "familyDecisionSubtitle": MessageLookupByLibrary.simpleMessage(
      "Create your family space and invite your kids to start earning screen time.",
    ),
    "familyLabel": MessageLookupByLibrary.simpleMessage("Family"),
    "footerText": MessageLookupByLibrary.simpleMessage(
      "Safe screen time for smart kids 🌟",
    ),
    "free": MessageLookupByLibrary.simpleMessage("FREE"),
    "fri": MessageLookupByLibrary.simpleMessage("FRI"),
    "genderBoy": MessageLookupByLibrary.simpleMessage("Boy"),
    "genderGirl": MessageLookupByLibrary.simpleMessage("Girl"),
    "genderOptional": MessageLookupByLibrary.simpleMessage("Gender (optional)"),
    "genderOther": MessageLookupByLibrary.simpleMessage("Other"),
    "goToMyFamily": MessageLookupByLibrary.simpleMessage("Go to my family"),
    "goToTasks": MessageLookupByLibrary.simpleMessage("Go to Tasks"),
    "goodAfternoon": MessageLookupByLibrary.simpleMessage("Good afternoon 👋"),
    "goodEvening": MessageLookupByLibrary.simpleMessage("Good evening 👋"),
    "goodMorning": MessageLookupByLibrary.simpleMessage("Good morning 👋"),
    "goodNight": MessageLookupByLibrary.simpleMessage("Good night 🌙"),
    "googleClientIdMissing": MessageLookupByLibrary.simpleMessage(
      "Google Web Client ID is missing. Set GOOGLE_WEB_CLIENT_ID (OAuth Web client from Google Cloud).",
    ),
    "holdToMarkDone": MessageLookupByLibrary.simpleMessage(
      "Hold to mark it done",
    ),
    "home": MessageLookupByLibrary.simpleMessage("Home"),
    "iconSection": MessageLookupByLibrary.simpleMessage("Icon"),
    "imAKid": MessageLookupByLibrary.simpleMessage("I\'m a Kid!"),
    "imAParent": MessageLookupByLibrary.simpleMessage("I\'m a Parent"),
    "inTheFamilySince": MessageLookupByLibrary.simpleMessage(
      "In the family since",
    ),
    "inviteAParent": MessageLookupByLibrary.simpleMessage("Invite a parent"),
    "inviteAParentBody": MessageLookupByLibrary.simpleMessage(
      "They install Safini, sign in, then enter this code.",
    ),
    "inviteChildOrRefresh": MessageLookupByLibrary.simpleMessage(
      "Invite a child or refresh after linking a family member.",
    ),
    "inviteCodeCopied": MessageLookupByLibrary.simpleMessage(
      "Invite code copied",
    ),
    "inviteCodeValid": MessageLookupByLibrary.simpleMessage(
      "Invite code · valid 30 min",
    ),
    "invited": MessageLookupByLibrary.simpleMessage("Invited"),
    "joinFamilyAction": MessageLookupByLibrary.simpleMessage(
      "Join with a code",
    ),
    "joinFamilySubtitle": MessageLookupByLibrary.simpleMessage(
      "Use an invite code from the other parent",
    ),
    "keepHolding": MessageLookupByLibrary.simpleMessage("Keep holding…"),
    "kidHasLeftToday": m19,
    "kidSubtitle": MessageLookupByLibrary.simpleMessage("Earn coins & play"),
    "kidUsedToday": m20,
    "kidsApps": m21,
    "kidsEarnTimeCoins": MessageLookupByLibrary.simpleMessage(
      "Kids earn Time Coins to unlock extra minutes for these apps.",
    ),
    "laneActive": MessageLookupByLibrary.simpleMessage("Active"),
    "laneDone": MessageLookupByLibrary.simpleMessage("Done"),
    "laneToReview": MessageLookupByLibrary.simpleMessage("To review"),
    "lessons": MessageLookupByLibrary.simpleMessage("Lessons"),
    "lessonsChangeText": MessageLookupByLibrary.simpleMessage("+1 today"),
    "levelHero": m22,
    "levelShort": MessageLookupByLibrary.simpleMessage("Level"),
    "levelValue": m23,
    "limitThisApp": MessageLookupByLibrary.simpleMessage("Limit this app"),
    "limitsFootnote": MessageLookupByLibrary.simpleMessage(
      "A blocked app disappears from the home screen. Apps with no limit are always allowed.",
    ),
    "limitsSubtitle": m24,
    "lockedLabel": MessageLookupByLibrary.simpleMessage("Locked"),
    "loginBack": MessageLookupByLibrary.simpleMessage("Back"),
    "loginSubtitle": MessageLookupByLibrary.simpleMessage(
      "Continue with your Google account",
    ),
    "loginTitle": MessageLookupByLibrary.simpleMessage("Sign in"),
    "loginWithEmailTest": MessageLookupByLibrary.simpleMessage(
      "Sign in with email (Test)",
    ),
    "loginWithGoogle": MessageLookupByLibrary.simpleMessage(
      "Continue with Google",
    ),
    "logout": MessageLookupByLibrary.simpleMessage("Logout"),
    "logoutConfirmBody": MessageLookupByLibrary.simpleMessage(
      "Are you sure you want to log out?",
    ),
    "logoutConfirmTitle": MessageLookupByLibrary.simpleMessage("Log out?"),
    "lookCloser": MessageLookupByLibrary.simpleMessage("Look closer"),
    "manageAll": MessageLookupByLibrary.simpleMessage("Manage All"),
    "markItDone": MessageLookupByLibrary.simpleMessage("Mark it done"),
    "minuteCount": m25,
    "minutes": MessageLookupByLibrary.simpleMessage("Minutes"),
    "minutesLeftShort": m26,
    "minutesRemainingLong": m27,
    "mon": MessageLookupByLibrary.simpleMessage("MON"),
    "monitor": MessageLookupByLibrary.simpleMessage("Monitor"),
    "moreCoinsNeeded": m28,
    "mostOfItIn": m29,
    "myAvatar": MessageLookupByLibrary.simpleMessage("My Avatar"),
    "myFamily": MessageLookupByLibrary.simpleMessage("My Family"),
    "myProfile": MessageLookupByLibrary.simpleMessage("My Profile"),
    "myQuests": MessageLookupByLibrary.simpleMessage("My Quests"),
    "nDayStreak": m30,
    "name": MessageLookupByLibrary.simpleMessage("Name"),
    "nameHintExample": MessageLookupByLibrary.simpleMessage("Amir"),
    "nameYourFamily": MessageLookupByLibrary.simpleMessage(
      "Name it something the whole family recognises. You can invite people once it exists.",
    ),
    "needsPhotoProof": MessageLookupByLibrary.simpleMessage(
      "Needs photo proof",
    ),
    "needsYourReview": MessageLookupByLibrary.simpleMessage(
      "Needs your review",
    ),
    "networkError": MessageLookupByLibrary.simpleMessage(
      "Network error. Check your connection.",
    ),
    "newBtn": MessageLookupByLibrary.simpleMessage("New"),
    "newSubmissionsLandHere": MessageLookupByLibrary.simpleMessage(
      "New submissions land here.",
    ),
    "newTask": MessageLookupByLibrary.simpleMessage("New Task"),
    "nicknameLabel": MessageLookupByLibrary.simpleMessage("Nickname"),
    "nicknameRequired": MessageLookupByLibrary.simpleMessage(
      "Nickname is required.",
    ),
    "nicknameTooLong": MessageLookupByLibrary.simpleMessage(
      "Nickname must be at most 80 characters.",
    ),
    "noChildYetBody": MessageLookupByLibrary.simpleMessage(
      "Set one up and their day shows here.",
    ),
    "noChildrenFoundYet": MessageLookupByLibrary.simpleMessage(
      "No children found yet",
    ),
    "noChildrenYet": MessageLookupByLibrary.simpleMessage("No children yet"),
    "noChildrenYetBody": MessageLookupByLibrary.simpleMessage(
      "Add one and they get a pairing code.",
    ),
    "noCodeAskParent": MessageLookupByLibrary.simpleMessage(
      "No code? Ask your parent to open Safini, then My family.",
    ),
    "noCodeAskThem": MessageLookupByLibrary.simpleMessage(
      "No code? Ask them to open Safini, then My family.",
    ),
    "noFamilySetupYet": MessageLookupByLibrary.simpleMessage(
      "No family set up yet",
    ),
    "noLimitLabel": MessageLookupByLibrary.simpleMessage("No limit"),
    "noLimitsSet": MessageLookupByLibrary.simpleMessage("No limits set"),
    "noQuestsInCategory": MessageLookupByLibrary.simpleMessage(
      "No quests in this category",
    ),
    "noTasksYet": MessageLookupByLibrary.simpleMessage(
      "No tasks for this day yet.",
    ),
    "notEnoughCoins": MessageLookupByLibrary.simpleMessage("Not enough coins!"),
    "notPairedYet": MessageLookupByLibrary.simpleMessage("Not paired yet"),
    "notRecorded": MessageLookupByLibrary.simpleMessage("Not recorded"),
    "notSet": MessageLookupByLibrary.simpleMessage("Not set"),
    "notYet": MessageLookupByLibrary.simpleMessage("Not yet"),
    "noteForParent": MessageLookupByLibrary.simpleMessage(
      "Note for your parent · optional",
    ),
    "noteFromParent": MessageLookupByLibrary.simpleMessage(
      "Note from your parent",
    ),
    "nothingHereYet": MessageLookupByLibrary.simpleMessage("Nothing here yet"),
    "nothingInStore": MessageLookupByLibrary.simpleMessage(
      "Nothing in the store yet.",
    ),
    "nothingLeft": MessageLookupByLibrary.simpleMessage("Nothing left"),
    "ofTotal": m31,
    "offMeansAlwaysAllowed": MessageLookupByLibrary.simpleMessage(
      "Off means it is always allowed",
    ),
    "ok": MessageLookupByLibrary.simpleMessage("OK"),
    "on": MessageLookupByLibrary.simpleMessage("ON"),
    "openOneFromList": MessageLookupByLibrary.simpleMessage(
      "Open one from the list to change its limit.",
    ),
    "outfitsAndItems": MessageLookupByLibrary.simpleMessage("Outfits & Items"),
    "paidOutNice": MessageLookupByLibrary.simpleMessage("Paid out. Nice one."),
    "pairStepAllow": MessageLookupByLibrary.simpleMessage(
      "Allow screen time access when asked",
    ),
    "pairStepInstall": m32,
    "pairStepTap": MessageLookupByLibrary.simpleMessage(
      "Tap \"I\'m a kid\" and type the code",
    ),
    "paired": MessageLookupByLibrary.simpleMessage("Paired"),
    "pairingCodeCaption": MessageLookupByLibrary.simpleMessage("Pairing code"),
    "parentAccount": MessageLookupByLibrary.simpleMessage("PARENT ACCOUNT"),
    "parentHomeScreen": MessageLookupByLibrary.simpleMessage(
      "Parent Home Screen",
    ),
    "parentInviteCodeTitle": MessageLookupByLibrary.simpleMessage(
      "Parent Invite Code",
    ),
    "parentName": MessageLookupByLibrary.simpleMessage("Safini Parent"),
    "parentReviewsNext": MessageLookupByLibrary.simpleMessage(
      "Your parent reviews them next. Coins land after that.",
    ),
    "parentSubtitle": MessageLookupByLibrary.simpleMessage("Monitor & reward"),
    "parents": MessageLookupByLibrary.simpleMessage("Parents"),
    "passwordHint": MessageLookupByLibrary.simpleMessage("Enter password"),
    "passwordLabel": MessageLookupByLibrary.simpleMessage("Password"),
    "passwordRequired": MessageLookupByLibrary.simpleMessage(
      "Enter your password",
    ),
    "pendingApproval": MessageLookupByLibrary.simpleMessage("Pending Approval"),
    "percentToNextLevel": m33,
    "photoProofAsked": MessageLookupByLibrary.simpleMessage(
      "Photo proof was asked for",
    ),
    "pillCheck": MessageLookupByLibrary.simpleMessage("Check"),
    "pillPaid": MessageLookupByLibrary.simpleMessage("Paid"),
    "pillWaiting": MessageLookupByLibrary.simpleMessage("Waiting"),
    "profile": MessageLookupByLibrary.simpleMessage("Profile"),
    "profileUpdated": MessageLookupByLibrary.simpleMessage("Saved"),
    "questsDone": MessageLookupByLibrary.simpleMessage("Quests Done"),
    "questsText": MessageLookupByLibrary.simpleMessage("Quests"),
    "readFor20Mins": MessageLookupByLibrary.simpleMessage("Read for 20 mins"),
    "readyToSpend": MessageLookupByLibrary.simpleMessage(
      "Ready to spend your coins?",
    ),
    "readyWhenYouAre": MessageLookupByLibrary.simpleMessage(
      "Ready when you are",
    ),
    "realWorldTasks": MessageLookupByLibrary.simpleMessage("Real-world Tasks"),
    "reconnectCodeValid": MessageLookupByLibrary.simpleMessage(
      "Re-connect code · valid 30 min",
    ),
    "reconnectWithCode": MessageLookupByLibrary.simpleMessage(
      "Re-connect with a code",
    ),
    "redeemExplainer": m34,
    "reject": MessageLookupByLibrary.simpleMessage("Reject"),
    "remaining": MessageLookupByLibrary.simpleMessage("Remaining"),
    "remainingTime": m35,
    "removeFromFamily": MessageLookupByLibrary.simpleMessage(
      "Remove from family",
    ),
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
    "rewardBlurbAppTime": MessageLookupByLibrary.simpleMessage(
      "Added to today only, once your parent approves.",
    ),
    "rewardBlurbAvatar": MessageLookupByLibrary.simpleMessage(
      "Wear it on your avatar. Yours to keep.",
    ),
    "rewardFieldLabel": MessageLookupByLibrary.simpleMessage("Reward"),
    "rewardStore": MessageLookupByLibrary.simpleMessage("Reward Store"),
    "roleLabel": MessageLookupByLibrary.simpleMessage("Role"),
    "roleOwner": MessageLookupByLibrary.simpleMessage("Owner"),
    "roleParent": MessageLookupByLibrary.simpleMessage("Parent"),
    "roleSelectionSubtitle": MessageLookupByLibrary.simpleMessage(
      "How will you use Safini?",
    ),
    "russian": MessageLookupByLibrary.simpleMessage("Russian"),
    "sat": MessageLookupByLibrary.simpleMessage("SAT"),
    "save": MessageLookupByLibrary.simpleMessage("Save"),
    "saveChanges": MessageLookupByLibrary.simpleMessage("Save Changes"),
    "saveForName": m36,
    "saveMyLook": MessageLookupByLibrary.simpleMessage("Save My Look!"),
    "savedForName": m37,
    "scopeEveryone": MessageLookupByLibrary.simpleMessage("Everyone"),
    "screenTime": MessageLookupByLibrary.simpleMessage("Screen time"),
    "sectionAccount": MessageLookupByLibrary.simpleMessage("Account"),
    "sectionApp": MessageLookupByLibrary.simpleMessage("App"),
    "selectLanguage": MessageLookupByLibrary.simpleMessage("Select Language"),
    "setUpANewProfile": MessageLookupByLibrary.simpleMessage(
      "Set up a new profile",
    ),
    "settings": MessageLookupByLibrary.simpleMessage("Settings"),
    "setupYourFamily": MessageLookupByLibrary.simpleMessage(
      "Set Up Your Family",
    ),
    "signInAction": MessageLookupByLibrary.simpleMessage("Sign in"),
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
    "statCoins": MessageLookupByLibrary.simpleMessage("Coins"),
    "statDayStreak": MessageLookupByLibrary.simpleMessage("Day streak"),
    "statTasksDone": MessageLookupByLibrary.simpleMessage("Tasks done"),
    "statusActive": MessageLookupByLibrary.simpleMessage("ACTIVE"),
    "statusDone": MessageLookupByLibrary.simpleMessage("DONE"),
    "statusPending": MessageLookupByLibrary.simpleMessage("PENDING"),
    "step1of2": MessageLookupByLibrary.simpleMessage(
      "Step 1 of 2 - you can add more kids later.",
    ),
    "step2of2": MessageLookupByLibrary.simpleMessage(
      "Step 2 of 2 - the code works for 30 minutes.",
    ),
    "steps": MessageLookupByLibrary.simpleMessage("Steps"),
    "stepsChangeText": MessageLookupByLibrary.simpleMessage(
      "+12% vs yesterday",
    ),
    "stepsToday": MessageLookupByLibrary.simpleMessage("Steps Today"),
    "store": MessageLookupByLibrary.simpleMessage("Store"),
    "storeAppTimeTab": MessageLookupByLibrary.simpleMessage("App time"),
    "storeAvatarTab": MessageLookupByLibrary.simpleMessage("Avatar"),
    "storeSubtitle": MessageLookupByLibrary.simpleMessage(
      "Your parent approves before it is yours",
    ),
    "streakText": MessageLookupByLibrary.simpleMessage("Streak"),
    "sun": MessageLookupByLibrary.simpleMessage("SUN"),
    "supabaseConfigMissing": MessageLookupByLibrary.simpleMessage(
      "Supabase URL or anon key is missing. Set SUPABASE_URL and SUPABASE_ANON_KEY when running the app.",
    ),
    "surname": MessageLookupByLibrary.simpleMessage("Surname"),
    "switchToKidMode": MessageLookupByLibrary.simpleMessage(
      "Switch to Kid Mode / Logout",
    ),
    "tabFamily": MessageLookupByLibrary.simpleMessage("Family"),
    "tabLimits": MessageLookupByLibrary.simpleMessage("Limits"),
    "tabMe": MessageLookupByLibrary.simpleMessage("Me"),
    "tabStore": MessageLookupByLibrary.simpleMessage("Store"),
    "tabTasks": MessageLookupByLibrary.simpleMessage("Tasks"),
    "tabToday": MessageLookupByLibrary.simpleMessage("Today"),
    "tagline": MessageLookupByLibrary.simpleMessage("Learn. Earn. Play."),
    "taskApprovedMessage": MessageLookupByLibrary.simpleMessage(
      "Task approved!",
    ),
    "taskChessSub": MessageLookupByLibrary.simpleMessage("Master the board"),
    "taskChessTitle": MessageLookupByLibrary.simpleMessage("Chess Lesson"),
    "taskCount": m38,
    "taskCreatedMessage": MessageLookupByLibrary.simpleMessage("Task created!"),
    "taskDeletedMessage": MessageLookupByLibrary.simpleMessage("Task deleted."),
    "taskDetailsHint": MessageLookupByLibrary.simpleMessage(
      "What counts as done? Optional.",
    ),
    "taskDuolingoSub": MessageLookupByLibrary.simpleMessage(
      "Daily streak bonus!",
    ),
    "taskDuolingoTitle": MessageLookupByLibrary.simpleMessage(
      "Complete Duolingo",
    ),
    "taskFieldLabel": MessageLookupByLibrary.simpleMessage("Task"),
    "taskGroupSummary": m39,
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
    "taskScopeLine": m40,
    "taskStepsSub": MessageLookupByLibrary.simpleMessage("Keep it moving!"),
    "taskStepsTitle": MessageLookupByLibrary.simpleMessage("Walk 5,000 Steps"),
    "taskSubmittedForReview": MessageLookupByLibrary.simpleMessage(
      "Sent to your parent",
    ),
    "taskTitleHint": MessageLookupByLibrary.simpleMessage("Water the plants"),
    "taskUpdatedMessage": MessageLookupByLibrary.simpleMessage("Task updated!"),
    "tasks": MessageLookupByLibrary.simpleMessage("Tasks"),
    "tasksAndRewards": MessageLookupByLibrary.simpleMessage("Tasks & Rewards"),
    "tasksLeftCoinsOnTable": m41,
    "theirNote": MessageLookupByLibrary.simpleMessage("Their note"),
    "theyInstallSafini": MessageLookupByLibrary.simpleMessage(
      "They install Safini and sign in, then enter this code.",
    ),
    "thisWeek": MessageLookupByLibrary.simpleMessage("This week"),
    "thu": MessageLookupByLibrary.simpleMessage("THU"),
    "timeCoins": MessageLookupByLibrary.simpleMessage("Time Coins"),
    "timeLeft": m42,
    "timeUsed": m43,
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
    "toGo": m44,
    "todaysQuests": MessageLookupByLibrary.simpleMessage("Today\'s Quests"),
    "tryAgain": MessageLookupByLibrary.simpleMessage("Try again"),
    "tue": MessageLookupByLibrary.simpleMessage("TUE"),
    "typeCodeFromOtherParent": MessageLookupByLibrary.simpleMessage(
      "Type the code from the other parent",
    ),
    "typeCodeFromParent": MessageLookupByLibrary.simpleMessage(
      "Type the code from your parent",
    ),
    "typeItOnPhone": m45,
    "unitHour": MessageLookupByLibrary.simpleMessage("h"),
    "unitMinute": MessageLookupByLibrary.simpleMessage("m"),
    "unlockExtraTime": MessageLookupByLibrary.simpleMessage(
      "Unlock Extra Time",
    ),
    "unlockOnceKeepForever": MessageLookupByLibrary.simpleMessage(
      "Unlock once, keep forever",
    ),
    "unlocked": MessageLookupByLibrary.simpleMessage("unlocked"),
    "usedLimit": m46,
    "usedNoLimit": m47,
    "usedOfLimit": m48,
    "usedOfLimitOver": m49,
    "usedTodayShort": m50,
    "uzbek": MessageLookupByLibrary.simpleMessage("Uzbek"),
    "viewAsKid": MessageLookupByLibrary.simpleMessage("View as Kid"),
    "waitingCount": m51,
    "waitingForParentCheck": MessageLookupByLibrary.simpleMessage(
      "Waiting for your parent to check it",
    ),
    "waitingForPhone": m52,
    "wearLabel": MessageLookupByLibrary.simpleMessage("Wear"),
    "wed": MessageLookupByLibrary.simpleMessage("WED"),
    "weeklyScreenTime": MessageLookupByLibrary.simpleMessage(
      "Weekly Screen Time",
    ),
    "whereTheTimeWent": MessageLookupByLibrary.simpleMessage(
      "Where the time went",
    ),
    "whoAreWeSettingUp": MessageLookupByLibrary.simpleMessage(
      "Who are we setting up?",
    ),
    "whoSection": MessageLookupByLibrary.simpleMessage("Who"),
    "wornLabel": MessageLookupByLibrary.simpleMessage("On"),
    "worthCoins": m53,
    "yearsOld": m54,
    "youNeedMoreCoins": m55,
    "youSuffix": m56,
    "yourAccount": MessageLookupByLibrary.simpleMessage("Your account"),
    "yourAvatar": MessageLookupByLibrary.simpleMessage("Your avatar"),
    "yourChildren": MessageLookupByLibrary.simpleMessage("YOUR CHILDREN"),
    "yourName": MessageLookupByLibrary.simpleMessage("Your name"),
    "yoursLabel": MessageLookupByLibrary.simpleMessage("Yours"),
  };
}
