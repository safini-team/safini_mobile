// DO NOT EDIT. This is code generated via package:intl/generate_localized.dart
// This is a library that provides messages for a uz locale. All the
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
  String get localeName => 'uz';

  static String m0(name) => "${name} roʻyxatiga qoʻshish";

  static String m1(age, gender) => "${age} yosh • ${gender}";

  static String m2(age) => "Yosh: ${age}";

  static String m3(app, minutes) => "${app} · ${minutes} daqiqa";

  static String m4(coins) => "Tasdiqlash · ${coins} berish";

  static String m5(count) => "${count} tanga";

  static String m6(count) => "${count} vazifa";

  static String m7(name) => "${name} taraqqiyoti";

  static String m8(done, total, coins) =>
      "Bugun ${total} dan ${done} · ${coins} tanga kutmoqda";

  static String m9(name) => "${name} uchun kod tayyor";

  static String m10(count) =>
      "${Intl.plural(count, one: '${count} tanga', other: '${count} tanga')}";

  static String m11(count) => "${Intl.plural(count, other: '${count} tanga')}";

  static String m12(count) => "${count} tanga";

  static String m13(count) =>
      "${Intl.plural(count, one: '${count} tanga mukofot', other: '${count} tanga mukofot')}";

  static String m14(count) => "Yana ${count} tanga";

  static String m15(count) => "Yana ${count} tanga";

  static String m16(name) => "${name} · kunlik limit";

  static String m17(name) => "${name}ni tahrirlash";

  static String m18(date, time) => "Amal qiladi: ${date}, ${time}";

  static String m19(name, time) => "${name}da bugun ${time} qoldi";

  static String m20(name, time) => "${name} bugun ${time} ishlatdi";

  static String m21(name) => "${name} ilovalari";

  static String m22(level) => "${level}-daraja qahramoni";

  static String m23(level) => "${level}-daraja";

  static String m24(name) => "${name} telefoni · bugun";

  static String m25(count) =>
      "${Intl.plural(count, one: '${count} daqiqa', other: '${count} daqiqa')}";

  static String m26(minutes) => "${minutes} daqiqa qoldi";

  static String m27(minutes) => "${minutes} daqiqa qoldi";

  static String m28(count) => "Yana ${count} tanga kerak";

  static String m29(app) => "Koʻpi ${app}da";

  static String m30(count) => "${count} kun ketma-ket";

  static String m31(total) => "${total} dan";

  static String m32(name) => "${name} telefoniga Safini oʻrnating";

  static String m33(percent) => "Keyingi darajagacha ${percent}%";

  static String m34(cost, time) =>
      "Bola kunlik limitdan tashqari ${time} ochish uchun ${cost} tanga sarflashi mumkin.";

  static String m35(minutes) => "${minutes} daqiqa qoldi";

  static String m36(name) => "${name} uchun saqlash";

  static String m37(name) => "${name} uchun saqlandi";

  static String m38(count) => "${Intl.plural(count, other: '${count} vazifa')}";

  static String m39(tasks, coins) => "${tasks} · ${coins}";

  static String m40(scope, tasks) => "${scope} · ${tasks}";

  static String m41(tasks, coins) => "${tasks} qoldi - ${coins} yoʻlda";

  static String m42(time) => "${time} qoldi";

  static String m43(time) => "${time} ishlatildi";

  static String m44(count) => "yana ${count}";

  static String m45(name) =>
      "${name} telefonida \"Men bolaman\" boʻlimiga kiriting.";

  static String m46(used, limit) => "${used} ishlatildi / ${limit} cheklov";

  static String m47(used) => "${used} · cheklovsiz";

  static String m48(used, limit) => "${limit} dan ${used}";

  static String m49(used, limit) => "${limit} dan ${used} · oshdi";

  static String m50(time) => "Bugun ${time}";

  static String m51(count) =>
      "${Intl.plural(count, other: '${count} ta kutmoqda')}";

  static String m52(name) => "${name} telefoni kutilmoqda…";

  static String m53(name, coins) => "${name} · ${coins}";

  static String m54(age) => "${age} yosh";

  static String m55(count) => "Sizga yana ${count} tanga kerak.";

  static String m56(name) => "${name} (siz)";

  final messages = _notInlinedMessages(_notInlinedMessages);
  static Map<String, Function> _notInlinedMessages(_) => <String, Function>{
    "achievements": MessageLookupByLibrary.simpleMessage("Yutuqlar"),
    "activeTasks": MessageLookupByLibrary.simpleMessage("Faol topshiriqlar"),
    "addAChild": MessageLookupByLibrary.simpleMessage("Farzand qoʻshish"),
    "addAnApp": MessageLookupByLibrary.simpleMessage("Ilova qoʻshish"),
    "addAnotherApp": MessageLookupByLibrary.simpleMessage(
      "Yana ilova qoʻshish",
    ),
    "addAnotherChild": MessageLookupByLibrary.simpleMessage(
      "Yana farzand qoʻshish",
    ),
    "addAppAction": MessageLookupByLibrary.simpleMessage("Qoʻshish"),
    "addChild": MessageLookupByLibrary.simpleMessage("Farzand qoʻshish"),
    "addShort": MessageLookupByLibrary.simpleMessage("Qoʻshish"),
    "addToEveryonesList": MessageLookupByLibrary.simpleMessage(
      "Hammaga qoʻshish",
    ),
    "addToList": m0,
    "admin": MessageLookupByLibrary.simpleMessage("Administrator"),
    "ageAndGender": m1,
    "ageFieldLabel": MessageLookupByLibrary.simpleMessage("Yosh"),
    "ageLabel": m2,
    "ageMustBeInteger": MessageLookupByLibrary.simpleMessage(
      "Yosh butun son boʻlishi kerak.",
    ),
    "ageRange": MessageLookupByLibrary.simpleMessage(
      "Yosh 0 va 18 orasida boʻlishi kerak.",
    ),
    "ageRequired": MessageLookupByLibrary.simpleMessage(
      "Yosh kiritilishi shart.",
    ),
    "allCaughtUp": MessageLookupByLibrary.simpleMessage("Hammasi tekshirildi"),
    "allTasks": MessageLookupByLibrary.simpleMessage("Barcha vazifalar"),
    "almostYours": MessageLookupByLibrary.simpleMessage("Deyarli seniki"),
    "alwaysAllowedNoRedemption": MessageLookupByLibrary.simpleMessage(
      "Doim ochiq · almashtirilmaydi",
    ),
    "appLimits": MessageLookupByLibrary.simpleMessage("Ilova cheklovlari"),
    "appLimitsSubtitle": MessageLookupByLibrary.simpleMessage(
      "Kunlik ekran vaqti cheklovini belgilang",
    ),
    "appName": MessageLookupByLibrary.simpleMessage("SAFINI"),
    "appTimeItem": m3,
    "appTimeTab": MessageLookupByLibrary.simpleMessage("Ilova vaqti"),
    "approve": MessageLookupByLibrary.simpleMessage("Tasdiqlash"),
    "approvePayCoins": m4,
    "approvedTaskConflict": MessageLookupByLibrary.simpleMessage(
      "Tasdiqlangan topshiriqni tahrirlash yoki oʻchirish mumkin emas.",
    ),
    "apps": MessageLookupByLibrary.simpleMessage("Ilovalar"),
    "askForSomethingNew": MessageLookupByLibrary.simpleMessage(
      "Yangi narsa soʻra - ota-onang doʻkonga qoʻshadi.",
    ),
    "askForThis": MessageLookupByLibrary.simpleMessage("Soʻrash"),
    "askToRedo": MessageLookupByLibrary.simpleMessage(
      "Qayta bajarishni soʻrash",
    ),
    "avatarItem": MessageLookupByLibrary.simpleMessage("Avatar buyumi"),
    "avatarItemsTab": MessageLookupByLibrary.simpleMessage("Avatar buyumlari"),
    "badgeCoins": m5,
    "badgeTasksDone": m6,
    "badges": MessageLookupByLibrary.simpleMessage("Nishonlar"),
    "bothParentsSee": MessageLookupByLibrary.simpleMessage(
      "Ikkala ota-ona bir xil vazifalarni koʻradi va tasdiqlay oladi.",
    ),
    "buyIt": MessageLookupByLibrary.simpleMessage("Sotib olamiz! 🎉"),
    "buysLabel": MessageLookupByLibrary.simpleMessage("Beradi"),
    "cancel": MessageLookupByLibrary.simpleMessage("Bekor qilish"),
    "catAll": MessageLookupByLibrary.simpleMessage("Hammasi"),
    "catFitness": MessageLookupByLibrary.simpleMessage("Sport"),
    "catHealth": MessageLookupByLibrary.simpleMessage("Salomatlik"),
    "catHome": MessageLookupByLibrary.simpleMessage("Uy"),
    "catLearn": MessageLookupByLibrary.simpleMessage("Oʻrganish"),
    "catLogic": MessageLookupByLibrary.simpleMessage("Mantiq"),
    "catOutdoor": MessageLookupByLibrary.simpleMessage("Koʻcha"),
    "catSchool": MessageLookupByLibrary.simpleMessage("Maktab"),
    "categoryAll": MessageLookupByLibrary.simpleMessage("Hammasi"),
    "categoryFitness": MessageLookupByLibrary.simpleMessage("Sport"),
    "categoryLearn": MessageLookupByLibrary.simpleMessage("Oʻrganish"),
    "categoryLogic": MessageLookupByLibrary.simpleMessage("Mantiq"),
    "changeAvatar": MessageLookupByLibrary.simpleMessage(
      "Avatarni almashtirish",
    ),
    "changeLanguage": MessageLookupByLibrary.simpleMessage(
      "Tilni oʻzgartirish",
    ),
    "changeOutfit": MessageLookupByLibrary.simpleMessage(
      "Kiyim, soch va boshqalarni oʻzgartir",
    ),
    "childInviteCodeTitle": MessageLookupByLibrary.simpleMessage(
      "Farzand taklif kodi",
    ),
    "childProgressTitle": m7,
    "childTasksSubtitle": m8,
    "childUpdatedSuccess": MessageLookupByLibrary.simpleMessage(
      "Farzand profili yangilandi.",
    ),
    "chooseYourRole": MessageLookupByLibrary.simpleMessage(
      "Rolingizni tanlang",
    ),
    "cleanTheRoom": MessageLookupByLibrary.simpleMessage("Xonani yigʻishtir"),
    "close": MessageLookupByLibrary.simpleMessage("Yopish"),
    "codeCopied": MessageLookupByLibrary.simpleMessage("Kod nusxalandi"),
    "codeIsReady": m9,
    "coinCount": m10,
    "coinCountShort": m11,
    "coins": MessageLookupByLibrary.simpleMessage("Tangalar"),
    "coinsCount": m12,
    "coinsPaidAfterApproval": MessageLookupByLibrary.simpleMessage(
      "Tangalar siz tasdiqlaganingizdan keyingina beriladi. Takrorlanuvchi vazifalar yarim tunda yangilanadi.",
    ),
    "coinsReward": m13,
    "coinsText": MessageLookupByLibrary.simpleMessage("Tangalar"),
    "coinsToGo": m14,
    "coinsToGoShort": m15,
    "comingSoon": MessageLookupByLibrary.simpleMessage("Tez orada!"),
    "completeDailyQuests": MessageLookupByLibrary.simpleMessage(
      "Koʻproq tanga uchun kunlik topshiriqlarni bajar!",
    ),
    "completed": MessageLookupByLibrary.simpleMessage("Bajarilgan"),
    "continueAction": MessageLookupByLibrary.simpleMessage("Davom etish"),
    "copy": MessageLookupByLibrary.simpleMessage("Nusxalash"),
    "copyCode": MessageLookupByLibrary.simpleMessage("Kodni nusxalash"),
    "costsLabel": MessageLookupByLibrary.simpleMessage("Narxi"),
    "createAnInviteCode": MessageLookupByLibrary.simpleMessage(
      "Taklif kodi yaratish",
    ),
    "createChildButton": MessageLookupByLibrary.simpleMessage(
      "Farzand yaratish",
    ),
    "createChildInviteCode": MessageLookupByLibrary.simpleMessage(
      "Farzand taklif kodini yaratish",
    ),
    "createChildProfileSubtitle": MessageLookupByLibrary.simpleMessage(
      "Oilangizga farzand qoʻshish uchun quyidagi maʼlumotlarni toʻldiring.",
    ),
    "createChildProfileTitle": MessageLookupByLibrary.simpleMessage(
      "Farzand profilini yaratish",
    ),
    "createFamilyAction": MessageLookupByLibrary.simpleMessage("Oila yaratish"),
    "createFamilySubtitle": MessageLookupByLibrary.simpleMessage(
      "Oila makonini yarating va boshqalarni taklif qiling",
    ),
    "createOrJoinFamily": MessageLookupByLibrary.simpleMessage(
      "Oila yarating yoki taklif kodi bilan qoʻshiling.",
    ),
    "createParentInviteCode": MessageLookupByLibrary.simpleMessage(
      "Ota-ona taklif kodini yaratish",
    ),
    "createTaskAddButton": MessageLookupByLibrary.simpleMessage(
      "Topshiriq qoʻshish",
    ),
    "createTaskCategoryDailyChore": MessageLookupByLibrary.simpleMessage(
      "Kundalik ish",
    ),
    "createTaskCategoryEducational": MessageLookupByLibrary.simpleMessage(
      "Taʼlimiy",
    ),
    "createTaskCategoryHobby": MessageLookupByLibrary.simpleMessage(
      "Mashgʻulot",
    ),
    "createTaskCategoryOther": MessageLookupByLibrary.simpleMessage("Boshqa"),
    "createTaskCategoryTitle": MessageLookupByLibrary.simpleMessage("Turkum"),
    "createTaskNameHint": MessageLookupByLibrary.simpleMessage(
      "masalan, Xonangni yigʻishtir",
    ),
    "createTaskNameLabel": MessageLookupByLibrary.simpleMessage(
      "Topshiriq nomi",
    ),
    "createTaskPickEmojiLabel": MessageLookupByLibrary.simpleMessage(
      "Emoji tanlang",
    ),
    "createTaskRewardLabel": MessageLookupByLibrary.simpleMessage(
      "Mukofot (Vaqt tangalari)",
    ),
    "createTaskSaveButton": MessageLookupByLibrary.simpleMessage("Saqlash"),
    "createTaskSheetTitle": MessageLookupByLibrary.simpleMessage(
      "Yangi topshiriq",
    ),
    "customizeAvatar": MessageLookupByLibrary.simpleMessage("Avatarni sozlash"),
    "dailyAllowanceFor": m16,
    "dailyChore": MessageLookupByLibrary.simpleMessage("Kundalik ish"),
    "dailyLimit": MessageLookupByLibrary.simpleMessage("Kunlik cheklov"),
    "dayStreak": MessageLookupByLibrary.simpleMessage("Kunlik seriya"),
    "deleteAccount": MessageLookupByLibrary.simpleMessage("Hisobni oʻchirish"),
    "deleteAccountConfirmBody": MessageLookupByLibrary.simpleMessage(
      "Hisobingizni oʻchirmoqchimisiz? Bu amalni ortga qaytarib boʻlmaydi.",
    ),
    "deleteAccountConfirmTitle": MessageLookupByLibrary.simpleMessage(
      "Hisob oʻchirilsinmi?",
    ),
    "deleteTaskBody": MessageLookupByLibrary.simpleMessage(
      "Buni ortga qaytarib boʻlmaydi.",
    ),
    "deleteTaskButton": MessageLookupByLibrary.simpleMessage("Oʻchirish"),
    "deleteTaskTitle": MessageLookupByLibrary.simpleMessage(
      "Topshiriq oʻchirilsinmi?",
    ),
    "detailsFieldLabel": MessageLookupByLibrary.simpleMessage("Tafsilotlar"),
    "detailsSection": MessageLookupByLibrary.simpleMessage("Maʼlumotlar"),
    "doHomework": MessageLookupByLibrary.simpleMessage("Uy vazifasini bajar"),
    "doThisNext": MessageLookupByLibrary.simpleMessage("Keyingisi"),
    "doneAction": MessageLookupByLibrary.simpleMessage("Tayyor"),
    "doneToday": MessageLookupByLibrary.simpleMessage("Bugun bajarildi"),
    "earnMoreCoins": MessageLookupByLibrary.simpleMessage(
      "Koʻproq tanga ishlab top",
    ),
    "earnedToday": MessageLookupByLibrary.simpleMessage("Bugun ishlab topildi"),
    "edit": MessageLookupByLibrary.simpleMessage("Tahrirlash"),
    "editChild": MessageLookupByLibrary.simpleMessage("Farzandni tahrirlash"),
    "editMyProfile": MessageLookupByLibrary.simpleMessage(
      "Profilimni tahrirlash",
    ),
    "editName": m17,
    "editProfile": MessageLookupByLibrary.simpleMessage("Profilni tahrirlash"),
    "editProfileSubtitle": MessageLookupByLibrary.simpleMessage(
      "Farzandingiz maʼlumotlarini yangilang.",
    ),
    "editTaskSheetTitle": MessageLookupByLibrary.simpleMessage(
      "Topshiriqni tahrirlash",
    ),
    "educational": MessageLookupByLibrary.simpleMessage("Taʼlimiy"),
    "emailHint": MessageLookupByLibrary.simpleMessage("tekshiruvchi@misol.uz"),
    "emailLabel": MessageLookupByLibrary.simpleMessage("Elektron pochta"),
    "emailRequired": MessageLookupByLibrary.simpleMessage(
      "Toʻgʻri email kiriting",
    ),
    "emailSignInDescription": MessageLookupByLibrary.simpleMessage(
      "Faqat test va App Review tekshiruvi uchun.",
    ),
    "emailSignInTitle": MessageLookupByLibrary.simpleMessage(
      "Test hisobiga kirish",
    ),
    "emptyActiveBody": MessageLookupByLibrary.simpleMessage(
      "Quyidagi tugma bilan qoʻshing.",
    ),
    "emptyDoneBody": MessageLookupByLibrary.simpleMessage(
      "Tasdiqlangan vazifalar shu yerda chiqadi.",
    ),
    "emptyNoActiveTasks": MessageLookupByLibrary.simpleMessage(
      "Faol vazifa yoʻq",
    ),
    "emptyNothingPaidYet": MessageLookupByLibrary.simpleMessage(
      "Hali hech narsa toʻlanmadi",
    ),
    "emptyNothingToReview": MessageLookupByLibrary.simpleMessage(
      "Tekshiradigan narsa yoʻq",
    ),
    "emptyReviewBody": MessageLookupByLibrary.simpleMessage(
      "Yangi topshiriqlar shu yerda chiqadi.",
    ),
    "english": MessageLookupByLibrary.simpleMessage("Ingliz"),
    "equipped": MessageLookupByLibrary.simpleMessage("KIYILGAN"),
    "everyAppSetUp": MessageLookupByLibrary.simpleMessage(
      "Barcha ilovalar sozlangan",
    ),
    "everythingIsWithParent": MessageLookupByLibrary.simpleMessage(
      "Hammasi ota-onangda",
    ),
    "everythingSent": MessageLookupByLibrary.simpleMessage("Hammasi yuborildi"),
    "expiresLabel": m18,
    "extraBackpack": MessageLookupByLibrary.simpleMessage("Ryukzak"),
    "extraHair": MessageLookupByLibrary.simpleMessage("Soch"),
    "extraOutfit": MessageLookupByLibrary.simpleMessage("Kiyim"),
    "extrasFootnote": MessageLookupByLibrary.simpleMessage(
      "Qoʻshimchalar bir marta sotib olinadi. Vazifalarga taʼsir qilmaydi.",
    ),
    "extrasSection": MessageLookupByLibrary.simpleMessage("Qoʻshimchalar"),
    "faceSection": MessageLookupByLibrary.simpleMessage("Yuz"),
    "family": MessageLookupByLibrary.simpleMessage("Oila"),
    "familyAdmin": MessageLookupByLibrary.simpleMessage("Oila administratori"),
    "familyDecisionSubtitle": MessageLookupByLibrary.simpleMessage(
      "Oilaviy makon yarating va farzandlaringizni ekran vaqtini ishlab topishga taklif qiling.",
    ),
    "familyLabel": MessageLookupByLibrary.simpleMessage("Oila"),
    "footerText": MessageLookupByLibrary.simpleMessage(
      "Aqlli bolalar uchun xavfsiz ekran vaqti 🌟",
    ),
    "free": MessageLookupByLibrary.simpleMessage("BEPUL"),
    "fri": MessageLookupByLibrary.simpleMessage("JUM"),
    "genderBoy": MessageLookupByLibrary.simpleMessage("Oʻgʻil bola"),
    "genderGirl": MessageLookupByLibrary.simpleMessage("Qiz bola"),
    "genderOptional": MessageLookupByLibrary.simpleMessage("Jins (ixtiyoriy)"),
    "genderOther": MessageLookupByLibrary.simpleMessage("Boshqa"),
    "goToMyFamily": MessageLookupByLibrary.simpleMessage("Oilamga oʻtish"),
    "goToTasks": MessageLookupByLibrary.simpleMessage("Topshiriqlarga oʻtish"),
    "goodAfternoon": MessageLookupByLibrary.simpleMessage("Xayrli kun 👋"),
    "goodEvening": MessageLookupByLibrary.simpleMessage("Xayrli kech 👋"),
    "goodMorning": MessageLookupByLibrary.simpleMessage("Xayrli tong 👋"),
    "goodNight": MessageLookupByLibrary.simpleMessage("Xayrli tun 🌙"),
    "googleClientIdMissing": MessageLookupByLibrary.simpleMessage(
      "Google Web Client ID topilmadi. GOOGLE_WEB_CLIENT_ID ni belgilang (Google Cloud OAuth Web mijozi).",
    ),
    "holdToMarkDone": MessageLookupByLibrary.simpleMessage(
      "Bajarildi deb belgilash uchun ushlab turing",
    ),
    "home": MessageLookupByLibrary.simpleMessage("Bosh sahifa"),
    "iconSection": MessageLookupByLibrary.simpleMessage("Belgi"),
    "imAKid": MessageLookupByLibrary.simpleMessage("Men bolaman!"),
    "imAParent": MessageLookupByLibrary.simpleMessage("Men ota-onaman"),
    "inTheFamilySince": MessageLookupByLibrary.simpleMessage("Oilada"),
    "inviteAParent": MessageLookupByLibrary.simpleMessage(
      "Ota-onani taklif qilish",
    ),
    "inviteAParentBody": MessageLookupByLibrary.simpleMessage(
      "Safini oʻrnatib, kirsin va shu kodni kiritsin.",
    ),
    "inviteChildOrRefresh": MessageLookupByLibrary.simpleMessage(
      "Farzandni taklif qiling yoki oila aʼzosi ulangach yangilang.",
    ),
    "inviteCodeCopied": MessageLookupByLibrary.simpleMessage(
      "Taklif kodi nusxalandi",
    ),
    "inviteCodeValid": MessageLookupByLibrary.simpleMessage(
      "Taklif kodi · 24 soat",
    ),
    "invited": MessageLookupByLibrary.simpleMessage("Taklif"),
    "joinFamilyAction": MessageLookupByLibrary.simpleMessage(
      "Kod bilan qoʻshilish",
    ),
    "joinFamilySubtitle": MessageLookupByLibrary.simpleMessage(
      "Ikkinchi ota-onaning kodidan foydalaning",
    ),
    "keepHolding": MessageLookupByLibrary.simpleMessage("Ushlab turing…"),
    "kidHasLeftToday": m19,
    "kidSubtitle": MessageLookupByLibrary.simpleMessage(
      "Tanga ishlab top va oʻyna",
    ),
    "kidUsedToday": m20,
    "kidsApps": m21,
    "kidsEarnTimeCoins": MessageLookupByLibrary.simpleMessage(
      "Bolalar bu ilovalarda qoʻshimcha daqiqalar ochish uchun Vaqt tangalarini ishlab topadi.",
    ),
    "laneActive": MessageLookupByLibrary.simpleMessage("Faol"),
    "laneDone": MessageLookupByLibrary.simpleMessage("Bajarilgan"),
    "laneToReview": MessageLookupByLibrary.simpleMessage("Tekshirish"),
    "lessons": MessageLookupByLibrary.simpleMessage("Darslar"),
    "lessonsChangeText": MessageLookupByLibrary.simpleMessage("bugun +1"),
    "levelHero": m22,
    "levelShort": MessageLookupByLibrary.simpleMessage("Daraja"),
    "levelValue": m23,
    "limitThisApp": MessageLookupByLibrary.simpleMessage("Ilovani cheklash"),
    "limitsFootnote": MessageLookupByLibrary.simpleMessage(
      "Bloklangan ilova bosh ekrandan yoʻqoladi. Cheklovsiz ilovalar doim ochiq.",
    ),
    "limitsSubtitle": m24,
    "lockedLabel": MessageLookupByLibrary.simpleMessage("Yopiq"),
    "loginBack": MessageLookupByLibrary.simpleMessage("Orqaga"),
    "loginSubtitle": MessageLookupByLibrary.simpleMessage(
      "Google hisobingiz bilan davom eting",
    ),
    "loginTitle": MessageLookupByLibrary.simpleMessage("Kirish"),
    "loginWithEmailTest": MessageLookupByLibrary.simpleMessage(
      "Email orqali kirish (test)",
    ),
    "loginWithGoogle": MessageLookupByLibrary.simpleMessage(
      "Google bilan davom etish",
    ),
    "logout": MessageLookupByLibrary.simpleMessage("Chiqish"),
    "logoutConfirmBody": MessageLookupByLibrary.simpleMessage(
      "Hisobdan chiqmoqchimisiz?",
    ),
    "logoutConfirmTitle": MessageLookupByLibrary.simpleMessage("Chiqilsinmi?"),
    "lookCloser": MessageLookupByLibrary.simpleMessage("Batafsil"),
    "manageAll": MessageLookupByLibrary.simpleMessage("Barchasini boshqarish"),
    "markItDone": MessageLookupByLibrary.simpleMessage(
      "Bajarildi deb belgilash",
    ),
    "minuteCount": m25,
    "minutes": MessageLookupByLibrary.simpleMessage("Daqiqalar"),
    "minutesLeftShort": m26,
    "minutesRemainingLong": m27,
    "mon": MessageLookupByLibrary.simpleMessage("DUS"),
    "monitor": MessageLookupByLibrary.simpleMessage("Kuzatuv"),
    "moreCoinsNeeded": m28,
    "mostOfItIn": m29,
    "myAvatar": MessageLookupByLibrary.simpleMessage("Mening avatarim"),
    "myFamily": MessageLookupByLibrary.simpleMessage("Mening oilam"),
    "myProfile": MessageLookupByLibrary.simpleMessage("Mening profilim"),
    "myQuests": MessageLookupByLibrary.simpleMessage("Mening topshiriqlarim"),
    "nDayStreak": m30,
    "name": MessageLookupByLibrary.simpleMessage("Ism"),
    "nameHintExample": MessageLookupByLibrary.simpleMessage("Amir"),
    "nameYourFamily": MessageLookupByLibrary.simpleMessage(
      "Butun oila taniydigan nom bering. Yaratgandan keyin odamlarni taklif qilasiz.",
    ),
    "needsPhotoProof": MessageLookupByLibrary.simpleMessage("Foto kerak"),
    "needsYourReview": MessageLookupByLibrary.simpleMessage("Tekshirish kerak"),
    "networkError": MessageLookupByLibrary.simpleMessage(
      "Tarmoq xatosi. Ulanishni tekshiring.",
    ),
    "newBtn": MessageLookupByLibrary.simpleMessage("Yangi"),
    "newSubmissionsLandHere": MessageLookupByLibrary.simpleMessage(
      "Yangi topshiriqlar shu yerda chiqadi.",
    ),
    "newTask": MessageLookupByLibrary.simpleMessage("Yangi topshiriq"),
    "nicknameLabel": MessageLookupByLibrary.simpleMessage("Taxallus"),
    "nicknameRequired": MessageLookupByLibrary.simpleMessage(
      "Taxallus kiritilishi shart.",
    ),
    "nicknameTooLong": MessageLookupByLibrary.simpleMessage(
      "Taxallus 80 belgidan oshmasligi kerak.",
    ),
    "noChildYetBody": MessageLookupByLibrary.simpleMessage(
      "Farzand qoʻshing - uning kuni shu yerda chiqadi.",
    ),
    "noChildrenFoundYet": MessageLookupByLibrary.simpleMessage(
      "Hali farzand topilmadi",
    ),
    "noChildrenYet": MessageLookupByLibrary.simpleMessage("Hali farzand yoʻq"),
    "noChildrenYetBody": MessageLookupByLibrary.simpleMessage(
      "Farzand qoʻshing - unga ulanish kodi beriladi.",
    ),
    "noCodeAskParent": MessageLookupByLibrary.simpleMessage(
      "Kod yoʻqmi? Ota-onangizdan Safini va \"Mening oilam\" boʻlimini ochishni soʻrang.",
    ),
    "noCodeAskThem": MessageLookupByLibrary.simpleMessage(
      "Kod yoʻqmi? Ulardan Safini va \"Mening oilam\" boʻlimini ochishni soʻrang.",
    ),
    "noFamilySetupYet": MessageLookupByLibrary.simpleMessage(
      "Hali oila sozlanmagan",
    ),
    "noLimitLabel": MessageLookupByLibrary.simpleMessage("Cheklovsiz"),
    "noLimitsSet": MessageLookupByLibrary.simpleMessage("Cheklov qoʻyilmagan"),
    "noQuestsInCategory": MessageLookupByLibrary.simpleMessage(
      "Bu turkumda topshiriq yoʻq",
    ),
    "noTasksYet": MessageLookupByLibrary.simpleMessage(
      "Bu kun uchun topshiriq yoʻq.",
    ),
    "notEnoughCoins": MessageLookupByLibrary.simpleMessage(
      "Tanga yetarli emas!",
    ),
    "notPairedYet": MessageLookupByLibrary.simpleMessage("Hali ulanmagan"),
    "notRecorded": MessageLookupByLibrary.simpleMessage("Koʻrsatilmagan"),
    "notSet": MessageLookupByLibrary.simpleMessage("Koʻrsatilmagan"),
    "notYet": MessageLookupByLibrary.simpleMessage("Hozir emas"),
    "noteForParent": MessageLookupByLibrary.simpleMessage(
      "Ota-onaga izoh · ixtiyoriy",
    ),
    "noteFromParent": MessageLookupByLibrary.simpleMessage("Ota-onadan izoh"),
    "nothingHereYet": MessageLookupByLibrary.simpleMessage("Hozircha boʻsh"),
    "nothingInStore": MessageLookupByLibrary.simpleMessage(
      "Doʻkon hozircha boʻsh.",
    ),
    "nothingLeft": MessageLookupByLibrary.simpleMessage("Hech narsa qolmadi"),
    "ofTotal": m31,
    "offMeansAlwaysAllowed": MessageLookupByLibrary.simpleMessage(
      "Oʻchiq boʻlsa - doim ochiq",
    ),
    "ok": MessageLookupByLibrary.simpleMessage("OK"),
    "on": MessageLookupByLibrary.simpleMessage("YOQILGAN"),
    "openOneFromList": MessageLookupByLibrary.simpleMessage(
      "Cheklovni oʻzgartirish uchun roʻyxatdan ilovani oching.",
    ),
    "outfitsAndItems": MessageLookupByLibrary.simpleMessage(
      "Kiyim va buyumlar",
    ),
    "paidOutNice": MessageLookupByLibrary.simpleMessage("Toʻlandi. Zoʻr."),
    "pairStepAllow": MessageLookupByLibrary.simpleMessage(
      "Soʻralganda ekran vaqtiga ruxsat bering",
    ),
    "pairStepInstall": m32,
    "pairStepTap": MessageLookupByLibrary.simpleMessage(
      "\"Men bolaman\" ni bosib, kodni kiriting",
    ),
    "paired": MessageLookupByLibrary.simpleMessage("Ulangan"),
    "pairingCodeCaption": MessageLookupByLibrary.simpleMessage("Ulanish kodi"),
    "parentAccount": MessageLookupByLibrary.simpleMessage("OTA-ONA HISOBI"),
    "parentHomeScreen": MessageLookupByLibrary.simpleMessage(
      "Ota-ona bosh sahifasi",
    ),
    "parentInviteCodeTitle": MessageLookupByLibrary.simpleMessage(
      "Ota-ona taklif kodi",
    ),
    "parentName": MessageLookupByLibrary.simpleMessage("Safini ota-onasi"),
    "parentReviewsNext": MessageLookupByLibrary.simpleMessage(
      "Ota-onang keyin tekshiradi. Tangalar shundan keyin keladi.",
    ),
    "parentSubtitle": MessageLookupByLibrary.simpleMessage(
      "Kuzat va ragʻbatlantir",
    ),
    "parents": MessageLookupByLibrary.simpleMessage("Ota-onalar"),
    "passwordHint": MessageLookupByLibrary.simpleMessage("Parolni kiriting"),
    "passwordLabel": MessageLookupByLibrary.simpleMessage("Parol"),
    "passwordRequired": MessageLookupByLibrary.simpleMessage(
      "Parolni kiriting",
    ),
    "pendingApproval": MessageLookupByLibrary.simpleMessage(
      "Tasdiqlash kutilmoqda",
    ),
    "percentToNextLevel": m33,
    "photoProofAsked": MessageLookupByLibrary.simpleMessage(
      "Foto tasdiq soʻralgan",
    ),
    "pillCheck": MessageLookupByLibrary.simpleMessage("Tekshir"),
    "pillPaid": MessageLookupByLibrary.simpleMessage("Toʻlangan"),
    "pillWaiting": MessageLookupByLibrary.simpleMessage("Kutmoqda"),
    "profile": MessageLookupByLibrary.simpleMessage("Profil"),
    "profileUpdated": MessageLookupByLibrary.simpleMessage("Saqlandi"),
    "questsDone": MessageLookupByLibrary.simpleMessage(
      "Bajarilgan topshiriqlar",
    ),
    "questsText": MessageLookupByLibrary.simpleMessage("Topshiriqlar"),
    "readFor20Mins": MessageLookupByLibrary.simpleMessage(
      "20 daqiqa kitob oʻqi",
    ),
    "readyToSpend": MessageLookupByLibrary.simpleMessage(
      "Tangalaringni sarflashga tayyormisan?",
    ),
    "readyWhenYouAre": MessageLookupByLibrary.simpleMessage(
      "Tayyor boʻlsang, boshla",
    ),
    "realWorldTasks": MessageLookupByLibrary.simpleMessage(
      "Hayotiy topshiriqlar",
    ),
    "reconnectCodeValid": MessageLookupByLibrary.simpleMessage(
      "Qayta ulanish kodi · 24 soat",
    ),
    "reconnectWithCode": MessageLookupByLibrary.simpleMessage(
      "Kod bilan qayta ulash",
    ),
    "redeemExplainer": m34,
    "reject": MessageLookupByLibrary.simpleMessage("Rad etish"),
    "remaining": MessageLookupByLibrary.simpleMessage("Qoldi"),
    "remainingTime": m35,
    "removeFromFamily": MessageLookupByLibrary.simpleMessage(
      "Oiladan chiqarish",
    ),
    "removeParent": MessageLookupByLibrary.simpleMessage("Oiladan chiqarish"),
    "removeParentConfirmBody": MessageLookupByLibrary.simpleMessage(
      "Bu ota-onani oiladan chiqarmoqchimisiz?",
    ),
    "removeParentConfirmTitle": MessageLookupByLibrary.simpleMessage(
      "Ota-ona chiqarilsinmi?",
    ),
    "retry": MessageLookupByLibrary.simpleMessage("Qayta urinish"),
    "reviewNoteHint": MessageLookupByLibrary.simpleMessage(
      "Izoh qoʻshing (ixtiyoriy)",
    ),
    "reviewTaskSheetTitle": MessageLookupByLibrary.simpleMessage(
      "Topshiriqni tekshirish",
    ),
    "rewardBlurbAppTime": MessageLookupByLibrary.simpleMessage(
      "Ota-onang tasdiqlagach, faqat bugunga qoʻshiladi.",
    ),
    "rewardBlurbAvatar": MessageLookupByLibrary.simpleMessage(
      "Avataringga kiy. Sende qoladi.",
    ),
    "rewardFieldLabel": MessageLookupByLibrary.simpleMessage("Mukofot"),
    "rewardStore": MessageLookupByLibrary.simpleMessage("Mukofot doʻkoni"),
    "roleLabel": MessageLookupByLibrary.simpleMessage("Rol"),
    "roleOwner": MessageLookupByLibrary.simpleMessage("Egasi"),
    "roleParent": MessageLookupByLibrary.simpleMessage("Ota-ona"),
    "roleSelectionSubtitle": MessageLookupByLibrary.simpleMessage(
      "Safini bilan qanday ishlaysiz?",
    ),
    "russian": MessageLookupByLibrary.simpleMessage("Rus"),
    "sat": MessageLookupByLibrary.simpleMessage("SHA"),
    "save": MessageLookupByLibrary.simpleMessage("Saqlash"),
    "saveChanges": MessageLookupByLibrary.simpleMessage(
      "Oʻzgarishlarni saqlash",
    ),
    "saveForName": m36,
    "saveMyLook": MessageLookupByLibrary.simpleMessage("Koʻrinishimni saqla!"),
    "savedForName": m37,
    "scopeEveryone": MessageLookupByLibrary.simpleMessage("Hammasi"),
    "screenTime": MessageLookupByLibrary.simpleMessage("Ekran vaqti"),
    "sectionAccount": MessageLookupByLibrary.simpleMessage("Hisob"),
    "sectionApp": MessageLookupByLibrary.simpleMessage("Ilova"),
    "selectLanguage": MessageLookupByLibrary.simpleMessage("Tilni tanlang"),
    "setUpANewProfile": MessageLookupByLibrary.simpleMessage(
      "Yangi profil yaratish",
    ),
    "settings": MessageLookupByLibrary.simpleMessage("Sozlamalar"),
    "setupYourFamily": MessageLookupByLibrary.simpleMessage(
      "Oilangizni sozlang",
    ),
    "signInAction": MessageLookupByLibrary.simpleMessage("Kirish"),
    "signInError": MessageLookupByLibrary.simpleMessage(
      "Kirishda xatolik. Qaytadan urinib koʻring.",
    ),
    "signedInSuccess": MessageLookupByLibrary.simpleMessage(
      "Muvaffaqiyatli kirdingiz",
    ),
    "signingIn": MessageLookupByLibrary.simpleMessage("Kirilmoqda..."),
    "spendYourTimeCoins": MessageLookupByLibrary.simpleMessage(
      "Vaqt tangalaringni sarfla",
    ),
    "statCoins": MessageLookupByLibrary.simpleMessage("Tanga"),
    "statDayStreak": MessageLookupByLibrary.simpleMessage("Kun ketma-ket"),
    "statTasksDone": MessageLookupByLibrary.simpleMessage("Vazifalar"),
    "statusActive": MessageLookupByLibrary.simpleMessage("FAOL"),
    "statusDone": MessageLookupByLibrary.simpleMessage("BAJARILDI"),
    "statusPending": MessageLookupByLibrary.simpleMessage("KUTILMOQDA"),
    "step1of2": MessageLookupByLibrary.simpleMessage(
      "2 bosqichdan 1-si - boshqa farzandlarni keyin qoʻshasiz.",
    ),
    "step2of2": MessageLookupByLibrary.simpleMessage(
      "2 bosqichdan 2-si - kod 24 soat amal qiladi.",
    ),
    "steps": MessageLookupByLibrary.simpleMessage("Qadamlar"),
    "stepsChangeText": MessageLookupByLibrary.simpleMessage(
      "kechagiga nisbatan +12%",
    ),
    "stepsToday": MessageLookupByLibrary.simpleMessage("Bugungi qadamlar"),
    "store": MessageLookupByLibrary.simpleMessage("Doʻkon"),
    "storeAppTimeTab": MessageLookupByLibrary.simpleMessage("Ilova vaqti"),
    "storeAvatarTab": MessageLookupByLibrary.simpleMessage("Avatar"),
    "storeSubtitle": MessageLookupByLibrary.simpleMessage(
      "Ota-onang tasdiqlagach seniki boʻladi",
    ),
    "streakText": MessageLookupByLibrary.simpleMessage("Seriya"),
    "sun": MessageLookupByLibrary.simpleMessage("YAK"),
    "supabaseConfigMissing": MessageLookupByLibrary.simpleMessage(
      "Supabase URL yoki anon kalit topilmadi. Ilovani ishga tushirishda SUPABASE_URL va SUPABASE_ANON_KEY ni belgilang.",
    ),
    "surname": MessageLookupByLibrary.simpleMessage("Familiya"),
    "switchToKidMode": MessageLookupByLibrary.simpleMessage(
      "Bola rejimiga oʻtish / Chiqish",
    ),
    "tabFamily": MessageLookupByLibrary.simpleMessage("Oila"),
    "tabLimits": MessageLookupByLibrary.simpleMessage("Cheklovlar"),
    "tabMe": MessageLookupByLibrary.simpleMessage("Men"),
    "tabStore": MessageLookupByLibrary.simpleMessage("Doʻkon"),
    "tabTasks": MessageLookupByLibrary.simpleMessage("Vazifalar"),
    "tabToday": MessageLookupByLibrary.simpleMessage("Bugun"),
    "tagline": MessageLookupByLibrary.simpleMessage(
      "Oʻrgan. Ishlab top. Oʻyna.",
    ),
    "taskApprovedMessage": MessageLookupByLibrary.simpleMessage(
      "Topshiriq tasdiqlandi!",
    ),
    "taskChessSub": MessageLookupByLibrary.simpleMessage("Taxtani egalla"),
    "taskChessTitle": MessageLookupByLibrary.simpleMessage("Shaxmat darsi"),
    "taskCount": m38,
    "taskCreatedMessage": MessageLookupByLibrary.simpleMessage(
      "Topshiriq yaratildi!",
    ),
    "taskDeletedMessage": MessageLookupByLibrary.simpleMessage(
      "Topshiriq oʻchirildi.",
    ),
    "taskDetailsHint": MessageLookupByLibrary.simpleMessage(
      "Nima bajarilgan hisoblanadi? Ixtiyoriy.",
    ),
    "taskDuolingoSub": MessageLookupByLibrary.simpleMessage(
      "Kunlik seriya bonusi!",
    ),
    "taskDuolingoTitle": MessageLookupByLibrary.simpleMessage(
      "Duolingo darsini tugat",
    ),
    "taskFieldLabel": MessageLookupByLibrary.simpleMessage("Vazifa"),
    "taskGroupSummary": m39,
    "taskPuzzleSub": MessageLookupByLibrary.simpleMessage("Miya uchun mashq"),
    "taskPuzzleTitle": MessageLookupByLibrary.simpleMessage("Mantiqiy jumboq"),
    "taskReadingSub": MessageLookupByLibrary.simpleMessage(
      "Bilimingni kengaytir",
    ),
    "taskReadingTitle": MessageLookupByLibrary.simpleMessage(
      "20 daqiqa kitob oʻqi",
    ),
    "taskRejectedMessage": MessageLookupByLibrary.simpleMessage(
      "Topshiriq rad etildi.",
    ),
    "taskRoomSub": MessageLookupByLibrary.simpleMessage("Kundalik ish"),
    "taskRoomTitle": MessageLookupByLibrary.simpleMessage(
      "Xonangni yigʻishtir",
    ),
    "taskScopeLine": m40,
    "taskStepsSub": MessageLookupByLibrary.simpleMessage("Harakatda boʻl!"),
    "taskStepsTitle": MessageLookupByLibrary.simpleMessage("5 000 qadam yur"),
    "taskSubmittedForReview": MessageLookupByLibrary.simpleMessage(
      "Ota-onangga yuborildi",
    ),
    "taskTitleHint": MessageLookupByLibrary.simpleMessage("Gullarni sugʻorish"),
    "taskUpdatedMessage": MessageLookupByLibrary.simpleMessage(
      "Topshiriq yangilandi!",
    ),
    "tasks": MessageLookupByLibrary.simpleMessage("Topshiriqlar"),
    "tasksAndRewards": MessageLookupByLibrary.simpleMessage(
      "Topshiriqlar va mukofotlar",
    ),
    "tasksLeftCoinsOnTable": m41,
    "theirNote": MessageLookupByLibrary.simpleMessage("Uning izohi"),
    "theyInstallSafini": MessageLookupByLibrary.simpleMessage(
      "Safini oʻrnatib, kirsin va shu kodni kiritsin.",
    ),
    "thisWeek": MessageLookupByLibrary.simpleMessage("Bu hafta"),
    "thu": MessageLookupByLibrary.simpleMessage("PAY"),
    "timeCoins": MessageLookupByLibrary.simpleMessage("Vaqt tangalari"),
    "timeLeft": m42,
    "timeUsed": m43,
    "tip1": MessageLookupByLibrary.simpleMessage(
      "Masʼuliyatni oʻrgatadigan mazmunli topshiriqlar bering",
    ),
    "tip2": MessageLookupByLibrary.simpleMessage(
      "Ekran vaqti mukofotini ochiq havodagi mashgʻulotlar bilan muvozanatlang",
    ),
    "tip3": MessageLookupByLibrary.simpleMessage(
      "Farzandingiz yutuqlarini nishonlang",
    ),
    "tip4": MessageLookupByLibrary.simpleMessage(
      "Tanga qiymatini sarflangan mehnatga moslang",
    ),
    "tipsForParents": MessageLookupByLibrary.simpleMessage(
      "Ota-onalar uchun maslahatlar",
    ),
    "toGo": m44,
    "todaysQuests": MessageLookupByLibrary.simpleMessage(
      "Bugungi topshiriqlar",
    ),
    "tryAgain": MessageLookupByLibrary.simpleMessage("Qayta urinish"),
    "tue": MessageLookupByLibrary.simpleMessage("SES"),
    "typeCodeFromOtherParent": MessageLookupByLibrary.simpleMessage(
      "Ikkinchi ota-ona bergan kodni kiriting",
    ),
    "typeCodeFromParent": MessageLookupByLibrary.simpleMessage(
      "Ota-onangiz bergan kodni kiriting",
    ),
    "typeItOnPhone": m45,
    "unitHour": MessageLookupByLibrary.simpleMessage("s"),
    "unitMinute": MessageLookupByLibrary.simpleMessage("d"),
    "unlockExtraTime": MessageLookupByLibrary.simpleMessage(
      "Qoʻshimcha vaqt ochish",
    ),
    "unlockOnceKeepForever": MessageLookupByLibrary.simpleMessage(
      "Bir marta och - abadiy qoladi",
    ),
    "unlocked": MessageLookupByLibrary.simpleMessage("ochilgan"),
    "usedLimit": m46,
    "usedNoLimit": m47,
    "usedOfLimit": m48,
    "usedOfLimitOver": m49,
    "usedTodayShort": m50,
    "uzbek": MessageLookupByLibrary.simpleMessage("Oʻzbek"),
    "viewAsKid": MessageLookupByLibrary.simpleMessage("Bola sifatida koʻrish"),
    "waitingCount": m51,
    "waitingForParentCheck": MessageLookupByLibrary.simpleMessage(
      "Ota-ona tekshirishini kutmoqdamiz",
    ),
    "waitingForPhone": m52,
    "wearLabel": MessageLookupByLibrary.simpleMessage("Kiyish"),
    "wed": MessageLookupByLibrary.simpleMessage("CHOR"),
    "weeklyScreenTime": MessageLookupByLibrary.simpleMessage(
      "Haftalik ekran vaqti",
    ),
    "whereTheTimeWent": MessageLookupByLibrary.simpleMessage(
      "Vaqt qayerga ketdi",
    ),
    "whoAreWeSettingUp": MessageLookupByLibrary.simpleMessage(
      "Kimni sozlaymiz?",
    ),
    "whoSection": MessageLookupByLibrary.simpleMessage("Kimga"),
    "wornLabel": MessageLookupByLibrary.simpleMessage("Kiyilgan"),
    "worthCoins": m53,
    "yearsOld": m54,
    "youNeedMoreCoins": m55,
    "youSuffix": m56,
    "yourAccount": MessageLookupByLibrary.simpleMessage("Hisobingiz"),
    "yourAvatar": MessageLookupByLibrary.simpleMessage("Avataring"),
    "yourChildren": MessageLookupByLibrary.simpleMessage("FARZANDLARINGIZ"),
    "yourName": MessageLookupByLibrary.simpleMessage("Ismingiz"),
    "yoursLabel": MessageLookupByLibrary.simpleMessage("Seniki"),
  };
}
