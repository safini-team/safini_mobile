import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:safini/core/app/locale_cubit.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<SharedPreferences> _prefs([Map<String, Object> initial = const {}]) {
  SharedPreferences.setMockInitialValues(initial);
  return SharedPreferences.getInstance();
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('resolving the phone language', () {
    test('maps Russian and English from the device, never Uzbek', () {
      expect(LocaleCubit.resolve([const Locale('ru')]).languageCode, 'ru');
      expect(LocaleCubit.resolve([const Locale('en')]).languageCode, 'en');
      expect(
        LocaleCubit.resolve([const Locale('uz')]),
        LocaleCubit.parentDefault,
        reason: 'Uzbek is picker-only; a uz device must not auto-select it',
      );
    });

    test('matches on language, ignoring the region', () {
      expect(
        LocaleCubit.resolve([const Locale('uz', 'UZ')]),
        LocaleCubit.parentDefault,
      );
      expect(
        LocaleCubit.resolve([const Locale('en', 'GB')]).languageCode,
        'en',
      );
      expect(
        LocaleCubit.resolve([const Locale('ru', 'KZ')]).languageCode,
        'ru',
      );
    });

    test('walks the device preference order, skipping Uzbek', () {
      // German first, Russian second: Russian is the highest auto language.
      expect(
        LocaleCubit.resolve([
          const Locale('de'),
          const Locale('ru'),
          const Locale('en'),
        ]).languageCode,
        'ru',
      );
      expect(
        LocaleCubit.resolve([
          const Locale('tr'),
          const Locale('en'),
        ]).languageCode,
        'en',
      );
      // An Android phone whose first language is Uzbek, with Russian next,
      // must land on Russian rather than treating uz as a match.
      expect(
        LocaleCubit.resolve([
          const Locale('uz'),
          const Locale('ru'),
        ]).languageCode,
        'ru',
      );
      expect(
        LocaleCubit.resolve([
          const Locale('uz'),
          const Locale('en'),
        ]).languageCode,
        'en',
      );
    });

    test('falls back to Russian when nothing auto-selectable matches', () {
      expect(
        LocaleCubit.resolve([const Locale('kk')]),
        LocaleCubit.parentDefault,
      );
      expect(
        LocaleCubit.resolve([const Locale('ky')]),
        LocaleCubit.parentDefault,
      );
      expect(
        LocaleCubit.resolve([const Locale('uz')]),
        LocaleCubit.parentDefault,
      );
      expect(LocaleCubit.resolve(const []), LocaleCubit.parentDefault);
      expect(LocaleCubit.resolve(null), LocaleCubit.parentDefault);
    });
  });

  group('the stored override', () {
    test('is null until the user picks, so the phone decides', () async {
      final cubit = LocaleCubit(await _prefs());
      expect(
        cubit.state,
        isNull,
        reason: 'a null override lets MaterialApp resolve the system locale',
      );
      expect(cubit.hasExplicitChoice, isFalse);
    });

    test('is restored when the user has chosen before login', () async {
      final cubit = LocaleCubit(
        await _prefs({'app_locale': 'uz', 'app_locale_chosen': true}),
      );
      expect(cubit.state?.languageCode, 'uz');
      expect(cubit.hasExplicitChoice, isTrue);
    });

    test('ignores a stored language we no longer ship', () async {
      // Anyone upgrading from the build that still shipped Kazakh.
      final cubit = LocaleCubit(
        await _prefs({'app_locale': 'kk', 'app_locale_chosen': true}),
      );
      expect(cubit.state, isNull);
    });

    test(
      'does not restore an unchosen leftover, including old child Uzbek',
      () async {
        final cubit = LocaleCubit(await _prefs({'app_locale': 'uz'}));
        expect(
          cubit.state,
          isNull,
          reason: 'applyChildDefault used to write uz without marking chosen',
        );
      },
    );

    test('survives a missing preferences plugin', () async {
      expect(LocaleCubit(null).state, isNull);
    });

    test('persists the choice and marks it explicit', () async {
      final prefs = await _prefs();
      final cubit = LocaleCubit(prefs);

      await cubit.setLocale(const Locale('uz'));

      expect(cubit.state?.languageCode, 'uz');
      expect(prefs.getString('app_locale'), 'uz');
      expect(cubit.hasExplicitChoice, isTrue);
    });
  });

  group('account pin', () {
    test(
      'assigns the device language on first login and restores it later',
      () async {
        final prefs = await _prefs();
        final cubit = LocaleCubit(prefs);

        await cubit.bindAccount(
          'parent-1',
          deviceLocales: [const Locale('en', 'GB')],
        );
        expect(cubit.state?.languageCode, 'en');
        expect(prefs.getString('app_locale_for_parent-1'), 'en');

        await cubit.unbindAccount();
        expect(
          cubit.state,
          isNull,
          reason: 'logout follows the phone until the same account signs in',
        );
        expect(
          prefs.getString('app_locale_for_parent-1'),
          'en',
          reason: 'the pin stays keyed by user id across logout',
        );

        await cubit.bindAccount(
          'parent-1',
          deviceLocales: [const Locale('ru')],
        );
        expect(
          cubit.state?.languageCode,
          'en',
          reason: 'login must not re-resolve from the current device language',
        );
      },
    );

    test(
      'pins an explicit picker choice, including Uzbek, to that account',
      () async {
        final prefs = await _prefs();
        final cubit = LocaleCubit(prefs);

        await cubit.setLocale(const Locale('uz'));
        await cubit.bindAccount(
          'parent-1',
          deviceLocales: [const Locale('ru')],
        );

        expect(cubit.state?.languageCode, 'uz');
        expect(prefs.getString('app_locale_for_parent-1'), 'uz');

        await cubit.unbindAccount();
        await cubit.bindAccount(
          'parent-1',
          deviceLocales: [const Locale('en')],
        );
        expect(cubit.state?.languageCode, 'uz');
      },
    );

    test(
      'keeps two accounts on the same handset from sharing a language',
      () async {
        final prefs = await _prefs();
        final cubit = LocaleCubit(prefs);

        await cubit.bindAccount(
          'parent-1',
          deviceLocales: [const Locale('ru')],
        );
        await cubit.setLocale(const Locale('uz'));
        await cubit.unbindAccount();

        await cubit.bindAccount('child-2', deviceLocales: [const Locale('en')]);
        expect(
          cubit.state?.languageCode,
          'en',
          reason:
              'a new account is assigned from the device, not the previous user',
        );

        await cubit.unbindAccount();
        await cubit.bindAccount(
          'parent-1',
          deviceLocales: [const Locale('en')],
        );
        expect(cubit.state?.languageCode, 'uz');
      },
    );

    test('assigns Russian when the device only offers Uzbek', () async {
      final cubit = LocaleCubit(await _prefs());
      await cubit.bindAccount('child-1', deviceLocales: [const Locale('uz')]);
      expect(cubit.state, LocaleCubit.parentDefault);
    });

    test('restores a pinned account on cold start before bind', () async {
      final cubit = LocaleCubit(
        await _prefs({
          'app_locale_account': 'parent-1',
          'app_locale_for_parent-1': 'uz',
        }),
      );
      expect(cubit.state?.languageCode, 'uz');
    });

    test(
      'migrates a legacy explicit global pick onto the first account',
      () async {
        final prefs = await _prefs({
          'app_locale': 'uz',
          'app_locale_chosen': true,
        });
        final cubit = LocaleCubit(prefs);
        expect(cubit.state?.languageCode, 'uz');

        await cubit.bindAccount(
          'parent-1',
          deviceLocales: [const Locale('en')],
        );
        expect(prefs.getString('app_locale_for_parent-1'), 'uz');
        expect(cubit.state?.languageCode, 'uz');
      },
    );
  });
}
