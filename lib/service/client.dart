import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:logger/logger.dart';
import 'package:mobile_app_starter/core/errors/app_exception.dart';

class ClientAPI {
  // Required on purpose: `dio ?? Dio()` would silently hand out a bare,
  // timeout-less instance whenever a registration was forgotten.
  ClientAPI({required Dio dio}) : _dioClient = dio;

  final Dio _dioClient;

  // Static and lazy: never allocated in release, where both call sites are
  // kDebugMode-gated.
  static final Logger _logger = Logger();

  Future<Response<dynamic>> request({required Request request}) async {
    try {
      // Relative URLs resolve against BaseOptions.baseUrl; an absolute URL in
      // [Request.url] overrides it, per Dio's own resolution rules.
      final Response<dynamic> response = await _dioClient.request(
        request.url,
        options: Options(
          method: request.method.value,
          contentType: request.contentType,
          headers: request.headers,
          responseType: ResponseType.json,
        ),
        data: request.data,
        queryParameters: request.queryParameters,
        cancelToken: request.cancelToken,
      );
      return response;
    } on DioException catch (exception) {
      if (kDebugMode && exception.type != DioExceptionType.cancel) {
        _logger.e(
          'DioException occurred',
          error: exception,
          stackTrace: exception.stackTrace,
          time: DateTime.now(),
        );
      }

      throw _handleDioException(exception);
    } catch (e, stackTrace) {
      if (kDebugMode) {
        _logger.e(
          'Unexpected error occurred',
          error: e,
          stackTrace: stackTrace,
          time: DateTime.now(),
        );
      }
      throw UnknownException(e.toString(), cause: e, stackTrace: stackTrace);
    }
  }

  /// Maps a [DioException] onto the app's own exception hierarchy.
  ///
  /// Exhaustive with no `default:` on purpose, so a dio release that adds a
  /// type fails the build here. See ARCHITECTURE.md, "Errors".
  AppException _handleDioException(DioException exception) {
    // The originating exception rides along as `cause`, so a crash reporter
    // still sees the request context after the mapping.
    final StackTrace trace = exception.stackTrace;
    switch (exception.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
      case DioExceptionType.transformTimeout:
        return RequestTimeoutException(
          'Request timed out. Please try again.',
          cause: exception,
          stackTrace: trace,
        );

      case DioExceptionType.badResponse:
        final int? statusCode = exception.response?.statusCode;
        final dynamic responseData = exception.response?.data;
        // No cast: `message` may be absent, null, or a non-string payload
        // (validation errors often carry a list), and a TypeError thrown here
        // would escape the AppException hierarchy entirely.
        final Object? rawMessage = responseData is Map
            ? responseData['message']
            : null;
        final String message =
            (rawMessage is String ? rawMessage : null) ??
            exception.message ??
            'Unknown error';

        switch (statusCode) {
          case 400:
            return BadRequestException(
              message,
              cause: exception,
              stackTrace: trace,
            );
          case 401:
            return UnauthorizedException(
              'Please log in again.',
              cause: exception,
              stackTrace: trace,
            );
          case 404:
            return NotFoundException(
              message,
              cause: exception,
              stackTrace: trace,
            );
          case 500:
          case 502:
          case 503:
            return ServerException(
              'Server error. Please try again later.',
              statusCode: statusCode,
              cause: exception,
              stackTrace: trace,
            );
          default:
            return ServerException(
              message,
              statusCode: statusCode,
              cause: exception,
              stackTrace: trace,
            );
        }

      case DioExceptionType.cancel:
        return const RequestCancelledException();

      case DioExceptionType.connectionError:
        return NetworkException(
          'No internet connection. Please check your network.',
          cause: exception,
          stackTrace: trace,
        );

      case DioExceptionType.badCertificate:
        return NetworkException(
          'Security certificate error',
          cause: exception,
          stackTrace: trace,
        );

      case DioExceptionType.unknown:
        return UnknownException(
          exception.message ?? 'An unexpected error occurred',
          cause: exception,
          stackTrace: trace,
        );
    }
  }
}

class Request {
  Request({
    required this.url,
    required this.method,
    this.contentType,
    this.data,
    this.queryParameters,
    this.headers,
    this.cancelToken,
  });

  final String url;
  final HttpMethod method;
  final dynamic data;
  final Map<String, dynamic>? queryParameters;
  final String? contentType;
  final Map<String, dynamic>? headers;

  /// Cancelling the handler that issued a request does not stop the request:
  /// the token is what reaches the transport.
  final CancelToken? cancelToken;
}

enum HttpMethod {
  get(value: 'GET'),
  post(value: 'POST'),
  put(value: 'PUT'),
  delete(value: 'DELETE');

  HttpMethod({required this.value});

  final String value;
}
