# Datasource & Data Layer

The Data Layer is responsible for handling data retrieval, storage mechanisms, and API communications. It provides concrete repositories that fetch data from specific Data Sources (Firebase, REST APIs, Hive, etc.).

## Non-Negotiable Rules

1. **Concrete Classes Only** — Avoid overusing Repository Interfaces unless explicitly doing test mocks. Use concrete `Repository` classes directly for simplicity.
2. **DTOs aren't necessary if simple** — Let the Dart `Model` parse JSON (`fromJson`) unless the API response strictly requires mapping intermediary DTOs.
3. **Repository Catches Exceptions** — The Repository is responsible for catching `Exceptions` thrown by the `DataSource` and converting them into strongly typed `Failure` objects (using `Left(Failure(...))`).

---

## Folder Structure

Datasources are split into two subfolders:

```
data/
  datasources/
    remote/
      <feature>_remote_datasource.dart
    local/
      <feature>_local_datasource.dart
  repositories/
    <feature>_repository.dart
```

---

## File Templates

### 1. Remote Data Source — `datasources/remote/<feature>_remote_datasource.dart`

Uses `Dio` for HTTP requests. The `Dio` instance is injected via the constructor.

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

Uses `SharedPreferences` for lightweight local storage. The `SharedPreferences` instance is injected via the constructor.

```dart
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

Orchestrates remote and local datasources. Tries remote first, falls back to cache, and updates cache on success.

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
