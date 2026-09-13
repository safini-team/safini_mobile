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

  static String m4(minutes) => "${minutes} daqiqa";

  static String m5(coins) => "Tasdiqlash · ${coins} berish";

  static String m6(count) => "${Intl.plural(count, other: '${count} tanga')}";

  static String m7(count) => "${Intl.plural(count, other: '${count} vazifa')}";

  static String m8(name) => "${name} taraqqiyoti";

  static String m9(done, total, coins) =>
      "Bugun ${total} dan ${done} · ${coins} tanga kutmoqda";

  static String m10(name) => "${name} uchun kod tayyor";

  static String m11(count) =>
      "${Intl.plural(count, one: '${count} tanga', other: '${count} tanga')}";

  static String m12(count) => "${Intl.plural(count, other: '${count} tanga')}";

  static String m13(count) => "${Intl.plural(count, other: '${count} tanga')}";

  static String m14(count) =>
      "${Intl.plural(count, one: '${count} tanga mukofot', other: '${count} tanga mukofot')}";

  static String m15(name) => "${name} · barcha ilovalar birgalikda";

  static String m16(name) => "${name}ni tahrirlash";

  static String m17(date, time) => "Amal qiladi: ${date}, ${time}";

  static String m18(name) => "${name} cheklansinmi?";

  static String m19(name) => "${name} bloklandi";

  static String m20(count) =>
      "${Intl.plural(count, zero: 'Ilovalar yoʻq', one: '1 ta ilova', other: '${count} ta ilova')}";

  static String m21(name) =>
      "${name} oʻz telefonida Safini’ni ochganda, oʻrnatilgan ilovalar shu yerda koʻrinadi.";

  static String m22(date) => "Oxirgi sinxronizatsiya: ${date}";

  static String m23(name) => "${name}ning telefonidagi barcha ilovalar";

  static String m24(name, time) =>
      "${name} uchun barcha ilovalarga ${time} qoldi";

  static String m25(name, time) => "${name} bugun ${time} ishlatdi";

  static String m26(name) => "${name} ilovalari";

  static String m27(level) => "${level}-daraja qahramoni";

  static String m28(level) => "${level}-daraja";

  static String m29(name) => "${name} telefoni · bugun";

  static String m30(count) =>
      "${Intl.plural(count, one: '${count} daqiqa', other: '${count} daqiqa')}";

  static String m31(minutes) => "${minutes} daqiqa qoldi";

  static String m32(minutes) => "Bugun ${minutes} daqiqa qoldi";

  static String m33(minutes) =>
      "${Intl.plural(minutes, other: '${minutes} daqiqa qoldi')}";

  static String m34(count) =>
      "${Intl.plural(count, other: 'Yana ${count} tanga kerak')}";

  static String m35(app) => "Koʻpi ${app}da";

  static String m36(count) =>
      "${Intl.plural(count, other: '${count} kun ketma-ket')}";

  static String m37(total) => "${total} dan";

  static String m38(name) => "${name} telefoniga Safini oʻrnating";

  static String m39(percent) => "Keyingi darajagacha ${percent}%";

  static String m40(cost, time) => "${time} uchun ${cost} tanga";

  static String m41(cost, time) =>
      "Bola kunlik limitdan tashqari ${time} ochish uchun ${cost} tanga sarflashi mumkin.";

  static String m42(minutes) => "${minutes} daqiqa qoldi";

  static String m43(name) => "${name} uchun saqlash";

  static String m44(name) => "${name} uchun saqlandi";

  static String m45(count) => "${Intl.plural(count, other: '${count} vazifa')}";

  static String m46(tasks, coins) => "${tasks} · ${coins}";

  static String m47(scope, tasks) => "${scope} · ${tasks}";

  static String m48(tasks, coins) => "${tasks} qoldi - ${coins} yoʻlda";

  static String m49(time) => "${time} qoldi";

  static String m50(time) => "${time} ishlatildi";

  static String m51(count) => "yana ${count}";

  static String m52(name) =>
      "${name} telefonida \"Men bolaman\" boʻlimiga kiriting.";

  static String m53(used, limit) => "${used} ishlatildi / ${limit} cheklov";

  static String m54(used) => "${used} · cheklovsiz";

  static String m55(used, limit) => "${limit} dan ${used}";

  static String m56(used, limit) => "${limit} dan ${used} · oshdi";

  static String m57(time) => "Bugun ${time}";

  static String m58(count) =>
      "${Intl.plural(count, other: '${count} ta kutmoqda')}";

  static String m59(name) => "${name} telefoni kutilmoqda…";

  static String m60(name, coins) => "${name} · ${coins}";

  static String m61(age) => "${Intl.plural(age, other: '${age} yosh')}";

  static String m62(count) =>
      "${Intl.plural(count, other: 'Sizga yana ${count} tanga kerak.')}";

  static String m63(name) => "${name} (siz)";

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
    "addPhoto": MessageLookupByLibrary.simpleMessage("Foto qoʻshish"),
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
    "allDoneToday": MessageLookupByLibrary.simpleMessage(
      "Bugungi ishlar bajarildi",
    ),
    "allDoneTodayBody": MessageLookupByLibrary.simpleMessage(
      "Hamma vazifa tasdiqlandi, tangalar hamyoningda.",
    ),
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
    "appTimeMinutes": m4,
    "appTimeTab": MessageLookupByLibrary.simpleMessage("Ilova vaqti"),
    "approve": MessageLookupByLibrary.simpleMessage("Tasdiqlash"),
    "approvePayCoins": m5,
    "approvedTaskConflict": MessageLookupByLibrary.simpleMessage(
      "Tasdiqlangan topshiriqni tahrirlash yoki oʻchirish mumkin emas.",
    ),
    "apps": MessageLookupByLibrary.simpleMessage("Ilovalar"),
    "askForSomethingNew": MessageLookupByLibrary.simpleMessage(
      "Yangi narsa soʻra - ota-onang doʻkonga qoʻshadi.",
    ),
    "askForThis": MessageLookupByLibrary.simpleMessage("Ochish"),
    "askToRedo": MessageLookupByLibrary.simpleMessage(
      "Qayta bajarishni soʻrash",
    ),
    "avatarItem": MessageLookupByLibrary.simpleMessage("Avatar buyumi"),
    "avatarItemsTab": MessageLookupByLibrary.simpleMessage("Avatar buyumlari"),
    "badgeCoins": m6,
    "badgeTasksDone": m7,
    "badges": MessageLookupByLibrary.simpleMessage("Nishonlar"),
    "blockCompletely": MessageLookupByLibrary.simpleMessage("To‘liq bloklash"),
    "bothParentsSee": MessageLookupByLibrary.simpleMessage(
      "Ikkala ota-ona bir xil vazifalarni koʻradi va tasdiqlay oladi.",
    ),
    "buyIt": MessageLookupByLibrary.simpleMessage("Sotib olamiz! 🎉"),
    "buysLabel": MessageLookupByLibrary.simpleMessage("Beradi"),
    "canBuyExtraTime": MessageLookupByLibrary.simpleMessage(
      "Qoʻshimcha vaqt sotib olsa boʻladi",
    ),
    "canBuyExtraTimeHint": MessageLookupByLibrary.simpleMessage(
      "Oʻchiq boʻlsa, kunlik limit oxirgi hisoblanadi",
    ),
    "cancel": MessageLookupByLibrary.simpleMessage("Bekor qilish"),
    "catAll": MessageLookupByLibrary.simpleMessage("Hammasi"),
    "catFitness": MessageLookupByLibrary.simpleMessage("Sport"),
    "catHealth": MessageLookupByLibrary.simpleMessage("Salomatlik"),
    "catHome": MessageLookupByLibrary.simpleMessage("Uy"),
    "catLearn": MessageLookupByLibrary.simpleMessage("Oʻrganish"),
    "catLogic": MessageLookupByLibrary.simpleMessage("Mantiq"),
    "catOther": MessageLookupByLibrary.simpleMessage("Boshqa"),
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
    "childProgressTitle": m8,
    "childTasksSubtitle": m9,
    "childUpdatedSuccess": MessageLookupByLibrary.simpleMessage(
      "Farzand profili yangilandi.",
    ),
    "chooseFromLibrary": MessageLookupByLibrary.simpleMessage(
      "Galereyadan tanlash",
    ),
    "chooseYourRole": MessageLookupByLibrary.simpleMessage(
      "Rolingizni tanlang",
    ),
    "cleanTheRoom": MessageLookupByLibrary.simpleMessage("Xonani yigʻishtir"),
    "close": MessageLookupByLibrary.simpleMessage("Yopish"),
    "codeCopied": MessageLookupByLibrary.simpleMessage("Kod nusxalandi"),
    "codeIsReady": m10,
    "coinCount": m11,
    "coinCountShort": m12,
    "coins": MessageLookupByLibrary.simpleMessage("Tangalar"),
    "coinsCount": m13,
    "coinsPaidAfterApproval": MessageLookupByLibrary.simpleMessage(
      "Tangalar siz tasdiqlaganingizdan keyingina beriladi. Takrorlanuvchi vazifalar ertasi kuni qaytadi.",
    ),
    "coinsReward": m14,
    "coinsText": MessageLookupByLibrary.simpleMessage("Tangalar"),
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
    "dailyAllowanceFor": m15,
    "dailyChore": MessageLookupByLibrary.simpleMessage("Kundalik ish"),
    "dailyLimit": MessageLookupByLibrary.simpleMessage("Kunlik cheklov"),
    "dailyLimitToggle": MessageLookupByLibrary.simpleMessage("Kunlik limit"),
    "dailyLimitToggleHint": MessageLookupByLibrary.simpleMessage(
      "Oʻchiq boʻlsa, ilova cheklanmaydi",
    ),
    "dateToday": MessageLookupByLibrary.simpleMessage("Bugun"),
    "dateTomorrow": MessageLookupByLibrary.simpleMessage("Ertaga"),
    "dateYesterday": MessageLookupByLibrary.simpleMessage("Kecha"),
    "dayStreak": MessageLookupByLibrary.simpleMessage("Kunlik seriya"),
    "deleteAccount": MessageLookupByLibrary.simpleMessage("Hisobni oʻchirish"),
    "deleteAccountChildConfirmBody": MessageLookupByLibrary.simpleMessage(
      "Hisobingiz, farzand profili, vazifalar, mukofotlar, tasdiqlovchi suratlar va faoliyat butunlay oʻchiriladi. Bu amalni ortga qaytarib boʻlmaydi.",
    ),
    "deleteAccountConfirmBody": MessageLookupByLibrary.simpleMessage(
      "Hisobingizni oʻchirmoqchimisiz? Bu amalni ortga qaytarib boʻlmaydi.",
    ),
    "deleteAccountConfirmTitle": MessageLookupByLibrary.simpleMessage(
      "Hisob oʻchirilsinmi?",
    ),
    "deleteAccountFailed": MessageLookupByLibrary.simpleMessage(
      "Seans yaroqsiz. Hisobni oʻchirishdan oldin qayta kiring.",
    ),
    "deleteAccountParentConfirmBody": MessageLookupByLibrary.simpleMessage(
      "Hisobingiz va shaxsiy maʼlumotlaringiz butunlay oʻchiriladi. Agar siz yagona ota-ona boʻlsangiz, oila va farzandlarning barcha faoliyati ham oʻchiriladi. Bu amalni ortga qaytarib boʻlmaydi.",
    ),
    "deleteAccountRetry": MessageLookupByLibrary.simpleMessage(
      "Hisobni oʻchirish vaqtincha ishlamayapti. Qayta urinib koʻring.",
    ),
    "deleteTaskBody": MessageLookupByLibrary.simpleMessage(
      "Buni ortga qaytarib boʻlmaydi.",
    ),
    "deleteTaskButton": MessageLookupByLibrary.simpleMessage("Oʻchirish"),
    "deleteTaskTitle": MessageLookupByLibrary.simpleMessage(
      "Topshiriq oʻchirilsinmi?",
    ),
    "deletingAccount": MessageLookupByLibrary.simpleMessage(
      "Hisob oʻchirilmoqda…",
    ),
    "detailsFieldLabel": MessageLookupByLibrary.simpleMessage("Tafsilotlar"),
    "detailsSection": MessageLookupByLibrary.simpleMessage("Maʼlumotlar"),
    "displayNameFallback": MessageLookupByLibrary.simpleMessage("Ota-ona"),
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
    "editName": m16,
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
    "enforcementActive": MessageLookupByLibrary.simpleMessage(
      "Ilova limitlari ishlayapti",
    ),
    "enforcementAttention": MessageLookupByLibrary.simpleMessage(
      "Bola telefonida ilova limitlarini tekshirish kerak.",
    ),
    "enforcementNotConfigured": MessageLookupByLibrary.simpleMessage(
      "Bolaning Android telefonida ilova limitlarini sozlang.",
    ),
    "enforcementOffline": MessageLookupByLibrary.simpleMessage(
      "Bola qurilmasi internetsiz yoki ma’lumot yubormayapti. Telefonni tekshiring.",
    ),
    "enforcementUnknown": MessageLookupByLibrary.simpleMessage(
      "Himoyani tekshirib bo‘lmadi. Qayta urinish uchun bosing.",
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
    "expiresLabel": m17,
    "expiresTonight": MessageLookupByLibrary.simpleMessage(
      "Bugun ishlat, yarim tunda tugaydi.",
    ),
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
    "genericErrorRetry": MessageLookupByLibrary.simpleMessage(
      "Nimadir xato ketdi. Qayta urinib koʻring.",
    ),
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
    "installedAppsAddBody": MessageLookupByLibrary.simpleMessage(
      "Uni shu telefon cheklovlariga qoʻshing. Kunlik limitni keyin sozlashingiz mumkin.",
    ),
    "installedAppsAddTitle": m18,
    "installedAppsBlockCompletely": MessageLookupByLibrary.simpleMessage(
      "Toʻliq bloklash",
    ),
    "installedAppsBlockedSnack": m19,
    "installedAppsCount": m20,
    "installedAppsEmptyBody": m21,
    "installedAppsEmptyTitle": MessageLookupByLibrary.simpleMessage(
      "Ilovalar hali sinxronlanmagan",
    ),
    "installedAppsLastSynced": m22,
    "installedAppsNotControllable": MessageLookupByLibrary.simpleMessage(
      "Safini bu ilovani hali cheklay olmaydi.",
    ),
    "installedAppsSetLimit": MessageLookupByLibrary.simpleMessage(
      "Kunlik limit qoʻyish",
    ),
    "installedAppsSubtitle": m23,
    "installedAppsTapHint": MessageLookupByLibrary.simpleMessage(
      "Cheklov qoʻyish yoki bloklash uchun tanish ilovani bosing.",
    ),
    "installedAppsTitle": MessageLookupByLibrary.simpleMessage(
      "Oʻrnatilgan ilovalar",
    ),
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
    "kidComingSoonIos": MessageLookupByLibrary.simpleMessage(
      "iOS uchun tez orada",
    ),
    "kidComingSoonIosBody": MessageLookupByLibrary.simpleMessage(
      "Hozircha Safini’ni bolaning Android telefoniga oʻrnating. Ota-ona ilovasi iPhone’da allaqachon ishlaydi.",
    ),
    "kidComingSoonIosTitle": MessageLookupByLibrary.simpleMessage(
      "Bola rejimi tez orada iPhone’da ham boʻladi",
    ),
    "kidHasLeftToday": m24,
    "kidSubtitle": MessageLookupByLibrary.simpleMessage(
      "Tanga ishlab top va oʻyna",
    ),
    "kidUsedToday": m25,
    "kidsApps": m26,
    "kidsEarnTimeCoins": MessageLookupByLibrary.simpleMessage(
      "Bolalar bu ilovalarda qoʻshimcha daqiqalar ochish uchun Vaqt tangalarini ishlab topadi.",
    ),
    "laneActive": MessageLookupByLibrary.simpleMessage("Faol"),
    "laneDone": MessageLookupByLibrary.simpleMessage("Bajarilgan"),
    "laneToReview": MessageLookupByLibrary.simpleMessage("Tekshirish"),
    "lessons": MessageLookupByLibrary.simpleMessage("Darslar"),
    "lessonsChangeText": MessageLookupByLibrary.simpleMessage("bugun +1"),
    "levelHero": m27,
    "levelShort": MessageLookupByLibrary.simpleMessage("Daraja"),
    "levelValue": m28,
    "limitThisApp": MessageLookupByLibrary.simpleMessage("Ilovani cheklash"),
    "limitsBattery": MessageLookupByLibrary.simpleMessage(
      "Batareya sozlamalari",
    ),
    "limitsBatteryHint": MessageLookupByLibrary.simpleMessage(
      "Samsung’da batareya cheklovlarini o‘chiring. Xiaomi’da avtomatik ishga tushirishni ham yoqing. Safini’ni uyqudagi ilovalardan chiqaring.",
    ),
    "limitsFootnote": MessageLookupByLibrary.simpleMessage(
      "Kunlik limit tugagach, ilova ochilmay qoladi va Safini ekranini koʻrsatadi.",
    ),
    "limitsNotYetEnforced": MessageLookupByLibrary.simpleMessage(
      "Bloklash uchun bolaning Android telefonida sozlash kerak. iOS bloklashi hozircha mavjud emas.",
    ),
    "limitsOverlayAccess": MessageLookupByLibrary.simpleMessage(
      "Boshqa ilovalar ustida",
    ),
    "limitsRetry": MessageLookupByLibrary.simpleMessage(
      "Tekshirish va ulanish",
    ),
    "limitsSetupError": MessageLookupByLibrary.simpleMessage(
      "Limitlarga ulanib bo‘lmadi. Internetni tekshirib, qayta urining.",
    ),
    "limitsSetupHint": MessageLookupByLibrary.simpleMessage(
      "Android sozlamalarida foydalanish statistikasiga va boshqa ilovalar ustida ko‘rsatishga ruxsat bering.",
    ),
    "limitsSetupTitle": MessageLookupByLibrary.simpleMessage(
      "Ilova limitlarini yoqing",
    ),
    "limitsSubtitle": m29,
    "limitsUsageAccess": MessageLookupByLibrary.simpleMessage(
      "Foydalanish statistikasi",
    ),
    "lockedLabel": MessageLookupByLibrary.simpleMessage("Yopiq"),
    "loginBack": MessageLookupByLibrary.simpleMessage("Orqaga"),
    "loginSubtitle": MessageLookupByLibrary.simpleMessage(
      "Davom etish uchun kiring",
    ),
    "loginTitle": MessageLookupByLibrary.simpleMessage("Kirish"),
    "loginWithApple": MessageLookupByLibrary.simpleMessage(
      "Apple bilan davom etish",
    ),
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
    "manualBlockHint": MessageLookupByLibrary.simpleMessage(
      "Ilovani, jumladan sotib olingan vaqtni to‘xtatish.",
    ),
    "markItDone": MessageLookupByLibrary.simpleMessage(
      "Bajarildi deb belgilash",
    ),
    "minuteCount": m30,
    "minutes": MessageLookupByLibrary.simpleMessage("Daqiqalar"),
    "minutesLeftShort": m31,
    "minutesLeftToday": m32,
    "minutesPerPurchase": MessageLookupByLibrary.simpleMessage(
      "Har xarid uchun daqiqa",
    ),
    "minutesRemainingLong": m33,
    "mon": MessageLookupByLibrary.simpleMessage("DUS"),
    "monitor": MessageLookupByLibrary.simpleMessage("Kuzatuv"),
    "moreCoinsNeeded": m34,
    "mostOfItIn": m35,
    "myAvatar": MessageLookupByLibrary.simpleMessage("Mening avatarim"),
    "myFamily": MessageLookupByLibrary.simpleMessage("Mening oilam"),
    "myProfile": MessageLookupByLibrary.simpleMessage("Mening profilim"),
    "myQuests": MessageLookupByLibrary.simpleMessage("Mening topshiriqlarim"),
    "nDayStreak": m36,
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
    "noFreeTime": MessageLookupByLibrary.simpleMessage("Bepul vaqt yoʻq"),
    "noLimitLabel": MessageLookupByLibrary.simpleMessage("Cheklovsiz"),
    "noLimitsSet": MessageLookupByLibrary.simpleMessage("Cheklov qoʻyilmagan"),
    "noQuestsInCategory": MessageLookupByLibrary.simpleMessage(
      "Bu turkumda topshiriq yoʻq",
    ),
    "noScreenTimeCap": MessageLookupByLibrary.simpleMessage(
      "Umumiy limit yoʻq",
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
    "nothingForToday": MessageLookupByLibrary.simpleMessage(
      "Bugunga vazifa yoʻq",
    ),
    "nothingForTodayBody": MessageLookupByLibrary.simpleMessage(
      "Hozircha vazifa yoʻq. Yaxshi dam ol.",
    ),
    "nothingHereYet": MessageLookupByLibrary.simpleMessage("Hozircha boʻsh"),
    "nothingInStore": MessageLookupByLibrary.simpleMessage(
      "Doʻkon hozircha boʻsh.",
    ),
    "nothingLeft": MessageLookupByLibrary.simpleMessage("Hech narsa qolmadi"),
    "ofTotal": m37,
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
    "pairStepInstall": m38,
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
    "percentToNextLevel": m39,
    "photoProofAsked": MessageLookupByLibrary.simpleMessage(
      "Foto tasdiq soʻralgan",
    ),
    "photoRequired": MessageLookupByLibrary.simpleMessage(
      "Bu vazifa uchun foto kerak.",
    ),
    "photoUploadFailed": MessageLookupByLibrary.simpleMessage(
      "Fotoni yuklab boʻlmadi. Qayta urinib koʻring.",
    ),
    "pickAtLeastOneDay": MessageLookupByLibrary.simpleMessage(
      "Kamida bitta kunni tanlang.",
    ),
    "pillCheck": MessageLookupByLibrary.simpleMessage("Tekshir"),
    "pillPaid": MessageLookupByLibrary.simpleMessage("Toʻlangan"),
    "pillWaiting": MessageLookupByLibrary.simpleMessage("Kutmoqda"),
    "priceLabel": MessageLookupByLibrary.simpleMessage("Narx"),
    "priceUnit": m40,
    "privacyPolicy": MessageLookupByLibrary.simpleMessage("Maxfiylik siyosati"),
    "privacyPolicyOpenFailed": MessageLookupByLibrary.simpleMessage(
      "Maxfiylik siyosatini ochib boʻlmadi.",
    ),
    "privacyPolicySubtitle": MessageLookupByLibrary.simpleMessage(
      "Safini oila maʼlumotlarini qanday qayta ishlaydi",
    ),
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
    "redeemExplainer": m41,
    "reject": MessageLookupByLibrary.simpleMessage("Rad etish"),
    "remaining": MessageLookupByLibrary.simpleMessage("Qoldi"),
    "remainingTime": m42,
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
    "repeatDaily": MessageLookupByLibrary.simpleMessage("Har kuni"),
    "repeatDailyShort": MessageLookupByLibrary.simpleMessage("Har kuni"),
    "repeatLabel": MessageLookupByLibrary.simpleMessage("Takrorlash"),
    "repeatOnce": MessageLookupByLibrary.simpleMessage("Bir marta"),
    "repeatWeekly": MessageLookupByLibrary.simpleMessage("Tanlangan kunlar"),
    "repeatWeeklyShort": MessageLookupByLibrary.simpleMessage("Haftalik"),
    "retakePhoto": MessageLookupByLibrary.simpleMessage("Qayta olish"),
    "retry": MessageLookupByLibrary.simpleMessage("Qayta urinish"),
    "reviewNoteHint": MessageLookupByLibrary.simpleMessage(
      "Izoh qoʻshing (ixtiyoriy)",
    ),
    "reviewTaskSheetTitle": MessageLookupByLibrary.simpleMessage(
      "Topshiriqni tekshirish",
    ),
    "rewardBlurbAppTime": MessageLookupByLibrary.simpleMessage(
      "Darhol qoʻshiladi. Bugun ishlat, yarim tunda tugaydi.",
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
    "saveForName": m43,
    "saveMyLook": MessageLookupByLibrary.simpleMessage("Koʻrinishimni saqla!"),
    "savedForName": m44,
    "scopeEveryone": MessageLookupByLibrary.simpleMessage("Hammasi"),
    "screenTime": MessageLookupByLibrary.simpleMessage("Ekran vaqti"),
    "screenTimeCap": MessageLookupByLibrary.simpleMessage("Kunlik ekran vaqti"),
    "screenTimeCapHint": MessageLookupByLibrary.simpleMessage(
      "Barcha ilovalar birgalikda. Oʻchiq boʻlsa, faqat ilova limitlari.",
    ),
    "sectionAccount": MessageLookupByLibrary.simpleMessage("Hisob"),
    "sectionApp": MessageLookupByLibrary.simpleMessage("Ilova"),
    "seeAllApps": MessageLookupByLibrary.simpleMessage(
      "Telefondagi barcha ilovalar",
    ),
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
      "Tangalaring, sening tanloving",
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
    "takePhoto": MessageLookupByLibrary.simpleMessage("Foto olish"),
    "taskApprovedMessage": MessageLookupByLibrary.simpleMessage(
      "Topshiriq tasdiqlandi!",
    ),
    "taskChessSub": MessageLookupByLibrary.simpleMessage("Taxtani egalla"),
    "taskChessTitle": MessageLookupByLibrary.simpleMessage("Shaxmat darsi"),
    "taskCount": m45,
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
    "taskGroupSummary": m46,
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
    "taskScopeLine": m47,
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
    "tasksLeftCoinsOnTable": m48,
    "theirNote": MessageLookupByLibrary.simpleMessage("Uning izohi"),
    "theyInstallSafini": MessageLookupByLibrary.simpleMessage(
      "Safini oʻrnatib, kirsin va shu kodni kiritsin.",
    ),
    "thisWeek": MessageLookupByLibrary.simpleMessage("Bu hafta"),
    "thu": MessageLookupByLibrary.simpleMessage("PAY"),
    "timeCoins": MessageLookupByLibrary.simpleMessage("Vaqt tangalari"),
    "timeLeft": m49,
    "timeUsed": m50,
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
    "toGo": m51,
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
    "typeItOnPhone": m52,
    "unitHour": MessageLookupByLibrary.simpleMessage("s"),
    "unitMinute": MessageLookupByLibrary.simpleMessage("d"),
    "unlockExtraTime": MessageLookupByLibrary.simpleMessage(
      "Qoʻshimcha vaqt ochish",
    ),
    "unlockOnceKeepForever": MessageLookupByLibrary.simpleMessage(
      "Bir marta och - abadiy qoladi",
    ),
    "unlocked": MessageLookupByLibrary.simpleMessage("ochilgan"),
    "usedLimit": m53,
    "usedNoLimit": m54,
    "usedOfLimit": m55,
    "usedOfLimitOver": m56,
    "usedTodayShort": m57,
    "uzbek": MessageLookupByLibrary.simpleMessage("Oʻzbek"),
    "viewAsKid": MessageLookupByLibrary.simpleMessage("Bola sifatida koʻrish"),
    "waitingCount": m58,
    "waitingForParentCheck": MessageLookupByLibrary.simpleMessage(
      "Ota-ona tekshirishini kutmoqdamiz",
    ),
    "waitingForPhone": m59,
    "wearLabel": MessageLookupByLibrary.simpleMessage("Kiyish"),
    "wed": MessageLookupByLibrary.simpleMessage("CHOR"),
    "weekdayFri": MessageLookupByLibrary.simpleMessage("Ju"),
    "weekdayMon": MessageLookupByLibrary.simpleMessage("Du"),
    "weekdaySat": MessageLookupByLibrary.simpleMessage("Sh"),
    "weekdaySun": MessageLookupByLibrary.simpleMessage("Ya"),
    "weekdayThu": MessageLookupByLibrary.simpleMessage("Pa"),
    "weekdayTue": MessageLookupByLibrary.simpleMessage("Se"),
    "weekdayWed": MessageLookupByLibrary.simpleMessage("Ch"),
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
    "worthCoins": m60,
    "yearsOld": m61,
    "youNeedMoreCoins": m62,
    "youSuffix": m63,
    "yourAccount": MessageLookupByLibrary.simpleMessage("Hisobingiz"),
    "yourAvatar": MessageLookupByLibrary.simpleMessage("Avataring"),
    "yourChildren": MessageLookupByLibrary.simpleMessage("FARZANDLARINGIZ"),
    "yourName": MessageLookupByLibrary.simpleMessage("Ismingiz"),
    "yoursLabel": MessageLookupByLibrary.simpleMessage("Seniki"),
  };
}
