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
    test('prefers the phone language when it is one of the three', () {
      for (final code in LocaleCubit.supported) {
        expect(
          LocaleCubit.resolve([Locale(code)]).languageCode,
          code,
          reason: 'a device set to $code should open in $code',
        );
      }
    });

    test('matches on language, ignoring the region', () {
      expect(LocaleCubit.resolve([const Locale('uz', 'UZ')]).languageCode, 'uz');
      expect(LocaleCubit.resolve([const Locale('en', 'GB')]).languageCode, 'en');
      expect(LocaleCubit.resolve([const Locale('ru', 'KZ')]).languageCode, 'ru');
    });

    test('walks the device preference order', () {
      // A phone set to German first, Russian second, should land on Russian
      // because that is the highest-ranked language we actually ship.
      expect(
        LocaleCubit.resolve([
          const Locale('de'),
          const Locale('ru'),
          const Locale('en'),
        ]).languageCode,
        'ru',
      );
      expect(
        LocaleCubit.resolve([const Locale('tr'), const Locale('en')])
            .languageCode,
        'en',
      );
    });

    test('falls back to Russian when nothing matches', () {
      expect(LocaleCubit.resolve([const Locale('kk')]), LocaleCubit.parentDefault);
      expect(LocaleCubit.resolve([const Locale('ky')]), LocaleCubit.parentDefault);
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

    test('is restored when the user has chosen before', () async {
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

  group('child default', () {
    test('applies Uzbek when the user has not chosen', () async {
      final prefs = await _prefs();
      final cubit = LocaleCubit(prefs);

      await cubit.applyChildDefault();

      expect(cubit.state, LocaleCubit.childDefault);
      expect(prefs.getString('app_locale'), 'uz');
    });

    test('leaves an explicit choice alone', () async {
      final prefs = await _prefs();
      final cubit = LocaleCubit(prefs);
      await cubit.setLocale(const Locale('ru'));

      await cubit.applyChildDefault();

      expect(
        cubit.state?.languageCode,
        'ru',
        reason: 'claiming a profile must not override what the user picked',
      );
    });
  });
}
