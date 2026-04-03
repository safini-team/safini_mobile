# Domain Layer

The domain layer encapsulates the core business rules of the application. It acts as the orchestrator between the presentation layer and the data layer.

## Non-Negotiable Rules

1. **Pure Dart Only** — Controllers and Models must NEVER import `flutter/material.dart` or any UI-specific packages.
2. **No Code Generation for Models** — Provide explicit standard `fromJson` and `toJson` methods without relying on `freezed` or `json_serializable`.
3. **Immutability preferred** — Make model properties `final` where applicable.
4. **Error Handling** — The Controller is responsible for executing business flows and returning an `Either<Failure, Result>`, standardizing error handling for the Presentation layer.

---

## File Templates

### 1. Model — `<feature>_model.dart`

```dart
class <Feature>Model {
  final String id;
  final String name;

  const <Feature>Model({
    required this.id,
    required this.name,
  });

  factory <Feature>Model.fromJson(Map<String, dynamic> json) {
    return <Feature>Model(
      id: json['id'] as String,
      name: json['name'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
    };
  }
}
```

### 2. Controller — `<feature>_controller.dart`

```dart
// No Flutter imports — pure Dart only
import 'package:dartz/dartz.dart';
import '../models/<feature>_model.dart';
import '../../data/repositories/<feature>_repository.dart';
import '../../../../core/utils/failure.dart';

class <Feature>Controller {
  final <Feature>Repository _repository;

  <Feature>Controller(this._repository);

  Future<Either<Failure, <Feature>Model>> fetch() async {
    return _repository.fetch();
  }
}
```
