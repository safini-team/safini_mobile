# Flutter Architecture Skill
## Stack: Cubit (Presentation) + MVC (Domain/Data)

---

## Purpose

This skill defines the canonical architecture pattern for all Flutter features in this project. Every time an AI agent generates, scaffolds, or modifies Flutter code, it **must** follow this template exactly — no deviations unless explicitly instructed.

---

## Layer Overview

| Layer          | Responsibility                             | Hard Rules                                      |
|----------------|--------------------------------------------|-------------------------------------------------|
| **Presentation** | Widgets + Cubits                         | No business logic in widgets; Cubit calls Controller only |
| **Domain**     | Controllers + Models + Repository (abstract) | No Flutter imports in Controllers; pure Dart only |
| **Data**       | Repository implementations + DTOs + Sources | Knows Firebase / REST / Hive; never exposed to View |

---

## Canonical Folder Template

Every feature **must** follow this exact layout. Replace `<feature>` with the feature name (snake_case).

```
lib/
├── core/
│   ├── di/                   # get_it + injectable setup
│   ├── router/               # auto_route configuration
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
│       │   ├── models/           # Immutable Dart models: <feature>_model.dart
│       │   ├── controllers/      # <feature>_controller.dart (no Flutter imports)
│       │   └── repositories/     # Abstract contracts: i_<feature>_repository.dart
│       │
│       └── data/
│           ├── repositories/     # Concrete impl: <feature>_repository_impl.dart
│           ├── datasources/      # Firebase / REST / Hive calls
│           └── dto/              # JSON mappers: <feature>_dto.dart
│
└── main.dart
```

---

## Data Flow — Always Unidirectional

```
User Action
  → Screen (View)
  → <Feature>Cubit.method()
  → <Feature>Controller.execute()
  → I<Feature>Repository (abstract)
  → <Feature>RepositoryImpl (Firebase / Hive / REST)
  ← returns Either<Failure, Model>
  ← Cubit.emit(<Feature>State)
  ← BlocBuilder/BlocListener rebuilds Screen
```

---

## File Templates

### 1. State — `<feature>_state.dart`

```dart
part of '<feature>_cubit.dart';

@freezed
class <Feature>State with _$<Feature>State {
  const factory <Feature>State.initial() = _Initial;
  const factory <Feature>State.loading() = _Loading;
  const factory <Feature>State.loaded(<Feature>Model data) = _Loaded;
  const factory <Feature>State.error(String message) = _Error;
}
```

### 2. Cubit — `<feature>_cubit.dart`

```dart
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import '../domain/controllers/<feature>_controller.dart';
import '../domain/models/<feature>_model.dart';

part '<feature>_state.dart';
part '<feature>_cubit.freezed.dart';

class <Feature>Cubit extends Cubit<<Feature>State> {
  final <Feature>Controller _controller;

  <Feature>Cubit(this._controller) : super(const <Feature>State.initial());

  Future<void> load() async {
    emit(const <Feature>State.loading());
    final result = await _controller.fetch();
    result.fold(
      (failure) => emit(<Feature>State.error(failure.message)),
      (data)    => emit(<Feature>State.loaded(data)),
    );
  }
}
```

### 3. Controller — `<feature>_controller.dart`

```dart
// No Flutter imports — pure Dart only
import 'package:dartz/dartz.dart';
import '../models/<feature>_model.dart';
import '../repositories/i_<feature>_repository.dart';
import '../../../../core/utils/failure.dart';

class <Feature>Controller {
  final I<Feature>Repository _repository;

  <Feature>Controller(this._repository);

  Future<Either<Failure, <Feature>Model>> fetch() async {
    return _repository.fetch();
  }
}
```

### 4. Model — `<feature>_model.dart`

```dart
import 'package:freezed_annotation/freezed_annotation.dart';

part '<feature>_model.freezed.dart';

@freezed
class <Feature>Model with _$<Feature>Model {
  const factory <Feature>Model({
    required String id,
    required String name,
    // Add fields here
  }) = _<Feature>Model;
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

## Non-Negotiable Rules

1. **Views are dumb** — Screens and Widgets contain zero business logic. They call Cubit methods and render state.
2. **Controllers are pure Dart** — Never import `flutter/material.dart` or any Flutter package in a Controller.
3. **One Cubit per screen** — Not per widget.
4. **All errors are caught in the Cubit** — Views only switch on state variants; they never catch exceptions.
5. **Models are immutable** — Always use `freezed` or a manual `copyWith`. No mutable fields.
6. **Repositories are interfaces in Domain** — Concrete implementations live in Data only.
7. **No cross-feature imports** — Features communicate only through `core/`. Never import `features/a` into `features/b`.
8. **DTOs stay in Data** — Domain models never know about JSON or Firebase documents.

---

## Checklist — Before Submitting Any Feature

- [ ] Folder structure matches the canonical template above
- [ ] `<feature>_state.dart` uses `freezed` sealed states
- [ ] `<feature>_cubit.dart` only calls the Controller, never a Repository directly
- [ ] `<feature>_controller.dart` has zero Flutter imports
- [ ] Repository interface lives in `domain/repositories/`
- [ ] Concrete implementation lives in `data/repositories/`
- [ ] DTO has `fromJson` and `toDomain()` methods
- [ ] DI module registers all dependencies
- [ ] All async paths return `Either<Failure, T>`