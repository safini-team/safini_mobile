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

  static String m0(name) => "Добавить для ${name}";

  static String m1(name) => "Добавить ${name}";

  static String m2(age, gender) => "Возраст ${age} • ${gender}";

  static String m3(age) => "Возраст: ${age}";

  static String m4(app, minutes) => "${app} · ${minutes} м";

  static String m5(minutes) => "${minutes} м";

  static String m6(coins) => "Одобрить · начислить ${coins}";

  static String m7(name) => "Одобрено · ${name}";

  static String m8(when) => "Одобрено · ${when}";

  static String m9(name) => "На переделку · ${name}";

  static String m10(time) => "В среднем ${time} в день";

  static String m11(count) =>
      "${Intl.plural(count, one: '${count} монета', few: '${count} монеты', many: '${count} монет', other: '${count} монет')}";

  static String m12(count) =>
      "${Intl.plural(count, one: '${count} задание', few: '${count} задания', many: '${count} заданий', other: '${count} заданий')}";

  static String m13(time) => "Приложения заблокированы до ${time}.";

  static String m14(time) => "Обновится: ${time}";

  static String m15(name) => "Прогресс ${name}";

  static String m16(done, total, coins) =>
      "${done} из ${total} сегодня · ${coins} монет ждут";

  static String m17(name) => "Код для ${name} готов";

  static String m18(count) =>
      "${Intl.plural(count, one: '${count} монета', few: '${count} монеты', many: '${count} монет', other: '${count} монет')}";

  static String m19(count) =>
      "${Intl.plural(count, one: '${count} монета', few: '${count} монеты', many: '${count} монет', other: '${count} монет')}";

  static String m20(count) =>
      "${Intl.plural(count, one: '${count} монета', few: '${count} монеты', many: '${count} монет', other: '${count} монет')}";

  static String m21(count) =>
      "${Intl.plural(count, one: 'Награда: ${count} монета', few: 'Награда: ${count} монеты', many: 'Награда: ${count} монет', other: 'Награда: ${count} монет')}";

  static String m22(name) => "${name} · дневной лимит";

  static String m23(time) => "Дневной лимит · ${time}";

  static String m24(name) => "Изменить ${name}";

  static String m25(date, time) => "Истекает: ${date}, ${time}";

  static String m26(name) => "Всё, что Fini сделал для ${name}";

  static String m27(name) => "Цель для ${name}";

  static String m28(time) => "Разрешить ${time} в день";

  static String m29(time) =>
      "Fini не понял, что это за приложение. Пока вы не выберете, новые приложения делят ${time} в день.";

  static String m30(time) => "Делит с ними ${time} в день.";

  static String m31(name, minutes) => "${name} просит ещё ${minutes} мин";

  static String m32(app, time) => "Снизить ${app} до ${time} в день?";

  static String m33(app, time) => "Поднять ${app} до ${time} в день?";

  static String m34(goal) => "${goal}: время на сегодня закончилось.";

  static String m35(app) => "Новое приложение: ${app}. Куда его отнести?";

  static String m36(app, category) => "Отнести ${app} к «${category}»?";

  static String m37(app, time) => "${app}: свои ${time} в день";

  static String m38(app) => "Заблокирован ${app}";

  static String m39(minutes) => "Добавлено ${minutes} мин";

  static String m40(app, time) => "${app}: ${time} в день";

  static String m41(name) => "Записка для ${name}";

  static String m42(app, category) => "${app} перенесено в «${category}»";

  static String m43(app, category) => "${app} теперь в «${category}»";

  static String m44(app) => "Разблокирован ${app}";

  static String m45(minutes) => "Дать ${minutes} мин";

  static String m46(name) => "Теперь подключим телефон. ${name} ждёт!";

  static String m47(name) =>
      "Fini начнёт работу, когда телефон ${name} будет подключён.";

  static String m48(category) => "Не «${category}»";

  static String m49(name) => "Поставить Fini на паузу для ${name}";

  static String m50(name) => "Снова включить Fini для ${name}";

  static String m51(minutes) => "До ${minutes} мин в день, один раз";

  static String m52(name) => "Выберите цель для ${name}, дальше я сам.";

  static String m53(name) =>
      "Я занимаюсь планом ${name}. Следующий шаг в понедельник.";

  static String m54(name) =>
      "Я на паузе для ${name}. Все правила остаются как есть.";

  static String m55(count) =>
      "${Intl.plural(count, one: 'Одно дело ждёт вашего решения.', few: '${count} дела ждут вашего решения.', many: '${count} дел ждут вашего решения.', other: '${count} дел ждут вашего решения.')}";

  static String m56(name) =>
      "Я буду предлагать изменения для ${name}, решаете вы.";

  static String m57(on, total) => "Включено ${on} из ${total}";

  static String m58(count) =>
      "${Intl.plural(count, zero: 'Сегодня пока ничего', one: '1 действие сегодня', few: '${count} действия сегодня', many: '${count} действий сегодня', other: '${count} действий сегодня')}";

  static String m59(count) =>
      "${Intl.plural(count, one: 'Пробный период · остался ${count} день', few: 'Пробный период · осталось ${count} дня', many: 'Пробный период · осталось ${count} дней', other: 'Пробный период · осталось ${count} дней')}";

  static String m60(app, used, needed) =>
      "${app}: ${used} сегодня, задание просило ${needed}.";

  static String m61(count) =>
      "${Intl.plural(count, one: '${count} приз', few: '${count} приза', many: '${count} призов', other: '${count} призов')}";

  static String m62(name) => "Удалить ${name}?";

  static String m63(count) =>
      "${Intl.plural(count, one: '${count} задание сегодня', few: '${count} задания сегодня', many: '${count} заданий сегодня', other: '${count} заданий сегодня')}";

  static String m64(done, total) => "${done} из ${total}";

  static String m65(target) => "Сразу ${target}";

  static String m66(time) => "${time} в день";

  static String m67(target) => "Цель достигнута: ${target} в день. Держу так.";

  static String m68(target) =>
      "На iPhone я не вижу время в приложениях, поэтому цель действует сразу: ${target} в день, без шагов.";

  static String m69(target) =>
      "С завтрашнего дня ${target}. В первые дни возможны споры.";

  static String m70(current, next, weeks) =>
      "Сегодня лимит ${current}. В следующий понедельник ${next}, цель через ${weeks} нед.";

  static String m71(start, target, weeks) =>
      "Сейчас около ${start} в день. Небольшой шаг каждый понедельник, ${target} через ${weeks} нед.";

  static String m72(name) =>
      "Начну наблюдать, когда подключится телефон: ${name}.";

  static String m73(seen, total, name) =>
      "Наблюдаю: день ${seen} из ${total}. Потом план начнётся с того, сколько ${name} тратит на самом деле.";

  static String m74(from, to) => "Без экранов ${from}-${to}";

  static String m75(n) => "нед ${n}";

  static String m76(from, to) => "${from}-${to}";

  static String m77(name) => "Ограничить ${name}?";

  static String m78(name) => "${name} заблокировано";

  static String m79(count) => "Всего приложений: ${count}";

  static String m80(name) =>
      "Когда ${name} откроет Safini на своём телефоне, установленные приложения появятся здесь.";

  static String m81(name) =>
      "Apple не показывает Safini список приложений на iPhone, которым пользуется ${name}, поэтому выбрать лимиты на этом экране пока нельзя.";

  static String m82(date) => "Синхронизировано: ${date}";

  static String m83(name) => "Все приложения на телефоне ${name}";

  static String m84(apps) => "${apps} · на сегодня всё";

  static String m85(minutes) => "Попросить у родителя ${minutes}";

  static String m86(parent, minutes) => "${parent}: да, +${minutes}";

  static String m87(minutes) => "Да: +${minutes}. Задания сделаны.";

  static String m88(limit) => "По семейному плану на игры ${limit} в день.";

  static String m89(limit) => "По семейному плану ${limit} в день.";

  static String m90(limit) => "По семейному плану на ленты ${limit} в день.";

  static String m91(time) => "+${time} за монеты";

  static String m92(name, time) => "${name}: осталось ${time} на сегодня";

  static String m93(time) => "Снова можно в ${time}";

  static String m94(time) => "${time} в день";

  static String m95(time) => "Сегодня осталось ${time}";

  static String m96(step, total) => "${step} из ${total}";

  static String m97(name, time) => "${name} использовал ${time} сегодня";

  static String m98(name) => "Приложения ${name}";

  static String m99(level) => "Герой ${level} уровня";

  static String m100(level) => "Уровень ${level}";

  static String m101(name) => "Телефон ${name} · сегодня";

  static String m102(count) =>
      "${Intl.plural(count, one: '${count} минута', few: '${count} минуты', many: '${count} минут', other: '${count} минут')}";

  static String m103(minutes) => "${minutes} м осталось";

  static String m104(minutes) => "Осталось ${minutes} м сегодня";

  static String m105(minutes) =>
      "${Intl.plural(minutes, one: 'Осталась ${minutes} минута', few: 'Осталось ${minutes} минуты', many: 'Осталось ${minutes} минут', other: 'Осталось ${minutes} минут')}";

  static String m106(count) =>
      "${Intl.plural(count, one: 'Нужна ещё ${count} монета', few: 'Нужно ещё ${count} монеты', many: 'Нужно ещё ${count} монет', other: 'Нужно ещё ${count} монет')}";

  static String m107(app) => "Больше всего - в ${app}";

  static String m108(count) =>
      "${Intl.plural(count, one: '${count} день подряд', few: '${count} дня подряд', many: '${count} дней подряд', other: '${count} дней подряд')}";

  static String m109(name) => "Что вы хотите изменить для ${name}?";

  static String m110(from, to) => "С ${from} до ${to} приложения закрыты.";

  static String m111(name) =>
      "Когда телефон ${name} подключится, я изучу обычный день. Пока ничего не меняется.";

  static String m112(age) =>
      "Не уверены? Это наши рекомендации для возраста ${age}. Их можно изменить в любой момент.";

  static String m113(day) => "День ${day}";

  static String m114(name) =>
      "К чему вы хотите прийти. Fini приведёт ${name} к этому шаг за шагом.";

  static String m115(total) => "из ${total}";

  static String m116(name, coins) => "${name} · выплачено ${coins}";

  static String m117(name) => "Установите Safini на телефон ${name}";

  static String m118(percent) => "${percent}% до следующего уровня";

  static String m119(name) => "Телефон подключён! ${name} на связи.";

  static String m120(to) => "Цель действует сразу: ${to} в день.";

  static String m121(from, to) =>
      "На прошлой неделе ${from} заканчивались каждый день. Ослабить до ${to} на неделю?";

  static String m122(to) =>
      "На прошлой неделе лимит ни разу не закончился. Перейти сразу на ${to} в день?";

  static String m123(to) => "Сразу перешли к цели: ${to} в день.";

  static String m124(to) => "План начался с ${to} в день после наблюдения.";

  static String m125(from, to, target) =>
      "Шаг понедельника: с ${from} до ${to} в день, цель ${target}.";

  static String m126(used, limit) => "${used} из ${limit} сегодня";

  static String m127(limit) => "${limit} на сегодня израсходовано";

  static String m128(coins) =>
      "Отложено: ${coins}. Отметьте «Вручено», когда отдадите.";

  static String m129(name, prize) => "${name} просит: ${prize}";

  static String m130(name) =>
      "Когда ${name} просит подарок, монеты откладываются. Отметьте «Вручено», когда отдадите, или откажите - монеты вернутся.";

  static String m131(name) => "${name} просит этот подарок";

  static String m132(name) =>
      "Настоящие подарки, на которые ${name} может копить монеты. Вручаете вы.";

  static String m133(name) => "Подарки: ${name}";

  static String m134(date) => "Активен до ${date}";

  static String m135(price) => "${price} в месяц";

  static String m136(price) => "${price} в год";

  static String m137(date) => "Продлится ${date}";

  static String m138(percent) => "Выгода ${percent}%";

  static String m139(count) =>
      "${Intl.plural(count, one: '${count} день бесплатно', few: '${count} дня бесплатно', many: '${count} дней бесплатно', other: '${count} дня бесплатно')}";

  static String m140(count) =>
      "${Intl.plural(count, one: '${count} месяц бесплатно', few: '${count} месяца бесплатно', many: '${count} месяцев бесплатно', other: '${count} месяца бесплатно')}";

  static String m141(trial, price) => "${trial}, затем ${price}";

  static String m142(date) => "Бесплатный период до ${date}";

  static String m143(count) =>
      "${Intl.plural(count, one: '${count} неделя бесплатно', few: '${count} недели бесплатно', many: '${count} недель бесплатно', other: '${count} недели бесплатно')}";

  static String m144(count) =>
      "${Intl.plural(count, one: '${count} год бесплатно', few: '${count} года бесплатно', many: '${count} лет бесплатно', other: '${count} года бесплатно')}";

  static String m145(name) =>
      "Введите его на новом телефоне ${name} в разделе «Я ребёнок». Монеты, задания и история перейдут туда, а на старом телефоне лимиты перестанут работать.";

  static String m146(cost, time) =>
      "Ребёнок может потратить ${cost} монет, чтобы открыть ${time} сверх дневного лимита.";

  static String m147(minutes) => "осталось ${minutes}м";

  static String m148(name) =>
      "Это навсегда удалит аккаунт ребёнка «${name}» и все связанные данные: задания, монеты и настройки приложений. Отменить это нельзя.";

  static String m149(name) => "Удалить аккаунт ребёнка «${name}»?";

  static String m150(name) => "Аккаунт ребёнка «${name}» навсегда удалён.";

  static String m151(name) => "Сохранить для ${name}";

  static String m152(name) => "Сохранено для ${name}";

  static String m153(count) => "Показать все приложения (${count})";

  static String m154(code) => "Код ${code} · лимиты отключатся";

  static String m155(name) => "${name} хочет выйти";

  static String m156(count) =>
      "${Intl.plural(count, one: 'Неверный код. Осталась ${count} попытка.', few: 'Неверный код. Осталось ${count} попытки.', many: 'Неверный код. Осталось ${count} попыток.', other: 'Неверный код. Осталось ${count} попыток.')}";

  static String m157(count) =>
      "${Intl.plural(count, one: '${count} задание', few: '${count} задания', many: '${count} заданий', other: '${count} заданий')}";

  static String m158(app, used, needed) =>
      "Fini: ${app}, ${used} из ${needed} сегодня";

  static String m159(note) => "Fini: ${note}";

  static String m160(tasks, coins) => "${tasks} · ${coins}";

  static String m161(scope, tasks) => "${scope} · ${tasks}";

  static String m162(tasks, coins) => "${tasks} осталось - ${coins} на кону";

  static String m163(time) => "${time} осталось";

  static String m164(time) => "${time} использовано";

  static String m165(count) => "ещё ${count}";

  static String m166(step, total) => "${step} из ${total}";

  static String m167(name) =>
      "Введите его на телефоне ${name} в разделе «Я ребёнок».";

  static String m168(used, limit) => "${used} исп. / ${limit} лимит";

  static String m169(used) => "${used} · без лимита";

  static String m170(used, limit) => "${used} из ${limit}";

  static String m171(used, limit) => "${used} из ${limit} · превышен";

  static String m172(time) => "${time} сегодня";

  static String m173(seconds) => "Осталось ${seconds} с";

  static String m174(count) =>
      "${Intl.plural(count, one: '${count} ожидает', few: '${count} ожидают', many: '${count} ожидают', other: '${count} ожидают')}";

  static String m175(name) => "Ждём телефон ${name}…";

  static String m176(name) =>
      "Назначьте цену, и это появится в магазине: ${name}.";

  static String m177(name, prize) => "${name} мечтает: ${prize}";

  static String m178(name, coins) => "${name} · ${coins}";

  static String m179(age) =>
      "${Intl.plural(age, one: '${age} год', few: '${age} года', many: '${age} лет', other: '${age} лет')}";

  static String m180(count) =>
      "${Intl.plural(count, one: 'Нужна ещё ${count} монета.', few: 'Нужно ещё ${count} монеты.', many: 'Нужно ещё ${count} монет.', other: 'Нужно ещё ${count} монет.')}";

  static String m181(name) => "${name} (вы)";

  final messages = _notInlinedMessages(_notInlinedMessages);
  static Map<String, Function> _notInlinedMessages(_) => <String, Function>{
    "achievements": MessageLookupByLibrary.simpleMessage("Достижения"),
    "activeTasks": MessageLookupByLibrary.simpleMessage("Активные задания"),
    "addAChild": MessageLookupByLibrary.simpleMessage("Добавить ребёнка"),
    "addAPrize": MessageLookupByLibrary.simpleMessage("Добавить подарок"),
    "addAnApp": MessageLookupByLibrary.simpleMessage("Добавить приложение"),
    "addAnAppLimit": MessageLookupByLibrary.simpleMessage(
      "Добавить лимит приложения",
    ),
    "addAnotherApp": MessageLookupByLibrary.simpleMessage(
      "Добавить приложение",
    ),
    "addAnotherChild": MessageLookupByLibrary.simpleMessage("Добавить ребенка"),
    "addAppAction": MessageLookupByLibrary.simpleMessage("Добавить"),
    "addChild": MessageLookupByLibrary.simpleMessage("Добавить ребенка"),
    "addLimitAction": MessageLookupByLibrary.simpleMessage("Добавить лимит"),
    "addPhoto": MessageLookupByLibrary.simpleMessage("Добавить фото"),
    "addPrizeFor": m0,
    "addShort": MessageLookupByLibrary.simpleMessage("Добавить"),
    "addToEveryonesList": MessageLookupByLibrary.simpleMessage("Добавить всем"),
    "addToList": m1,
    "addToStore": MessageLookupByLibrary.simpleMessage("В магазин"),
    "admin": MessageLookupByLibrary.simpleMessage("Админ"),
    "ageAndGender": m2,
    "ageFieldLabel": MessageLookupByLibrary.simpleMessage("Возраст"),
    "ageLabel": m3,
    "ageMustBeInteger": MessageLookupByLibrary.simpleMessage(
      "Возраст должен быть числом.",
    ),
    "ageRange": MessageLookupByLibrary.simpleMessage(
      "Возраст должен быть от 0 до 18.",
    ),
    "ageRequired": MessageLookupByLibrary.simpleMessage("Укажите возраст."),
    "alertDigestSubtitle": MessageLookupByLibrary.simpleMessage(
      "Сводка в воскресенье вечером",
    ),
    "alertDigestTitle": MessageLookupByLibrary.simpleMessage("Итоги недели"),
    "alertLimitsSubtitle": MessageLookupByLibrary.simpleMessage(
      "Когда у ребёнка закончилось время",
    ),
    "alertLimitsTitle": MessageLookupByLibrary.simpleMessage("Лимит исчерпан"),
    "alertSaveFailed": MessageLookupByLibrary.simpleMessage(
      "Не удалось сохранить. Проверьте интернет и попробуйте ещё раз.",
    ),
    "alertSubmissionsSubtitle": MessageLookupByLibrary.simpleMessage(
      "Сразу, как ребёнок отправил задание",
    ),
    "alertSubmissionsTitle": MessageLookupByLibrary.simpleMessage(
      "Задания на проверку",
    ),
    "alertsAlwaysOn": MessageLookupByLibrary.simpleMessage(
      "Оповещения о защите на телефоне ребёнка приходят всегда.",
    ),
    "allCaughtUp": MessageLookupByLibrary.simpleMessage("Всё проверено"),
    "allDoneToday": MessageLookupByLibrary.simpleMessage(
      "На сегодня всё сделано",
    ),
    "allDoneTodayBody": MessageLookupByLibrary.simpleMessage(
      "Все задания одобрены, монеты уже в кошельке.",
    ),
    "allTasks": MessageLookupByLibrary.simpleMessage("Все задания"),
    "alwaysAllowedNoRedemption": MessageLookupByLibrary.simpleMessage(
      "Всегда доступно · без обмена",
    ),
    "appLimits": MessageLookupByLibrary.simpleMessage("Лимиты приложений"),
    "appLimitsSubtitle": MessageLookupByLibrary.simpleMessage(
      "Установите дневные лимиты экранного времени",
    ),
    "appLock": MessageLookupByLibrary.simpleMessage("Блокировка приложения"),
    "appLockChange": MessageLookupByLibrary.simpleMessage("Сменить PIN"),
    "appLockChanged": MessageLookupByLibrary.simpleMessage("PIN обновлён"),
    "appLockConfirmNewPin": MessageLookupByLibrary.simpleMessage(
      "Повторите новый PIN",
    ),
    "appLockConfirmPin": MessageLookupByLibrary.simpleMessage("Повторите PIN"),
    "appLockCreatePin": MessageLookupByLibrary.simpleMessage(
      "Придумайте 4-значный PIN",
    ),
    "appLockCurrentPin": MessageLookupByLibrary.simpleMessage(
      "Введите текущий PIN",
    ),
    "appLockDisabled": MessageLookupByLibrary.simpleMessage(
      "Блокировка выключена",
    ),
    "appLockEnabled": MessageLookupByLibrary.simpleMessage(
      "Блокировка включена",
    ),
    "appLockEnterPin": MessageLookupByLibrary.simpleMessage("Введите PIN-код"),
    "appLockForgot": MessageLookupByLibrary.simpleMessage(
      "Выйдите из аккаунта и войдите снова. PIN на этом телефоне сбросится.",
    ),
    "appLockForgotAction": MessageLookupByLibrary.simpleMessage(
      "Забыли пароль?",
    ),
    "appLockInvalidPin": MessageLookupByLibrary.simpleMessage("Нужны 4 цифры"),
    "appLockLockout": MessageLookupByLibrary.simpleMessage(
      "Слишком много попыток. Подождите немного.",
    ),
    "appLockMismatch": MessageLookupByLibrary.simpleMessage(
      "PIN-коды не совпали. Попробуйте ещё раз.",
    ),
    "appLockNewPin": MessageLookupByLibrary.simpleMessage("Новый PIN-код"),
    "appLockOff": MessageLookupByLibrary.simpleMessage("Выкл."),
    "appLockOffHint": MessageLookupByLibrary.simpleMessage(
      "4-значный PIN хранится только на этом телефоне. Выйдите из аккаунта, чтобы сбросить его.",
    ),
    "appLockOn": MessageLookupByLibrary.simpleMessage("Вкл."),
    "appLockSignOut": MessageLookupByLibrary.simpleMessage("Выйти"),
    "appLockSignOutFailed": MessageLookupByLibrary.simpleMessage(
      "Не удалось выйти. Попробуйте ещё раз.",
    ),
    "appLockStorageError": MessageLookupByLibrary.simpleMessage(
      "Не удалось сохранить PIN на этом телефоне.",
    ),
    "appLockSubtitle": MessageLookupByLibrary.simpleMessage(
      "Спрашивать PIN при открытии Safini",
    ),
    "appLockWrongPin": MessageLookupByLibrary.simpleMessage("Неверный PIN"),
    "appName": MessageLookupByLibrary.simpleMessage("SAFINI"),
    "appTimeItem": m4,
    "appTimeMinutes": m5,
    "appTimeTab": MessageLookupByLibrary.simpleMessage("Приложения"),
    "approve": MessageLookupByLibrary.simpleMessage("Одобрить"),
    "approvePayCoins": m6,
    "approvedBy": m7,
    "approvedLabel": MessageLookupByLibrary.simpleMessage("Одобрено"),
    "approvedTaskConflict": MessageLookupByLibrary.simpleMessage(
      "Одобренные задания нельзя изменить или удалить.",
    ),
    "approvedWhen": m8,
    "apps": MessageLookupByLibrary.simpleMessage("Приложения"),
    "askForPrize": MessageLookupByLibrary.simpleMessage("Попросить"),
    "askForSomethingNew": MessageLookupByLibrary.simpleMessage(
      "Попроси что-то новое - родитель добавит это в магазин.",
    ),
    "askForThis": MessageLookupByLibrary.simpleMessage("Открыть"),
    "askParentToDeleteAccount": MessageLookupByLibrary.simpleMessage(
      "Если хочешь удалить аккаунт, попроси родителя.",
    ),
    "askToRedo": MessageLookupByLibrary.simpleMessage("Переделать"),
    "askedToRedoBy": m9,
    "askedToRedoLabel": MessageLookupByLibrary.simpleMessage("На переделку"),
    "avatarItem": MessageLookupByLibrary.simpleMessage("Предмет аватара"),
    "avatarItemsTab": MessageLookupByLibrary.simpleMessage("Предметы"),
    "avatarTabAccessories": MessageLookupByLibrary.simpleMessage("Аксессуары"),
    "avatarTabCharacters": MessageLookupByLibrary.simpleMessage("Персонажи"),
    "avatarTabHead": MessageLookupByLibrary.simpleMessage("Голова"),
    "avatarTabVehicles": MessageLookupByLibrary.simpleMessage("Транспорт"),
    "averagePerDay": m10,
    "backToSignIn": MessageLookupByLibrary.simpleMessage("Вернуться ко входу"),
    "badgeCoins": m11,
    "badgeTasksDone": m12,
    "badges": MessageLookupByLibrary.simpleMessage("Значки"),
    "blockCompletely": MessageLookupByLibrary.simpleMessage(
      "Заблокировать полностью",
    ),
    "blockSegment": MessageLookupByLibrary.simpleMessage("Блокировка"),
    "bothParentsSee": MessageLookupByLibrary.simpleMessage(
      "Все приглашённые взрослые видят одни и те же задания и могут их одобрять.",
    ),
    "budgetEnabled": MessageLookupByLibrary.simpleMessage("Включён"),
    "budgetExplanation": MessageLookupByLibrary.simpleMessage(
      "Когда общий лимит закончится, приложения под управлением Safini будут заблокированы. Отдельные лимиты приложений тоже действуют. Телефон, Сообщения и приложения без правил Safini останутся доступны.",
    ),
    "budgetMinutesError": MessageLookupByLibrary.simpleMessage(
      "Введите целое число от 0 до 1440.",
    ),
    "budgetMinutesHint": MessageLookupByLibrary.simpleMessage(
      "0 минут блокирует приложения под управлением Safini.",
    ),
    "budgetNoFreeTime": MessageLookupByLibrary.simpleMessage(
      "Нет бесплатного времени",
    ),
    "budgetOffExplanation": MessageLookupByLibrary.simpleMessage(
      "Действуют только лимиты отдельных приложений. Использованное сегодня время сохраняется.",
    ),
    "budgetPaused": MessageLookupByLibrary.simpleMessage(
      "Приложения заблокированы до обновления дневного лимита.",
    ),
    "budgetPausedUntil": m13,
    "budgetRemaining": MessageLookupByLibrary.simpleMessage("Осталось"),
    "budgetResetAt": m14,
    "budgetScope": MessageLookupByLibrary.simpleMessage(
      "Для приложений под управлением Safini",
    ),
    "budgetUnavailable": MessageLookupByLibrary.simpleMessage(
      "Данные об общем лимите недоступны. Потяните вниз, чтобы обновить.",
    ),
    "budgetUsageUnknown": MessageLookupByLibrary.simpleMessage(
      "Использование видно на устройстве ребёнка.",
    ),
    "budgetUsedToday": MessageLookupByLibrary.simpleMessage(
      "Использовано сегодня",
    ),
    "buyIt": MessageLookupByLibrary.simpleMessage("Купить! 🎉"),
    "buyMoreTime": MessageLookupByLibrary.simpleMessage("Купить ещё время"),
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
    "childProgressTitle": m15,
    "childTasksSubtitle": m16,
    "childUpdatedSuccess": MessageLookupByLibrary.simpleMessage(
      "Профиль ребёнка обновлён.",
    ),
    "chooseFromLibrary": MessageLookupByLibrary.simpleMessage(
      "Выбрать из галереи",
    ),
    "chooseTaskBody": MessageLookupByLibrary.simpleMessage(
      "Выберите готовое задание или создайте своё.",
    ),
    "chooseTaskTitle": MessageLookupByLibrary.simpleMessage("Создать задание"),
    "chooseYourRole": MessageLookupByLibrary.simpleMessage("Выберите роль"),
    "cleanTheRoom": MessageLookupByLibrary.simpleMessage("Убраться в комнате"),
    "close": MessageLookupByLibrary.simpleMessage("Закрыть"),
    "codeCopied": MessageLookupByLibrary.simpleMessage("Код скопирован"),
    "codeIsReady": m17,
    "coinCount": m18,
    "coinCountShort": m19,
    "coins": MessageLookupByLibrary.simpleMessage("Монеты"),
    "coinsCount": m20,
    "coinsPaidAfterApproval": MessageLookupByLibrary.simpleMessage(
      "Монеты начисляются только после вашего одобрения. Повторяющиеся задания появятся снова на следующий день.",
    ),
    "coinsReward": m21,
    "coinsText": MessageLookupByLibrary.simpleMessage("Монеты"),
    "comingSoon": MessageLookupByLibrary.simpleMessage("Скоро будет!"),
    "comingSoonSubtitle": MessageLookupByLibrary.simpleMessage(
      "Мы добавляем больше интересного. Загляни позже!",
    ),
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
    "dailyAllowanceFor": m22,
    "dailyChore": MessageLookupByLibrary.simpleMessage("Ежедневное дело"),
    "dailyLimit": MessageLookupByLibrary.simpleMessage("Дневной лимит"),
    "dailyLimitAppRuleMeaning": MessageLookupByLibrary.simpleMessage(
      "Собственный лимит приложения может заблокировать его раньше.",
    ),
    "dailyLimitAvailableMeaning": MessageLookupByLibrary.simpleMessage(
      "Телефон, Сообщения и приложения без правил Safini остаются доступны.",
    ),
    "dailyLimitSharedMeaning": MessageLookupByLibrary.simpleMessage(
      "Один общий лимит действует для всех приложений под управлением Safini.",
    ),
    "dailyLimitValue": m23,
    "dateToday": MessageLookupByLibrary.simpleMessage("Сегодня"),
    "dateTomorrow": MessageLookupByLibrary.simpleMessage("Завтра"),
    "dateYesterday": MessageLookupByLibrary.simpleMessage("Вчера"),
    "dayStreak": MessageLookupByLibrary.simpleMessage("Дней подряд"),
    "deleteAccount": MessageLookupByLibrary.simpleMessage("Удалить аккаунт"),
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
    "doneTaskSheetTitle": MessageLookupByLibrary.simpleMessage(
      "Выполненное задание",
    ),
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
    "editName": m24,
    "editPrize": MessageLookupByLibrary.simpleMessage("Изменить подарок"),
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
    "emailHint": MessageLookupByLibrary.simpleMessage("imya@primer.ru"),
    "emailLabel": MessageLookupByLibrary.simpleMessage("Эл. почта"),
    "emailRequired": MessageLookupByLibrary.simpleMessage(
      "Введите корректный email",
    ),
    "emailSignInDescription": MessageLookupByLibrary.simpleMessage(
      "Введите email и пароль существующего аккаунта Safini.",
    ),
    "emailSignInTitle": MessageLookupByLibrary.simpleMessage("Вход по email"),
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
    "enforcementActive": MessageLookupByLibrary.simpleMessage(
      "Лимиты приложений работают",
    ),
    "enforcementAttention": MessageLookupByLibrary.simpleMessage(
      "Лимиты требуют внимания на телефоне ребёнка.",
    ),
    "enforcementNotConfigured": MessageLookupByLibrary.simpleMessage(
      "Настройте лимиты на телефоне ребёнка.",
    ),
    "enforcementOffline": MessageLookupByLibrary.simpleMessage(
      "Устройство ребёнка не в сети или перестало отправлять данные. Проверьте телефон.",
    ),
    "enforcementSignedOut": MessageLookupByLibrary.simpleMessage(
      "Ребёнок вышел из Safini на своём телефоне. Лимиты приложений не работают, пока он снова не войдёт.",
    ),
    "enforcementUnknown": MessageLookupByLibrary.simpleMessage(
      "Не удалось проверить защиту. Нажмите, чтобы повторить.",
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
    "expiresLabel": m25,
    "expiresTonight": MessageLookupByLibrary.simpleMessage(
      "Используй сегодня, в полночь сгорит.",
    ),
    "extraAccessory": MessageLookupByLibrary.simpleMessage("Аксессуар"),
    "extraBackpack": MessageLookupByLibrary.simpleMessage("Рюкзак"),
    "extraHair": MessageLookupByLibrary.simpleMessage("Причёска"),
    "extraHead": MessageLookupByLibrary.simpleMessage("Голова"),
    "extraOutfit": MessageLookupByLibrary.simpleMessage("Одежда"),
    "extraVehicle": MessageLookupByLibrary.simpleMessage("Транспорт"),
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
    "finiActAlone": MessageLookupByLibrary.simpleMessage("Fini действует сам"),
    "finiActAloneSub": MessageLookupByLibrary.simpleMessage(
      "Выкл.: каждое изменение ждёт вас карточкой",
    ),
    "finiActivity": MessageLookupByLibrary.simpleMessage("Активность"),
    "finiActivityEmpty": MessageLookupByLibrary.simpleMessage(
      "Пока пусто. Здесь появятся действия Fini с кнопкой «Отменить».",
    ),
    "finiActivitySub": m26,
    "finiAddGoal": MessageLookupByLibrary.simpleMessage("Добавить цель"),
    "finiAddGoalFor": m27,
    "finiAllSet": MessageLookupByLibrary.simpleMessage(
      "Готово! Отличное начало.",
    ),
    "finiAllowApp": m28,
    "finiAlwaysAsks": MessageLookupByLibrary.simpleMessage(
      "Всегда спрашивает вас",
    ),
    "finiAppCantSort": m29,
    "finiAppCategoryEducation": MessageLookupByLibrary.simpleMessage("Учёба"),
    "finiAppCategoryGames": MessageLookupByLibrary.simpleMessage("Игры"),
    "finiAppCategoryOther": MessageLookupByLibrary.simpleMessage("Без лимита"),
    "finiAppCategoryShortVideo": MessageLookupByLibrary.simpleMessage(
      "Короткие видео",
    ),
    "finiAppCategorySocial": MessageLookupByLibrary.simpleMessage("Соцсети"),
    "finiAppCategoryVideo": MessageLookupByLibrary.simpleMessage("Видео"),
    "finiAppSortedBlocked": MessageLookupByLibrary.simpleMessage(
      "Это время сейчас закрыто, значит и приложение тоже.",
    ),
    "finiAppSortedShares": m30,
    "finiApprove": MessageLookupByLibrary.simpleMessage("Одобрить"),
    "finiAskApprove": MessageLookupByLibrary.simpleMessage("Одобрить задание?"),
    "finiAskCoins": MessageLookupByLibrary.simpleMessage(
      "Монеты сверх награды за задание",
    ),
    "finiAskGeneric": MessageLookupByLibrary.simpleMessage(
      "У Fini есть предложение",
    ),
    "finiAskGrant": m31,
    "finiAskLimit": m32,
    "finiAskRaise": MessageLookupByLibrary.simpleMessage(
      "Повышение любого лимита",
    ),
    "finiAskRaiseLimit": m33,
    "finiAskReason": m34,
    "finiAskReject": MessageLookupByLibrary.simpleMessage("Отказ по заданию"),
    "finiAskSortApp": m35,
    "finiAskSortedApp": m36,
    "finiAskUnblock": MessageLookupByLibrary.simpleMessage(
      "Разблокировка приложения",
    ),
    "finiDayEarlier": MessageLookupByLibrary.simpleMessage("Ранее"),
    "finiDayToday": MessageLookupByLibrary.simpleMessage("Сегодня"),
    "finiDidAllowApp": m37,
    "finiDidApprove": MessageLookupByLibrary.simpleMessage("Задание одобрено"),
    "finiDidBlock": m38,
    "finiDidGoal": MessageLookupByLibrary.simpleMessage("Подготовлена цель"),
    "finiDidGrant": m39,
    "finiDidLimit": m40,
    "finiDidMessage": m41,
    "finiDidMoveApp": m42,
    "finiDidReject": MessageLookupByLibrary.simpleMessage("Задание возвращено"),
    "finiDidSortApp": m43,
    "finiDidTasks": MessageLookupByLibrary.simpleMessage("Предложены задания"),
    "finiDidUnblock": m44,
    "finiDone": MessageLookupByLibrary.simpleMessage("Готово"),
    "finiGive": m45,
    "finiGoalsHeader": MessageLookupByLibrary.simpleMessage("Цели"),
    "finiIosNote": MessageLookupByLibrary.simpleMessage(
      "Лимиты работают; пошаговые планы пока только на Android.",
    ),
    "finiKeepWithPro": MessageLookupByLibrary.simpleMessage(
      "Продолжить с Fini Pro",
    ),
    "finiNeedsYou": MessageLookupByLibrary.simpleMessage("Нужно ваше решение"),
    "finiNeverNames": MessageLookupByLibrary.simpleMessage(
      "Без имени и фото ребёнка",
    ),
    "finiNewApp": MessageLookupByLibrary.simpleMessage("Новое приложение"),
    "finiNextAppLock": MessageLookupByLibrary.simpleMessage(
      "Поставьте PIN, чтобы Safini открывали только вы.",
    ),
    "finiNextChild": MessageLookupByLibrary.simpleMessage(
      "Сначала добавим ребёнка.",
    ),
    "finiNextLimit": MessageLookupByLibrary.simpleMessage(
      "Сколько экранного времени в день достаточно?",
    ),
    "finiNextPhone": m46,
    "finiNextPrize": MessageLookupByLibrary.simpleMessage(
      "Добавьте подарок, ради которого стоит копить.",
    ),
    "finiNextTask": MessageLookupByLibrary.simpleMessage(
      "Добавьте первое задание. За задания дают монеты.",
    ),
    "finiNoChild": MessageLookupByLibrary.simpleMessage(
      "Добавьте ребёнка, чтобы познакомиться с Fini.",
    ),
    "finiNotAGame": MessageLookupByLibrary.simpleMessage("Это не игра"),
    "finiNotConnected": m47,
    "finiNotInCategory": m48,
    "finiNotNow": MessageLookupByLibrary.simpleMessage("Не сейчас"),
    "finiNotToday": MessageLookupByLibrary.simpleMessage("Не сегодня"),
    "finiOnItsOwn": MessageLookupByLibrary.simpleMessage("Сам"),
    "finiPauseFor": m49,
    "finiPauseNote": MessageLookupByLibrary.simpleMessage(
      "Пауза оставляет все правила как есть.",
    ),
    "finiPausedBody": MessageLookupByLibrary.simpleMessage(
      "Бесплатный период закончился. Все лимиты остаются как есть.",
    ),
    "finiPausedTitle": MessageLookupByLibrary.simpleMessage(
      "Fini отдыхает. Ваши правила работают.",
    ),
    "finiPickGoal": MessageLookupByLibrary.simpleMessage("Выберите цель"),
    "finiPromise": MessageLookupByLibrary.simpleMessage(
      "Я никогда не ослабляю лимит без вашего согласия.",
    ),
    "finiResultAccepted": MessageLookupByLibrary.simpleMessage("Вы одобрили"),
    "finiResultDismissed": MessageLookupByLibrary.simpleMessage("Вы отказали"),
    "finiResultRefused": MessageLookupByLibrary.simpleMessage(
      "Не разрешено, не выполнено",
    ),
    "finiResultUndone": MessageLookupByLibrary.simpleMessage("Отменено"),
    "finiResumeFor": m50,
    "finiRuleLower": MessageLookupByLibrary.simpleMessage(
      "Снижать лимиты по плану",
    ),
    "finiRuleLowerSub": MessageLookupByLibrary.simpleMessage(
      "Не быстрее выбранного темпа",
    ),
    "finiRulePhoto": MessageLookupByLibrary.simpleMessage("Проверять фото"),
    "finiRulePhotoSub": MessageLookupByLibrary.simpleMessage(
      "Одобряет только чёткое фото, иначе спросит вас",
    ),
    "finiRuleSort": MessageLookupByLibrary.simpleMessage(
      "Распределять новые приложения",
    ),
    "finiRuleSortSub": MessageLookupByLibrary.simpleMessage(
      "Новая игра сразу получает лимит",
    ),
    "finiRuleTime": MessageLookupByLibrary.simpleMessage(
      "Давать дополнительное время",
    ),
    "finiRuleTimeSub": m51,
    "finiRuleUsage": MessageLookupByLibrary.simpleMessage(
      "Одобрять задания по данным приложений",
    ),
    "finiRuleUsageSub": MessageLookupByLibrary.simpleMessage(
      "Duolingo 10 мин сделано? Оплачено. Отмена 24 ч",
    ),
    "finiStatusNoGoals": m52,
    "finiStatusOnTrack": m53,
    "finiStatusPaused": m54,
    "finiStatusPending": m55,
    "finiStatusSuggest": m56,
    "finiSwitchesOn": m57,
    "finiThingsToday": m58,
    "finiTrialPill": m59,
    "finiUndo": MessageLookupByLibrary.simpleMessage("Отменить"),
    "finiUsageProof": m60,
    "finiWhatItCanDo": MessageLookupByLibrary.simpleMessage("Что умеет Fini"),
    "finiWhatItLookedAt": MessageLookupByLibrary.simpleMessage(
      "На что смотрел Fini",
    ),
    "finiWhyAdmin": MessageLookupByLibrary.simpleMessage(
      "Так Safini не удалить. Если его выключат, родители узнают.",
    ),
    "finiWhyOverlay": MessageLookupByLibrary.simpleMessage(
      "Так я смогу поставить приложение на паузу, когда время выйдет.",
    ),
    "finiWhyUsage": MessageLookupByLibrary.simpleMessage(
      "Так я вижу, какое приложение открыто, и считаю время.",
    ),
    "footerText": MessageLookupByLibrary.simpleMessage(
      "Безопасное экранное время для умных детей 🌟",
    ),
    "free": MessageLookupByLibrary.simpleMessage("БЕСПЛАТНО"),
    "freeLimitApps": MessageLookupByLibrary.simpleMessage(
      "В бесплатном плане можно ограничить пять приложений на ребёнка. С Safini Pro можно ограничить все приложения.",
    ),
    "freeLimitChildren": MessageLookupByLibrary.simpleMessage(
      "В бесплатном плане один ребёнок. С Safini Pro можно добавить всех детей в семье.",
    ),
    "freeLimitParents": MessageLookupByLibrary.simpleMessage(
      "В бесплатном плане один родитель. С Safini Pro к семье может присоединиться второй родитель.",
    ),
    "freeLimitSeePro": MessageLookupByLibrary.simpleMessage(
      "Подробнее о Safini Pro",
    ),
    "freeLimitTasks": MessageLookupByLibrary.simpleMessage(
      "В бесплатном плане повторяются пять заданий на ребёнка. С Safini Pro повторять можно все задания.",
    ),
    "freeLimitTitle": MessageLookupByLibrary.simpleMessage(
      "Это предел бесплатного плана",
    ),
    "freeLimitWeb": MessageLookupByLibrary.simpleMessage(
      "На Android Safini Pro покупается на safini.fun.",
    ),
    "fri": MessageLookupByLibrary.simpleMessage("ПТ"),
    "friends": MessageLookupByLibrary.simpleMessage("Друзья"),
    "friendsAdd": MessageLookupByLibrary.simpleMessage("Добавить друга"),
    "friendsAddHint": MessageLookupByLibrary.simpleMessage(
      "Введи 6-значный ID Safini.",
    ),
    "friendsAddTitle": MessageLookupByLibrary.simpleMessage("Добавить друга"),
    "friendsAlready": MessageLookupByLibrary.simpleMessage("Вы уже друзья."),
    "friendsCopied": MessageLookupByLibrary.simpleMessage("ID скопирован"),
    "friendsCopy": MessageLookupByLibrary.simpleMessage("Копировать"),
    "friendsEmptyBody": MessageLookupByLibrary.simpleMessage(
      "Попроси у друга его ID Safini и добавь его здесь.",
    ),
    "friendsEmptyTitle": MessageLookupByLibrary.simpleMessage(
      "Пока нет друзей",
    ),
    "friendsError": MessageLookupByLibrary.simpleMessage(
      "Не получилось загрузить друзей. Потяни вниз, чтобы повторить.",
    ),
    "friendsInvalid": MessageLookupByLibrary.simpleMessage("Введи все 6 цифр."),
    "friendsNotFound": MessageLookupByLibrary.simpleMessage("Такого ID нет."),
    "friendsPrizes": m61,
    "friendsRemove": MessageLookupByLibrary.simpleMessage("Удалить"),
    "friendsRemoveBody": MessageLookupByLibrary.simpleMessage(
      "Их можно добавить снова по ID.",
    ),
    "friendsRemoveTitle": m62,
    "friendsRowSubtitle": MessageLookupByLibrary.simpleMessage(
      "Смотри, как дела у друзей",
    ),
    "friendsSortLevel": MessageLookupByLibrary.simpleMessage("По уровню"),
    "friendsSortRecent": MessageLookupByLibrary.simpleMessage("Недавние"),
    "friendsTasksToday": m63,
    "friendsYourId": MessageLookupByLibrary.simpleMessage("Твой ID Safini"),
    "friendsYourIdHint": MessageLookupByLibrary.simpleMessage(
      "Друг вводит его, чтобы добавить тебя.",
    ),
    "friendsYourself": MessageLookupByLibrary.simpleMessage("Это твой ID."),
    "genderBoy": MessageLookupByLibrary.simpleMessage("Мальчик"),
    "genderGirl": MessageLookupByLibrary.simpleMessage("Девочка"),
    "genderOptional": MessageLookupByLibrary.simpleMessage(
      "Пол (необязательно)",
    ),
    "genericErrorRetry": MessageLookupByLibrary.simpleMessage(
      "Что-то пошло не так. Попробуйте ещё раз.",
    ),
    "gettingStartedCount": m64,
    "gettingStartedHide": MessageLookupByLibrary.simpleMessage("Скрыть"),
    "gettingStartedTitle": MessageLookupByLibrary.simpleMessage("Первые шаги"),
    "goToMyFamily": MessageLookupByLibrary.simpleMessage("К моей семье"),
    "goToTasks": MessageLookupByLibrary.simpleMessage("Перейти к заданиям"),
    "goalADayTogether": MessageLookupByLibrary.simpleMessage(
      "в день, всё вместе",
    ),
    "goalAdded": MessageLookupByLibrary.simpleMessage("Добавлено"),
    "goalBedtime": MessageLookupByLibrary.simpleMessage("Отбой"),
    "goalDinner": MessageLookupByLibrary.simpleMessage("Ужин без экранов"),
    "goalFrom": MessageLookupByLibrary.simpleMessage("С"),
    "goalGames": MessageLookupByLibrary.simpleMessage("Меньше игр"),
    "goalGamesSub": MessageLookupByLibrary.simpleMessage(
      "Roblox, Minecraft, Brawl Stars…",
    ),
    "goalHomework": MessageLookupByLibrary.simpleMessage("Сначала уроки"),
    "goalHomeworkDetail": MessageLookupByLibrary.simpleMessage(
      "Игры закрыты, пока не одобрено учебное задание.",
    ),
    "goalHomeworkSub": MessageLookupByLibrary.simpleMessage(
      "Игры открываются после уроков",
    ),
    "goalJumpNote": MessageLookupByLibrary.simpleMessage(
      "Пропускает оставшиеся шаги. В первые дни возможны споры.",
    ),
    "goalJumpNow": m65,
    "goalLearning": MessageLookupByLibrary.simpleMessage("Учёба не считается"),
    "goalLearningDetail": MessageLookupByLibrary.simpleMessage(
      "Учебные приложения не считаются в лимит.",
    ),
    "goalLearningSub": MessageLookupByLibrary.simpleMessage(
      "Duolingo не считается",
    ),
    "goalMinutesADay": m66,
    "goalNoMoreThan": MessageLookupByLibrary.simpleMessage("Не больше"),
    "goalPlanAtTarget": m67,
    "goalPlanIphone": m68,
    "goalPlanNow": m69,
    "goalPlanStepping": m70,
    "goalPlanText": m71,
    "goalPlanWaitingPhone": m72,
    "goalPlanWatching": MessageLookupByLibrary.simpleMessage(
      "Сначала 3 дня наблюдаю, потом планирую шаги.",
    ),
    "goalPlanWatchingDays": m73,
    "goalPoolNote": MessageLookupByLibrary.simpleMessage(
      "Fini добавляет сюда приложения по мере знакомства с ними.",
    ),
    "goalRemove": MessageLookupByLibrary.simpleMessage("Удалить цель"),
    "goalRemoveNote": MessageLookupByLibrary.simpleMessage(
      "Уже заданные лимиты останутся.",
    ),
    "goalSchool": MessageLookupByLibrary.simpleMessage("Школьные часы"),
    "goalScreensOff": m74,
    "goalScrolling": MessageLookupByLibrary.simpleMessage("Меньше ленты"),
    "goalScrollingSub": MessageLookupByLibrary.simpleMessage(
      "TikTok, Shorts, Reels",
    ),
    "goalThePlan": MessageLookupByLibrary.simpleMessage("План"),
    "goalUntil": MessageLookupByLibrary.simpleMessage("До"),
    "goalVideo": MessageLookupByLibrary.simpleMessage("Меньше видео"),
    "goalVideoSub": MessageLookupByLibrary.simpleMessage(
      "YouTube, без Shorts · скоро",
    ),
    "goalWeekN": m75,
    "goalWeekNow": MessageLookupByLibrary.simpleMessage("сейчас"),
    "goalWeekendExtra": MessageLookupByLibrary.simpleMessage(
      "Больше в выходные",
    ),
    "goalWeekendExtraSub": MessageLookupByLibrary.simpleMessage(
      "+30 мин в субботу и воскресенье",
    ),
    "goalWindow": m76,
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
    "howDailyLimitWorks": MessageLookupByLibrary.simpleMessage(
      "Как работает дневной лимит",
    ),
    "iconSection": MessageLookupByLibrary.simpleMessage("Значок"),
    "imAKid": MessageLookupByLibrary.simpleMessage("Я ребенок!"),
    "imAParent": MessageLookupByLibrary.simpleMessage("Я родитель"),
    "inTheFamilySince": MessageLookupByLibrary.simpleMessage("В семье с"),
    "installedAppsAddBody": MessageLookupByLibrary.simpleMessage(
      "Добавьте его в лимиты этого телефона. Дневной лимит можно настроить дальше.",
    ),
    "installedAppsAddTitle": m77,
    "installedAppsAlwaysAllowed": MessageLookupByLibrary.simpleMessage(
      "Всегда разрешено",
    ),
    "installedAppsAlwaysAllowedInfo": MessageLookupByLibrary.simpleMessage(
      "Телефон, сообщения и настройки всегда разрешены, чтобы ребёнок всегда мог связаться с вами.",
    ),
    "installedAppsBlockCompletely": MessageLookupByLibrary.simpleMessage(
      "Полностью заблокировать",
    ),
    "installedAppsBlockedSnack": m78,
    "installedAppsCount": m79,
    "installedAppsEmptyBody": m80,
    "installedAppsEmptyTitle": MessageLookupByLibrary.simpleMessage(
      "Приложения ещё не синхронизированы",
    ),
    "installedAppsIosBody": m81,
    "installedAppsIosTitle": MessageLookupByLibrary.simpleMessage(
      "Приложения iPhone здесь не показываются",
    ),
    "installedAppsLastSynced": m82,
    "installedAppsLimited": MessageLookupByLibrary.simpleMessage("Есть лимит"),
    "installedAppsNoMatch": MessageLookupByLibrary.simpleMessage(
      "По вашему запросу приложений не найдено.",
    ),
    "installedAppsNotControllable": MessageLookupByLibrary.simpleMessage(
      "Safini пока не может ограничить это приложение.",
    ),
    "installedAppsSearchHint": MessageLookupByLibrary.simpleMessage(
      "Найти приложение",
    ),
    "installedAppsSetLimit": MessageLookupByLibrary.simpleMessage(
      "Задать дневной лимит",
    ),
    "installedAppsSubtitle": m83,
    "installedAppsTapHint": MessageLookupByLibrary.simpleMessage(
      "Нажмите на знакомое приложение, чтобы задать лимит или заблокировать.",
    ),
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
    "iosScreenTimeAllow": MessageLookupByLibrary.simpleMessage(
      "Разрешить экранное время",
    ),
    "iosScreenTimeChoose": MessageLookupByLibrary.simpleMessage(
      "Для каждого правила выберите соответствующее приложение в окне Apple. Выберите одно приложение, а не категорию. Чтобы сбросить выбор, родитель должен отозвать доступ Safini в Настройках.",
    ),
    "iosScreenTimeDone": MessageLookupByLibrary.simpleMessage("Готово"),
    "iosScreenTimeErrorCanceled": MessageLookupByLibrary.simpleMessage(
      "Запрос доступа к Экранному времени отменён.",
    ),
    "iosScreenTimeErrorGeneric": MessageLookupByLibrary.simpleMessage(
      "Не удалось получить доступ к Экранному времени. Попробуйте ещё раз.",
    ),
    "iosScreenTimeErrorInvalidAccount": MessageLookupByLibrary.simpleMessage(
      "Этот Apple Account не может выдать доступ к Экранному времени. Войдите под Apple Account ребёнка или попросите родителя добавить его в семейную группу Apple.",
    ),
    "iosScreenTimeErrorNetwork": MessageLookupByLibrary.simpleMessage(
      "Не удалось связаться с Apple для подтверждения доступа. Проверьте соединение и повторите попытку.",
    ),
    "iosScreenTimeErrorRestricted": MessageLookupByLibrary.simpleMessage(
      "Экранное время ограничено на этом устройстве. Его отключил родитель или профиль управления устройством.",
    ),
    "iosScreenTimeErrorUnavailable": MessageLookupByLibrary.simpleMessage(
      "Экранное время недоступно на этом устройстве. Включите Экранное время в Настройках и повторите попытку.",
    ),
    "iosScreenTimeFamily": MessageLookupByLibrary.simpleMessage(
      "Попросите родителя помочь на этом iPhone или iPad. Войдите в Apple Account ребёнка, который входит в семейную группу Apple родителя. Родитель должен одобрить доступ к Экранному времени.",
    ),
    "iosScreenTimeLinked": MessageLookupByLibrary.simpleMessage(
      "Связано на этом устройстве",
    ),
    "iosScreenTimeLocalUsage": MessageLookupByLibrary.simpleMessage(
      "Фактическое использование доступно в разделе «Экранное время» на устройстве ребёнка.",
    ),
    "iosScreenTimeLocalUsageShort": MessageLookupByLibrary.simpleMessage(
      "Использование · на устройстве ребёнка",
    ),
    "iosScreenTimeNoRules": MessageLookupByLibrary.simpleMessage(
      "Родитель может добавить правила в разделе «Лимиты».",
    ),
    "iosScreenTimeNotSetUp": MessageLookupByLibrary.simpleMessage(
      "На iPhone ребёнка не настроено экранное время, поэтому лимиты не работают. Откройте на нём Safini и разрешите экранное время.",
    ),
    "iosScreenTimeOff": MessageLookupByLibrary.simpleMessage(
      "Проверьте настройку",
    ),
    "iosScreenTimeOn": MessageLookupByLibrary.simpleMessage(
      "Контроль настроен",
    ),
    "iosScreenTimeParent": MessageLookupByLibrary.simpleMessage(
      "Экранное время iOS · последний статус",
    ),
    "iosScreenTimePrivacy": MessageLookupByLibrary.simpleMessage(
      "Отчёты об использовании остаются на устройстве. Safini синхронизирует правила и состояние защиты, но не историю использования приложений.",
    ),
    "iosScreenTimeReport": MessageLookupByLibrary.simpleMessage(
      "Посмотреть отчёт",
    ),
    "iosScreenTimeRetry": MessageLookupByLibrary.simpleMessage(
      "Не удалось обновить экранное время. Проверьте интернет и разрешения, затем повторите. Сохранённые лимиты продолжают действовать.",
    ),
    "iosScreenTimeSelect": MessageLookupByLibrary.simpleMessage(
      "Выберите соответствующее приложение",
    ),
    "iosScreenTimeSetup": MessageLookupByLibrary.simpleMessage(
      "Настройка экранного времени",
    ),
    "iosScreenTimeSync": MessageLookupByLibrary.simpleMessage(
      "Синхронизировать правила и статус",
    ),
    "iosScreenTimeSyncHint": MessageLookupByLibrary.simpleMessage(
      "Откройте Safini на этом устройстве для получения новых правил. Сохранённые лимиты действуют и при закрытом приложении. Заработанные минуты истекают в полночь по времени семьи; лимиты действуют на этом устройстве.",
    ),
    "iosScreenTimeWeek": MessageLookupByLibrary.simpleMessage("7 дней"),
    "joinFamilyAction": MessageLookupByLibrary.simpleMessage("Войти по коду"),
    "joinFamilySubtitle": MessageLookupByLibrary.simpleMessage(
      "Используйте код от второго родителя",
    ),
    "kazakh": MessageLookupByLibrary.simpleMessage("Казахский"),
    "keepHolding": MessageLookupByLibrary.simpleMessage("Держи…"),
    "kidAppBlocked": MessageLookupByLibrary.simpleMessage("Закрыто"),
    "kidAppBlockedBody": MessageLookupByLibrary.simpleMessage(
      "Родитель выключил это приложение",
    ),
    "kidAppTimesUp": MessageLookupByLibrary.simpleMessage("Время вышло"),
    "kidAskAppsUp": m84,
    "kidAskButton": m85,
    "kidAskDeclined": MessageLookupByLibrary.simpleMessage(
      "Не сегодня. Время вернётся завтра.",
    ),
    "kidAskGrantedBy": m86,
    "kidAskGrantedFini": m87,
    "kidAskOnceADay": MessageLookupByLibrary.simpleMessage(
      "Просить можно раз в день.",
    ),
    "kidAskPending": MessageLookupByLibrary.simpleMessage(
      "Просьба отправлена! Родитель скоро ответит.",
    ),
    "kidAskPlanGames": m88,
    "kidAskPlanOther": m89,
    "kidAskPlanScrolling": m90,
    "kidAskTitleGames": MessageLookupByLibrary.simpleMessage(
      "Хочешь ещё поиграть?",
    ),
    "kidAskTitleOther": MessageLookupByLibrary.simpleMessage(
      "Хочешь ещё времени?",
    ),
    "kidAskTitleScrolling": MessageLookupByLibrary.simpleMessage(
      "Хочешь ещё посмотреть ленту?",
    ),
    "kidBonusFromCoins": m91,
    "kidBudgetShared": MessageLookupByLibrary.simpleMessage(
      "Общее для приложений, которые настроил родитель",
    ),
    "kidComingSoonIos": MessageLookupByLibrary.simpleMessage("Скоро на iOS"),
    "kidComingSoonIosBody": MessageLookupByLibrary.simpleMessage(
      "Детский режим пока недоступен на iPhone. Установите Safini на Android-телефон ребёнка. Режим родителя работает на iPhone.",
    ),
    "kidComingSoonIosTitle": MessageLookupByLibrary.simpleMessage(
      "Детский режим скоро появится на iPhone",
    ),
    "kidGetMoreInStore": MessageLookupByLibrary.simpleMessage(
      "Ещё время можно купить в Магазине",
    ),
    "kidHasLeftToday": m92,
    "kidHelloGo": MessageLookupByLibrary.simpleMessage("Поехали"),
    "kidHelloParent": MessageLookupByLibrary.simpleMessage(
      "Родители видят, какими приложениями ты пользуешься",
    ),
    "kidHelloSpend": MessageLookupByLibrary.simpleMessage(
      "Трать монеты на экранное время и подарки",
    ),
    "kidHelloTasks": MessageLookupByLibrary.simpleMessage(
      "Выполняй задания и получай монеты",
    ),
    "kidHelloTitle": MessageLookupByLibrary.simpleMessage("Привет! Я Фини."),
    "kidScreenTimeBackAt": m93,
    "kidScreenTimeDaily": m94,
    "kidScreenTimeLeft": m95,
    "kidScreenTimeUp": MessageLookupByLibrary.simpleMessage(
      "На сегодня время закончилось",
    ),
    "kidSetupAlmost": MessageLookupByLibrary.simpleMessage("Почти готово!"),
    "kidSetupBadge": MessageLookupByLibrary.simpleMessage("Телефон ребёнка"),
    "kidSetupBatteryLink": MessageLookupByLibrary.simpleMessage(
      "Safini закрывается сам?",
    ),
    "kidSetupGo": MessageLookupByLibrary.simpleMessage("Открыть настройки"),
    "kidSetupHintAdmin": MessageLookupByLibrary.simpleMessage(
      "Пролистайте вниз и нажмите «Активировать».",
    ),
    "kidSetupHintList": MessageLookupByLibrary.simpleMessage(
      "Найдите Safini в списке и включите.",
    ),
    "kidSetupStepOf": m96,
    "kidSubtitle": MessageLookupByLibrary.simpleMessage(
      "Зарабатывай монеты и играй",
    ),
    "kidUsedToday": m97,
    "kidsApps": m98,
    "kidsEarnTimeCoins": MessageLookupByLibrary.simpleMessage(
      "Дети зарабатывают Монеты Времени, чтобы разблокировать минуты для этих приложений.",
    ),
    "kyrgyz": MessageLookupByLibrary.simpleMessage("Кыргызский"),
    "laneActive": MessageLookupByLibrary.simpleMessage("Активные"),
    "laneDone": MessageLookupByLibrary.simpleMessage("Готово"),
    "laneToReview": MessageLookupByLibrary.simpleMessage("На проверку"),
    "lastSevenDays": MessageLookupByLibrary.simpleMessage("Последние 7 дней"),
    "lessons": MessageLookupByLibrary.simpleMessage("Уроки"),
    "lessonsChangeText": MessageLookupByLibrary.simpleMessage("+1 сегодня"),
    "levelHero": m99,
    "levelShort": MessageLookupByLibrary.simpleMessage("Уровень"),
    "levelValue": m100,
    "limitThisApp": MessageLookupByLibrary.simpleMessage(
      "Ограничить приложение",
    ),
    "limitsBattery": MessageLookupByLibrary.simpleMessage("Настройки батареи"),
    "limitsBatteryHint": MessageLookupByLibrary.simpleMessage(
      "На Samsung разрешите работу без ограничений батареи. На Xiaomi также включите автозапуск. Исключите Safini из спящих приложений.",
    ),
    "limitsDeviceAdmin": MessageLookupByLibrary.simpleMessage(
      "Защита от удаления",
    ),
    "limitsDeviceAdminHint": MessageLookupByLibrary.simpleMessage(
      "Не даёт удалить лимиты; родитель узнает, если это отключат.",
    ),
    "limitsFootnote": MessageLookupByLibrary.simpleMessage(
      "Когда дневной лимит закончится, приложение перестанет открываться и покажет экран Safini.",
    ),
    "limitsNotYetEnforced": MessageLookupByLibrary.simpleMessage(
      "Блокировка начнёт работать после настройки Safini на телефоне ребёнка.",
    ),
    "limitsOverlayAccess": MessageLookupByLibrary.simpleMessage(
      "Поверх других приложений",
    ),
    "limitsPools": MessageLookupByLibrary.simpleMessage("Бюджеты Fini"),
    "limitsPoolsNote": MessageLookupByLibrary.simpleMessage(
      "Один общий лимит на все приложения группы. Новая игра попадает сюда в тот же день, как Fini её увидит.",
    ),
    "limitsRetry": MessageLookupByLibrary.simpleMessage(
      "Проверить и подключить",
    ),
    "limitsSetupError": MessageLookupByLibrary.simpleMessage(
      "Не удалось подключить лимиты. Проверьте интернет и повторите.",
    ),
    "limitsSubtitle": m101,
    "limitsUsageAccess": MessageLookupByLibrary.simpleMessage(
      "Доступ к статистике",
    ),
    "lockedLabel": MessageLookupByLibrary.simpleMessage("Закрыто"),
    "loginBack": MessageLookupByLibrary.simpleMessage("Назад"),
    "loginSubtitle": MessageLookupByLibrary.simpleMessage(
      "Войдите, чтобы продолжить",
    ),
    "loginTitle": MessageLookupByLibrary.simpleMessage("Вход"),
    "loginWithApple": MessageLookupByLibrary.simpleMessage(
      "Продолжить с Apple",
    ),
    "loginWithEmail": MessageLookupByLibrary.simpleMessage("Войти по email"),
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
    "manualBlockHint": MessageLookupByLibrary.simpleMessage(
      "Приостановить приложение, включая купленное время.",
    ),
    "markGiven": MessageLookupByLibrary.simpleMessage("Вручено"),
    "markItDone": MessageLookupByLibrary.simpleMessage("Отметить выполненным"),
    "micPermissionDenied": MessageLookupByLibrary.simpleMessage(
      "Микрофон выключен. Включите его в Настройках, чтобы записать голосовую инструкцию.",
    ),
    "minuteCount": m102,
    "minutes": MessageLookupByLibrary.simpleMessage("Минуты"),
    "minutesLeftShort": m103,
    "minutesLeftToday": m104,
    "minutesPerPurchase": MessageLookupByLibrary.simpleMessage(
      "Минут за покупку",
    ),
    "minutesRemainingLong": m105,
    "mon": MessageLookupByLibrary.simpleMessage("ПН"),
    "monitor": MessageLookupByLibrary.simpleMessage("Мониторинг"),
    "moreCoinsNeeded": m106,
    "mostOfItIn": m107,
    "myAvatar": MessageLookupByLibrary.simpleMessage("Мой аватар"),
    "myFamily": MessageLookupByLibrary.simpleMessage("Моя семья"),
    "myProfile": MessageLookupByLibrary.simpleMessage("Мой профиль"),
    "myQuests": MessageLookupByLibrary.simpleMessage("Мои квесты"),
    "myUsageToday": MessageLookupByLibrary.simpleMessage("Моё время сегодня"),
    "nDayStreak": m108,
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
    "newCustomTask": MessageLookupByLibrary.simpleMessage("Новое своё задание"),
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
    "noCosmeticsYet": MessageLookupByLibrary.simpleMessage(
      "Пока нет предметов",
    ),
    "noDailyLimit": MessageLookupByLibrary.simpleMessage("Без дневного лимита"),
    "noFamilySetupYet": MessageLookupByLibrary.simpleMessage(
      "Семья еще не настроена",
    ),
    "noFreeTime": MessageLookupByLibrary.simpleMessage(
      "Без бесплатного времени",
    ),
    "noLimitLabel": MessageLookupByLibrary.simpleMessage("Без лимита"),
    "noLimitsSet": MessageLookupByLibrary.simpleMessage("Лимиты не заданы"),
    "noOverallDailyBudget": MessageLookupByLibrary.simpleMessage("Выключен"),
    "noPrizesYet": MessageLookupByLibrary.simpleMessage(
      "Подарков пока нет. Загадай желание - родитель может его добавить.",
    ),
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
    "notThisTime": MessageLookupByLibrary.simpleMessage("Не сейчас"),
    "notUsedLastSevenDays": MessageLookupByLibrary.simpleMessage(
      "За последние 7 дней не использовалось",
    ),
    "notYet": MessageLookupByLibrary.simpleMessage("Не сейчас"),
    "noteForParent": MessageLookupByLibrary.simpleMessage("Заметка"),
    "noteFromParent": MessageLookupByLibrary.simpleMessage(
      "Заметка от родителя",
    ),
    "nothingForToday": MessageLookupByLibrary.simpleMessage(
      "На сегодня заданий нет",
    ),
    "nothingForTodayBody": MessageLookupByLibrary.simpleMessage(
      "Заданий пока нет. Отдыхай.",
    ),
    "nothingHereYet": MessageLookupByLibrary.simpleMessage("Здесь пока пусто"),
    "nothingInStore": MessageLookupByLibrary.simpleMessage(
      "В магазине пока пусто.",
    ),
    "nothingLeft": MessageLookupByLibrary.simpleMessage("Ничего не осталось"),
    "nothingSentWithTask": MessageLookupByLibrary.simpleMessage(
      "К заданию ничего не приложено",
    ),
    "notificationsOffBody": MessageLookupByLibrary.simpleMessage(
      "Включите их в настройках телефона, чтобы получать эти оповещения.",
    ),
    "notificationsOffTitle": MessageLookupByLibrary.simpleMessage(
      "Уведомления Safini выключены",
    ),
    "obADayAtMost": MessageLookupByLibrary.simpleMessage("в день, не больше"),
    "obAge16Plus": MessageLookupByLibrary.simpleMessage("16+"),
    "obAndroid": MessageLookupByLibrary.simpleMessage("Android"),
    "obAnyStudyTask": MessageLookupByLibrary.simpleMessage(
      "Любое учебное задание, которое вы одобрите",
    ),
    "obChangeLimits": MessageLookupByLibrary.simpleMessage("Изменить лимиты"),
    "obChildName": MessageLookupByLibrary.simpleMessage("Имя ребёнка"),
    "obGoalsSub": MessageLookupByLibrary.simpleMessage(
      "Выберите сколько угодно.",
    ),
    "obGoalsTitle": m109,
    "obHiWho": MessageLookupByLibrary.simpleMessage(
      "Привет, я Fini! Кому помогаем?",
    ),
    "obHomeworkGate": MessageLookupByLibrary.simpleMessage(
      "Игры открываются после задания",
    ),
    "obInCharge": MessageLookupByLibrary.simpleMessage(
      "Решаете вы. Я никогда не ослабляю лимит и не открываю приложение без вашего согласия.",
    ),
    "obIphone": MessageLookupByLibrary.simpleMessage("iPhone"),
    "obPlanHomeworkBody": MessageLookupByLibrary.simpleMessage(
      "Игры закрыты, пока вы не одобрите учебное задание.",
    ),
    "obPlanHomeworkTitle": MessageLookupByLibrary.simpleMessage(
      "Каждый день: сначала уроки",
    ),
    "obPlanMondayBody": MessageLookupByLibrary.simpleMessage(
      "Примерно на четверть меньше каждую неделю, пока лимиты не дойдут до заданных.",
    ),
    "obPlanMondayTitle": MessageLookupByLibrary.simpleMessage(
      "Каждый понедельник: маленький шаг",
    ),
    "obPlanNightBody": m110,
    "obPlanNightTitle": MessageLookupByLibrary.simpleMessage(
      "Каждый вечер: экраны выключены",
    ),
    "obPlanTitle": MessageLookupByLibrary.simpleMessage(
      "Вот мой план. Без резких запретов, значит меньше ссор.",
    ),
    "obPlanWatchBody": m111,
    "obPlanWatchTitle": MessageLookupByLibrary.simpleMessage(
      "Первые 3 дня: я наблюдаю",
    ),
    "obScreensOff": MessageLookupByLibrary.simpleMessage("Экраны выключены"),
    "obSkip": MessageLookupByLibrary.simpleMessage("Пропустить"),
    "obSoundsGood": MessageLookupByLibrary.simpleMessage("Отлично"),
    "obStartTrial": MessageLookupByLibrary.simpleMessage(
      "Начать 14 дней бесплатно",
    ),
    "obSuggested": m112,
    "obTheirPhone": MessageLookupByLibrary.simpleMessage("Телефон ребёнка"),
    "obTrialDay": m113,
    "obTrialDay12Body": MessageLookupByLibrary.simpleMessage(
      "Напомним до конца пробного периода",
    ),
    "obTrialDay14Body": MessageLookupByLibrary.simpleMessage(
      "Оставьте с Safini Pro. Или Fini встанет на паузу, а ваши правила останутся как есть.",
    ),
    "obTrialLead": MessageLookupByLibrary.simpleMessage("Мы дарим вам"),
    "obTrialSub": MessageLookupByLibrary.simpleMessage(
      "Карта не нужна. Fini ведёт план, вы просто заглядываете.",
    ),
    "obTrialTitle": MessageLookupByLibrary.simpleMessage(
      "14 дней Fini бесплатно",
    ),
    "obTrialTodayBody": MessageLookupByLibrary.simpleMessage(
      "Все возможности Fini для всех детей",
    ),
    "obTuneSub": m114,
    "obTuneTitle": MessageLookupByLibrary.simpleMessage(
      "Задайте нужные лимиты",
    ),
    "ofTotal": m115,
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
    "overallDailyBudget": MessageLookupByLibrary.simpleMessage(
      "Общий дневной лимит",
    ),
    "paceGentle": MessageLookupByLibrary.simpleMessage("Мягко"),
    "paceNow": MessageLookupByLibrary.simpleMessage("Сразу"),
    "paceSteady": MessageLookupByLibrary.simpleMessage("Ровно"),
    "paidCoinsTo": m116,
    "paidOutNice": MessageLookupByLibrary.simpleMessage("Оплачено. Отлично."),
    "pairStepAllow": MessageLookupByLibrary.simpleMessage(
      "Разрешите доступ к экранному времени",
    ),
    "pairStepInstall": m117,
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
    "parentVoiceInstruction": MessageLookupByLibrary.simpleMessage(
      "Голос родителя",
    ),
    "parents": MessageLookupByLibrary.simpleMessage("Родители"),
    "parentsNote": MessageLookupByLibrary.simpleMessage("Заметка родителя"),
    "passwordHint": MessageLookupByLibrary.simpleMessage("Введите пароль"),
    "passwordLabel": MessageLookupByLibrary.simpleMessage("Пароль"),
    "passwordRequired": MessageLookupByLibrary.simpleMessage("Введите пароль"),
    "pauseVoice": MessageLookupByLibrary.simpleMessage("Пауза"),
    "pendingApproval": MessageLookupByLibrary.simpleMessage("Ожидают проверки"),
    "percentToNextLevel": m118,
    "phoneConnectedBody": MessageLookupByLibrary.simpleMessage(
      "Теперь задания и лимиты работают на нём.",
    ),
    "phoneConnectedTitle": m119,
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
    "planLineAtTarget": m120,
    "planLineEase": m121,
    "planLineJump": m122,
    "planLineJumped": m123,
    "planLineStart": m124,
    "planLineStep": m125,
    "playVoice": MessageLookupByLibrary.simpleMessage("Слушать"),
    "poolUsedOf": m126,
    "poolUsedUp": m127,
    "priceLabel": MessageLookupByLibrary.simpleMessage("Цена"),
    "privacyPolicy": MessageLookupByLibrary.simpleMessage(
      "Политика конфиденциальности",
    ),
    "privacyPolicyOpenFailed": MessageLookupByLibrary.simpleMessage(
      "Не удалось открыть политику конфиденциальности.",
    ),
    "privacyPolicySubtitle": MessageLookupByLibrary.simpleMessage(
      "Как Safini обрабатывает данные семьи",
    ),
    "prizeAskReviewBody": m128,
    "prizeAskReviewTitle": m129,
    "prizeAsked": MessageLookupByLibrary.simpleMessage(
      "Готово! Родитель увидит просьбу.",
    ),
    "prizeBlurb": MessageLookupByLibrary.simpleMessage(
      "Подарок вручит родитель. До этого монеты отложены.",
    ),
    "prizeHoldExplainer": m130,
    "prizeIdeaBackpack": MessageLookupByLibrary.simpleMessage("Новый рюкзак"),
    "prizeIdeaBike": MessageLookupByLibrary.simpleMessage("Новый велосипед"),
    "prizeIdeaBook": MessageLookupByLibrary.simpleMessage("Новая книга"),
    "prizeIdeaCinema": MessageLookupByLibrary.simpleMessage("Поход в кино"),
    "prizeIdeaIceCream": MessageLookupByLibrary.simpleMessage("Мороженое"),
    "prizeIdeaLego": MessageLookupByLibrary.simpleMessage("Набор Lego"),
    "prizeIdeaNewToy": MessageLookupByLibrary.simpleMessage("Новая игрушка"),
    "prizeIdeaPet": MessageLookupByLibrary.simpleMessage("Домашний питомец"),
    "prizeIdeaPizzaNight": MessageLookupByLibrary.simpleMessage("Вечер пиццы"),
    "prizeIdeaVideoGame": MessageLookupByLibrary.simpleMessage(
      "Новая видеоигра",
    ),
    "prizeIdeasTitle": MessageLookupByLibrary.simpleMessage("Идеи"),
    "prizeLabel": MessageLookupByLibrary.simpleMessage("Подарок"),
    "prizeNameHint": MessageLookupByLibrary.simpleMessage("Мороженое"),
    "prizeNameLabel": MessageLookupByLibrary.simpleMessage("Название"),
    "prizeNoteHint": MessageLookupByLibrary.simpleMessage("Только по выходным"),
    "prizeNoteLabel": MessageLookupByLibrary.simpleMessage("Заметка"),
    "prizePriceLabel": MessageLookupByLibrary.simpleMessage("Цена"),
    "prizeWaiting": MessageLookupByLibrary.simpleMessage("Ждёт"),
    "prizeWaitingBody": MessageLookupByLibrary.simpleMessage(
      "Родитель увидит. Монеты отложены, пока он не ответит.",
    ),
    "prizeWaitingForYou": m131,
    "prizesBody": m132,
    "prizesFootnote": MessageLookupByLibrary.simpleMessage(
      "Настоящие подарки от родителя. Копи, проси - и родитель вручит.",
    ),
    "prizesFor": m133,
    "prizesTab": MessageLookupByLibrary.simpleMessage("Подарки"),
    "proActiveTitle": MessageLookupByLibrary.simpleMessage(
      "У вашей семьи Safini Pro",
    ),
    "proActiveUntil": m134,
    "proBuyOnWeb": MessageLookupByLibrary.simpleMessage("Подключить Pro"),
    "proFailed": MessageLookupByLibrary.simpleMessage(
      "Покупка не прошла. Попробуйте ещё раз.",
    ),
    "proFeatureApps": MessageLookupByLibrary.simpleMessage(
      "Лимиты на все приложения, а не только на пять",
    ),
    "proFeatureChildren": MessageLookupByLibrary.simpleMessage(
      "Все дети, а не только один",
    ),
    "proFeatureFini": MessageLookupByLibrary.simpleMessage(
      "Fini ведёт ваш план шаг за шагом",
    ),
    "proFeatureParents": MessageLookupByLibrary.simpleMessage(
      "Второй родитель в семье",
    ),
    "proFeatureTasks": MessageLookupByLibrary.simpleMessage(
      "Неограниченные повторяющиеся задания",
    ),
    "proHeadline": MessageLookupByLibrary.simpleMessage(
      "Один план на всю семью",
    ),
    "proLede": MessageLookupByLibrary.simpleMessage(
      "Действует для обоих родителей и всех детей. Отменить можно в любой момент.",
    ),
    "proLegal": MessageLookupByLibrary.simpleMessage(
      "Оплата списывается с вашего Apple ID. Подписка продлевается автоматически по той же цене, если не отменить её минимум за 24 часа до конца периода. Управлять подпиской и отменить её можно в настройках App Store.",
    ),
    "proLegalTrial": MessageLookupByLibrary.simpleMessage(
      "Во время бесплатного периода ничего не списывается. Отмените минимум за 24 часа до его конца, и вы ничего не заплатите; иначе подписка начнётся, когда он закончится.",
    ),
    "proManage": MessageLookupByLibrary.simpleMessage("Управлять подпиской"),
    "proManageOnWeb": MessageLookupByLibrary.simpleMessage(
      "Управлять на safini.fun",
    ),
    "proMonthly": MessageLookupByLibrary.simpleMessage("Помесячно"),
    "proNothingToRestore": MessageLookupByLibrary.simpleMessage(
      "На этом Apple ID нет подписки Safini Pro.",
    ),
    "proOtherFamily": MessageLookupByLibrary.simpleMessage(
      "Подписка этого Apple ID принадлежит другой семье в Safini.",
    ),
    "proPaymentIssue": MessageLookupByLibrary.simpleMessage(
      "Apple не смог списать оплату. Обновите карту, чтобы сохранить Pro.",
    ),
    "proPending": MessageLookupByLibrary.simpleMessage(
      "Ждём подтверждения. Pro включится сразу после него.",
    ),
    "proPerMonth": m135,
    "proPerYear": m136,
    "proRenewsOn": m137,
    "proRestore": MessageLookupByLibrary.simpleMessage("Восстановить покупки"),
    "proRestored": MessageLookupByLibrary.simpleMessage(
      "Safini Pro восстановлен.",
    ),
    "proSave": m138,
    "proSettingsFree": MessageLookupByLibrary.simpleMessage("Бесплатный план"),
    "proStartTrial": MessageLookupByLibrary.simpleMessage(
      "Начать бесплатный период",
    ),
    "proStoreUnavailable": MessageLookupByLibrary.simpleMessage(
      "Не удалось связаться с App Store.",
    ),
    "proSubscribe": MessageLookupByLibrary.simpleMessage("Оформить подписку"),
    "proTerms": MessageLookupByLibrary.simpleMessage("Условия использования"),
    "proTitle": MessageLookupByLibrary.simpleMessage("Safini Pro"),
    "proTrialDays": m139,
    "proTrialMonths": m140,
    "proTrialThen": m141,
    "proTrialUntil": m142,
    "proTrialWeeks": m143,
    "proTrialYears": m144,
    "proWebFailed": MessageLookupByLibrary.simpleMessage(
      "Не удалось открыть safini.fun. Попробуйте ещё раз.",
    ),
    "proWebLede": MessageLookupByLibrary.simpleMessage(
      "На Android Safini Pro покупается на safini.fun. Входить заново не нужно, это займёт минуту. Есть промокод? Введите его ниже.",
    ),
    "proWelcome": MessageLookupByLibrary.simpleMessage(
      "Добро пожаловать в Safini Pro!",
    ),
    "proYearly": MessageLookupByLibrary.simpleMessage("На год"),
    "profile": MessageLookupByLibrary.simpleMessage("Профиль"),
    "profileUpdated": MessageLookupByLibrary.simpleMessage("Сохранено"),
    "promoAlreadyPro": MessageLookupByLibrary.simpleMessage(
      "У вашей семьи уже есть Safini Pro.",
    ),
    "promoAlreadyUsed": MessageLookupByLibrary.simpleMessage(
      "Ваша семья уже использовала этот промокод.",
    ),
    "promoApplied": MessageLookupByLibrary.simpleMessage(
      "Промокод применён. У вашей семьи Safini Pro.",
    ),
    "promoApply": MessageLookupByLibrary.simpleMessage("Применить"),
    "promoFailed": MessageLookupByLibrary.simpleMessage(
      "Не удалось проверить код. Попробуйте ещё раз.",
    ),
    "promoHint": MessageLookupByLibrary.simpleMessage("Введите код"),
    "promoInvalid": MessageLookupByLibrary.simpleMessage(
      "Этот промокод недействителен.",
    ),
    "promoTitle": MessageLookupByLibrary.simpleMessage("Промокод"),
    "promoTooMany": MessageLookupByLibrary.simpleMessage(
      "Слишком много попыток. Подождите несколько минут и попробуйте снова.",
    ),
    "promoUsedUp": MessageLookupByLibrary.simpleMessage(
      "Этот промокод уже закончился.",
    ),
    "proofPhotoFailed": MessageLookupByLibrary.simpleMessage(
      "Не удалось загрузить фото",
    ),
    "questsDone": MessageLookupByLibrary.simpleMessage("Заданий выполнено"),
    "questsText": MessageLookupByLibrary.simpleMessage("Задания"),
    "readFor20Mins": MessageLookupByLibrary.simpleMessage("Читать 20 м"),
    "readyToSpend": MessageLookupByLibrary.simpleMessage(
      "Готовы потратить монеты?",
    ),
    "readyWhenYouAre": MessageLookupByLibrary.simpleMessage("Можно начинать"),
    "realWorldTasks": MessageLookupByLibrary.simpleMessage("Задания в жизни"),
    "reconnectCodeValid": MessageLookupByLibrary.simpleMessage(
      "Код повторной связи · 24 часа",
    ),
    "reconnectMovesProfile": m145,
    "reconnectWithCode": MessageLookupByLibrary.simpleMessage(
      "Связать заново по коду",
    ),
    "recordVoiceInstruction": MessageLookupByLibrary.simpleMessage(
      "Записать голосовую инструкцию",
    ),
    "recordingVoice": MessageLookupByLibrary.simpleMessage("Запись"),
    "redeemExplainer": m146,
    "redoNoteHint": MessageLookupByLibrary.simpleMessage(
      "Что исправить? Необязательно.",
    ),
    "reject": MessageLookupByLibrary.simpleMessage("Отклонить"),
    "remaining": MessageLookupByLibrary.simpleMessage("Осталось"),
    "remainingTime": m147,
    "removeChild": MessageLookupByLibrary.simpleMessage(
      "Удалить аккаунт ребёнка",
    ),
    "removeChildConfirmBody": m148,
    "removeChildConfirmTitle": m149,
    "removeChildDeletedSuccess": m150,
    "removeChildError": MessageLookupByLibrary.simpleMessage(
      "Не удалось удалить аккаунт ребёнка. Попробуйте снова.",
    ),
    "removeChildForbidden": MessageLookupByLibrary.simpleMessage(
      "У вас нет прав на удаление этого аккаунта.",
    ),
    "removeChildInProgress": MessageLookupByLibrary.simpleMessage(
      "Удаляем аккаунт ребёнка…",
    ),
    "removeChildNetworkError": MessageLookupByLibrary.simpleMessage(
      "Не удалось подключиться. Проверьте интернет и попробуйте снова.",
    ),
    "removeChildNotFound": MessageLookupByLibrary.simpleMessage(
      "Этого ребёнка больше нет в вашей семье. Список семьи обновлён.",
    ),
    "removeChildRefreshError": MessageLookupByLibrary.simpleMessage(
      "Аккаунт ребёнка удалён, но не удалось обновить список семьи. Попробуйте обновить его ещё раз.",
    ),
    "removeChildUnauthorized": MessageLookupByLibrary.simpleMessage(
      "Сессия истекла. Войдите снова, чтобы удалить аккаунт ребёнка.",
    ),
    "removeFromFamily": MessageLookupByLibrary.simpleMessage("Убрать из семьи"),
    "removeLimit": MessageLookupByLibrary.simpleMessage("Убрать лимит"),
    "removeParent": MessageLookupByLibrary.simpleMessage("Удалить из семьи"),
    "removeParentConfirmBody": MessageLookupByLibrary.simpleMessage(
      "Вы уверены, что хотите удалить этого родителя из семьи?",
    ),
    "removeParentConfirmTitle": MessageLookupByLibrary.simpleMessage(
      "Удалить родителя?",
    ),
    "removePrize": MessageLookupByLibrary.simpleMessage("Удалить подарок"),
    "removeVoice": MessageLookupByLibrary.simpleMessage("Удалить"),
    "repeatDaily": MessageLookupByLibrary.simpleMessage("Каждый день"),
    "repeatDailyShort": MessageLookupByLibrary.simpleMessage("Ежедневно"),
    "repeatLabel": MessageLookupByLibrary.simpleMessage("Повтор"),
    "repeatOnce": MessageLookupByLibrary.simpleMessage("Один раз"),
    "repeatWeekly": MessageLookupByLibrary.simpleMessage("По дням"),
    "repeatWeeklyShort": MessageLookupByLibrary.simpleMessage("Еженедельно"),
    "rerecordVoice": MessageLookupByLibrary.simpleMessage("Записать заново"),
    "retakePhoto": MessageLookupByLibrary.simpleMessage("Переснять"),
    "retry": MessageLookupByLibrary.simpleMessage("Повторить"),
    "reviewNoteHint": MessageLookupByLibrary.simpleMessage("Необязательно"),
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
    "rewardsForYou": MessageLookupByLibrary.simpleMessage("Награды для тебя"),
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
    "saveForName": m151,
    "saveMyLook": MessageLookupByLibrary.simpleMessage("Сохранить вид!"),
    "savedForName": m152,
    "scopeEveryone": MessageLookupByLibrary.simpleMessage("Все"),
    "screenTime": MessageLookupByLibrary.simpleMessage("Экранное время"),
    "screenTimeCap": MessageLookupByLibrary.simpleMessage(
      "Экранное время в день",
    ),
    "screenTimeCapHint": MessageLookupByLibrary.simpleMessage(
      "На все приложения вместе. Если выключено, только лимиты приложений.",
    ),
    "sectionAccount": MessageLookupByLibrary.simpleMessage("Аккаунт"),
    "sectionAlerts": MessageLookupByLibrary.simpleMessage("Оповещения"),
    "sectionApp": MessageLookupByLibrary.simpleMessage("Приложение"),
    "seeAllApps": MessageLookupByLibrary.simpleMessage(
      "Все приложения на телефоне",
    ),
    "seeAllRewards": MessageLookupByLibrary.simpleMessage("Все"),
    "selectLanguage": MessageLookupByLibrary.simpleMessage("Выберите язык"),
    "sendWish": MessageLookupByLibrary.simpleMessage("Отправить"),
    "sentForApproval": MessageLookupByLibrary.simpleMessage(
      "Отправлено на проверку",
    ),
    "setUpANewProfile": MessageLookupByLibrary.simpleMessage(
      "Создать новый профиль",
    ),
    "settings": MessageLookupByLibrary.simpleMessage("Настройки"),
    "setupStepAppLock": MessageLookupByLibrary.simpleMessage(
      "Поставить PIN-код",
    ),
    "setupStepChild": MessageLookupByLibrary.simpleMessage("Добавить ребёнка"),
    "setupStepLimit": MessageLookupByLibrary.simpleMessage(
      "Задать дневной лимит",
    ),
    "setupStepPhone": MessageLookupByLibrary.simpleMessage(
      "Подключить телефон",
    ),
    "setupStepPrize": MessageLookupByLibrary.simpleMessage("Добавить подарок"),
    "setupStepTask": MessageLookupByLibrary.simpleMessage("Создать задание"),
    "setupYourFamily": MessageLookupByLibrary.simpleMessage("Настройте семью"),
    "showAllAppsCount": m153,
    "showFewerApps": MessageLookupByLibrary.simpleMessage("Свернуть"),
    "signInAction": MessageLookupByLibrary.simpleMessage("Войти"),
    "signInError": MessageLookupByLibrary.simpleMessage(
      "Не удалось войти. Попробуйте ещё раз.",
    ),
    "signedInSuccess": MessageLookupByLibrary.simpleMessage("Вход выполнен"),
    "signingIn": MessageLookupByLibrary.simpleMessage("Вход..."),
    "signoutAllow": MessageLookupByLibrary.simpleMessage("Разрешить"),
    "signoutAskAgain": MessageLookupByLibrary.simpleMessage(
      "Попросить ещё раз",
    ),
    "signoutAskBody": MessageLookupByLibrary.simpleMessage(
      "После выхода лимиты приложений отключатся, поэтому нужно согласие родителя. Мы отправили ему запрос.",
    ),
    "signoutAskTitle": MessageLookupByLibrary.simpleMessage(
      "Попроси родителя разрешить выход",
    ),
    "signoutDenied": MessageLookupByLibrary.simpleMessage(
      "Родитель не разрешил, поэтому ты остаёшься в аккаунте.",
    ),
    "signoutEnded": MessageLookupByLibrary.simpleMessage(
      "Запрос больше не действует. Попроси ещё раз, если всё ещё нужно выйти.",
    ),
    "signoutKeep": MessageLookupByLibrary.simpleMessage("Не выходить"),
    "signoutReviewMeta": m154,
    "signoutReviewTitle": m155,
    "signoutTypeCode": MessageLookupByLibrary.simpleMessage(
      "Или введи код, который назовёт родитель",
    ),
    "signoutWaiting": MessageLookupByLibrary.simpleMessage("Ждём ответа…"),
    "signoutWrongCode": m156,
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
    "stopRecording": MessageLookupByLibrary.simpleMessage("Стоп"),
    "store": MessageLookupByLibrary.simpleMessage("Магазин"),
    "storeAppTimeTab": MessageLookupByLibrary.simpleMessage("Время"),
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
    "tabFini": MessageLookupByLibrary.simpleMessage("Fini"),
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
    "taskCount": m157,
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
    "taskFiniApproved": MessageLookupByLibrary.simpleMessage("Одобрено Fini"),
    "taskFiniCheck": MessageLookupByLibrary.simpleMessage(
      "Пусть Fini проверит",
    ),
    "taskFiniCheckSub": MessageLookupByLibrary.simpleMessage(
      "Fini сверит задание со временем в приложениях за сегодня и фото, если оно есть, и одобрит, только если всё ясно. Отменить можно в течение 24 ч.",
    ),
    "taskFiniCheckingTask": MessageLookupByLibrary.simpleMessage(
      "Fini проверяет",
    ),
    "taskFiniNoSignals": MessageLookupByLibrary.simpleMessage(
      "Fini: сегодня нечего проверить, ни времени в приложениях, ни фото",
    ),
    "taskFiniSawApp": m158,
    "taskFiniSawPhoto": m159,
    "taskFiniUndo": MessageLookupByLibrary.simpleMessage("Отменить"),
    "taskGroupSummary": m160,
    "taskIdeaBrushTeethDetails": MessageLookupByLibrary.simpleMessage(
      "Почисти зубы две минуты после сна и пришли фото.",
    ),
    "taskIdeaBrushTeethTitle": MessageLookupByLibrary.simpleMessage(
      "Почистить зубы утром",
    ),
    "taskIdeaDuolingoDetails": MessageLookupByLibrary.simpleMessage(
      "Пройди сегодня хотя бы один урок в Duolingo.",
    ),
    "taskIdeaDuolingoTitle": MessageLookupByLibrary.simpleMessage(
      "Пройти урок в Duolingo",
    ),
    "taskIdeaExerciseDetails": MessageLookupByLibrary.simpleMessage(
      "Активно подвигайся дома или на улице не меньше 20 минут.",
    ),
    "taskIdeaExerciseTitle": MessageLookupByLibrary.simpleMessage(
      "Позаниматься 20 минут",
    ),
    "taskIdeaFeedPetDetails": MessageLookupByLibrary.simpleMessage(
      "Дай питомцу подходящий корм и свежую воду.",
    ),
    "taskIdeaFeedPetTitle": MessageLookupByLibrary.simpleMessage(
      "Покормить питомца",
    ),
    "taskIdeaHomeworkDetails": MessageLookupByLibrary.simpleMessage(
      "Выполни задания, которые задали на следующий учебный день.",
    ),
    "taskIdeaHomeworkTitle": MessageLookupByLibrary.simpleMessage(
      "Сделать домашнее задание",
    ),
    "taskIdeaMakeBedDetails": MessageLookupByLibrary.simpleMessage(
      "Аккуратно заправь кровать после подъёма и пришли фото.",
    ),
    "taskIdeaMakeBedTitle": MessageLookupByLibrary.simpleMessage(
      "Заправить кровать",
    ),
    "taskIdeaPackSchoolBagDetails": MessageLookupByLibrary.simpleMessage(
      "Собери книги и принадлежности на следующий учебный день.",
    ),
    "taskIdeaPackSchoolBagTitle": MessageLookupByLibrary.simpleMessage(
      "Собрать школьный рюкзак",
    ),
    "taskIdeaPracticeInstrumentDetails": MessageLookupByLibrary.simpleMessage(
      "Позанимайся на музыкальном инструменте не меньше 20 минут.",
    ),
    "taskIdeaPracticeInstrumentTitle": MessageLookupByLibrary.simpleMessage(
      "Позаниматься на инструменте",
    ),
    "taskIdeaPutAwayLaundryDetails": MessageLookupByLibrary.simpleMessage(
      "Сложи чистую одежду и убери её в нужные ящики.",
    ),
    "taskIdeaPutAwayLaundryTitle": MessageLookupByLibrary.simpleMessage(
      "Убрать чистую одежду",
    ),
    "taskIdeaPutAwayToysDetails": MessageLookupByLibrary.simpleMessage(
      "Убери все игрушки в коробки или на полки.",
    ),
    "taskIdeaPutAwayToysTitle": MessageLookupByLibrary.simpleMessage(
      "Убрать игрушки",
    ),
    "taskIdeaRead20Details": MessageLookupByLibrary.simpleMessage(
      "Почитай книгу не меньше 20 минут, не отвлекаясь на приложения.",
    ),
    "taskIdeaRead20Title": MessageLookupByLibrary.simpleMessage(
      "Читать 20 минут",
    ),
    "taskIdeaSetTableDetails": MessageLookupByLibrary.simpleMessage(
      "Поставь тарелки, чашки и приборы для семейной еды.",
    ),
    "taskIdeaSetTableTitle": MessageLookupByLibrary.simpleMessage(
      "Накрыть на стол",
    ),
    "taskIdeaSolvePuzzleDetails": MessageLookupByLibrary.simpleMessage(
      "Реши одну подходящую по возрасту головоломку, загадку или шахматную задачу.",
    ),
    "taskIdeaSolvePuzzleTitle": MessageLookupByLibrary.simpleMessage(
      "Решить головоломку",
    ),
    "taskIdeaTidyRoomDetails": MessageLookupByLibrary.simpleMessage(
      "Разложи вещи по местам и освободи пол.",
    ),
    "taskIdeaTidyRoomTitle": MessageLookupByLibrary.simpleMessage(
      "Убрать в комнате",
    ),
    "taskIdeaWaterPlantsDetails": MessageLookupByLibrary.simpleMessage(
      "Проверь растения и полей те, которым нужна вода.",
    ),
    "taskIdeaWaterPlantsTitle": MessageLookupByLibrary.simpleMessage(
      "Полить растения",
    ),
    "taskIdeasEmptyTitle": MessageLookupByLibrary.simpleMessage(
      "Пока нет заданий",
    ),
    "taskIdeasHint": MessageLookupByLibrary.simpleMessage(
      "Нажмите на идею, проверьте детали и добавьте.",
    ),
    "taskIdeasMoreTitle": MessageLookupByLibrary.simpleMessage("Ещё идеи"),
    "taskPuzzleSub": MessageLookupByLibrary.simpleMessage("Зарядка для ума"),
    "taskPuzzleTitle": MessageLookupByLibrary.simpleMessage(
      "Логическая головоломка",
    ),
    "taskReadingSub": MessageLookupByLibrary.simpleMessage("Расширяй кругозор"),
    "taskReadingTitle": MessageLookupByLibrary.simpleMessage("Читать 20 м"),
    "taskRejectedMessage": MessageLookupByLibrary.simpleMessage(
      "Задание отклонено.",
    ),
    "taskRoomSub": MessageLookupByLibrary.simpleMessage("Ежедневное дело"),
    "taskRoomTitle": MessageLookupByLibrary.simpleMessage("Убраться в комнате"),
    "taskScopeLine": m161,
    "taskStepsSub": MessageLookupByLibrary.simpleMessage("Больше движения!"),
    "taskStepsTitle": MessageLookupByLibrary.simpleMessage(
      "Пройти 5,000 шагов",
    ),
    "taskSubmittedForReview": MessageLookupByLibrary.simpleMessage(
      "Отправлено родителю",
    ),
    "taskTemplatesTitle": MessageLookupByLibrary.simpleMessage("Шаблоны"),
    "taskTitleHint": MessageLookupByLibrary.simpleMessage("Полить цветы"),
    "taskUpdatedMessage": MessageLookupByLibrary.simpleMessage(
      "Задание обновлено!",
    ),
    "tasks": MessageLookupByLibrary.simpleMessage("Задания"),
    "tasksAndRewards": MessageLookupByLibrary.simpleMessage(
      "Задания и награды",
    ),
    "tasksLeftCoinsOnTable": m162,
    "theirNote": MessageLookupByLibrary.simpleMessage("Его заметка"),
    "theyInstallSafini": MessageLookupByLibrary.simpleMessage(
      "Пусть установят Safini, войдут и введут этот код.",
    ),
    "thisWeek": MessageLookupByLibrary.simpleMessage("На этой неделе"),
    "thu": MessageLookupByLibrary.simpleMessage("ЧТ"),
    "timeCoins": MessageLookupByLibrary.simpleMessage("Монеты времени"),
    "timeLeft": m163,
    "timeUsed": m164,
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
    "toGo": m165,
    "todayOffline": MessageLookupByLibrary.simpleMessage("Нет связи"),
    "todayOfflineBody": MessageLookupByLibrary.simpleMessage(
      "Задания появятся, когда будет интернет. Потяни вниз, чтобы обновить.",
    ),
    "todaysQuests": MessageLookupByLibrary.simpleMessage("Сегодняшние задания"),
    "tourChildFriendsBody": MessageLookupByLibrary.simpleMessage(
      "Добавь друга по его 6-значному ID Safini и посмотри, как у него дела.",
    ),
    "tourChildFriendsTitle": MessageLookupByLibrary.simpleMessage(
      "Твои друзья",
    ),
    "tourChildMeBody": MessageLookupByLibrary.simpleMessage(
      "Настрой аватар и смотри свои успехи здесь.",
    ),
    "tourChildMeTitle": MessageLookupByLibrary.simpleMessage("Твоя страница"),
    "tourChildStoreBody": MessageLookupByLibrary.simpleMessage(
      "Меняй монеты на время в приложениях, вещи для аватара или подарки. Запросы на подарки получает родитель.",
    ),
    "tourChildStoreTitle": MessageLookupByLibrary.simpleMessage("Трать монеты"),
    "tourChildTasksBody": MessageLookupByLibrary.simpleMessage(
      "Выполни задание и отправь родителю. Монеты придут после подтверждения.",
    ),
    "tourChildTasksTitle": MessageLookupByLibrary.simpleMessage("Твои задания"),
    "tourChildTodayBody": MessageLookupByLibrary.simpleMessage(
      "Здесь видно твоё время, монеты, серию дней и следующий шаг. Родитель также видит, какими приложениями ты пользуешься.",
    ),
    "tourChildTodayTitle": MessageLookupByLibrary.simpleMessage(
      "Твоя главная страница",
    ),
    "tourDone": MessageLookupByLibrary.simpleMessage("Понятно"),
    "tourNext": MessageLookupByLibrary.simpleMessage("Далее"),
    "tourParentFamilyBody": MessageLookupByLibrary.simpleMessage(
      "Здесь можно добавить детей и подключить их телефоны. Список шагов настройки остаётся на главной странице.",
    ),
    "tourParentFamilyTitle": MessageLookupByLibrary.simpleMessage("Семья"),
    "tourParentGiftsBody": MessageLookupByLibrary.simpleMessage(
      "Добавляйте настоящие подарки. Когда ребёнок просит подарок, монеты резервируются, пока вы не вручите его или не отклоните запрос.",
    ),
    "tourParentGiftsTitle": MessageLookupByLibrary.simpleMessage("Подарки"),
    "tourParentLimitsBody": MessageLookupByLibrary.simpleMessage(
      "Установите дневной бюджет экранного времени и правила для приложений. Вы решаете, можно ли покупать дополнительное время за монеты.",
    ),
    "tourParentLimitsTitle": MessageLookupByLibrary.simpleMessage("Лимиты"),
    "tourParentReviewBody": MessageLookupByLibrary.simpleMessage(
      "Сюда попадают выполненные задания и запросы на подарки. Подтвердите задание, чтобы начислить монеты, или сначала откройте его.",
    ),
    "tourParentReviewTitle": MessageLookupByLibrary.simpleMessage(
      "Нужно проверить",
    ),
    "tourParentTasksBody": MessageLookupByLibrary.simpleMessage(
      "Создавайте задания, назначайте награду в монетах и проверяйте работу ребёнка.",
    ),
    "tourParentTasksTitle": MessageLookupByLibrary.simpleMessage("Задания"),
    "tourParentTodayBody": MessageLookupByLibrary.simpleMessage(
      "Здесь видно экранное время, задания, серию дней и монеты каждого ребёнка.",
    ),
    "tourParentTodayTitle": MessageLookupByLibrary.simpleMessage(
      "Ваша главная страница",
    ),
    "tourSkip": MessageLookupByLibrary.simpleMessage("Пропустить"),
    "tourStep": m166,
    "tryAgain": MessageLookupByLibrary.simpleMessage("Повторить"),
    "tue": MessageLookupByLibrary.simpleMessage("ВТ"),
    "typeCodeFromOtherParent": MessageLookupByLibrary.simpleMessage(
      "Введите код от второго родителя",
    ),
    "typeCodeFromParent": MessageLookupByLibrary.simpleMessage(
      "Введите код от родителя",
    ),
    "typeItOnPhone": m167,
    "unitHour": MessageLookupByLibrary.simpleMessage("ч"),
    "unitMinute": MessageLookupByLibrary.simpleMessage("м"),
    "unlockExtraTime": MessageLookupByLibrary.simpleMessage(
      "Разблокировать время",
    ),
    "unlockOnceKeepForever": MessageLookupByLibrary.simpleMessage(
      "Открой один раз - останется навсегда",
    ),
    "unlocked": MessageLookupByLibrary.simpleMessage("разблокировано"),
    "updateCta": MessageLookupByLibrary.simpleMessage("Обновить"),
    "updateDismiss": MessageLookupByLibrary.simpleMessage("Позже"),
    "updateHardBody": MessageLookupByLibrary.simpleMessage(
      "Эта версия больше не поддерживается. Обновите приложение, чтобы продолжить.",
    ),
    "updateHardTitle": MessageLookupByLibrary.simpleMessage("Нужно обновить"),
    "updateSoftBody": MessageLookupByLibrary.simpleMessage(
      "Вышла более новая версия.",
    ),
    "updateSoftTitle": MessageLookupByLibrary.simpleMessage(
      "Доступно обновление",
    ),
    "usedLimit": m168,
    "usedNoLimit": m169,
    "usedOfLimit": m170,
    "usedOfLimitOver": m171,
    "usedTodayShort": m172,
    "uzbek": MessageLookupByLibrary.simpleMessage("Узбекский"),
    "viewAsKid": MessageLookupByLibrary.simpleMessage("Войти как ребенок"),
    "viewPhoto": MessageLookupByLibrary.simpleMessage("Открыть фото"),
    "voiceAttachFailed": MessageLookupByLibrary.simpleMessage(
      "Не удалось прикрепить голосовую заметку. Попробуйте ещё раз.",
    ),
    "voiceInstructionLabel": MessageLookupByLibrary.simpleMessage(
      "Голосовая инструкция",
    ),
    "voicePlaybackFailed": MessageLookupByLibrary.simpleMessage(
      "Не удалось воспроизвести голосовую заметку.",
    ),
    "voiceSecondsLeft": m173,
    "waitingCount": m174,
    "waitingForParentCheck": MessageLookupByLibrary.simpleMessage(
      "Ждём проверки родителя",
    ),
    "waitingForPhone": m175,
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
    "wishForSomething": MessageLookupByLibrary.simpleMessage(
      "Загадать желание",
    ),
    "wishLabel": MessageLookupByLibrary.simpleMessage("Желание"),
    "wishNameHint": MessageLookupByLibrary.simpleMessage("Футбольный мяч"),
    "wishPriceLabel": MessageLookupByLibrary.simpleMessage("Цена"),
    "wishReviewBody": m176,
    "wishReviewTitle": m177,
    "wishSent": MessageLookupByLibrary.simpleMessage(
      "Желание отправлено. Родитель увидит его.",
    ),
    "wishSheetBody": MessageLookupByLibrary.simpleMessage(
      "Назови цену. Родитель может добавить это в твой магазин.",
    ),
    "wishSheetTitle": MessageLookupByLibrary.simpleMessage(
      "О чём ты мечтаешь?",
    ),
    "wornLabel": MessageLookupByLibrary.simpleMessage("Надето"),
    "worthCoins": m178,
    "yearsOld": m179,
    "youNeedMoreCoins": m180,
    "youSuffix": m181,
    "yourAccount": MessageLookupByLibrary.simpleMessage("Ваш аккаунт"),
    "yourAvatar": MessageLookupByLibrary.simpleMessage("Твой аватар"),
    "yourChildren": MessageLookupByLibrary.simpleMessage("ВАШИ ДЕТИ"),
    "yourName": MessageLookupByLibrary.simpleMessage("Ваше имя"),
    "yourOwnPrize": MessageLookupByLibrary.simpleMessage("Свой подарок"),
    "yoursLabel": MessageLookupByLibrary.simpleMessage("Твоё"),
  };
}
