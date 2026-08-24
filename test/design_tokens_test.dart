import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:safini/core/theme/app_colors.dart';
import 'package:safini/core/theme/app_shadows.dart';

/// Token drift is the failure mode of a hand-ported design system: a value gets
/// nudged to fix one screen and the artboard relationship is quietly gone.
///
/// Every `TextStyle` in `app_typography.dart` carries its artboard spec in a
/// doc comment (`34 / 700 / -.024em`). This reads both the comment and the code
/// out of the source and checks they still agree - so a new style is covered
/// the moment it is written, without anyone remembering to extend this file.
void main() {
  group('typography matches its documented artboard spec', () {
    final source = File(
      'lib/core/theme/app_typography.dart',
    ).readAsStringSync();

    // `/// 34 / 700 / -.024em - …` immediately above
    // `static const TextStyle largeTitle = TextStyle( … );`
    final pattern = RegExp(
      r'///\s*(\d+(?:\.\d+)?)\s*/\s*(\d+)(?:\s*/\s*(-?\.?\d+(?:\.\d+)?)em)?'
      r'[^\n]*\n(?:\s*///[^\n]*\n)*'
      r'\s*static const TextStyle (\w+) = TextStyle\(([^;]*?)\);',
      multiLine: true,
    );

    final matches = pattern.allMatches(source).toList();

    test('the doc comments are still machine-readable', () {
      // If this drops, the rest of the group silently stops checking anything.
      expect(
        matches.length,
        greaterThanOrEqualTo(20),
        reason: 'only ${matches.length} styles parsed - the doc-comment shape '
            'in app_typography.dart changed and this test went blind',
      );
    });

    for (final match in matches) {
      final specSize = double.parse(match.group(1)!);
      final specEm = match.group(3);
      final name = match.group(4)!;
      final body = match.group(5)!;

      double? valueOf(String field) {
        final found = RegExp(
          '$field:\\s*(-?\\d+(?:\\.\\d+)?)',
        ).firstMatch(body);
        return found == null ? null : double.parse(found.group(1)!);
      }

      test('AppText.$name', () {
        expect(
          valueOf('fontSize'),
          specSize,
          reason: 'fontSize disagrees with the doc comment',
        );

        if (specEm == null) return;

        // CSS letter-spacing is em; Flutter's is logical pixels.
        final expected = specSize * double.parse(specEm);
        expect(
          valueOf('letterSpacing'),
          closeTo(expected, 0.001),
          reason: 'letterSpacing should be $specSize x ${specEm}em',
        );
      });
    }
  });

  group('AppColors.kidColor', () {
    test('is stable for a given child', () {
      // The design promises a child keeps the same colour on every surface:
      // the Today chip, the review avatar, the family card. That only holds if
      // the hash is pure.
      final first = AppColors.kidColor('child-uuid-1');
      for (var i = 0; i < 100; i++) {
        expect(AppColors.kidColor('child-uuid-1'), first);
      }
    });

    test('only ever returns a colour from the palette', () {
      for (var i = 0; i < 500; i++) {
        expect(AppColors.kidPalette, contains(AppColors.kidColor('kid-$i')));
      }
    });

    test('falls back to the brand purple with nothing to hash', () {
      expect(AppColors.kidColor(null), AppColors.primary);
      expect(AppColors.kidColor(''), AppColors.primary);
    });

    test('distinguishes ids that differ by one character', () {
      // Sibling ids from the same backend often share a long prefix; a hash
      // that ignored the tail would paint a whole family one colour.
      final colours = {
        for (var i = 0; i < 5; i++)
          AppColors.kidColor('f47ac10b-58cc-4372-a567-0e02b2c3d47$i'),
      };
      expect(colours.length, greaterThan(1));
    });

    test('takes a non-string seed', () {
      expect(AppColors.kidPalette, contains(AppColors.kidColor(42)));
    });
  });

  group('shadows keep the two-layer structure', () {
    test('a lifted card is a contact layer plus a spread-back lift', () {
      // The artboard pairs `0 1px 2px` with a wide negative-spread layer.
      // Dropping the 1px contact shadow is the usual "simplification" and it
      // makes every card look like it is floating.
      for (final shadow in [
        AppShadows.card,
        AppShadows.cardSoft,
      ]) {
        expect(shadow, hasLength(2));

        final contact = shadow.first;
        expect(contact.offset, const Offset(0, 1));
        expect(contact.blurRadius, 2);
        expect(contact.spreadRadius, 0);

        final lift = shadow.last;
        expect(lift.offset.dy, greaterThan(8));
        expect(lift.spreadRadius, lessThan(0));
      }
    });

    test('the flat variants are a single contact layer', () {
      expect(AppShadows.flat, hasLength(1));
      expect(AppShadows.hairline, hasLength(1));
      expect(AppShadows.flat.single.offset, const Offset(0, 1));
    });
  });

  group('palettes', () {
    test('are the artboard sets, in order', () {
      // Add a colour here and the "Their colour" row on Add-a-child grows a
      // swatch - that is a design decision, not a refactor.
      expect(AppColors.kidPalette, const [
        Color(0xFF8100D1),
        Color(0xFFEE4FA2),
        Color(0xFFF09A77),
        Color(0xFF00A6C5),
        Color(0xFF00C566),
      ]);
      expect(AppColors.avatarPalette, hasLength(6));
      expect(AppColors.avatarPalette.first, AppColors.primaryDeep);
    });

    test('carry no duplicates', () {
      expect(AppColors.kidPalette.toSet(), hasLength(5));
      expect(AppColors.avatarPalette.toSet(), hasLength(6));
    });
  });
}
