import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:logger/logger.dart';
import 'package:mobile_app_starter/config.dart' as config;
import 'package:mobile_app_starter/core/errors/app_exception.dart';
import 'package:mobile_app_starter/utils/curl_logger.dart';

export './pokemon_api.dart';

class ClientAPI {
  ClientAPI({Dio? dio}) : _dioClient = dio ?? Dio() {
    if (!kReleaseMode) {
      _dioClient.interceptors.add(CurlLogger(printOnSuccess: true));
    }
  }

  final Dio _dioClient;
  final Logger _logger = Logger();

  Future<Response<dynamic>> request({
    required Request request,
    required Map<String, dynamic> errorData,
    bool otherUrl = true,
  }) async {
    try {
      final Response<dynamic> response = await _dioClient.request(
        '${otherUrl ? config.env : ''}${request.url}',
        options: Options(
          method: request.method.name,
          contentType: request.contentType,
          headers: request.headers,
          responseType: ResponseType.json,
        ),
        data: request.data,
        queryParameters: request.queryParameters,
      );
      return response;
    } on DioException catch (exception) {
      // Log the error for debugging
      if (kDebugMode) {
        _logger.e(
          'DioException occurred',
          error: exception,
          stackTrace: exception.stackTrace,
          time: DateTime.now(),
        );
      }

      // Convert DioException to AppException
      throw _handleDioException(exception);
    } catch (e, stackTrace) {
      // Handle any other exceptions
      if (kDebugMode) {
        _logger.e(
          'Unexpected error occurred',
          error: e,
          stackTrace: stackTrace,
          time: DateTime.now(),
        );
      }
      throw UnknownException(e.toString());
    }
  }

  AppException _handleDioException(DioException exception) {
    switch (exception.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return const TimeoutException('Request timed out. Please try again.');

      case DioExceptionType.badResponse:
        final int? statusCode = exception.response?.statusCode;
        final dynamic responseData = exception.response?.data;
        final String message =
            (responseData is Map && responseData.containsKey('message')
                ? responseData['message'] as String
                : null) ??
            exception.message ??
            'Unknown error';

        switch (statusCode) {
          case 400:
            return BadRequestException(message);
          case 401:
            return const UnauthorizedException('Please log in again.');
          case 404:
            return NotFoundException(message);
          case 500:
          case 502:
          case 503:
            return ServerException(
              'Server error. Please try again later.',
              statusCode,
            );
          default:
            return ServerException(message, statusCode);
        }

      case DioExceptionType.cancel:
        return const UnknownException('Request was cancelled');

      case DioExceptionType.connectionError:
        return const NetworkException(
          'No internet connection. Please check your network.',
        );

      case DioExceptionType.badCertificate:
        return const NetworkException('Security certificate error');

      case DioExceptionType.unknown:
        return UnknownException(
          exception.message ?? 'An unexpected error occurred',
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
  });

  final String url;
  final HttpMethod method;
  final dynamic data;
  final Map<String, dynamic>? queryParameters;
  final String? contentType;
  final Map<String, dynamic>? headers;
}

enum HttpMethod {
  get(value: 'GET'),
  post(value: 'POST'),
  put(value: 'PUT'),
  delete(value: 'DELETE');

  const HttpMethod({required this.value});

  final String value;
}
