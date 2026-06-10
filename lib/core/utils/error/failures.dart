abstract class Failure {
  final String message;
  const Failure(this.message);
}

class ServerFailure extends Failure {
  const ServerFailure(super.message);
}

class CacheFailure extends Failure {
  const CacheFailure(super.message);
}

class NetworkFailure extends Failure {
  const NetworkFailure(super.message);
}

class UnauthorizedFailure extends Failure {
  const UnauthorizedFailure(super.message);
}

class ValidationFailure extends Failure {
  const ValidationFailure(super.message);
}

class FieldValidationFailure extends ValidationFailure {
  final Map<String, String> fieldErrors;

  const FieldValidationFailure(super.message, this.fieldErrors);
}

class NotFoundFailure extends Failure {
  const NotFoundFailure(super.message);
}

/// 409 Conflict — e.g. an approved task can no longer be edited or deleted.
class ConflictFailure extends Failure {
  const ConflictFailure(super.message);
}
