import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:safini/core/translation/generated/l10n.dart';
import 'package:safini/features/parent/presentation/screens/monitor/parent_today_view.dart';

/// `formatHm` / `formatHmTight` are ports of `hm()` and `hmTight()` from the
/// artboard script, and every duration in the app renders through one of them.
///
/// `localization_test.dart` already checks that the *units* come from the ARB.
/// What it does not cover is the arithmetic: which parts get dropped, and the
/// zero-pad branch. Those are the ones a refactor breaks silently.
///
/// `Intl.message` resolves against the ambient locale, so `S.load` has to run
/// inside each test rather than once in `setUpAll` - a cached `S` from an
/// earlier locale still renders in whichever locale was loaded last.
void main() {
  Future<S> load(String code) async {
    await S.load(Locale(code));
    return S.current;
  }

  group('formatHm', () {
    test('drops the hour part below 60 minutes', () async {
      final s = await load('en');
      expect(formatHm(s, 0), '0 m');
      expect(formatHm(s, 45), '45 m');
      expect(formatHm(s, 59), '59 m');
    });

    test('drops the minute part on a whole hour', () async {
      final s = await load('en');
      expect(formatHm(s, 60), '1 h');
      expect(formatHm(s, 180), '3 h');
      expect(formatHm(s, 600), '10 h');
    });

    test('keeps both parts otherwise', () async {
      final s = await load('en');
      // The artboard's own numbers: Amir has used 130 of a 180 minute
      // allowance, so the card reads "2 h 10 m" and "50 m" left.
      expect(formatHm(s, 130), '2 h 10 m');
      expect(formatHm(s, 50), '50 m');
      expect(formatHm(s, 61), '1 h 1 m');
    });
  });

  group('formatHmTight', () {
    test('is the ring form: no spaces, unit between the numbers', () async {
      final s = await load('en');
      expect(formatHmTight(s, 130), '2h10');
      expect(formatHmTight(s, 180), '3h');
      expect(formatHmTight(s, 45), '45m');
      expect(formatHmTight(s, 0), '0m');
    });

    test('zero-pads a single-digit minute so the ring keeps its width', () async {
      // The ring label is tabular, which only holds the width if the digit
      // count is stable - "1h5" beside "1h55" would reflow it mid-day.
      final s = await load('en');
      expect(formatHmTight(s, 61), '1h01');
      expect(formatHmTight(s, 65), '1h05');
      expect(formatHmTight(s, 69), '1h09');
      expect(formatHmTight(s, 70), '1h10');
      expect(formatHmTight(s, 119), '1h59');
    });

    test('matches the Russian artboard exactly', () async {
      // The RU copy-pressure artboard shows "2ч10" inside the ring with
      // "из 3ч" underneath.
      final s = await load('ru');
      expect(formatHmTight(s, 130), '2ч10');
      expect(formatHmTight(s, 180), '3ч');
    });
  });
}
