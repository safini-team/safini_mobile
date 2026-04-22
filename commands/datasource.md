# Datasource & Data Layer

The data layer handles API communication and local persistence. It sits between the domain layer and external services (REST APIs, SharedPreferences, etc.).

## Non-Negotiable Rules

1. **Remote always uses Dio** — inject `Dio` via constructor. Never use the `http` package directly.
2. **Local always uses SharedPreferences** — inject `SharedPreferences` via constructor.
3. **Datasources throw typed exceptions** — throw `ServerException` (remote) or `CacheException` (local). Never return null silently.
4. **Repository catches exceptions** — converts them into `Left(Failure(...))`. The presentation layer never sees raw exceptions.
5. **DTOs are optional** — use `Model.fromJson()` directly unless the API shape is fundamentally different from the domain model.

---

## Folder Structure

```
data/
├── datasources/
│   ├── remote/
│   │   └── <feature>_remote_datasource.dart
│   └── local/
│       └── <feature>_local_datasource.dart
└── repositories/
    └── <feature>_repository.dart
```

---

## File Templates

### 1. Remote Data Source — `datasources/remote/<feature>_remote_datasource.dart`

```dart
import 'package:dio/dio.dart';
import '../../domain/models/<feature>_model.dart';
import '../../../../core/error/exceptions.dart';

class <Feature>RemoteDataSource {
  final Dio _dio;

  <Feature>RemoteDataSource(this._dio);

  Future<<Feature>Model> fetch() async {
    try {
      final response = await _dio.get('/endpoint');
      return <Feature>Model.fromJson(response.data);
    } on DioException catch (e) {
      throw ServerException(e.message ?? 'Server error');
    } catch (e) {
      throw ServerException(e.toString());
    }
  }
}
```

### 2. Local Data Source — `datasources/local/<feature>_local_datasource.dart`

```dart
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../domain/models/<feature>_model.dart';
import '../../../../core/error/exceptions.dart';

class <Feature>LocalDataSource {
  final SharedPreferences _prefs;

  <Feature>LocalDataSource(this._prefs);

  Future<<Feature>Model?> getCached() async {
    try {
      final jsonString = _prefs.getString('<feature>_cached');
      if (jsonString == null) return null;
      return <Feature>Model.fromJson(jsonDecode(jsonString));
    } catch (e) {
      throw CacheException(e.toString());
    }
  }

  Future<void> cache(<Feature>Model model) async {
    try {
      await _prefs.setString('<feature>_cached', jsonEncode(model.toJson()));
    } catch (e) {
      throw CacheException(e.toString());
    }
  }
}
```

### 3. Repository — `repositories/<feature>_repository.dart`

Tries remote first, falls back to cache, updates cache on success.

```dart
import 'package:dartz/dartz.dart';
import '../../domain/models/<feature>_model.dart';
import '../datasources/remote/<feature>_remote_datasource.dart';
import '../datasources/local/<feature>_local_datasource.dart';
import '../../../../core/utils/failure.dart';
import '../../../../core/error/exceptions.dart';

class <Feature>Repository {
  final <Feature>RemoteDataSource _remote;
  final <Feature>LocalDataSource _local;

  <Feature>Repository(this._remote, this._local);

  Future<Either<Failure, <Feature>Model>> fetch() async {
    try {
      final model = await _remote.fetch();
      await _local.cache(model);
      return Right(model);
    } on ServerException catch (e) {
      final cached = await _local.getCached();
      if (cached != null) return Right(cached);
      return Left(Failure(e.message));
    } on CacheException catch (e) {
      return Left(Failure(e.message));
    }
  }
}
```