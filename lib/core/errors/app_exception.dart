abstract class AppException implements Exception {
  const AppException(this.message, {this.statusCode});

  final String message;
  final int? statusCode;

  @override
  String toString() => message;
}

class NetworkException extends AppException {
  const NetworkException([super.message = 'Network error occurred']);
}

class ServerException extends AppException {
  const ServerException([
    super.message = 'Server error occurred',
    int? statusCode,
  ]) : super(statusCode: statusCode);
}

class TimeoutException extends AppException {
  const TimeoutException([super.message = 'Request timed out']);
}

class UnauthorizedException extends AppException {
  const UnauthorizedException([super.message = 'Unauthorized access'])
    : super(statusCode: 401);
}

class NotFoundException extends AppException {
  const NotFoundException([super.message = 'Resource not found'])
    : super(statusCode: 404);
}

class BadRequestException extends AppException {
  const BadRequestException([super.message = 'Bad request'])
    : super(statusCode: 400);
}

class UnknownException extends AppException {
  const UnknownException([super.message = 'An unknown error occurred']);
}
