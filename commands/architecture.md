# Flutter Architecture Skill
## Stack: Cubit (Presentation) + MVC (Domain/Data)

---

## Purpose

This skill defines the canonical architecture pattern for all Flutter features in this project. Every time an AI agent generates, scaffolds, or modifies Flutter code, it **must** follow this template exactly — no deviations unless explicitly instructed. This architecture aims for simplicity, avoiding interfaces and code generation where possible.

---

## Layer Overview

| Layer          | Responsibility                             | Hard Rules                                      |
|----------------|--------------------------------------------|-------------------------------------------------|
| **Presentation** | Widgets + Cubits                         | No business logic in widgets; Cubit calls Controller only |
| **Domain**     | Controllers + Models                       | No Flutter imports in Controllers; pure Dart only |
| **Data**       | Repositories + Sources                     | Knows Firebase / REST / Hive; never exposed to View |

---

## Canonical Folder Template

Every feature **must** follow this exact layout. Replace `<feature>` with the feature name (snake_case).

```text
lib/
├── core/
│   ├── di/                   # Manual get_it setup
│   ├── router/               # Route configuration
│   ├── theme/                # AppTheme, colors, text styles
│   └── utils/                # Extensions, constants, helpers
│
├── features/
│   └── <feature>/
│       ├── presentation/
│       │   ├── screens/          # One file per screen: <feature>_screen.dart
│       │   ├── widgets/          # Reusable sub-widgets for this feature
│       │   └── cubit/
│       │       ├── <feature>_cubit.dart
│       │       └── <feature>_state.dart
│       │
│       ├── domain/
│       │   ├── models/           # Simple Dart models: <feature>_model.dart
│       │   └── controllers/      # <feature>_controller.dart (no Flutter imports)
│       │
│       └── data/
│           ├── repositories/     # Concrete repository: <feature>_repository.dart
│           └── datasources/      # Firebase / REST / Hive calls: <feature>_remote_datasource.dart
│
└── main.dart
```

---

## Data Flow — Always Unidirectional

```text
User Action
  → Screen (View)
  → <Feature>Cubit.method()
  → <Feature>Controller.execute()
  → <Feature>Repository (Concrete)
  → <Feature>RemoteDataSource (Firebase / Hive / REST)
  ← returns Either<Failure, Model>
  ← Cubit.emit(<Feature>State)
  ← BlocBuilder/BlocListener rebuilds Screen
```

---

## Layer Details & File Templates

For specific file templates and rules per layer, refer to the following documents:

- [Presentation Layer](presentation.md) (Widgets, Cubits, State)
- [Domain Layer](domain.md) (Controllers, Models)
- [Datasource & Data Layer](datasource.md) (Repositories, Remote Sources)

---

## DI Registration (`core/di/`)

```dart
// Using get_it manually
import 'package:get_it/get_it.dart';

final sl = GetIt.instance; // service locator

void init<Feature>() {
  // Data sources
  sl.registerLazySingleton(() => <Feature>RemoteDataSource());
  
  // Repository
  sl.registerLazySingleton(() => <Feature>Repository(sl()));
  
  // Controller
  sl.registerFactory(() => <Feature>Controller(sl()));
  
  // Cubit
  sl.registerFactory(() => <Feature>Cubit(sl()));
}
```

---

## Required Packages

| Purpose          | Package                        |
|------------------|--------------------------------|
| State management | `flutter_bloc`                 |
| DI               | `get_it`                       |
| Functional       | `dartz`                        |
| Navigation       | `auto_route`                   |
| Remote           | `dio` or `firebase_core`       |
| Local storage    | `hive_flutter`                 |

---

## Non-Negotiable Rules

1. **Views are dumb** — Screens and Widgets contain zero business logic. They call Cubit methods and render state.
2. **Controllers are pure Dart** — Never import `flutter/material.dart` or any Flutter package in a Controller.
3. **One Cubit per screen** — Not per widget.
4. **All errors are caught in the Cubit** — Views only switch on state variations; they never catch exceptions.
5. **Concrete classes only** — Avoid interfaces. Use concrete Repository classes directly.
6. **No code generation for models** — Write Dart classes with standard `fromJson` manually for simplicity.
7. **No cross-feature imports** — Features communicate only through `core/`. Never import `features/a` into `features/b`.

---

## Checklist — Before Submitting Any Feature

- [ ] Folder structure matches the canonical template above
- [ ] `<feature>_state.dart` is a standard class with a `Status` enum
- [ ] `<feature>_model.dart` uses standard Dart classes with `fromJson`
- [ ] `<feature>_cubit.dart` only calls the Controller, never a Repository directly
- [ ] `<feature>_controller.dart` has zero Flutter imports
- [ ] Repository is a concrete class and lives in `data/repositories/`
- [ ] Manual GetIt registration is added for all dependencies
- [ ] All async paths return `Either<Failure, T>`