# Localization Guide

This project uses Flutter Intl-generated localization files with Uzbek (Latin), Russian, English, Kyrgyz and Kazakh (both Cyrillic).

## Source of truth

- Translation strings live in:
  - `lib/core/translation/l10n/intl_en.arb`
  - `lib/core/translation/l10n/intl_ru.arb`
  - `lib/core/translation/l10n/intl_uz.arb`
  - `lib/core/translation/l10n/intl_ky.arb`
  - `lib/core/translation/l10n/intl_kk.arb`
- Generated accessors live in:
  - `lib/core/translation/generated/l10n.dart`
- Generated lookup files live in:
  - `lib/core/translation/generated/intl/messages_<locale>.dart`
- The Android block screen, service notification and device-admin copy live in
  `android/app/src/main/res/values{,-ru,-uz,-ky,-kk}/strings.xml`.

## Supported locales

The app currently supports:

- `uz` - Uzbek (Latin)
- `ru` - Russian
- `en` - English
- `ky` - Kyrgyz
- `kk` - Kazakh

Only Russian and English are ever picked from the phone language. Uzbek,
Kyrgyz and Kazakh are offered in the in-app picker and used only after the user
selects one; a phone set to any of them opens in Russian until then
(`LocaleCubit.autoFromDevice`, and `resolvePhoneLanguage` on the native side).

Locale selection is initialized through `lib/core/app/locale_cubit.dart`, and the app registers the localization delegates in `lib/core/app/app.dart`.

## How to add or update a translation

1. Add or update the key in all five locale ARB files (`intl_en`, `intl_ru`, `intl_uz`, `intl_ky`, `intl_kk`).
2. Include placeholders in all locales if the string needs dynamic values.
3. Regenerate the Flutter Intl output (`flutter pub run intl_utils:generate`) so `lib/core/translation/generated/l10n.dart` and the message lookup files stay in sync.
4. Use the generated `S` class in widgets, for example:
   - `S.of(context).appLimits`
   - `S.of(context).childProgressTitle(name)`

## String conventions

- Prefer short, UI-friendly phrases.
- Keep placeholders named consistently across locales.
- Avoid hardcoding user-facing text in widgets when a localized key exists.
- Prefer ICU plurals for count-based text (`coinCount`, `minuteCount`) instead of string concatenation.
- Do not edit generated files by hand unless you are fixing checked-in generated output.

## Pluralization examples

- `coinCount`: `{count, plural, =1{{count} coin} other{{count} coins}}`
- `minuteCount`: `{count, plural, =1{{count} minute} other{{count} minutes}}`
- Widget usage:
  - `S.of(context).coinCount(coins)`
  - `S.of(context).minuteCount(minutes)`

For Russian, define `one`/`few`/`many`/`other`. Uzbek, Kyrgyz and Kazakh keep
the noun singular after a number (`5 монета`), so `=1`/`other` with the same
noun is correct there.

## Parent-side layout guidance for localization

Longer Russian, Kyrgyz and Kazakh strings can overflow in compact rows.
`test/no_english_leak_test.dart` renders the main screens in every non-English
locale and fails on an overflow. Prefer:

- `Expanded`/`Flexible` around text inside `Row`.
- `Text(maxLines: 1 or 2, overflow: TextOverflow.ellipsis)` for headers, badges, and buttons.
- Avoid hard-coded text widths when labels are localized.

## Where localization is used in the app

- App-level delegate registration:
  - `lib/core/app/app.dart`
- Runtime locale handling:
  - `lib/core/app/locale_cubit.dart`
- Feature screens and widgets:
  - Use `S.of(context)` inside `build` methods.
  - Pass localized strings down to dumb widgets when needed.

## Practical example

For a dynamic title like a child progress card:

- ARB key:
  - `childProgressTitle: "{name}'s Progress"`
- Dart usage:
  - `S.of(context).childProgressTitle('Alex')`

## Notes

- If a widget is built inside a `BlocProvider.create` or other lifecycle callback, resolve localization first in the widget `build` method and pass the string down.
- If you add a new locale, update together: the ARB files, `LocaleCubit.supported`,
  `appLanguages` and `AppFlag`, the `_locales` lists in `test/localization_test.dart`
  and `test/no_english_leak_test.dart`, the Android `values-<code>` folder and
  `AppBlockForegroundService.text`, and `notification_copy.py` in safini-api.

