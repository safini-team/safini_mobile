# Feature Development Guide

Use this whenever creating a new feature. Features live inside `lib/features/child/`, `lib/features/parent/`, or `lib/features/common/` depending on who owns the feature.

---

## Full Folder Structure

```
lib/features/<child|parent|common>/
│
├── <child|parent|common>_injection.dart   ← registers all features for this section
│
├── data/
│   ├── datasources/
│   │   ├── remote/
│   │   │   └── <feature>_remote_datasource.dart
│   │   └── local/
│   │       └── <feature>_local_datasource.dart
│   └── repositories/
│       └── <feature>_repository.dart
│
├── domain/
│   ├── models/
│   │   └── <feature>_model.dart
│   └── controllers/
│       └── <feature>_controller.dart
│
└── presentation/
    ├── cubit/
    │   └── <feature>/                    ← one subfolder per feature
    │       ├── <feature>_cubit.dart
    │       └── <feature>_state.dart
    ├── screens/
    │   └── <feature>/                    ← one subfolder per screen group
    │       └── <child|parent>_<feature>_screen.dart
    └── widgets/
        └── <feature>/
            ├── cards/
            ├── tiles/
            ├── dialogs/
            └── utils/
```

---

## Injection File

Every section has a single `<section>_injection.dart` at the root of `lib/features/<section>/`. It registers all datasources, repositories, controllers, and cubits for every feature in that section using `get_it`.

### Template — `<child|parent|common>_injection.dart`

```dart
import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'data/datasources/remote/<feature>_remote_datasource.dart';
import 'data/datasources/local/<feature>_local_datasource.dart';
import 'data/repositories/<feature>_repository.dart';
import 'domain/controllers/<feature>_controller.dart';
import 'presentation/cubit/<feature>/<feature>_cubit.dart';

Future<void> register<Child|Parent|Common>Dependencies(GetIt sl) async {
  final prefs = await SharedPreferences.getInstance();

  // ── <Feature> ──────────────────────────────────────────
  sl.registerLazySingleton(() => <Feature>RemoteDataSource(sl<Dio>()));
  sl.registerLazySingleton(() => <Feature>LocalDataSource(prefs));
  sl.registerLazySingleton(() => <Feature>Repository(sl(), sl()));
  sl.registerLazySingleton(() => <Feature>Controller(sl()));
  sl.registerFactory(() => <Feature>Cubit(sl()));
}
```

> Call `registerChildDependencies(sl)`, `registerParentDependencies(sl)`, and `registerCommonDependencies(sl)` from the root `di/injection.dart`.

---

## Naming Rules

- Screen files are prefixed with the section: `child_tasks_screen.dart`, `parent_monitor_screen.dart`.
- Cubit folder matches the feature name: `cubit/tasks/tasks_cubit.dart`.
- Screen folder matches the feature name: `screens/tasks/child_tasks_screen.dart`.
- Widgets folder mirrors the screen it supports: `widgets/tasks/tiles/task_item_tile.dart`.

---

## New Feature Checklist

- [ ] `data/datasources/remote/<feature>_remote_datasource.dart` — Dio, throws `ServerException`
- [ ] `data/datasources/local/<feature>_local_datasource.dart` — SharedPreferences, throws `CacheException`
- [ ] `data/repositories/<feature>_repository.dart` — catches exceptions, returns `Either<Failure, Model>`
- [ ] `domain/models/<feature>_model.dart` — pure Dart, `fromJson` / `toJson`
- [ ] `domain/controllers/<feature>_controller.dart` — pure Dart, calls repository
- [ ] `presentation/cubit/<feature>/<feature>_state.dart`
- [ ] `presentation/cubit/<feature>/<feature>_cubit.dart`
- [ ] `presentation/screens/<feature>/<child|parent>_<feature>_screen.dart`
- [ ] `presentation/widgets/<feature>/` — cards, tiles, dialogs, utils as needed
- [ ] Register everything in `<section>_injection.dart`

---

## Layer Rules

| Layer | Rule |
|---|---|
| `data/datasources/remote` | Always inject `Dio`. Never use `http` package. |
| `data/datasources/local` | Always inject `SharedPreferences`. |
| `data/repositories` | Catches exceptions, returns `Either<Failure, Model>`. |
| `domain` | Pure Dart only — no Flutter imports. |
| `presentation/cubit` | All business logic lives here. No try/catch in screens. |
| `presentation/screens` | Dumb — only calls cubit methods and renders state. |
| `presentation/widgets` | Reusable UI parts. No direct cubit access unless necessary. |

---

## Cross-Feature Rule

Features must **not** import from each other. Shared logic lives in `lib/core/` only.