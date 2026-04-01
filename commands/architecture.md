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

### 5. Repository Interface — `i_<feature>_repository.dart`

```dart
import 'package:dartz/dartz.dart';
import '../models/<feature>_model.dart';
import '../../../../core/utils/failure.dart';

abstract class I<Feature>Repository {
  Future<Either<Failure, <Feature>Model>> fetch();
  // Add other abstract methods here
}
```

### 6. Repository Implementation — `<feature>_repository_impl.dart`

```dart
import 'package:injectable/injectable.dart';
import '../../domain/models/<feature>_model.dart';
import '../../domain/repositories/i_<feature>_repository.dart';
import '../datasources/<feature>_remote_datasource.dart';
import 'package:dartz/dartz.dart';
import '../../../../core/utils/failure.dart';

@Injectable(as: I<Feature>Repository)
class <Feature>RepositoryImpl implements I<Feature>Repository {
  final <Feature>RemoteDataSource _remote;

  <Feature>RepositoryImpl(this._remote);

  @override
  Future<Either<Failure, <Feature>Model>> fetch() async {
    try {
      final dto = await _remote.fetch();
      return Right(dto.toDomain());
    } catch (e) {
      return Left(Failure(e.toString()));
    }
  }
}
```

### 7. DTO — `<feature>_dto.dart`

```dart
import '../../domain/models/<feature>_model.dart';

class <Feature>Dto {
  final String id;
  final String name;

  <Feature>Dto({required this.id, required this.name});

  factory <Feature>Dto.fromJson(Map<String, dynamic> json) => <Feature>Dto(
        id:   json['id']   as String,
        name: json['name'] as String,
      );

  <Feature>Model toDomain() => <Feature>Model(id: id, name: name);
}
```

### 8. Screen — `<feature>_screen.dart`

```dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../cubit/<feature>_cubit.dart';

class <Feature>Screen extends StatelessWidget {
  const <Feature>Screen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (ctx) => ctx.read<<Feature>Cubit>()..load(),
      child: Scaffold(
        body: BlocBuilder<<Feature>Cubit, <Feature>State>(
          builder: (context, state) => state.when(
            initial: () => const SizedBox.shrink(),
            loading: () => const Center(child: CircularProgressIndicator()),
            loaded:  (data) => _<Feature>Body(data: data),
            error:   (msg)  => Center(child: Text(msg)),
          ),
        ),
      ),
    );
  }
}

class _<Feature>Body extends StatelessWidget {
  final <Feature>Model data;
  const _<Feature>Body({required this.data});

  @override
  Widget build(BuildContext context) {
    return const Placeholder(); // Replace with real UI
  }
}
```

---

## DI Registration (`core/di/`)

```dart
// Using get_it + injectable
@module
abstract class <Feature>Module {
  @lazySingleton
  <Feature>RemoteDataSource get remoteDataSource;

  @lazySingleton
  I<Feature>Repository get repository => <Feature>RepositoryImpl(remoteDataSource);

  @factory
  <Feature>Controller get controller => <Feature>Controller(repository);

  @factory
  <Feature>Cubit get cubit => <Feature>Cubit(controller);
}
```

---

## Required Packages

| Purpose          | Package                        |
|------------------|--------------------------------|
| State management | `flutter_bloc`                 |
| DI               | `get_it` + `injectable`        |
| Immutable models | `freezed` + `freezed_annotation` |
| Functional       | `dartz`                        |
| Navigation       | `auto_route`                   |
| Remote           | `dio` or `firebase_core`       |
| Local storage    | `hive_flutter`                 |
| Code generation  | `build_runner`                 |

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