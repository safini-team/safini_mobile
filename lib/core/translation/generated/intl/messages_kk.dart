// DO NOT EDIT. This is code generated via package:intl/generate_localized.dart
// This is a library that provides messages for a kk locale. All the
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
  String get localeName => 'kk';

  static String m0(age, gender) => "Жасы ${age} • ${gender}";

  static String m1(name) => "${name} прогресі";

  static String m2(count) =>
      "${Intl.plural(count, one: '${count} монета', other: '${count} монеталар')}";

  static String m3(count) => "${count} монета";

  static String m4(count) =>
      "${Intl.plural(count, one: '${count} монета сыйақысы', other: '${count} монета сыйақысы')}";

  static String m5(level) => "${level} деңгей кейіпкері";

  static String m6(count) =>
      "${Intl.plural(count, one: '${count} минут', other: '${count} минут')}";

  static String m7(minutes) => "${minutes} минут қалды";

  static String m8(minutes) => "${minutes} мин қалды";

  static String m9(used, limit) => "${used} қолданылды / ${limit} лимит";

  static String m10(count) => "Сізге тағы ${count} монета керек";

  final messages = _notInlinedMessages(_notInlinedMessages);
  static Map<String, Function> _notInlinedMessages(_) => <String, Function>{
        "achievements": MessageLookupByLibrary.simpleMessage("Жетістіктер"),
        "activeTasks":
            MessageLookupByLibrary.simpleMessage("Белсенді тапсырмалар"),
        "addAnotherApp":
            MessageLookupByLibrary.simpleMessage("Тағы бір қолданба қосу"),
        "addAnotherChild":
            MessageLookupByLibrary.simpleMessage("Тағы бір бала қосу"),
        "admin": MessageLookupByLibrary.simpleMessage("Әкімші"),
        "ageAndGender": m0,
        "appLimits":
            MessageLookupByLibrary.simpleMessage("Қолданба шектеулері"),
        "appLimitsSubtitle": MessageLookupByLibrary.simpleMessage(
            "Күнделікті экран уақытының шектеуін орнатыңыз"),
        "appName": MessageLookupByLibrary.simpleMessage("SAFINI"),
        "appTimeTab": MessageLookupByLibrary.simpleMessage("Қолданба уақыты"),
        "approve": MessageLookupByLibrary.simpleMessage("Бекіту"),
        "approvedTaskConflict": MessageLookupByLibrary.simpleMessage(
            "Бекітілген тапсырмаларды өзгертуге немесе жоюға болмайды."),
        "apps": MessageLookupByLibrary.simpleMessage("Қолданбалар"),
        "avatarItemsTab":
            MessageLookupByLibrary.simpleMessage("Аватар заттары"),
        "buyIt": MessageLookupByLibrary.simpleMessage("Сатып ал! 🎉"),
        "cancel": MessageLookupByLibrary.simpleMessage("Бас тарту"),
        "categoryAll": MessageLookupByLibrary.simpleMessage("Барлығы"),
        "categoryFitness": MessageLookupByLibrary.simpleMessage("Фитнес"),
        "categoryLearn": MessageLookupByLibrary.simpleMessage("Үйрену"),
        "categoryLogic": MessageLookupByLibrary.simpleMessage("Логика"),
        "changeLanguage": MessageLookupByLibrary.simpleMessage("Тілді өзгерту"),
        "changeOutfit": MessageLookupByLibrary.simpleMessage(
            "Киім, шаш және тағы басқасын өзгерту"),
        "childProgressTitle": m1,
        "chooseYourRole":
            MessageLookupByLibrary.simpleMessage("Рөліңізді таңдаңыз"),
        "cleanTheRoom": MessageLookupByLibrary.simpleMessage("Бөлмені жина"),
        "coinCount": m2,
        "coins": MessageLookupByLibrary.simpleMessage("Мәнет"),
        "coinsCount": m3,
        "coinsReward": m4,
        "coinsText": MessageLookupByLibrary.simpleMessage("Монеталар"),
        "comingSoon": MessageLookupByLibrary.simpleMessage("Жақында!"),
        "completeDailyQuests": MessageLookupByLibrary.simpleMessage(
            "Көбірек монета табу үшін күнделікті тапсырмаларды орында!"),
        "completed": MessageLookupByLibrary.simpleMessage("Орындалды"),
        "createTaskAddButton":
            MessageLookupByLibrary.simpleMessage("Тапсырма қосу"),
        "createTaskCategoryDailyChore":
            MessageLookupByLibrary.simpleMessage("Үй жұмысы"),
        "createTaskCategoryEducational":
            MessageLookupByLibrary.simpleMessage("Оқу"),
        "createTaskCategoryHobby":
            MessageLookupByLibrary.simpleMessage("Хобби"),
        "createTaskCategoryOther":
            MessageLookupByLibrary.simpleMessage("Басқа"),
        "createTaskCategoryTitle":
            MessageLookupByLibrary.simpleMessage("Санат"),
        "createTaskNameHint":
            MessageLookupByLibrary.simpleMessage("мыс. Бөлмені жина"),
        "createTaskNameLabel": MessageLookupByLibrary.simpleMessage("Атауы"),
        "createTaskPickEmojiLabel":
            MessageLookupByLibrary.simpleMessage("Эмодзи таңда"),
        "createTaskRewardLabel":
            MessageLookupByLibrary.simpleMessage("Марапат (Уақыт монеталары)"),
        "createTaskSaveButton": MessageLookupByLibrary.simpleMessage("Сақтау"),
        "createTaskSheetTitle":
            MessageLookupByLibrary.simpleMessage("Жаңа тапсырма"),
        "customizeAvatar":
            MessageLookupByLibrary.simpleMessage("Аватарды баптау"),
        "dailyChore": MessageLookupByLibrary.simpleMessage("Күнделікті жұмыс"),
        "dailyLimit": MessageLookupByLibrary.simpleMessage("Күндік шектеу"),
        "dayStreak": MessageLookupByLibrary.simpleMessage("Күндік серия"),
        "deleteTaskBody":
            MessageLookupByLibrary.simpleMessage("Мұны қайтару мүмкін емес."),
        "deleteTaskButton": MessageLookupByLibrary.simpleMessage("Жою"),
        "deleteTaskTitle":
            MessageLookupByLibrary.simpleMessage("Тапсырманы жою?"),
        "doHomework":
            MessageLookupByLibrary.simpleMessage("Үй тапсырмасын орында"),
        "doneToday": MessageLookupByLibrary.simpleMessage("Бүгін орындалды"),
        "earnMoreCoins":
            MessageLookupByLibrary.simpleMessage("Көбірек монета тап"),
        "earnedToday": MessageLookupByLibrary.simpleMessage("Бүгін табылды"),
        "edit": MessageLookupByLibrary.simpleMessage("Өңдеу"),
        "editTaskSheetTitle":
            MessageLookupByLibrary.simpleMessage("Тапсырманы өзгерту"),
        "educational": MessageLookupByLibrary.simpleMessage("Білім беру"),
        "english": MessageLookupByLibrary.simpleMessage("Ағылшын"),
        "equipped": MessageLookupByLibrary.simpleMessage("ҚОЛДАНЫЛУДА"),
        "family": MessageLookupByLibrary.simpleMessage("Отбасы"),
        "familyAdmin": MessageLookupByLibrary.simpleMessage("Отбасы әкімшісі"),
        "familyDecisionSubtitle": MessageLookupByLibrary.simpleMessage(
            "Отбасылық кеңістік жасаңыз және балаларыңызды экран уақытын табуға шақырыңыз."),
        "footerText": MessageLookupByLibrary.simpleMessage(
            "Ақылды балаларға қауіпсіз экран уақыты 🌟"),
        "free": MessageLookupByLibrary.simpleMessage("ТЕГІН"),
        "fri": MessageLookupByLibrary.simpleMessage("ЖМ"),
        "goToTasks": MessageLookupByLibrary.simpleMessage("Тапсырмаларға өту"),
        "goodMorning": MessageLookupByLibrary.simpleMessage("Қайырлы таң 👋"),
        "googleClientIdMissing": MessageLookupByLibrary.simpleMessage(
            "Google Web Client ID жоқ. GOOGLE_WEB_CLIENT_ID орнатыңыз (Google Cloud OAuth Web client)"),
        "home": MessageLookupByLibrary.simpleMessage("Басты бет"),
        "imAKid": MessageLookupByLibrary.simpleMessage("Мен баламын!"),
        "imAParent": MessageLookupByLibrary.simpleMessage("Мен ата-анамын"),
        "kazakh": MessageLookupByLibrary.simpleMessage("Қазақша"),
        "kidSubtitle":
            MessageLookupByLibrary.simpleMessage("Монета жинап, ойна"),
        "kidsEarnTimeCoins": MessageLookupByLibrary.simpleMessage(
            "Балалар осы қолданбаларға қосымша уақыт ашу үшін Уақыт монеталарын табады"),
        "lessons": MessageLookupByLibrary.simpleMessage("Сабақтар"),
        "lessonsChangeText": MessageLookupByLibrary.simpleMessage("Бүгін +1"),
        "levelHero": m5,
        "loginBack": MessageLookupByLibrary.simpleMessage("Артқа"),
        "loginSubtitle": MessageLookupByLibrary.simpleMessage(
            "Google аккаунтыңызбен жалғастырыңыз"),
        "loginTitle": MessageLookupByLibrary.simpleMessage("Кіру"),
        "loginWithGoogle":
            MessageLookupByLibrary.simpleMessage("Google арқылы кіру"),
        "manageAll": MessageLookupByLibrary.simpleMessage("Барлығын басқару"),
        "minuteCount": m6,
        "minutes": MessageLookupByLibrary.simpleMessage("Минут"),
        "minutesRemainingLong": m7,
        "mon": MessageLookupByLibrary.simpleMessage("ДС"),
        "monitor": MessageLookupByLibrary.simpleMessage("Бақылау"),
        "myAvatar": MessageLookupByLibrary.simpleMessage("Менің аватарым"),
        "myProfile": MessageLookupByLibrary.simpleMessage("Менің профилім"),
        "myQuests": MessageLookupByLibrary.simpleMessage("Менің тапсырмаларым"),
        "networkError": MessageLookupByLibrary.simpleMessage(
            "Желі қатесі. Байланысыңызды тексеріңіз."),
        "newBtn": MessageLookupByLibrary.simpleMessage("Жаңа"),
        "newTask": MessageLookupByLibrary.simpleMessage("Жаңа тапсырма"),
        "noQuestsInCategory":
            MessageLookupByLibrary.simpleMessage("Бұл санатта тапсырма жоқ"),
        "noTasksYet": MessageLookupByLibrary.simpleMessage(
            "Бұл күнге әзірге тапсырма жоқ."),
        "notEnoughCoins":
            MessageLookupByLibrary.simpleMessage("Монеталар жеткіліксіз!"),
        "ok": MessageLookupByLibrary.simpleMessage("Жарайды"),
        "on": MessageLookupByLibrary.simpleMessage("ҚОСУЛЫ"),
        "outfitsAndItems":
            MessageLookupByLibrary.simpleMessage("Киімдер мен заттар"),
        "parentAccount":
            MessageLookupByLibrary.simpleMessage("АТА-АНА ЕСЕПТІГІ"),
        "parentHomeScreen":
            MessageLookupByLibrary.simpleMessage("Ата-ана басты беті"),
        "parentName": MessageLookupByLibrary.simpleMessage("Safini ата-анасы"),
        "parentSubtitle":
            MessageLookupByLibrary.simpleMessage("Бақылап, марапатта"),
        "pendingApproval":
            MessageLookupByLibrary.simpleMessage("Бекітуді күтуде"),
        "profile": MessageLookupByLibrary.simpleMessage("Профиль"),
        "questsDone":
            MessageLookupByLibrary.simpleMessage("Орындалған тапсырмалар"),
        "questsText": MessageLookupByLibrary.simpleMessage("Тапсырмалар"),
        "readFor20Mins": MessageLookupByLibrary.simpleMessage("20 минут оқы"),
        "readyToSpend": MessageLookupByLibrary.simpleMessage(
            "Монеталарды жұмсауға дайынсыз ба?"),
        "realWorldTasks":
            MessageLookupByLibrary.simpleMessage("Шынайы өмір тапсырмалары"),
        "reject": MessageLookupByLibrary.simpleMessage("Қабылдамау"),
        "remaining": MessageLookupByLibrary.simpleMessage("Қалды"),
        "remainingTime": m8,
        "retry": MessageLookupByLibrary.simpleMessage("Қайталау"),
        "reviewNoteHint":
            MessageLookupByLibrary.simpleMessage("Жазба қосу (міндетті емес)"),
        "reviewTaskSheetTitle":
            MessageLookupByLibrary.simpleMessage("Тапсырманы тексеру"),
        "rewardStore": MessageLookupByLibrary.simpleMessage("Сыйлықтар дүкені"),
        "roleSelectionSubtitle":
            MessageLookupByLibrary.simpleMessage("Safini-ді қалай қолданасыз?"),
        "russian": MessageLookupByLibrary.simpleMessage("Орыс"),
        "sat": MessageLookupByLibrary.simpleMessage("СБ"),
        "save": MessageLookupByLibrary.simpleMessage("Сақтау"),
        "saveMyLook": MessageLookupByLibrary.simpleMessage("Көріністі сақтау!"),
        "selectLanguage":
            MessageLookupByLibrary.simpleMessage("Тілді таңдаңыз"),
        "setUpANewProfile":
            MessageLookupByLibrary.simpleMessage("Жаңа профиль жасау"),
        "setupYourFamily":
            MessageLookupByLibrary.simpleMessage("Отбасыңызды орнатыңыз"),
        "signInError": MessageLookupByLibrary.simpleMessage(
            "Кіру сәтсіз. Қайта байқап көріңіз."),
        "signedInSuccess":
            MessageLookupByLibrary.simpleMessage("Сәтті кірдіңіз"),
        "signingIn": MessageLookupByLibrary.simpleMessage("Кіруде..."),
        "spendYourTimeCoins":
            MessageLookupByLibrary.simpleMessage("Уақыт монеталарын жұмса"),
        "statusActive": MessageLookupByLibrary.simpleMessage("БЕЛСЕНДІ"),
        "statusDone": MessageLookupByLibrary.simpleMessage("ОРЫНДАЛДЫ"),
        "statusPending": MessageLookupByLibrary.simpleMessage("КҮТУДЕ"),
        "steps": MessageLookupByLibrary.simpleMessage("Қадамдар"),
        "stepsChangeText":
            MessageLookupByLibrary.simpleMessage("Кешегіден +12%"),
        "stepsToday": MessageLookupByLibrary.simpleMessage("Бүгінгі қадамдар"),
        "store": MessageLookupByLibrary.simpleMessage("Дүкен"),
        "streakText": MessageLookupByLibrary.simpleMessage("Серия"),
        "sun": MessageLookupByLibrary.simpleMessage("ЖС"),
        "supabaseConfigMissing": MessageLookupByLibrary.simpleMessage(
            "Supabase URL немесе anon key жоқ. Қосымшаны іске қосқанда SUPABASE_URL және SUPABASE_ANON_KEY орнатыңыз"),
        "switchToKidMode":
            MessageLookupByLibrary.simpleMessage("Бала режиміне өту / Шығу"),
        "tagline":
            MessageLookupByLibrary.simpleMessage("Үйрен. Табыс тап. Ойна."),
        "taskApprovedMessage":
            MessageLookupByLibrary.simpleMessage("Тапсырма бекітілді!"),
        "taskChessSub": MessageLookupByLibrary.simpleMessage("Ойынды меңгер"),
        "taskChessTitle": MessageLookupByLibrary.simpleMessage("Шахмат сабағы"),
        "taskCreatedMessage":
            MessageLookupByLibrary.simpleMessage("Тапсырма жасалды!"),
        "taskDeletedMessage":
            MessageLookupByLibrary.simpleMessage("Тапсырма жойылды."),
        "taskDuolingoSub":
            MessageLookupByLibrary.simpleMessage("Күндік серия бонусы!"),
        "taskDuolingoTitle":
            MessageLookupByLibrary.simpleMessage("Duolingo аяқта"),
        "taskPuzzleSub": MessageLookupByLibrary.simpleMessage("Миды дамыту"),
        "taskPuzzleTitle":
            MessageLookupByLibrary.simpleMessage("Логикалық тапсырма"),
        "taskReadingSub":
            MessageLookupByLibrary.simpleMessage("Ой-өрісіңді кеңейт"),
        "taskReadingTitle":
            MessageLookupByLibrary.simpleMessage("20 минут оқы"),
        "taskRejectedMessage":
            MessageLookupByLibrary.simpleMessage("Тапсырма қабылданбады."),
        "taskRoomSub": MessageLookupByLibrary.simpleMessage("Күнделікті жұмыс"),
        "taskRoomTitle": MessageLookupByLibrary.simpleMessage("Бөлмеңді жина"),
        "taskStepsSub":
            MessageLookupByLibrary.simpleMessage("Қозғалысты тоқтатпа!"),
        "taskStepsTitle":
            MessageLookupByLibrary.simpleMessage("5 000 қадам жүр"),
        "taskUpdatedMessage":
            MessageLookupByLibrary.simpleMessage("Тапсырма жаңартылды!"),
        "tasks": MessageLookupByLibrary.simpleMessage("Тапсырмалар"),
        "tasksAndRewards":
            MessageLookupByLibrary.simpleMessage("Тапсырмалар мен марапаттар"),
        "thu": MessageLookupByLibrary.simpleMessage("БС"),
        "timeCoins": MessageLookupByLibrary.simpleMessage("Уақыт монеталары"),
        "tip1": MessageLookupByLibrary.simpleMessage(
            "Жауапкершілікке үйрететін тапсырмалар беріңіз"),
        "tip2": MessageLookupByLibrary.simpleMessage(
            "Экран уақытын сыртқы белсенділікпен теңестіріңіз"),
        "tip3": MessageLookupByLibrary.simpleMessage(
            "Балаңызбен бірге жетістіктерді атап өтіңіз"),
        "tip4": MessageLookupByLibrary.simpleMessage(
            "Монета мәнін күш деңгейіне сай реттеңіз"),
        "tipsForParents":
            MessageLookupByLibrary.simpleMessage("Ата-аналарға кеңестер"),
        "todaysQuests":
            MessageLookupByLibrary.simpleMessage("Бүгінгі тапсырмалар"),
        "tue": MessageLookupByLibrary.simpleMessage("СЕ"),
        "unlockExtraTime":
            MessageLookupByLibrary.simpleMessage("Қосымша уақыт ашу"),
        "unlocked": MessageLookupByLibrary.simpleMessage("ашылды"),
        "usedLimit": m9,
        "viewAsKid": MessageLookupByLibrary.simpleMessage("Бала ретінде көру"),
        "wed": MessageLookupByLibrary.simpleMessage("СР"),
        "weeklyScreenTime":
            MessageLookupByLibrary.simpleMessage("Апталық экран уақыты"),
        "youNeedMoreCoins": m10,
        "yourChildren":
            MessageLookupByLibrary.simpleMessage("СІЗДІҢ БАЛАЛАРЫҢЫЗ")
      };
}
