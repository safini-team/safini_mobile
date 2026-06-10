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

  static String m1(name) => "Прогресс ${name}";

  static String m2(count) =>
      "${Intl.plural(count, one: '${count} монета', few: '${count} монеты', many: '${count} монет', other: '${count} монеты')}";

  static String m3(count) => "${count} монет";

  static String m4(count) =>
      "${Intl.plural(count, one: 'Награда: ${count} монета', few: 'Награда: ${count} монеты', many: 'Награда: ${count} монет', other: 'Награда: ${count} монеты')}";

  static String m5(level) => "Герой ${level} уровня";

  static String m6(count) =>
      "${Intl.plural(count, one: '${count} минута', few: '${count} минуты', many: '${count} минут', other: '${count} минуты')}";

  static String m7(minutes) => "Осталось ${minutes} мин.";

  static String m8(minutes) => "осталось ${minutes}м";

  static String m9(used, limit) => "${used} исп. / ${limit} лимит";

  static String m10(count) => "Вам нужно еще ${count} монет.";

  final messages = _notInlinedMessages(_notInlinedMessages);
  static Map<String, Function> _notInlinedMessages(_) => <String, Function>{
        "achievements": MessageLookupByLibrary.simpleMessage("Достижения"),
        "activeTasks": MessageLookupByLibrary.simpleMessage("Активные задания"),
        "addAnotherApp":
            MessageLookupByLibrary.simpleMessage("Добавить приложение"),
        "addAnotherChild":
            MessageLookupByLibrary.simpleMessage("Добавить ребенка"),
        "admin": MessageLookupByLibrary.simpleMessage("Админ"),
        "ageAndGender": m0,
        "appLimits": MessageLookupByLibrary.simpleMessage("Лимиты приложений"),
        "appLimitsSubtitle": MessageLookupByLibrary.simpleMessage(
            "Установите дневные лимиты экранного времени"),
        "appName": MessageLookupByLibrary.simpleMessage("SAFINI"),
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
            "Сменить одежду, прическу и др."),
        "childProgressTitle": m1,
        "chooseYourRole": MessageLookupByLibrary.simpleMessage("Выберите роль"),
        "cleanTheRoom":
            MessageLookupByLibrary.simpleMessage("Убраться в комнате"),
        "coinCount": m2,
        "coins": MessageLookupByLibrary.simpleMessage("Монеты"),
        "coinsCount": m3,
        "coinsReward": m4,
        "coinsText": MessageLookupByLibrary.simpleMessage("Монеты"),
        "comingSoon": MessageLookupByLibrary.simpleMessage("Скоро будет!"),
        "completeDailyQuests": MessageLookupByLibrary.simpleMessage(
            "Выполняйте ежедневные квесты, чтобы заработать больше монет!"),
        "completed": MessageLookupByLibrary.simpleMessage("Выполнено"),
        "createTaskAddButton":
            MessageLookupByLibrary.simpleMessage("Добавить задание"),
        "createTaskCategoryDailyChore":
            MessageLookupByLibrary.simpleMessage("Дело по дому"),
        "createTaskCategoryEducational":
            MessageLookupByLibrary.simpleMessage("Обучение"),
        "createTaskCategoryHobby":
            MessageLookupByLibrary.simpleMessage("Хобби"),
        "createTaskCategoryOther":
            MessageLookupByLibrary.simpleMessage("Другое"),
        "createTaskCategoryTitle":
            MessageLookupByLibrary.simpleMessage("Категория"),
        "createTaskNameHint":
            MessageLookupByLibrary.simpleMessage("напр. Убраться в комнате"),
        "createTaskNameLabel": MessageLookupByLibrary.simpleMessage("Название"),
        "createTaskPickEmojiLabel":
            MessageLookupByLibrary.simpleMessage("Выберите эмодзи"),
        "createTaskRewardLabel":
            MessageLookupByLibrary.simpleMessage("Награда (Монеты времени)"),
        "createTaskSheetTitle":
            MessageLookupByLibrary.simpleMessage("Новое задание"),
        "customizeAvatar":
            MessageLookupByLibrary.simpleMessage("Настроить аватар"),
        "dailyChore": MessageLookupByLibrary.simpleMessage("Ежедневное дело"),
        "dailyLimit": MessageLookupByLibrary.simpleMessage("Дневной лимит"),
        "dayStreak": MessageLookupByLibrary.simpleMessage("Дней подряд"),
        "doHomework": MessageLookupByLibrary.simpleMessage("Сделать уроки"),
        "doneToday": MessageLookupByLibrary.simpleMessage("Сделано"),
        "earnMoreCoins":
            MessageLookupByLibrary.simpleMessage("Заработать больше монет"),
        "earnedToday": MessageLookupByLibrary.simpleMessage("Заработано"),
        "edit": MessageLookupByLibrary.simpleMessage("Изменить"),
        "educational": MessageLookupByLibrary.simpleMessage("Образование"),
        "english": MessageLookupByLibrary.simpleMessage("Английский"),
        "equipped": MessageLookupByLibrary.simpleMessage("НАДЕТО"),
        "family": MessageLookupByLibrary.simpleMessage("Семья"),
        "familyAdmin": MessageLookupByLibrary.simpleMessage("Админ семьи"),
        "familyDecisionSubtitle": MessageLookupByLibrary.simpleMessage(
            "Создайте семейное пространство и пригласите детей зарабатывать экранное время."),
        "footerText": MessageLookupByLibrary.simpleMessage(
            "Безопасное экранное время для умных детей 🌟"),
        "free": MessageLookupByLibrary.simpleMessage("БЕСПЛАТНО"),
        "fri": MessageLookupByLibrary.simpleMessage("ПТ"),
        "goToTasks": MessageLookupByLibrary.simpleMessage("Перейти к заданиям"),
        "goodMorning": MessageLookupByLibrary.simpleMessage("Доброе утро 👋"),
        "googleClientIdMissing": MessageLookupByLibrary.simpleMessage(
            "Не задан Google Web Client ID. Укажите GOOGLE_WEB_CLIENT_ID (OAuth Web в Google Cloud)."),
        "home": MessageLookupByLibrary.simpleMessage("Главная"),
        "imAKid": MessageLookupByLibrary.simpleMessage("Я ребенок!"),
        "imAParent": MessageLookupByLibrary.simpleMessage("Я родитель"),
        "kazakh": MessageLookupByLibrary.simpleMessage("Казахский"),
        "kidSubtitle":
            MessageLookupByLibrary.simpleMessage("Зарабатывай монеты и играй"),
        "kidsEarnTimeCoins": MessageLookupByLibrary.simpleMessage(
            "Дети зарабатывают Монеты Времени, чтобы разблокировать минуты для этих приложений."),
        "lessons": MessageLookupByLibrary.simpleMessage("Уроки"),
        "lessonsChangeText": MessageLookupByLibrary.simpleMessage("+1 сегодня"),
        "levelHero": m5,
        "loginBack": MessageLookupByLibrary.simpleMessage("Назад"),
        "loginSubtitle": MessageLookupByLibrary.simpleMessage(
            "Продолжите с аккаунтом Google"),
        "loginTitle": MessageLookupByLibrary.simpleMessage("Вход"),
        "loginWithGoogle":
            MessageLookupByLibrary.simpleMessage("Продолжить с Google"),
        "manageAll": MessageLookupByLibrary.simpleMessage("Управлять всем"),
        "minuteCount": m6,
        "minutes": MessageLookupByLibrary.simpleMessage("Минуты"),
        "minutesRemainingLong": m7,
        "mon": MessageLookupByLibrary.simpleMessage("ПН"),
        "monitor": MessageLookupByLibrary.simpleMessage("Мониторинг"),
        "myAvatar": MessageLookupByLibrary.simpleMessage("Мой аватар"),
        "myProfile": MessageLookupByLibrary.simpleMessage("Мой профиль"),
        "myQuests": MessageLookupByLibrary.simpleMessage("Мои квесты"),
        "networkError": MessageLookupByLibrary.simpleMessage(
            "Ошибка сети. Проверьте подключение."),
        "newBtn": MessageLookupByLibrary.simpleMessage("Новое"),
        "newTask": MessageLookupByLibrary.simpleMessage("Новое задание"),
        "noQuestsInCategory": MessageLookupByLibrary.simpleMessage(
            "Нет квестов в этой категории"),
        "noTasksYet": MessageLookupByLibrary.simpleMessage(
            "На этот день заданий пока нет."),
        "notEnoughCoins":
            MessageLookupByLibrary.simpleMessage("Недостаточно монет!"),
        "ok": MessageLookupByLibrary.simpleMessage("ОК"),
        "on": MessageLookupByLibrary.simpleMessage("ВКЛ"),
        "outfitsAndItems":
            MessageLookupByLibrary.simpleMessage("Одежда и предметы"),
        "parentAccount":
            MessageLookupByLibrary.simpleMessage("АККАУНТ РОДИТЕЛЯ"),
        "parentHomeScreen":
            MessageLookupByLibrary.simpleMessage("Главный экран родителя"),
        "parentName": MessageLookupByLibrary.simpleMessage("Родитель Safini"),
        "parentSubtitle":
            MessageLookupByLibrary.simpleMessage("Контролируй и награждай"),
        "pendingApproval":
            MessageLookupByLibrary.simpleMessage("Ожидают проверки"),
        "profile": MessageLookupByLibrary.simpleMessage("Профиль"),
        "questsDone": MessageLookupByLibrary.simpleMessage("Заданий выполнено"),
        "questsText": MessageLookupByLibrary.simpleMessage("Задания"),
        "readFor20Mins": MessageLookupByLibrary.simpleMessage("Читать 20 мин"),
        "readyToSpend":
            MessageLookupByLibrary.simpleMessage("Готовы потратить монеты?"),
        "realWorldTasks":
            MessageLookupByLibrary.simpleMessage("Задания в жизни"),
        "remaining": MessageLookupByLibrary.simpleMessage("Осталось"),
        "remainingTime": m8,
        "retry": MessageLookupByLibrary.simpleMessage("Повторить"),
        "rewardStore": MessageLookupByLibrary.simpleMessage("Магазин наград"),
        "roleSelectionSubtitle": MessageLookupByLibrary.simpleMessage(
            "Как вы будете использовать Safini?"),
        "russian": MessageLookupByLibrary.simpleMessage("Русский"),
        "sat": MessageLookupByLibrary.simpleMessage("СБ"),
        "save": MessageLookupByLibrary.simpleMessage("Сохранить"),
        "saveMyLook": MessageLookupByLibrary.simpleMessage("Сохранить вид!"),
        "selectLanguage": MessageLookupByLibrary.simpleMessage("Выберите язык"),
        "setUpANewProfile":
            MessageLookupByLibrary.simpleMessage("Создать новый профиль"),
        "setupYourFamily":
            MessageLookupByLibrary.simpleMessage("Настройте семью"),
        "signInError": MessageLookupByLibrary.simpleMessage(
            "Не удалось войти. Попробуйте ещё раз."),
        "signedInSuccess":
            MessageLookupByLibrary.simpleMessage("Вход выполнен"),
        "signingIn": MessageLookupByLibrary.simpleMessage("Вход..."),
        "spendYourTimeCoins": MessageLookupByLibrary.simpleMessage(
            "Потратьте свои монеты времени"),
        "statusActive": MessageLookupByLibrary.simpleMessage("АКТИВНО"),
        "statusDone": MessageLookupByLibrary.simpleMessage("ГОТОВО"),
        "statusPending": MessageLookupByLibrary.simpleMessage("ОЖИДАЕТ"),
        "steps": MessageLookupByLibrary.simpleMessage("Шаги"),
        "stepsChangeText":
            MessageLookupByLibrary.simpleMessage("+12% по сравнению со вчера"),
        "stepsToday": MessageLookupByLibrary.simpleMessage("Шагов сегодня"),
        "store": MessageLookupByLibrary.simpleMessage("Магазин"),
        "streakText": MessageLookupByLibrary.simpleMessage("Подряд"),
        "sun": MessageLookupByLibrary.simpleMessage("ВС"),
        "supabaseConfigMissing": MessageLookupByLibrary.simpleMessage(
            "Не заданы URL или anon-ключ Supabase. Укажите SUPABASE_URL и SUPABASE_ANON_KEY при запуске."),
        "switchToKidMode":
            MessageLookupByLibrary.simpleMessage("Режим ребенка / Выход"),
        "tagline":
            MessageLookupByLibrary.simpleMessage("Учись. Зарабатывай. Играй."),
        "taskChessSub": MessageLookupByLibrary.simpleMessage("Освой доску"),
        "taskChessTitle": MessageLookupByLibrary.simpleMessage("Урок шахмат"),
        "taskCreatedMessage":
            MessageLookupByLibrary.simpleMessage("Задание создано!"),
        "taskDuolingoSub":
            MessageLookupByLibrary.simpleMessage("Бонус за серию!"),
        "taskDuolingoTitle":
            MessageLookupByLibrary.simpleMessage("Пройти Duolingo"),
        "taskPuzzleSub":
            MessageLookupByLibrary.simpleMessage("Зарядка для ума"),
        "taskPuzzleTitle":
            MessageLookupByLibrary.simpleMessage("Логическая головоломка"),
        "taskReadingSub":
            MessageLookupByLibrary.simpleMessage("Расширяй кругозор"),
        "taskReadingTitle":
            MessageLookupByLibrary.simpleMessage("Читать 20 мин"),
        "taskRoomSub": MessageLookupByLibrary.simpleMessage("Ежедневное дело"),
        "taskRoomTitle":
            MessageLookupByLibrary.simpleMessage("Убраться в комнате"),
        "taskStepsSub":
            MessageLookupByLibrary.simpleMessage("Больше движения!"),
        "taskStepsTitle":
            MessageLookupByLibrary.simpleMessage("Пройти 5,000 шагов"),
        "tasks": MessageLookupByLibrary.simpleMessage("Задания"),
        "tasksAndRewards":
            MessageLookupByLibrary.simpleMessage("Задания и награды"),
        "thu": MessageLookupByLibrary.simpleMessage("ЧТ"),
        "timeCoins": MessageLookupByLibrary.simpleMessage("Монеты времени"),
        "tip1": MessageLookupByLibrary.simpleMessage(
            "Ставьте значимые задачи, которые учат ответственности"),
        "tip2": MessageLookupByLibrary.simpleMessage(
            "Балансируйте экранное время с прогулками на улице"),
        "tip3": MessageLookupByLibrary.simpleMessage(
            "Празднуйте достижения вместе с ребенком"),
        "tip4": MessageLookupByLibrary.simpleMessage(
            "Настраивайте стоимость монет в зависимости от усилий"),
        "tipsForParents":
            MessageLookupByLibrary.simpleMessage("Советы родителям"),
        "todaysQuests":
            MessageLookupByLibrary.simpleMessage("Сегодняшние задания"),
        "tue": MessageLookupByLibrary.simpleMessage("ВТ"),
        "unlockExtraTime":
            MessageLookupByLibrary.simpleMessage("Разблокировать время"),
        "unlocked": MessageLookupByLibrary.simpleMessage("разблокировано"),
        "usedLimit": m9,
        "viewAsKid": MessageLookupByLibrary.simpleMessage("Войти как ребенок"),
        "wed": MessageLookupByLibrary.simpleMessage("СР"),
        "weeklyScreenTime":
            MessageLookupByLibrary.simpleMessage("Экранное время за неделю"),
        "youNeedMoreCoins": m10,
        "yourChildren": MessageLookupByLibrary.simpleMessage("ВАШИ ДЕТИ")
      };
}
