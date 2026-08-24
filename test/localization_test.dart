import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:safini/core/translation/generated/l10n.dart';
import 'package:safini/features/parent/presentation/screens/monitor/parent_today_view.dart'
    show formatHm, formatHmTight;

/// PRD v4 §9.3: Uzbek (Latin), Russian, English. Kazakh is retired.
const List<String> _locales = ['en', 'ru', 'uz'];

Map<String, dynamic> _arb(String locale) {
  final file = File('lib/core/translation/l10n/intl_$locale.arb');
  expect(file.existsSync(), isTrue, reason: 'intl_$locale.arb is missing');
  return jsonDecode(file.readAsStringSync()) as Map<String, dynamic>;
}

Set<String> _keys(Map<String, dynamic> arb) =>
    arb.keys.where((k) => !k.startsWith('@')).toSet();

/// Placeholder names an ICU message depends on, e.g. `{name}` and `{count}`.
///
/// Skips ICU keywords and the literal branch text inside `=1{1 task}`, which is
/// not a placeholder even though it sits behind a brace.
Set<String> _placeholders(String message) {
  // Strip the literal text inside ICU branches first. `one{{count} монета}`
  // contributes `count` and nothing else; without this the branch body itself
  // parses as a placeholder, so "You need 1 more coin." reads as a `You`
  // placeholder that Russian does not have.
  final stripped = _stripBranchBodies(message);
  return RegExp(r'\{\s*([A-Za-z_]\w*)\s*[,}]')
      .allMatches(stripped)
      .map((m) => m.group(1)!)
      .where(
        (name) => !const {
          'plural',
          'select',
          'other',
          'one',
          'few',
          'many',
          'two',
          'zero',
        }.contains(name),
      )
      .toSet();
}

/// Replaces `=1{…}` / `other{…}` branch bodies with their placeholders only.
String _stripBranchBodies(String message) {
  final selector = RegExp(r'(=\d+|zero|one|two|few|many|other)\s*\{');
  var result = message;
  while (true) {
    final match = selector.firstMatch(result);
    if (match == null) return result;

    var depth = 1;
    var index = match.end;
    while (index < result.length && depth > 0) {
      if (result[index] == '{') depth++;
      if (result[index] == '}') depth--;
      index++;
    }
    final body = result.substring(match.end, index - 1);
    // Keep any nested placeholders, drop the prose around them.
    final kept = RegExp(r'\{\s*[A-Za-z_]\w*\s*\}')
        .allMatches(body)
        .map((m) => m.group(0)!)
        .join();
    result = result.replaceRange(match.start, index, kept);
  }
}

/// Keys whose translation legitimately matches English: proper nouns and words
/// that are spelled the same in the target language.
const Set<String> _sameAsEnglishByDesign = {
  'appName',
  'nameHintExample', // a person's name in the placeholder
  'storeAvatarTab', // "Avatar" is the same word in Uzbek
  'ok',
};

