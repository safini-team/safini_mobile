# Global Agent Context Map

Use this file first to decide which context doc to follow for any task.

## Context Priority Order

1. `commands/GLOBAL_CONTEXT.md` (this file)
2. `commands/architecture.md`
3. `commands/features.md`
4. `commands/widgets.md`
5. `commands/styles.md`

If rules conflict, follow the higher priority file.

## Which File To Use For What

- **Architecture, folders, layering, DI flow**
  - Use: `commands/architecture.md`
- **Creating or updating a feature module**
  - Use: `commands/features.md`
- **Creating widgets, splitting page UI into components**
  - Use: `commands/widgets.md`
- **Colors, fonts, text styles, theme usage**
  - Use: `commands/styles.md`

## Mandatory UI Rules (Always Apply)

- Use global theme extension import:
  - `package:safini/core/utils/extension/theme_extension.dart`
- Use typography via:
  - `context.textTheme.*`
- Use colors via:
  - `context.colorScheme.*`
- Use navigation via AutoRoute:
  - `context.router`
- Do not use raw `Navigator.of(context)` in feature UI.

## Mandatory Feature Rules (Always Apply)

- Feature structure must follow:
  - `presentation/`
  - `domain/`
  - `data/`
- Every page must be composed of separate widgets in `presentation/widgets`.
- Keep widgets dumb: no business logic, no repository calls in UI.

## Quick Decision Guide

- New screen/page requested:
  - Read `features.md` + `widgets.md` + `styles.md`
- New reusable component requested:
  - Read `widgets.md` + `styles.md`
- Refactor or scaffold module requested:
  - Read `architecture.md` + `features.md`
