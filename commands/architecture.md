# Flutter App Architecture Context
## Parent–Child Time-Saving App
### Stack: Cubit (State) + MVC (Logic/Data)

---

## Core Philosophy

| Layer         | Role                                      | Rule                            |
|---------------|-------------------------------------------|---------------------------------|
| View          | Widget tree only                          | No business logic               |
| Cubit         | Emits UI state, calls Controller          | No direct data source access    |
| Controller    | Orchestrates use-cases                    | No Flutter imports              |
| Model         | Immutable data class                      | Pure Dart                       |
| Repository    | Abstract contract                         | Interface only                  |
| Data          | Concrete implementations                  | Knows Firebase / REST / Hive    |

---

## Folder Structure

```
lib/
├── core/
│   ├── di/              # Dependency injection (get_it + injectable)
│   ├── router/          # go_router setup
│   ├── theme/           # AppTheme, colors, text styles
│   └── utils/           # Extensions, helpers, constants
│
├── features/
│   ├── auth/
│   │   ├── view/            # LoginScreen, RegisterScreen
│   │   ├── cubit/           # AuthCubit, AuthState
│   │   ├── model/           # UserModel
│   │   ├── controller/      # AuthController
│   │   └── repository/      # AuthRepository (abstract)
│   │
│   ├── schedule/            # Weekly schedule planner
│   └── rewards/             # Reward system for children
│
├── data/
│   ├── remote/              # Firebase / REST datasources
│   ├── local/               # Hive / SharedPreferences
│   ├── dto/                 # Data Transfer Objects (JSON mappers)
│   └── repositories/        # Concrete repository implementations
│
└── main.dart
```

---

## Data Flow (single direction)

```
User taps → View
         → Cubit.method()
         → Controller.useCase()
         → Repository.abstract()
         → RepositoryImpl (Firebase / Hive)
         ← returns data up the chain
         ← Cubit.emit(newState)
         ← BlocBuilder rebuilds View
```

---

## Recommended Packages

| Purpose            | Package                  |
|--------------------|--------------------------|
| State management   | `flutter_bloc`           |
| DI                 | `get_it`                 |
| Immutable models   | `freezed`                |
| Navigation         | `go_router`              |
| Remote             | `dio` or `firebase_core` |
| Local storage      | `hive_flutter`           |
| Code gen           | `build_runner`           |

---

## Feature Modules (App-Specific)

```
auth/         → Parent & child login, role switching
schedule/     → Weekly time-block planner per child
rewards/      → Points system, redeemable badges
timer/        → Countdown widget for focus sessions
notifications/→ Reminders for schedule and rewards
```

---

## Roles & Context

- **Parent role**: manages schedule, rewards, views reports
- **Child role**: sees own schedule, timer, earned rewards
- Role is stored in `UserModel.role` and drives navigation via `go_router` redirect guards

---

## Conventions

- Feature folders are self-contained — no cross-feature imports except through `core/`
- Controllers never import `flutter/material.dart`
- States are always immutable (use `freezed` or manual `copyWith`)
- One Cubit per screen/feature, not per widget
- All async errors are caught in the Cubit — Views only handle state variants