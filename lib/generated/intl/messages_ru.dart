// DO NOT EDIT. This is code generated via package:intl/generate_localized.dart
// This is a library that provides messages for a ru locale. All the
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
  String get localeName => 'ru';

  static String m0(age, gender) => "Возраст ${age} • ${gender}";

  static String m1(count) => "${count} монет";

  static String m2(level) => "Герой ${level} уровня";

  static String m3(minutes) => "осталось ${minutes}м";

  static String m4(count) => "Вам нужно еще ${count} монет.";

  final messages = _notInlinedMessages(_notInlinedMessages);
  static Map<String, Function> _notInlinedMessages(_) => <String, Function>{
    "achievements": MessageLookupByLibrary.simpleMessage("Достижения"),
    "activeTasks": MessageLookupByLibrary.simpleMessage("Активные задания"),
    "addAnotherApp": MessageLookupByLibrary.simpleMessage(
      "Добавить приложение",
    ),
    "addAnotherChild": MessageLookupByLibrary.simpleMessage("Добавить ребенка"),
    "admin": MessageLookupByLibrary.simpleMessage("Админ"),
    "ageAndGender": m0,
    "appLimits": MessageLookupByLibrary.simpleMessage("Лимиты приложений"),
    "appName": MessageLookupByLibrary.simpleMessage("SAFINIO"),
    "appTimeTab": MessageLookupByLibrary.simpleMessage("Приложения"),
    "apps": MessageLookupByLibrary.simpleMessage("Приложения"),
    "avatarItemsTab": MessageLookupByLibrary.simpleMessage("Предметы"),
    "buyIt": MessageLookupByLibrary.simpleMessage("Купить! 🎉"),
    "cancel": MessageLookupByLibrary.simpleMessage("Отмена"),
    "categoryAll": MessageLookupByLibrary.simpleMessage("Все"),
    "categoryFitness": MessageLookupByLibrary.simpleMessage("Спорт"),
    "categoryLearn": MessageLookupByLibrary.simpleMessage("Учеба"),
    "categoryLogic": MessageLookupByLibrary.simpleMessage("Логика"),
    "changeLanguage": MessageLookupByLibrary.simpleMessage("Сменить язык"),
    "changeOutfit": MessageLookupByLibrary.simpleMessage(
      "Сменить одежду, прическу и др.",
    ),
    "cleanTheRoom": MessageLookupByLibrary.simpleMessage("Убраться в комнате"),
    "coins": MessageLookupByLibrary.simpleMessage("Монеты"),
    "coinsCount": m1,
    "coinsText": MessageLookupByLibrary.simpleMessage("Монеты"),
    "comingSoon": MessageLookupByLibrary.simpleMessage("Скоро будет!"),
    "completeDailyQuests": MessageLookupByLibrary.simpleMessage(
      "Выполняйте ежедневные квесты, чтобы заработать больше монет!",
    ),
    "completed": MessageLookupByLibrary.simpleMessage("Выполнено"),
    "customizeAvatar": MessageLookupByLibrary.simpleMessage("Настроить аватар"),
    "dailyChore": MessageLookupByLibrary.simpleMessage("Ежедневное дело"),
    "dailyLimit": MessageLookupByLibrary.simpleMessage("Дневной лимит"),
    "dayStreak": MessageLookupByLibrary.simpleMessage("Дней подряд"),
    "doHomework": MessageLookupByLibrary.simpleMessage("Сделать уроки"),
    "doneToday": MessageLookupByLibrary.simpleMessage("Сделано"),
    "earnMoreCoins": MessageLookupByLibrary.simpleMessage(
      "Заработать больше монет",
    ),
    "earnedToday": MessageLookupByLibrary.simpleMessage("Заработано"),
    "edit": MessageLookupByLibrary.simpleMessage("Изменить"),
    "educational": MessageLookupByLibrary.simpleMessage("Образование"),
    "english": MessageLookupByLibrary.simpleMessage("Английский"),
    "family": MessageLookupByLibrary.simpleMessage("Семья"),
    "familyAdmin": MessageLookupByLibrary.simpleMessage("Админ семьи"),
    "footerText": MessageLookupByLibrary.simpleMessage(
      "Безопасное экранное время для умных детей 🌟",
    ),
    "free": MessageLookupByLibrary.simpleMessage("БЕСПЛАТНО"),
    "goToTasks": MessageLookupByLibrary.simpleMessage("Перейти к заданиям"),
    "goodMorning": MessageLookupByLibrary.simpleMessage("Доброе утро 👋"),
    "home": MessageLookupByLibrary.simpleMessage("Главная"),
    "imAKid": MessageLookupByLibrary.simpleMessage("Я ребенок!"),
    "imAParent": MessageLookupByLibrary.simpleMessage("Я родитель"),
    "kidSubtitle": MessageLookupByLibrary.simpleMessage(
      "Зарабатывай монеты и играй",
    ),
    "kidsEarnTimeCoins": MessageLookupByLibrary.simpleMessage(
      "Дети зарабатывают Монеты Времени, чтобы разблокировать минуты для этих приложений.",
    ),
    "lessons": MessageLookupByLibrary.simpleMessage("Уроки"),
    "levelHero": m2,
    "manageAll": MessageLookupByLibrary.simpleMessage("Управлять всем"),
    "monitor": MessageLookupByLibrary.simpleMessage("Мониторинг"),
    "myAvatar": MessageLookupByLibrary.simpleMessage("Мой аватар"),
    "myProfile": MessageLookupByLibrary.simpleMessage("Мой профиль"),
    "myQuests": MessageLookupByLibrary.simpleMessage("Мои квесты"),
    "newBtn": MessageLookupByLibrary.simpleMessage("Новое"),
    "newTask": MessageLookupByLibrary.simpleMessage("Новое задание"),
    "noQuestsInCategory": MessageLookupByLibrary.simpleMessage(
      "Нет квестов в этой категории",
    ),
    "notEnoughCoins": MessageLookupByLibrary.simpleMessage(
      "Недостаточно монет!",
    ),
    "ok": MessageLookupByLibrary.simpleMessage("ОК"),
    "on": MessageLookupByLibrary.simpleMessage("ВКЛ"),
    "outfitsAndItems": MessageLookupByLibrary.simpleMessage(
      "Одежда и предметы",
    ),
    "parentAccount": MessageLookupByLibrary.simpleMessage("АККАУНТ РОДИТЕЛЯ"),
    "parentHomeScreen": MessageLookupByLibrary.simpleMessage(
      "Главный экран родителя",
    ),
    "parentName": MessageLookupByLibrary.simpleMessage("Родитель Safinio"),
    "parentSubtitle": MessageLookupByLibrary.simpleMessage(
      "Контролируй и награждай",
    ),
    "pendingApproval": MessageLookupByLibrary.simpleMessage("Ожидают проверки"),
    "profile": MessageLookupByLibrary.simpleMessage("Профиль"),
    "questsDone": MessageLookupByLibrary.simpleMessage("Заданий выполнено"),
    "questsText": MessageLookupByLibrary.simpleMessage("Задания"),
    "readFor20Mins": MessageLookupByLibrary.simpleMessage("Читать 20 мин"),
    "readyToSpend": MessageLookupByLibrary.simpleMessage(
      "Готовы потратить монеты?",
    ),
    "realWorldTasks": MessageLookupByLibrary.simpleMessage("Задания в жизни"),
    "remaining": MessageLookupByLibrary.simpleMessage("Осталось"),
    "remainingTime": m3,
    "rewardStore": MessageLookupByLibrary.simpleMessage("Магазин наград"),
    "russian": MessageLookupByLibrary.simpleMessage("Русский"),
    "save": MessageLookupByLibrary.simpleMessage("Сохранить"),
    "saveMyLook": MessageLookupByLibrary.simpleMessage("Сохранить вид!"),
    "selectLanguage": MessageLookupByLibrary.simpleMessage("Выберите язык"),
    "setUpANewProfile": MessageLookupByLibrary.simpleMessage(
      "Создать новый профиль",
    ),
    "spendYourTimeCoins": MessageLookupByLibrary.simpleMessage(
      "Потратьте свои монеты времени",
    ),
    "steps": MessageLookupByLibrary.simpleMessage("Шаги"),
    "stepsToday": MessageLookupByLibrary.simpleMessage("Шагов сегодня"),
    "store": MessageLookupByLibrary.simpleMessage("Магазин"),
    "streakText": MessageLookupByLibrary.simpleMessage("Подряд"),
    "switchToKidMode": MessageLookupByLibrary.simpleMessage(
      "Режим ребенка / Выход",
    ),
    "tagline": MessageLookupByLibrary.simpleMessage(
      "Учись. Зарабатывай. Играй.",
    ),
    "taskChessSub": MessageLookupByLibrary.simpleMessage("Освой доску"),
    "taskChessTitle": MessageLookupByLibrary.simpleMessage("Урок шахмат"),
    "taskDuolingoSub": MessageLookupByLibrary.simpleMessage("Бонус за серию!"),
    "taskDuolingoTitle": MessageLookupByLibrary.simpleMessage(
      "Пройти Duolingo",
    ),
    "taskPuzzleSub": MessageLookupByLibrary.simpleMessage("Зарядка для ума"),
    "taskPuzzleTitle": MessageLookupByLibrary.simpleMessage(
      "Логическая головоломка",
    ),
    "taskReadingSub": MessageLookupByLibrary.simpleMessage("Расширяй кругозор"),
    "taskReadingTitle": MessageLookupByLibrary.simpleMessage("Читать 20 мин"),
    "taskRoomSub": MessageLookupByLibrary.simpleMessage("Ежедневное дело"),
    "taskRoomTitle": MessageLookupByLibrary.simpleMessage("Убраться в комнате"),
    "taskStepsSub": MessageLookupByLibrary.simpleMessage("Больше движения!"),
    "taskStepsTitle": MessageLookupByLibrary.simpleMessage(
      "Пройти 5,000 шагов",
    ),
    "tasks": MessageLookupByLibrary.simpleMessage("Задания"),
    "tasksAndRewards": MessageLookupByLibrary.simpleMessage(
      "Задания и награды",
    ),
    "tip1": MessageLookupByLibrary.simpleMessage(
      "Ставьте значимые задачи, которые учат ответственности",
    ),
    "tip2": MessageLookupByLibrary.simpleMessage(
      "Балансируйте экранное время с прогулками на улице",
    ),
    "tip3": MessageLookupByLibrary.simpleMessage(
      "Празднуйте достижения вместе с ребенком",
    ),
    "tip4": MessageLookupByLibrary.simpleMessage(
      "Настраивайте стоимость монет в зависимости от усилий",
    ),
    "tipsForParents": MessageLookupByLibrary.simpleMessage("Советы родителям"),
    "todaysQuests": MessageLookupByLibrary.simpleMessage("Сегодняшние задания"),
    "unlockExtraTime": MessageLookupByLibrary.simpleMessage(
      "Разблокировать время",
    ),
    "unlocked": MessageLookupByLibrary.simpleMessage("разблокировано"),
    "viewAsKid": MessageLookupByLibrary.simpleMessage("Войти как ребенок"),
    "youNeedMoreCoins": m4,
    "yourChildren": MessageLookupByLibrary.simpleMessage("ВАШИ ДЕТИ"),
  };
}
