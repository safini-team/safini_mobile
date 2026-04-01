# Datasource & Data Layer

The Data Layer is responsible for handling data retrieval, storage mechanisms, and API communications. It provides concrete repositories that fetch data from specific Data Sources (Firebase, REST APIs, Hive, etc.).

## Non-Negotiable Rules

1. **Concrete Classes Only** — Avoid overusing Repository Interfaces unless explicitly doing test mocks. Use concrete `Repository` classes directly for simplicity.
2. **DTOs aren't necessary if simple** — Let the Dart `Model` parse JSON (`fromJson`) unless the API response strictly requires mapping intermediary DTOs.
3. **Repository Catches Exceptions** — The Repository is responsible for catching `Exceptions` thrown by the `DataSource` and converting them into strongly typed `Failure` objects (using `Left(Failure(...))`).

---

## File Templates

### 1. Remote Data Source — `<feature>_remote_datasource.dart`

```dart
import '../../domain/models/<feature>_model.dart';
// import 'package:dio/dio.dart'; // or your API client

class <Feature>RemoteDataSource {
  <Feature>RemoteDataSource();

  Future<<Feature>Model> fetch() async {
    // try {
    //   final response = await dio.get('/endpoint');
    //   return <Feature>Model.fromJson(response.data);
    // } catch (e) {
    //   throw ServerException(e.toString());
    // }
    
    throw UnimplementedError();
  }
}
```

### 2. Repository — `<feature>_repository.dart`

```dart
import 'package:dartz/dartz.dart';
import '../../domain/models/<feature>_model.dart';
import '../datasources/<feature>_remote_datasource.dart';
import '../../../../core/utils/failure.dart';

class <Feature>Repository {
  final <Feature>RemoteDataSource _remote;

  <Feature>Repository(this._remote);

  Future<Either<Failure, <Feature>Model>> fetch() async {
    try {
      final model = await _remote.fetch();
      return Right(model);
    } catch (e) {
      return Left(Failure(e.toString()));
    }
  }
}
```
