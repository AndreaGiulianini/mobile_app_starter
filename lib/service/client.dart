import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:mobile_app_starter/config.dart' as config;
import 'package:mobile_app_starter/utils/curl_logger.dart';

export './pokemon_api.dart';

class ClientAPI {
  factory ClientAPI({BuildContext? context}) {
    _client ??= ClientAPI._(context: context);
    return _client!;
  }

  ClientAPI._({this.context}) {
    if (!kReleaseMode) {
      _dioClient.interceptors.add(CurlLogger(printOnSuccess: true));
    }
  }

  static ClientAPI? _client;
  final Dio _dioClient = Dio();
  late BuildContext? context;

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
        print('DioException occurred: ${exception.type}');
        print('Error message: ${exception.message}');
        print('Response data: ${exception.response?.data}');
      }

      // Rethrow the exception so the caller can handle it
      rethrow;
    }
  }
}

class Request {
  Request({required this.url, required this.method, this.contentType, this.data, this.queryParameters, this.headers});

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
