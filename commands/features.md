# Feature Development Context

Use this guide whenever creating a new feature in this project.

## Required Feature Structure

Every feature must follow clean architecture layers:

```text
lib/features/<feature_name>/
├── data/
│   ├── datasource/
│   │   ├── local/
│   │   └── remote/
│   └── models/
│
├── domain/
│   ├── repositories/
│   └── usecases/
│
└── presentation/
    ├── cubit/
    ├── pages/
    └── widgets/
```

## Layer Responsibilities

### data
- `datasource/local`: local persistence access (cache, device storage, prefs, db)
- `datasource/remote`: API/backend access (REST, Firebase, etc.)
- `models`: DTO/data models and mappers (JSON/fromMap/toMap)

### domain
- `repositories`: abstract contracts/interfaces used by business logic
- `usecases`: single-purpose business actions (one use-case per file)

### presentation
- `cubit`: state management (state, cubit, events/actions through cubit methods)
- `pages`: full screens/routes
- `widgets`: reusable UI parts used by pages

## Page Composition Rule (Mandatory)

Every time a new page is created, split UI into separate widgets inside `presentation/widgets`.

- Pages in `presentation/pages` should compose sections, not hold large UI blocks.
- Move repeated or sizeable UI parts into dedicated widget files.
- Common components must be separated by purpose, such as:
  - buttons
  - input fields
  - cards
  - headers
  - list items
- Prefer small, focused widgets with clear names (for example: `auth_primary_button.dart`, `email_input_field.dart`).
- Keep page files readable and orchestration-focused.

## Rules To Follow

- Keep feature code self-contained inside its own folder.
- Do not import from another feature directly; use shared code from `core/` only.
- Keep Flutter/UI imports out of `domain`.
- Keep business logic out of `pages/widgets`; it belongs in `usecases` + `cubit`.
- Repositories in `domain` are abstract; implementations live in `data`.
- Each new feature should start with minimal scaffolding for all three layers.
- Use global theme extension in UI: `context.textTheme` and `context.colorScheme`.
- Use AutoRoute for navigation (`context.router`), not raw `Navigator`.

## New Feature Checklist

- Create `data/domain/presentation` folders as defined above.
- Add at least one repository contract in `domain/repositories`.
- Add at least one use-case in `domain/usecases`.
- Add datasource stubs for both `local` and `remote`.
- Add model(s) in `data/models`.
- Add cubit + state in `presentation/cubit`.
- Add at least one page in `presentation/pages`.
- Add supporting widgets in `presentation/widgets` for every page.
- Split common UI types into separate widgets (for example: buttons, fields).
