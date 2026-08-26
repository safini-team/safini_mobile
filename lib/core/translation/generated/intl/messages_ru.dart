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

  static String m0(name) => "Добавить ${name}";

  static String m1(age, gender) => "Возраст ${age} • ${gender}";

  static String m2(age) => "Возраст: ${age}";

  static String m3(app, minutes) => "${app} · ${minutes} мин";

  static String m4(coins) => "Одобрить · начислить ${coins}";

  static String m5(count) =>
      "${Intl.plural(count, one: '${count} монета', few: '${count} монеты', many: '${count} монет', other: '${count} монет')}";

  static String m6(count) =>
      "${Intl.plural(count, one: '${count} задание', few: '${count} задания', many: '${count} заданий', other: '${count} заданий')}";

  static String m7(name) => "Прогресс ${name}";

  static String m8(done, total, coins) =>
      "${done} из ${total} сегодня · ${coins} монет ждут";

  static String m9(name) => "Код для ${name} готов";

  static String m10(count) =>
      "${Intl.plural(count, one: '${count} монета', few: '${count} монеты', many: '${count} монет', other: '${count} монеты')}";

  static String m11(count) =>
      "${Intl.plural(count, one: '${count} монета', few: '${count} монеты', many: '${count} монет', other: '${count} монет')}";

  static String m12(count) =>
      "${Intl.plural(count, one: '${count} монета', few: '${count} монеты', many: '${count} монет', other: '${count} монет')}";

  static String m13(count) =>
      "${Intl.plural(count, one: 'Награда: ${count} монета', few: 'Награда: ${count} монеты', many: 'Награда: ${count} монет', other: 'Награда: ${count} монеты')}";

  static String m14(count) =>
      "${Intl.plural(count, one: 'Ещё ${count} монета', few: 'Ещё ${count} монеты', many: 'Ещё ${count} монет', other: 'Ещё ${count} монет')}";

  static String m15(count) =>
      "${Intl.plural(count, one: 'Ещё ${count} монета', few: 'Ещё ${count} монеты', many: 'Ещё ${count} монет', other: 'Ещё ${count} монет')}";

  static String m16(name) => "${name} · все приложения вместе";

  static String m17(name) => "Изменить ${name}";

  static String m18(date, time) => "Истекает: ${date}, ${time}";

  static String m19(count) =>
      "${Intl.plural(count, zero: 'Нет приложений', one: '1 приложение', other: 'Приложений: ${count}')}";

  static String m20(name) =>
      "Когда ${name} откроет Safini на своём телефоне, установленные приложения появятся здесь.";

  static String m21(name) => "Все приложения на телефоне ${name}";

  static String m22(name, time) =>
      "У ${name} осталось ${time} на все приложения";

  static String m23(name, time) => "${name} использовал ${time} сегодня";

  static String m24(name) => "Приложения ${name}";

  static String m25(level) => "Герой ${level} уровня";

  static String m26(level) => "Уровень ${level}";

  static String m27(name) => "Телефон ${name} · сегодня";

  static String m28(count) =>
      "${Intl.plural(count, one: '${count} минута', few: '${count} минуты', many: '${count} минут', other: '${count} минуты')}";

  static String m29(minutes) => "${minutes} мин осталось";

  static String m30(minutes) => "Осталось ${minutes} мин сегодня";

  static String m31(minutes) =>
      "${Intl.plural(minutes, one: 'Осталась ${minutes} минута', few: 'Осталось ${minutes} минуты', many: 'Осталось ${minutes} минут', other: 'Осталось ${minutes} минут')}";

  static String m32(count) =>
      "${Intl.plural(count, one: 'Нужна ещё ${count} монета', few: 'Нужно ещё ${count} монеты', many: 'Нужно ещё ${count} монет', other: 'Нужно ещё ${count} монет')}";

  static String m33(app) => "Больше всего - в ${app}";

  static String m34(count) =>
      "${Intl.plural(count, one: '${count} день подряд', few: '${count} дня подряд', many: '${count} дней подряд', other: '${count} дней подряд')}";

  static String m35(total) => "из ${total}";

  static String m36(name) => "Установите Safini на телефон ${name}";

  static String m37(percent) => "${percent}% до следующего уровня";

  static String m38(cost, gap) => "${cost} · ещё ${gap}";

  static String m39(cost, time) => "${cost} монет за ${time}";

  static String m40(cost, time) =>
      "Ребёнок может потратить ${cost} монет, чтобы открыть ${time} сверх дневного лимита.";

  static String m41(minutes) => "осталось ${minutes}м";

  static String m42(name) => "Сохранить для ${name}";

  static String m43(name) => "Сохранено для ${name}";

  static String m44(count) =>
      "${Intl.plural(count, one: '${count} задание', few: '${count} задания', many: '${count} заданий', other: '${count} задания')}";

  static String m45(tasks, coins) => "${tasks} · ${coins}";

  static String m46(scope, tasks) => "${scope} · ${tasks}";

  static String m47(tasks, coins) => "${tasks} осталось - ${coins} на кону";

  static String m48(time) => "${time} осталось";

  static String m49(time) => "${time} использовано";

  static String m50(count) => "ещё ${count}";

  static String m51(name) =>
      "Введите его на телефоне ${name} в разделе «Я ребёнок».";

  static String m52(used, limit) => "${used} исп. / ${limit} лимит";

  static String m53(used) => "${used} · без лимита";

  static String m54(used, limit) => "${used} из ${limit}";

  static String m55(used, limit) => "${used} из ${limit} · превышен";

  static String m56(time) => "${time} сегодня";

  static String m57(count) =>
      "${Intl.plural(count, one: '${count} ожидает', few: '${count} ожидают', many: '${count} ожидают', other: '${count} ожидают')}";

  static String m58(name) => "Ждём телефон ${name}…";

  static String m59(name, coins) => "${name} · ${coins}";

  static String m60(age) =>
      "${Intl.plural(age, one: '${age} год', few: '${age} года', many: '${age} лет', other: '${age} лет')}";

  static String m61(count) =>
      "${Intl.plural(count, one: 'Нужна ещё ${count} монета.', few: 'Нужно ещё ${count} монеты.', many: 'Нужно ещё ${count} монет.', other: 'Нужно ещё ${count} монет.')}";

  static String m62(name) => "${name} (вы)";

  final messages = _notInlinedMessages(_notInlinedMessages);
  static Map<String, Function> _notInlinedMessages(_) => <String, Function>{
    "achievements": MessageLookupByLibrary.simpleMessage("Достижения"),
    "activeTasks": MessageLookupByLibrary.simpleMessage("Активные задания"),
    "addAChild": MessageLookupByLibrary.simpleMessage("Добавить ребёнка"),
    "addAnApp": MessageLookupByLibrary.simpleMessage("Добавить приложение"),
    "addAnotherApp": MessageLookupByLibrary.simpleMessage(
      "Добавить приложение",
    ),
    "addAnotherChild": MessageLookupByLibrary.simpleMessage("Добавить ребенка"),
    "addAppAction": MessageLookupByLibrary.simpleMessage("Добавить"),
    "addChild": MessageLookupByLibrary.simpleMessage("Добавить ребенка"),
    "addPhoto": MessageLookupByLibrary.simpleMessage("Добавить фото"),
    "addShort": MessageLookupByLibrary.simpleMessage("Добавить"),
    "addToEveryonesList": MessageLookupByLibrary.simpleMessage("Добавить всем"),
    "addToList": m0,
    "admin": MessageLookupByLibrary.simpleMessage("Админ"),
    "ageAndGender": m1,
    "ageFieldLabel": MessageLookupByLibrary.simpleMessage("Возраст"),
    "ageLabel": m2,
    "ageMustBeInteger": MessageLookupByLibrary.simpleMessage(
      "Возраст должен быть числом.",
    ),
    "ageRange": MessageLookupByLibrary.simpleMessage(
      "Возраст должен быть от 0 до 18.",
    ),
    "ageRequired": MessageLookupByLibrary.simpleMessage("Укажите возраст."),
    "allCaughtUp": MessageLookupByLibrary.simpleMessage("Всё проверено"),
    "allTasks": MessageLookupByLibrary.simpleMessage("Все задания"),
    "almostYours": MessageLookupByLibrary.simpleMessage("Почти твоё"),
    "alwaysAllowedNoRedemption": MessageLookupByLibrary.simpleMessage(
      "Всегда доступно · без обмена",
    ),
    "appLimits": MessageLookupByLibrary.simpleMessage("Лимиты приложений"),
    "appLimitsSubtitle": MessageLookupByLibrary.simpleMessage(
      "Установите дневные лимиты экранного времени",
    ),
    "appName": MessageLookupByLibrary.simpleMessage("SAFINI"),
    "appTimeItem": m3,
    "appTimeTab": MessageLookupByLibrary.simpleMessage("Приложения"),
    "approve": MessageLookupByLibrary.simpleMessage("Одобрить"),
    "approvePayCoins": m4,
    "approvedTaskConflict": MessageLookupByLibrary.simpleMessage(
      "Одобренные задания нельзя изменить или удалить.",
    ),
    "apps": MessageLookupByLibrary.simpleMessage("Приложения"),
    "askForSomethingNew": MessageLookupByLibrary.simpleMessage(
      "Попроси что-то новое - родитель добавит это в магазин.",
    ),
    "askForThis": MessageLookupByLibrary.simpleMessage("Открыть"),
    "askToRedo": MessageLookupByLibrary.simpleMessage("Переделать"),
    "avatarItem": MessageLookupByLibrary.simpleMessage("Предмет аватара"),
    "avatarItemsTab": MessageLookupByLibrary.simpleMessage("Предметы"),
    "badgeCoins": m5,
    "badgeTasksDone": m6,
    "badges": MessageLookupByLibrary.simpleMessage("Значки"),
    "bothParentsSee": MessageLookupByLibrary.simpleMessage(
      "Оба родителя видят одни и те же задания и могут их одобрять.",
    ),
    "buyIt": MessageLookupByLibrary.simpleMessage("Купить! 🎉"),
    "buysLabel": MessageLookupByLibrary.simpleMessage("Даёт"),
    "canBuyExtraTime": MessageLookupByLibrary.simpleMessage(
      "Можно купить время",
    ),
    "canBuyExtraTimeHint": MessageLookupByLibrary.simpleMessage(
      "Если выключено, дневной лимит окончательный",
    ),
    "cancel": MessageLookupByLibrary.simpleMessage("Отмена"),
    "catAll": MessageLookupByLibrary.simpleMessage("Все"),
    "catFitness": MessageLookupByLibrary.simpleMessage("Спорт"),
    "catHealth": MessageLookupByLibrary.simpleMessage("Здоровье"),
    "catHome": MessageLookupByLibrary.simpleMessage("Дом"),
    "catLearn": MessageLookupByLibrary.simpleMessage("Учёба"),
    "catLogic": MessageLookupByLibrary.simpleMessage("Логика"),
    "catOther": MessageLookupByLibrary.simpleMessage("Другое"),
    "catOutdoor": MessageLookupByLibrary.simpleMessage("Улица"),
    "catSchool": MessageLookupByLibrary.simpleMessage("Школа"),
    "categoryAll": MessageLookupByLibrary.simpleMessage("Все"),
    "categoryFitness": MessageLookupByLibrary.simpleMessage("Спорт"),
    "categoryLearn": MessageLookupByLibrary.simpleMessage("Учеба"),
    "categoryLogic": MessageLookupByLibrary.simpleMessage("Логика"),
    "changeAvatar": MessageLookupByLibrary.simpleMessage("Сменить аватар"),
    "changeLanguage": MessageLookupByLibrary.simpleMessage("Сменить язык"),
    "changeOutfit": MessageLookupByLibrary.simpleMessage(
      "Сменить одежду, прическу и др.",
    ),
    "childInviteCodeTitle": MessageLookupByLibrary.simpleMessage(
      "Код приглашения ребенка",
    ),
    "childProgressTitle": m7,
    "childTasksSubtitle": m8,
    "childUpdatedSuccess": MessageLookupByLibrary.simpleMessage(
      "Профиль ребёнка обновлён.",
    ),
    "chooseFromLibrary": MessageLookupByLibrary.simpleMessage(
      "Выбрать из галереи",
    ),
    "chooseYourRole": MessageLookupByLibrary.simpleMessage("Выберите роль"),
    "cleanTheRoom": MessageLookupByLibrary.simpleMessage("Убраться в комнате"),
    "close": MessageLookupByLibrary.simpleMessage("Закрыть"),
    "codeCopied": MessageLookupByLibrary.simpleMessage("Код скопирован"),
    "codeIsReady": m9,
    "coinCount": m10,
    "coinCountShort": m11,
    "coins": MessageLookupByLibrary.simpleMessage("Монеты"),
    "coinsCount": m12,
    "coinsPaidAfterApproval": MessageLookupByLibrary.simpleMessage(
      "Монеты начисляются только после вашего одобрения. Повторяющиеся задания появятся снова на следующий день.",
    ),
    "coinsReward": m13,
    "coinsText": MessageLookupByLibrary.simpleMessage("Монеты"),
    "coinsToGo": m14,
    "coinsToGoShort": m15,
    "comingSoon": MessageLookupByLibrary.simpleMessage("Скоро будет!"),
    "completeDailyQuests": MessageLookupByLibrary.simpleMessage(
      "Выполняйте ежедневные квесты, чтобы заработать больше монет!",
    ),
    "completed": MessageLookupByLibrary.simpleMessage("Выполнено"),
    "continueAction": MessageLookupByLibrary.simpleMessage("Продолжить"),
    "copy": MessageLookupByLibrary.simpleMessage("Копировать"),
    "copyCode": MessageLookupByLibrary.simpleMessage("Скопировать код"),
    "costsLabel": MessageLookupByLibrary.simpleMessage("Стоит"),
    "createAnInviteCode": MessageLookupByLibrary.simpleMessage(
      "Создать код приглашения",
    ),
    "createChildButton": MessageLookupByLibrary.simpleMessage(
      "Создать ребёнка",
    ),
    "createChildInviteCode": MessageLookupByLibrary.simpleMessage(
      "Создать код для ребенка",
    ),
    "createChildProfileSubtitle": MessageLookupByLibrary.simpleMessage(
      "Заполните данные ниже, чтобы добавить ребёнка в семью.",
    ),
    "createChildProfileTitle": MessageLookupByLibrary.simpleMessage(
      "Создать профиль ребёнка",
    ),
    "createFamilyAction": MessageLookupByLibrary.simpleMessage("Создать семью"),
    "createFamilySubtitle": MessageLookupByLibrary.simpleMessage(
      "Создайте пространство семьи и пригласите остальных",
    ),
    "createOrJoinFamily": MessageLookupByLibrary.simpleMessage(
      "Создайте семью или присоединитесь по коду.",
    ),
    "createParentInviteCode": MessageLookupByLibrary.simpleMessage(
      "Создать код для родителя",
    ),
    "createTaskAddButton": MessageLookupByLibrary.simpleMessage(
      "Добавить задание",
    ),
    "createTaskCategoryDailyChore": MessageLookupByLibrary.simpleMessage(
      "Дело по дому",
    ),
    "createTaskCategoryEducational": MessageLookupByLibrary.simpleMessage(
      "Обучение",
    ),
    "createTaskCategoryHobby": MessageLookupByLibrary.simpleMessage("Хобби"),
    "createTaskCategoryOther": MessageLookupByLibrary.simpleMessage("Другое"),
    "createTaskCategoryTitle": MessageLookupByLibrary.simpleMessage(
      "Категория",
    ),
    "createTaskNameHint": MessageLookupByLibrary.simpleMessage(
      "напр. Убраться в комнате",
    ),
    "createTaskNameLabel": MessageLookupByLibrary.simpleMessage("Название"),
    "createTaskPickEmojiLabel": MessageLookupByLibrary.simpleMessage(
      "Выберите эмодзи",
    ),
    "createTaskRewardLabel": MessageLookupByLibrary.simpleMessage(
      "Награда (Монеты времени)",
    ),
    "createTaskSaveButton": MessageLookupByLibrary.simpleMessage("Сохранить"),
    "createTaskSheetTitle": MessageLookupByLibrary.simpleMessage(
      "Новое задание",
    ),
    "customizeAvatar": MessageLookupByLibrary.simpleMessage("Настроить аватар"),
    "dailyAllowanceFor": m16,
    "dailyChore": MessageLookupByLibrary.simpleMessage("Ежедневное дело"),
    "dailyLimit": MessageLookupByLibrary.simpleMessage("Дневной лимит"),
    "dailyLimitToggle": MessageLookupByLibrary.simpleMessage("Дневной лимит"),
    "dailyLimitToggleHint": MessageLookupByLibrary.simpleMessage(
      "Если выключено, приложение без ограничений",
    ),
    "dateToday": MessageLookupByLibrary.simpleMessage("Сегодня"),
    "dateTomorrow": MessageLookupByLibrary.simpleMessage("Завтра"),
    "dateYesterday": MessageLookupByLibrary.simpleMessage("Вчера"),
    "dayStreak": MessageLookupByLibrary.simpleMessage("Дней подряд"),
    "deleteAccount": MessageLookupByLibrary.simpleMessage("Удалить аккаунт"),
    "deleteAccountChildConfirmBody": MessageLookupByLibrary.simpleMessage(
      "Ваш аккаунт, профиль ребёнка, задания, награды, фотографии-подтверждения и активность будут удалены навсегда. Это действие нельзя отменить.",
    ),
    "deleteAccountConfirmBody": MessageLookupByLibrary.simpleMessage(
      "Вы уверены, что хотите удалить свой аккаунт? Это действие нельзя отменить.",
    ),
    "deleteAccountConfirmTitle": MessageLookupByLibrary.simpleMessage(
      "Удалить аккаунт?",
    ),
    "deleteAccountFailed": MessageLookupByLibrary.simpleMessage(
      "Сессия недействительна. Войдите снова, прежде чем удалять аккаунт.",
    ),
    "deleteAccountParentConfirmBody": MessageLookupByLibrary.simpleMessage(
      "Ваш аккаунт и персональные данные будут удалены навсегда. Если вы единственный родитель, семья и вся активность детей также будут удалены. Это действие нельзя отменить.",
    ),
    "deleteAccountRetry": MessageLookupByLibrary.simpleMessage(
      "Удаление аккаунта временно недоступно. Попробуйте ещё раз.",
    ),
    "deleteTaskBody": MessageLookupByLibrary.simpleMessage(
      "Это нельзя отменить.",
    ),
    "deleteTaskButton": MessageLookupByLibrary.simpleMessage("Удалить"),
    "deleteTaskTitle": MessageLookupByLibrary.simpleMessage("Удалить задание?"),
    "deletingAccount": MessageLookupByLibrary.simpleMessage("Удаляем аккаунт…"),
    "detailsFieldLabel": MessageLookupByLibrary.simpleMessage("Детали"),
    "detailsSection": MessageLookupByLibrary.simpleMessage("Данные"),
    "displayNameFallback": MessageLookupByLibrary.simpleMessage("Родитель"),
    "doHomework": MessageLookupByLibrary.simpleMessage("Сделать уроки"),
    "doThisNext": MessageLookupByLibrary.simpleMessage("Следующее"),
    "doneAction": MessageLookupByLibrary.simpleMessage("Готово"),
    "doneToday": MessageLookupByLibrary.simpleMessage("Сделано"),
    "earnMoreCoins": MessageLookupByLibrary.simpleMessage(
      "Заработать больше монет",
    ),
    "earnedToday": MessageLookupByLibrary.simpleMessage("Заработано"),
    "edit": MessageLookupByLibrary.simpleMessage("Изменить"),
    "editChild": MessageLookupByLibrary.simpleMessage("Редактировать ребенка"),
    "editMyProfile": MessageLookupByLibrary.simpleMessage(
      "Изменить мой профиль",
    ),
    "editName": m17,
    "editProfile": MessageLookupByLibrary.simpleMessage(
      "Редактировать профиль",
    ),
    "editProfileSubtitle": MessageLookupByLibrary.simpleMessage(
      "Обновите данные ребёнка ниже.",
    ),
    "editTaskSheetTitle": MessageLookupByLibrary.simpleMessage(
      "Изменить задание",
    ),
    "educational": MessageLookupByLibrary.simpleMessage("Образование"),
    "emailHint": MessageLookupByLibrary.simpleMessage("reviewer@primer.ru"),
    "emailLabel": MessageLookupByLibrary.simpleMessage("Эл. почта"),
    "emailRequired": MessageLookupByLibrary.simpleMessage(
      "Введите корректный email",
    ),
    "emailSignInDescription": MessageLookupByLibrary.simpleMessage(
      "Только для отладки и проверки App Review.",
    ),
    "emailSignInTitle": MessageLookupByLibrary.simpleMessage(
      "Вход в тестовый аккаунт",
    ),
    "emptyActiveBody": MessageLookupByLibrary.simpleMessage(
      "Добавьте кнопкой ниже.",
    ),
    "emptyDoneBody": MessageLookupByLibrary.simpleMessage(
      "Одобренные задания появятся здесь.",
    ),
    "emptyNoActiveTasks": MessageLookupByLibrary.simpleMessage(
      "Нет активных заданий",
    ),
    "emptyNothingPaidYet": MessageLookupByLibrary.simpleMessage(
      "Пока ничего не оплачено",
    ),
    "emptyNothingToReview": MessageLookupByLibrary.simpleMessage(
      "Нечего проверять",
    ),
    "emptyReviewBody": MessageLookupByLibrary.simpleMessage(
      "Новые заявки появятся здесь.",
    ),
    "english": MessageLookupByLibrary.simpleMessage("Английский"),
    "equipped": MessageLookupByLibrary.simpleMessage("НАДЕТО"),
    "everyAppSetUp": MessageLookupByLibrary.simpleMessage(
      "Все приложения уже настроены",
    ),
    "everythingIsWithParent": MessageLookupByLibrary.simpleMessage(
      "Всё у родителя",
    ),
    "everythingSent": MessageLookupByLibrary.simpleMessage("Всё отправлено"),
    "expiresLabel": m18,
    "expiresTonight": MessageLookupByLibrary.simpleMessage(
      "Используй сегодня, в полночь сгорит.",
    ),
    "extraBackpack": MessageLookupByLibrary.simpleMessage("Рюкзак"),
    "extraHair": MessageLookupByLibrary.simpleMessage("Причёска"),
    "extraOutfit": MessageLookupByLibrary.simpleMessage("Одежда"),
    "extrasFootnote": MessageLookupByLibrary.simpleMessage(
      "Дополнения покупаются один раз. На задания это не влияет.",
    ),
    "extrasSection": MessageLookupByLibrary.simpleMessage("Дополнения"),
    "faceSection": MessageLookupByLibrary.simpleMessage("Лицо"),
    "family": MessageLookupByLibrary.simpleMessage("Семья"),
    "familyAdmin": MessageLookupByLibrary.simpleMessage("Админ семьи"),
    "familyDecisionSubtitle": MessageLookupByLibrary.simpleMessage(
      "Создайте семейное пространство и пригласите детей зарабатывать экранное время.",
    ),
    "familyLabel": MessageLookupByLibrary.simpleMessage("Семья"),
    "footerText": MessageLookupByLibrary.simpleMessage(
      "Безопасное экранное время для умных детей 🌟",
    ),
    "free": MessageLookupByLibrary.simpleMessage("БЕСПЛАТНО"),
    "fri": MessageLookupByLibrary.simpleMessage("ПТ"),
    "genderBoy": MessageLookupByLibrary.simpleMessage("Мальчик"),
    "genderGirl": MessageLookupByLibrary.simpleMessage("Девочка"),
    "genderOptional": MessageLookupByLibrary.simpleMessage(
      "Пол (необязательно)",
    ),
    "genderOther": MessageLookupByLibrary.simpleMessage("Другое"),
    "genericErrorRetry": MessageLookupByLibrary.simpleMessage(
      "Что-то пошло не так. Попробуйте ещё раз.",
    ),
    "goToMyFamily": MessageLookupByLibrary.simpleMessage("К моей семье"),
    "goToTasks": MessageLookupByLibrary.simpleMessage("Перейти к заданиям"),
    "goodAfternoon": MessageLookupByLibrary.simpleMessage("Добрый день 👋"),
    "goodEvening": MessageLookupByLibrary.simpleMessage("Добрый вечер 👋"),
    "goodMorning": MessageLookupByLibrary.simpleMessage("Доброе утро 👋"),
    "goodNight": MessageLookupByLibrary.simpleMessage("Доброй ночи 🌙"),
    "googleClientIdMissing": MessageLookupByLibrary.simpleMessage(
      "Не задан Google Web Client ID. Укажите GOOGLE_WEB_CLIENT_ID (OAuth Web в Google Cloud).",
    ),
    "holdToMarkDone": MessageLookupByLibrary.simpleMessage(
      "Удерживай, чтобы отметить",
    ),
    "home": MessageLookupByLibrary.simpleMessage("Главная"),
    "iconSection": MessageLookupByLibrary.simpleMessage("Значок"),
    "imAKid": MessageLookupByLibrary.simpleMessage("Я ребенок!"),
    "imAParent": MessageLookupByLibrary.simpleMessage("Я родитель"),
    "inTheFamilySince": MessageLookupByLibrary.simpleMessage("В семье с"),
    "installedAppsCount": m19,
    "installedAppsEmptyBody": m20,
    "installedAppsEmptyTitle": MessageLookupByLibrary.simpleMessage(
      "Приложения ещё не синхронизированы",
    ),
    "installedAppsSubtitle": m21,
    "installedAppsTitle": MessageLookupByLibrary.simpleMessage(
      "Установленные приложения",
    ),
    "inviteAParent": MessageLookupByLibrary.simpleMessage(
      "Пригласить родителя",
    ),
    "inviteAParentBody": MessageLookupByLibrary.simpleMessage(
      "Пусть установят Safini, войдут и введут этот код.",
    ),
    "inviteChildOrRefresh": MessageLookupByLibrary.simpleMessage(
      "Пригласите ребенка или обновите страницу.",
    ),
    "inviteCodeCopied": MessageLookupByLibrary.simpleMessage("Код скопирован"),
    "inviteCodeValid": MessageLookupByLibrary.simpleMessage(
      "Код приглашения · 24 часа",
    ),
    "invited": MessageLookupByLibrary.simpleMessage("Приглашён"),
    "joinFamilyAction": MessageLookupByLibrary.simpleMessage("Войти по коду"),
    "joinFamilySubtitle": MessageLookupByLibrary.simpleMessage(
      "Используйте код от второго родителя",
    ),
    "keepHolding": MessageLookupByLibrary.simpleMessage("Держи…"),
    "kidHasLeftToday": m22,
    "kidSubtitle": MessageLookupByLibrary.simpleMessage(
      "Зарабатывай монеты и играй",
    ),
    "kidUsedToday": m23,
    "kidsApps": m24,
    "kidsEarnTimeCoins": MessageLookupByLibrary.simpleMessage(
      "Дети зарабатывают Монеты Времени, чтобы разблокировать минуты для этих приложений.",
    ),
    "laneActive": MessageLookupByLibrary.simpleMessage("Активные"),
    "laneDone": MessageLookupByLibrary.simpleMessage("Готово"),
    "laneToReview": MessageLookupByLibrary.simpleMessage("На проверку"),
    "lessons": MessageLookupByLibrary.simpleMessage("Уроки"),
    "lessonsChangeText": MessageLookupByLibrary.simpleMessage("+1 сегодня"),
    "levelHero": m25,
    "levelShort": MessageLookupByLibrary.simpleMessage("Уровень"),
    "levelValue": m26,
    "limitThisApp": MessageLookupByLibrary.simpleMessage(
      "Ограничить приложение",
    ),
    "limitsFootnote": MessageLookupByLibrary.simpleMessage(
      "Когда дневной лимит закончится, приложение перестанет открываться и покажет экран Safini.",
    ),
    "limitsNotYetEnforced": MessageLookupByLibrary.simpleMessage(
      "Лимиты считаются, но пока не применяются. Завершите настройку на телефоне ребёнка.",
    ),
    "limitsSubtitle": m27,
    "lockedLabel": MessageLookupByLibrary.simpleMessage("Закрыто"),
    "loginBack": MessageLookupByLibrary.simpleMessage("Назад"),
    "loginSubtitle": MessageLookupByLibrary.simpleMessage(
      "Продолжите с аккаунтом Google",
    ),
    "loginTitle": MessageLookupByLibrary.simpleMessage("Вход"),
    "loginWithEmailTest": MessageLookupByLibrary.simpleMessage(
      "Войти по email (тест)",
    ),
    "loginWithGoogle": MessageLookupByLibrary.simpleMessage(
      "Продолжить с Google",
    ),
    "logout": MessageLookupByLibrary.simpleMessage("Выйти"),
    "logoutConfirmBody": MessageLookupByLibrary.simpleMessage(
      "Вы уверены, что хотите выйти из аккаунта?",
    ),
    "logoutConfirmTitle": MessageLookupByLibrary.simpleMessage("Выйти?"),
    "lookCloser": MessageLookupByLibrary.simpleMessage("Посмотреть"),
    "manageAll": MessageLookupByLibrary.simpleMessage("Управлять всем"),
    "markItDone": MessageLookupByLibrary.simpleMessage("Отметить выполненным"),
    "minuteCount": m28,
    "minutes": MessageLookupByLibrary.simpleMessage("Минуты"),
    "minutesLeftShort": m29,
    "minutesLeftToday": m30,
    "minutesPerPurchase": MessageLookupByLibrary.simpleMessage(
      "Минут за покупку",
    ),
    "minutesRemainingLong": m31,
    "mon": MessageLookupByLibrary.simpleMessage("ПН"),
    "monitor": MessageLookupByLibrary.simpleMessage("Мониторинг"),
    "moreCoinsNeeded": m32,
    "mostOfItIn": m33,
    "myAvatar": MessageLookupByLibrary.simpleMessage("Мой аватар"),
    "myFamily": MessageLookupByLibrary.simpleMessage("Моя семья"),
    "myProfile": MessageLookupByLibrary.simpleMessage("Мой профиль"),
    "myQuests": MessageLookupByLibrary.simpleMessage("Мои квесты"),
    "nDayStreak": m34,
    "name": MessageLookupByLibrary.simpleMessage("Имя"),
    "nameHintExample": MessageLookupByLibrary.simpleMessage("Амир"),
    "nameYourFamily": MessageLookupByLibrary.simpleMessage(
      "Назовите так, чтобы узнала вся семья. Пригласить участников можно после создания.",
    ),
    "needsPhotoProof": MessageLookupByLibrary.simpleMessage("Нужно фото"),
    "needsYourReview": MessageLookupByLibrary.simpleMessage("Требует проверки"),
    "networkError": MessageLookupByLibrary.simpleMessage(
      "Ошибка сети. Проверьте подключение.",
    ),
    "newBtn": MessageLookupByLibrary.simpleMessage("Новое"),
    "newSubmissionsLandHere": MessageLookupByLibrary.simpleMessage(
      "Новые заявки появятся здесь.",
    ),
    "newTask": MessageLookupByLibrary.simpleMessage("Новое задание"),
    "nicknameLabel": MessageLookupByLibrary.simpleMessage("Имя"),
    "nicknameRequired": MessageLookupByLibrary.simpleMessage("Введите имя."),
    "nicknameTooLong": MessageLookupByLibrary.simpleMessage(
      "Имя не должно превышать 80 символов.",
    ),
    "noChildYetBody": MessageLookupByLibrary.simpleMessage(
      "Добавьте ребёнка - и его день появится здесь.",
    ),
    "noChildrenFoundYet": MessageLookupByLibrary.simpleMessage(
      "Дети пока не добавлены",
    ),
    "noChildrenYet": MessageLookupByLibrary.simpleMessage("Пока нет детей"),
    "noChildrenYetBody": MessageLookupByLibrary.simpleMessage(
      "Добавьте ребёнка - и он получит код для связи.",
    ),
    "noCodeAskParent": MessageLookupByLibrary.simpleMessage(
      "Нет кода? Попросите родителя открыть Safini и раздел «Моя семья».",
    ),
    "noCodeAskThem": MessageLookupByLibrary.simpleMessage(
      "Нет кода? Попросите их открыть Safini и раздел «Моя семья».",
    ),
    "noFamilySetupYet": MessageLookupByLibrary.simpleMessage(
      "Семья еще не настроена",
    ),
    "noFreeTime": MessageLookupByLibrary.simpleMessage(
      "Без бесплатного времени",
    ),
    "noLimitLabel": MessageLookupByLibrary.simpleMessage("Без лимита"),
    "noLimitsSet": MessageLookupByLibrary.simpleMessage("Лимиты не заданы"),
    "noQuestsInCategory": MessageLookupByLibrary.simpleMessage(
      "Нет квестов в этой категории",
    ),
    "noScreenTimeCap": MessageLookupByLibrary.simpleMessage(
      "Без общего лимита",
    ),
    "noTasksYet": MessageLookupByLibrary.simpleMessage(
      "На этот день заданий пока нет.",
    ),
    "notEnoughCoins": MessageLookupByLibrary.simpleMessage(
      "Недостаточно монет!",
    ),
    "notPairedYet": MessageLookupByLibrary.simpleMessage("Ещё не связан"),
    "notRecorded": MessageLookupByLibrary.simpleMessage("Не указано"),
    "notSet": MessageLookupByLibrary.simpleMessage("Не указано"),
    "notYet": MessageLookupByLibrary.simpleMessage("Не сейчас"),
    "noteForParent": MessageLookupByLibrary.simpleMessage(
      "Заметка родителю · необязательно",
    ),
    "noteFromParent": MessageLookupByLibrary.simpleMessage(
      "Заметка от родителя",
    ),
    "nothingHereYet": MessageLookupByLibrary.simpleMessage("Здесь пока пусто"),
    "nothingInStore": MessageLookupByLibrary.simpleMessage(
      "В магазине пока пусто.",
    ),
    "nothingLeft": MessageLookupByLibrary.simpleMessage("Ничего не осталось"),
    "ofTotal": m35,
    "offMeansAlwaysAllowed": MessageLookupByLibrary.simpleMessage(
      "Выключено - доступно всегда",
    ),
    "ok": MessageLookupByLibrary.simpleMessage("ОК"),
    "on": MessageLookupByLibrary.simpleMessage("ВКЛ"),
    "openOneFromList": MessageLookupByLibrary.simpleMessage(
      "Откройте приложение из списка, чтобы изменить лимит.",
    ),
    "outfitsAndItems": MessageLookupByLibrary.simpleMessage(
      "Одежда и предметы",
    ),
    "paidOutNice": MessageLookupByLibrary.simpleMessage("Оплачено. Отлично."),
    "pairStepAllow": MessageLookupByLibrary.simpleMessage(
      "Разрешите доступ к экранному времени",
    ),
    "pairStepInstall": m36,
    "pairStepTap": MessageLookupByLibrary.simpleMessage(
      "Нажмите «Я ребёнок» и введите код",
    ),
    "paired": MessageLookupByLibrary.simpleMessage("Связан"),
    "pairingCodeCaption": MessageLookupByLibrary.simpleMessage("Код связи"),
    "parentAccount": MessageLookupByLibrary.simpleMessage("АККАУНТ РОДИТЕЛЯ"),
    "parentHomeScreen": MessageLookupByLibrary.simpleMessage(
      "Главный экран родителя",
    ),
    "parentInviteCodeTitle": MessageLookupByLibrary.simpleMessage(
      "Код приглашения родителя",
    ),
    "parentName": MessageLookupByLibrary.simpleMessage("Родитель Safini"),
    "parentReviewsNext": MessageLookupByLibrary.simpleMessage(
      "Родитель проверит их дальше. Монеты придут после этого.",
    ),
    "parentSubtitle": MessageLookupByLibrary.simpleMessage(
      "Контролируй и награждай",
    ),
    "parents": MessageLookupByLibrary.simpleMessage("Родители"),
    "passwordHint": MessageLookupByLibrary.simpleMessage("Введите пароль"),
    "passwordLabel": MessageLookupByLibrary.simpleMessage("Пароль"),
    "passwordRequired": MessageLookupByLibrary.simpleMessage("Введите пароль"),
    "pendingApproval": MessageLookupByLibrary.simpleMessage("Ожидают проверки"),
    "percentToNextLevel": m37,
    "photoProofAsked": MessageLookupByLibrary.simpleMessage(
      "Запрошено фото-подтверждение",
    ),
    "photoRequired": MessageLookupByLibrary.simpleMessage(
      "Для этого задания нужно фото.",
    ),
    "photoUploadFailed": MessageLookupByLibrary.simpleMessage(
      "Не удалось загрузить фото. Попробуйте ещё раз.",
    ),
    "pickAtLeastOneDay": MessageLookupByLibrary.simpleMessage(
      "Выберите хотя бы один день.",
    ),
    "pillCheck": MessageLookupByLibrary.simpleMessage("Проверить"),
    "pillPaid": MessageLookupByLibrary.simpleMessage("Оплачено"),
    "pillWaiting": MessageLookupByLibrary.simpleMessage("Ждёт"),
    "priceAndGap": m38,
    "priceLabel": MessageLookupByLibrary.simpleMessage("Цена"),
    "priceUnit": m39,
    "privacyPolicy": MessageLookupByLibrary.simpleMessage(
      "Политика конфиденциальности",
    ),
    "privacyPolicyOpenFailed": MessageLookupByLibrary.simpleMessage(
      "Не удалось открыть политику конфиденциальности.",
    ),
    "privacyPolicySubtitle": MessageLookupByLibrary.simpleMessage(
      "Как Safini обрабатывает данные семьи",
    ),
    "profile": MessageLookupByLibrary.simpleMessage("Профиль"),
    "profileUpdated": MessageLookupByLibrary.simpleMessage("Сохранено"),
    "questsDone": MessageLookupByLibrary.simpleMessage("Заданий выполнено"),
    "questsText": MessageLookupByLibrary.simpleMessage("Задания"),
    "readFor20Mins": MessageLookupByLibrary.simpleMessage("Читать 20 мин"),
    "readyToSpend": MessageLookupByLibrary.simpleMessage(
      "Готовы потратить монеты?",
    ),
    "readyWhenYouAre": MessageLookupByLibrary.simpleMessage("Можно начинать"),
    "realWorldTasks": MessageLookupByLibrary.simpleMessage("Задания в жизни"),
    "reconnectCodeValid": MessageLookupByLibrary.simpleMessage(
      "Код повторной связи · 24 часа",
    ),
    "reconnectWithCode": MessageLookupByLibrary.simpleMessage(
      "Связать заново по коду",
    ),
    "redeemExplainer": m40,
    "reject": MessageLookupByLibrary.simpleMessage("Отклонить"),
    "remaining": MessageLookupByLibrary.simpleMessage("Осталось"),
    "remainingTime": m41,
    "removeFromFamily": MessageLookupByLibrary.simpleMessage("Убрать из семьи"),
    "removeParent": MessageLookupByLibrary.simpleMessage("Удалить из семьи"),
    "removeParentConfirmBody": MessageLookupByLibrary.simpleMessage(
      "Вы уверены, что хотите удалить этого родителя из семьи?",
    ),
    "removeParentConfirmTitle": MessageLookupByLibrary.simpleMessage(
      "Удалить родителя?",
    ),
    "repeatDaily": MessageLookupByLibrary.simpleMessage("Каждый день"),
    "repeatDailyShort": MessageLookupByLibrary.simpleMessage("Ежедневно"),
    "repeatLabel": MessageLookupByLibrary.simpleMessage("Повтор"),
    "repeatOnce": MessageLookupByLibrary.simpleMessage("Один раз"),
    "repeatWeekly": MessageLookupByLibrary.simpleMessage("По дням"),
    "repeatWeeklyShort": MessageLookupByLibrary.simpleMessage("Еженедельно"),
    "retakePhoto": MessageLookupByLibrary.simpleMessage("Переснять"),
    "retry": MessageLookupByLibrary.simpleMessage("Повторить"),
    "reviewNoteHint": MessageLookupByLibrary.simpleMessage(
      "Добавить заметку (необязательно)",
    ),
    "reviewTaskSheetTitle": MessageLookupByLibrary.simpleMessage(
      "Проверить задание",
    ),
    "rewardBlurbAppTime": MessageLookupByLibrary.simpleMessage(
      "Добавится сразу. Используй сегодня, в полночь сгорит.",
    ),
    "rewardBlurbAvatar": MessageLookupByLibrary.simpleMessage(
      "Надень на аватар. Останется у тебя.",
    ),
    "rewardFieldLabel": MessageLookupByLibrary.simpleMessage("Награда"),
    "rewardStore": MessageLookupByLibrary.simpleMessage("Магазин наград"),
    "roleLabel": MessageLookupByLibrary.simpleMessage("Роль"),
    "roleOwner": MessageLookupByLibrary.simpleMessage("Владелец"),
    "roleParent": MessageLookupByLibrary.simpleMessage("Родитель"),
    "roleSelectionSubtitle": MessageLookupByLibrary.simpleMessage(
      "Как вы будете использовать Safini?",
    ),
    "russian": MessageLookupByLibrary.simpleMessage("Русский"),
    "sat": MessageLookupByLibrary.simpleMessage("СБ"),
    "save": MessageLookupByLibrary.simpleMessage("Сохранить"),
    "saveChanges": MessageLookupByLibrary.simpleMessage("Сохранить изменения"),
    "saveForName": m42,
    "saveMyLook": MessageLookupByLibrary.simpleMessage("Сохранить вид!"),
    "savedForName": m43,
    "scopeEveryone": MessageLookupByLibrary.simpleMessage("Все"),
    "screenTime": MessageLookupByLibrary.simpleMessage("Экранное время"),
    "screenTimeCap": MessageLookupByLibrary.simpleMessage(
      "Экранное время в день",
    ),
    "screenTimeCapHint": MessageLookupByLibrary.simpleMessage(
      "На все приложения вместе. Если выключено, только лимиты приложений.",
    ),
    "sectionAccount": MessageLookupByLibrary.simpleMessage("Аккаунт"),
    "sectionApp": MessageLookupByLibrary.simpleMessage("Приложение"),
    "seeAllApps": MessageLookupByLibrary.simpleMessage(
      "Все приложения на телефоне",
    ),
    "selectLanguage": MessageLookupByLibrary.simpleMessage("Выберите язык"),
    "setUpANewProfile": MessageLookupByLibrary.simpleMessage(
      "Создать новый профиль",
    ),
    "settings": MessageLookupByLibrary.simpleMessage("Настройки"),
    "setupYourFamily": MessageLookupByLibrary.simpleMessage("Настройте семью"),
    "signInAction": MessageLookupByLibrary.simpleMessage("Войти"),
    "signInError": MessageLookupByLibrary.simpleMessage(
      "Не удалось войти. Попробуйте ещё раз.",
    ),
    "signedInSuccess": MessageLookupByLibrary.simpleMessage("Вход выполнен"),
    "signingIn": MessageLookupByLibrary.simpleMessage("Вход..."),
    "spendYourTimeCoins": MessageLookupByLibrary.simpleMessage(
      "Потратьте свои монеты времени",
    ),
    "statCoins": MessageLookupByLibrary.simpleMessage("Монет"),
    "statDayStreak": MessageLookupByLibrary.simpleMessage("Дней подряд"),
    "statTasksDone": MessageLookupByLibrary.simpleMessage("Заданий"),
    "statusActive": MessageLookupByLibrary.simpleMessage("АКТИВНО"),
    "statusDone": MessageLookupByLibrary.simpleMessage("ГОТОВО"),
    "statusPending": MessageLookupByLibrary.simpleMessage("ОЖИДАЕТ"),
    "step1of2": MessageLookupByLibrary.simpleMessage(
      "Шаг 1 из 2 - других детей можно добавить позже.",
    ),
    "step2of2": MessageLookupByLibrary.simpleMessage(
      "Шаг 2 из 2 - код действует 24 часа.",
    ),
    "steps": MessageLookupByLibrary.simpleMessage("Шаги"),
    "stepsChangeText": MessageLookupByLibrary.simpleMessage(
      "+12% по сравнению со вчера",
    ),
    "stepsToday": MessageLookupByLibrary.simpleMessage("Шагов сегодня"),
    "store": MessageLookupByLibrary.simpleMessage("Магазин"),
    "storeAppTimeTab": MessageLookupByLibrary.simpleMessage(
      "Время в приложениях",
    ),
    "storeAvatarTab": MessageLookupByLibrary.simpleMessage("Аватар"),
    "storeSubtitle": MessageLookupByLibrary.simpleMessage(
      "Твои монеты, твой выбор",
    ),
    "streakText": MessageLookupByLibrary.simpleMessage("Подряд"),
    "sun": MessageLookupByLibrary.simpleMessage("ВС"),
    "supabaseConfigMissing": MessageLookupByLibrary.simpleMessage(
      "Не заданы URL или anon-ключ Supabase. Укажите SUPABASE_URL и SUPABASE_ANON_KEY при запуске.",
    ),
    "surname": MessageLookupByLibrary.simpleMessage("Фамилия"),
    "switchToKidMode": MessageLookupByLibrary.simpleMessage(
      "Режим ребенка / Выход",
    ),
    "tabFamily": MessageLookupByLibrary.simpleMessage("Семья"),
    "tabLimits": MessageLookupByLibrary.simpleMessage("Лимиты"),
    "tabMe": MessageLookupByLibrary.simpleMessage("Я"),
    "tabStore": MessageLookupByLibrary.simpleMessage("Магазин"),
    "tabTasks": MessageLookupByLibrary.simpleMessage("Задания"),
    "tabToday": MessageLookupByLibrary.simpleMessage("Сегодня"),
    "tagline": MessageLookupByLibrary.simpleMessage(
      "Учись. Зарабатывай. Играй.",
    ),
    "takePhoto": MessageLookupByLibrary.simpleMessage("Сделать фото"),
    "taskApprovedMessage": MessageLookupByLibrary.simpleMessage(
      "Задание одобрено!",
    ),
    "taskChessSub": MessageLookupByLibrary.simpleMessage("Освой доску"),
    "taskChessTitle": MessageLookupByLibrary.simpleMessage("Урок шахмат"),
    "taskCount": m44,
    "taskCreatedMessage": MessageLookupByLibrary.simpleMessage(
      "Задание создано!",
    ),
    "taskDeletedMessage": MessageLookupByLibrary.simpleMessage(
      "Задание удалено.",
    ),
    "taskDetailsHint": MessageLookupByLibrary.simpleMessage(
      "Что считается выполненным? Необязательно.",
    ),
    "taskDuolingoSub": MessageLookupByLibrary.simpleMessage("Бонус за серию!"),
    "taskDuolingoTitle": MessageLookupByLibrary.simpleMessage(
      "Пройти Duolingo",
    ),
    "taskFieldLabel": MessageLookupByLibrary.simpleMessage("Задание"),
    "taskGroupSummary": m45,
    "taskPuzzleSub": MessageLookupByLibrary.simpleMessage("Зарядка для ума"),
    "taskPuzzleTitle": MessageLookupByLibrary.simpleMessage(
      "Логическая головоломка",
    ),
    "taskReadingSub": MessageLookupByLibrary.simpleMessage("Расширяй кругозор"),
    "taskReadingTitle": MessageLookupByLibrary.simpleMessage("Читать 20 мин"),
    "taskRejectedMessage": MessageLookupByLibrary.simpleMessage(
      "Задание отклонено.",
    ),
    "taskRoomSub": MessageLookupByLibrary.simpleMessage("Ежедневное дело"),
    "taskRoomTitle": MessageLookupByLibrary.simpleMessage("Убраться в комнате"),
    "taskScopeLine": m46,
    "taskStepsSub": MessageLookupByLibrary.simpleMessage("Больше движения!"),
    "taskStepsTitle": MessageLookupByLibrary.simpleMessage(
      "Пройти 5,000 шагов",
    ),
    "taskSubmittedForReview": MessageLookupByLibrary.simpleMessage(
      "Отправлено родителю",
    ),
    "taskTitleHint": MessageLookupByLibrary.simpleMessage("Полить цветы"),
    "taskUpdatedMessage": MessageLookupByLibrary.simpleMessage(
      "Задание обновлено!",
    ),
    "tasks": MessageLookupByLibrary.simpleMessage("Задания"),
    "tasksAndRewards": MessageLookupByLibrary.simpleMessage(
      "Задания и награды",
    ),
    "tasksLeftCoinsOnTable": m47,
    "theirNote": MessageLookupByLibrary.simpleMessage("Его заметка"),
    "theyInstallSafini": MessageLookupByLibrary.simpleMessage(
      "Пусть установят Safini, войдут и введут этот код.",
    ),
    "thisWeek": MessageLookupByLibrary.simpleMessage("На этой неделе"),
    "thu": MessageLookupByLibrary.simpleMessage("ЧТ"),
    "timeCoins": MessageLookupByLibrary.simpleMessage("Монеты времени"),
    "timeLeft": m48,
    "timeUsed": m49,
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
    "toGo": m50,
    "todaysQuests": MessageLookupByLibrary.simpleMessage("Сегодняшние задания"),
    "tryAgain": MessageLookupByLibrary.simpleMessage("Повторить"),
    "tue": MessageLookupByLibrary.simpleMessage("ВТ"),
    "typeCodeFromOtherParent": MessageLookupByLibrary.simpleMessage(
      "Введите код от второго родителя",
    ),
    "typeCodeFromParent": MessageLookupByLibrary.simpleMessage(
      "Введите код от родителя",
    ),
    "typeItOnPhone": m51,
    "unitHour": MessageLookupByLibrary.simpleMessage("ч"),
    "unitMinute": MessageLookupByLibrary.simpleMessage("мин"),
    "unlockExtraTime": MessageLookupByLibrary.simpleMessage(
      "Разблокировать время",
    ),
    "unlockOnceKeepForever": MessageLookupByLibrary.simpleMessage(
      "Открой один раз - останется навсегда",
    ),
    "unlocked": MessageLookupByLibrary.simpleMessage("разблокировано"),
    "usedLimit": m52,
    "usedNoLimit": m53,
    "usedOfLimit": m54,
    "usedOfLimitOver": m55,
    "usedTodayShort": m56,
    "uzbek": MessageLookupByLibrary.simpleMessage("Узбекский"),
    "viewAsKid": MessageLookupByLibrary.simpleMessage("Войти как ребенок"),
    "waitingCount": m57,
    "waitingForParentCheck": MessageLookupByLibrary.simpleMessage(
      "Ждём проверки родителя",
    ),
    "waitingForPhone": m58,
    "wearLabel": MessageLookupByLibrary.simpleMessage("Надеть"),
    "wed": MessageLookupByLibrary.simpleMessage("СР"),
    "weekdayFri": MessageLookupByLibrary.simpleMessage("Пт"),
    "weekdayMon": MessageLookupByLibrary.simpleMessage("Пн"),
    "weekdaySat": MessageLookupByLibrary.simpleMessage("Сб"),
    "weekdaySun": MessageLookupByLibrary.simpleMessage("Вс"),
    "weekdayThu": MessageLookupByLibrary.simpleMessage("Чт"),
    "weekdayTue": MessageLookupByLibrary.simpleMessage("Вт"),
    "weekdayWed": MessageLookupByLibrary.simpleMessage("Ср"),
    "weeklyScreenTime": MessageLookupByLibrary.simpleMessage(
      "Экранное время за неделю",
    ),
    "whereTheTimeWent": MessageLookupByLibrary.simpleMessage("Куда ушло время"),
    "whoAreWeSettingUp": MessageLookupByLibrary.simpleMessage(
      "Кого настраиваем?",
    ),
    "whoSection": MessageLookupByLibrary.simpleMessage("Кому"),
    "wornLabel": MessageLookupByLibrary.simpleMessage("Надето"),
    "worthCoins": m59,
    "yearsOld": m60,
    "youNeedMoreCoins": m61,
    "youSuffix": m62,
    "yourAccount": MessageLookupByLibrary.simpleMessage("Ваш аккаунт"),
    "yourAvatar": MessageLookupByLibrary.simpleMessage("Твой аватар"),
    "yourChildren": MessageLookupByLibrary.simpleMessage("ВАШИ ДЕТИ"),
    "yourName": MessageLookupByLibrary.simpleMessage("Ваше имя"),
    "yoursLabel": MessageLookupByLibrary.simpleMessage("Твоё"),
  };
}
