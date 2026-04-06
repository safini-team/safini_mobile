# Localization Guide

This project uses Flutter Intl-generated localization files with English and Russian support.

## Source of truth

- Translation strings live in:
  - `lib/l10n/intl_en.arb`
  - `lib/l10n/intl_ru.arb`
- Generated accessors live in:
  - `lib/generated/l10n.dart`
- Generated lookup files live in:
  - `lib/generated/intl/messages_en.dart`
  - `lib/generated/intl/messages_ru.dart`

## Supported locales

The app currently supports:

- `en`
- `ru`

Locale selection is initialized through `lib/core/app/locale_cubit.dart`, and the app registers the localization delegates in `lib/core/app/app.dart`.

## How to add or update a translation

1. Add or update the key in both ARB files.
2. Include placeholders in both files if the string needs dynamic values.
3. Regenerate the Flutter Intl output so `lib/generated/l10n.dart` and the message lookup files stay in sync.
4. Use the generated `S` class in widgets, for example:
   - `S.of(context).appLimits`
   - `S.of(context).childProgressTitle(name)`

## String conventions

- Prefer short, UI-friendly phrases.
- Keep placeholders named consistently across locales.
- Avoid hardcoding user-facing text in widgets when a localized key exists.
- Do not edit generated files by hand unless you are fixing checked-in generated output.

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
- If you add a new locale, update the ARB files and the supported locale list together.

