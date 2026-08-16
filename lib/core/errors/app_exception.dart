import 'package:equatable/equatable.dart';

/// Base class for the app's own exceptions.
///
/// [message] is deliberately not localized — see ARCHITECTURE.md, "Errors".
/// [cause] and [stackTrace] carry the originating error (usually the
/// DioException) so a crash reporter still sees the request context; they are
/// excluded from equality, which compares what the user-facing layers use.
///
/// Everything except [message] is a **named** parameter on every subclass:
/// positional `cause`/`statusCode` used to occupy different slots in different
/// subclasses, so two constructions four lines apart meant different things.
abstract class AppException extends Equatable implements Exception {
  const AppException(this.message, {this.cause, this.stackTrace});

  final String message;
  final Object? cause;
  final StackTrace? stackTrace;

  /// The HTTP status this maps to, where it maps to a fixed one. Subclasses
  /// tied to a single code override it with that code; [ServerException],
  /// where it varies, shadows it with a field.
  int? get statusCode => null;

  @override
  List<Object?> get props => <Object?>[message, statusCode];

  @override
  String toString() => '$runtimeType(${statusCode ?? '-'}): $message';
}

class NetworkException extends AppException {
  const NetworkException(super.message, {super.cause, super.stackTrace});
}

class ServerException extends AppException {
  const ServerException(
    super.message, {
    this.statusCode,
    super.cause,
    super.stackTrace,
  });

  @override
  final int? statusCode;
}

/// Not `TimeoutException`: that name would shadow `dart:async`'s, making
/// `on TimeoutException` catch the wrong type wherever both are imported.
class RequestTimeoutException extends AppException {
  const RequestTimeoutException(super.message, {super.cause, super.stackTrace});
}

// The next three are each tied to one status code, stated as an override
// rather than threaded through the constructor: an UnauthorizedException
// *is* a 401, it does not merely happen to carry one.
class UnauthorizedException extends AppException {
  const UnauthorizedException(super.message, {super.cause, super.stackTrace});

  @override
  int? get statusCode => 401;
}

class NotFoundException extends AppException {
  const NotFoundException(super.message, {super.cause, super.stackTrace});

  @override
  int? get statusCode => 404;
}

class BadRequestException extends AppException {
  const BadRequestException(super.message, {super.cause, super.stackTrace});

  @override
  int? get statusCode => 400;
}

class UnknownException extends AppException {
  const UnknownException(super.message, {super.cause, super.stackTrace});
}

/// Raised when a `CancelToken` fires. Flow control, not a failure: callers
/// catch it and return rather than rendering an error.
///
/// Carries no cause: there is no failure to report, so the message has a
/// default and nothing else to pass.
class RequestCancelledException extends AppException {
  const RequestCancelledException([super.message = 'Request was cancelled']);
}

/// The response arrived but did not have the shape the parser expects —
/// a proxy error page, an empty body, a content-type mismatch.
class ParsingException extends AppException {
  const ParsingException([super.message = 'Malformed response payload']);
}