void main() {
  group('locale catalogue', () {
    test('ships exactly en, ru and uz', () {
      final files = Directory('lib/core/translation/l10n')
          .listSync()
          .whereType<File>()
          .map((f) => f.uri.pathSegments.last)
          .where((n) => n.endsWith('.arb'))
          .toList()
        ..sort();

      expect(
        files,
        ['intl_en.arb', 'intl_ru.arb', 'intl_uz.arb'],
        reason: 'Kazakh is retired; only en/ru/uz ship',
      );
    });

    test('S.delegate supports exactly those three', () {
      final codes =
          S.delegate.supportedLocales.map((l) => l.languageCode).toList()
            ..sort();
      final expected = [..._locales]..sort();
      expect(codes, expected);
      expect(S.delegate.isSupported(const Locale('kk')), isFalse);
    });

    test('every locale has the same key set', () {
      final en = _keys(_arb('en'));

      for (final locale in _locales.where((l) => l != 'en')) {
        final other = _keys(_arb(locale));
        expect(
          other.difference(en),
          isEmpty,
          reason: '$locale has keys English does not',
        );
        expect(
          en.difference(other),
          isEmpty,
          reason: '$locale is missing keys English has',
        );
      }
    });

    test('no value is empty or left in English by accident', () {
      final en = _arb('en');

      for (final locale in _locales.where((l) => l != 'en')) {
        final arb = _arb(locale);
        final untranslated = <String>[];

        for (final key in _keys(arb)) {
          final value = arb[key] as String;
          expect(
            value.trim(),
            isNotEmpty,
            reason: '$locale/$key is empty',
          );

          // A value identical to English is only legitimate when it carries no
          // translatable words: a brand name, a symbol, or pure placeholders.
          final english = en[key] as String;
          if (value != english) continue;
          if (_sameAsEnglishByDesign.contains(key)) continue;
          final words = value
              .replaceAll(RegExp(r'\{[^}]*\}'), '')
              .replaceAll(RegExp(r'[^A-Za-z ]'), '')
              .trim();
          if (words.isEmpty) continue;
          if (words == 'SAFINI' || words == 'Safini' || words == 'OK') continue;
          untranslated.add('$key = "$value"');
        }

        expect(
          untranslated,
          isEmpty,
          reason: '$locale still reads as English for: ${untranslated.join(", ")}',
        );
      }
    });

    test('placeholders match English in every locale', () {
      final en = _arb('en');

      for (final locale in _locales.where((l) => l != 'en')) {
        final arb = _arb(locale);
        for (final key in _keys(arb)) {
          expect(
            _placeholders(arb[key] as String),
            _placeholders(en[key] as String),
            reason: '$locale/$key uses different placeholders than English',
          );
        }
      }
    });

    test('Uzbek uses the official ʻ and ʼ, never an ASCII apostrophe', () {
      // An ASCII apostrophe is also ICU's escape character, so a stray one in a
      // placeholder message silently swallows the placeholder.
      final arb = _arb('uz');
      final offenders = <String>[];

      for (final key in _keys(arb)) {
        final value = arb[key] as String;
        if (value.contains("'")) offenders.add('$key = "$value"');
      }

      expect(offenders, isEmpty, reason: offenders.join(', '));
    });

    test('no locale contains an em or en dash', () {
      for (final locale in _locales) {
        final arb = _arb(locale);
        for (final key in _keys(arb)) {
          final value = arb[key] as String;
          expect(
            value.contains('—') || value.contains('–'),
            isFalse,
            reason: '$locale/$key contains a long dash: "$value"',
          );
        }
      }
    });
  });

  group('messages resolve at runtime', () {
    for (final locale in _locales) {
      testWidgets('every key renders in $locale', (tester) async {
        await S.load(Locale(locale));
        final s = S.current;

        // Spot-check one string per surface plus the tab labels, which is what
        // a user actually sees first in each language.
        final samples = <String, String>{
          'tabToday': s.tabToday,
          'tabTasks': s.tabTasks,
          'tabLimits': s.tabLimits,
          'tabFamily': s.tabFamily,
          'tabStore': s.tabStore,
          'tabMe': s.tabMe,
          'needsYourReview': s.needsYourReview,
          'whereTheTimeWent': s.whereTheTimeWent,
          'statTasksDone': s.statTasksDone,
          'allTasks': s.allTasks,
          'holdToMarkDone': s.holdToMarkDone,
          'myFamily': s.myFamily,
          'settings': s.settings,
          'uzbek': s.uzbek,
          'kidHasLeftToday': s.kidHasLeftToday('Amir', '50 m'),
          'taskCount': s.taskCount(3),
          'coinCountShort': s.coinCountShort(25),
          'waitingCount': s.waitingCount(2),
        };

        samples.forEach((key, value) {
          expect(value.trim(), isNotEmpty, reason: '$locale/$key is blank');
          expect(
            value,
            isNot(contains('{')),
            reason: '$locale/$key left an unresolved placeholder: $value',
          );
        });
      });
    }

    testWidgets('time units are localised, not English', (tester) async {
      // The ring and every duration render through formatHm; leaving "h"/"m"
      // in there is the kind of leak the arb diff cannot see.
      const cases = {
        'en': ('h', 'm'),
        'ru': ('ч', 'мин'),
        'uz': ('s', 'd'),
      };

      for (final entry in cases.entries) {
        await S.load(Locale(entry.key));
        final s = S.current;
        expect(s.unitHour, entry.value.$1, reason: '${entry.key} hour unit');
        expect(s.unitMinute, entry.value.$2, reason: '${entry.key} minute unit');
        expect(formatHm(s, 130), contains(entry.value.$1));
        expect(formatHm(s, 45), contains(entry.value.$2));
        expect(formatHmTight(s, 130), '2${entry.value.$1}10');
      }
    });

    testWidgets('plurals inflect in Russian', (tester) async {
      await S.load(const Locale('ru'));
      final s = S.current;

      expect(s.taskCount(1), contains('задание'));
      expect(s.taskCount(3), contains('задания'));
      expect(s.taskCount(5), contains('заданий'));
    });

    testWidgets('every count-bearing string inflects in Russian', (tester) async {
      // These all used to be plain interpolations, so the child badge read
      // "1 заданий" - genitive plural applied to one - and Russian is the
      // parent app's default language.
      await S.load(const Locale('ru'));
      final s = S.current;

      expect(s.badgeTasksDone(1), contains('задание'));
      expect(s.badgeTasksDone(2), contains('задания'));
      expect(s.badgeTasksDone(7), contains('заданий'));

      expect(s.coinsCount(1), contains('монета'));
      expect(s.coinsCount(3), contains('монеты'));
      expect(s.coinsCount(11), contains('монет'));

      expect(s.nDayStreak(1), contains('день'));
      expect(s.nDayStreak(2), contains('дня'));
      expect(s.nDayStreak(5), contains('дней'));

      expect(s.yearsOld(1), contains('год'));
      expect(s.yearsOld(4), contains('года'));
      expect(s.yearsOld(8), contains('лет'));

      expect(s.minutesRemainingLong(1), contains('минута'));
      expect(s.minutesRemainingLong(30), contains('минут'));
    });

    testWidgets('English count strings read naturally at one', (tester) async {
      await S.load(const Locale('en'));
      final s = S.current;

      expect(s.badgeTasksDone(1), '1 task done');
      expect(s.badgeTasksDone(3), '3 tasks done');
      expect(s.coinsCount(1), '1 coin');
      expect(s.yearsOld(1), '1 year old');
    });
  });
}
