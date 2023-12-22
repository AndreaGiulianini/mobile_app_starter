import 'dart:convert';
import 'dart:developer';
import 'package:dio/dio.dart';

class CurlLogger extends Interceptor {
  CurlLogger({this.printOnSuccess, this.convertFormData = true});
  final bool? printOnSuccess;
  final bool convertFormData;

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    _renderCurlRepresentation(err.requestOptions);

    return handler.next(err); //continue
  }

  @override
  void onResponse(
    Response<dynamic> response,
    ResponseInterceptorHandler handler,
  ) {
    if (printOnSuccess != null && printOnSuccess!) {
      _renderCurlRepresentation(response.requestOptions);
    }

    return handler.next(response); //continue
  }

  void _renderCurlRepresentation(RequestOptions requestOptions) {
    // add a breakpoint here so all errors can break
    try {
      log(_cURLRepresentation(requestOptions));
    } catch (err) {
      log('unable to create a CURL representation of the requestOptions');
    }
  }

  String _cURLRepresentation(RequestOptions options) {
    final List<String> components = <String>['curl -i'];
    if (options.method.toUpperCase() != 'GET') {
      components.add('-X ${options.method}');
    }

    options.headers.forEach((String k, v) {
      if (k != 'Cookie') {
        components.add('-H "$k: $v"');
      }
    });

    if (options.data != null) {
      // FormData can't be JSON-serialized, so keep only their fields attributes
      if (options.data is FormData && convertFormData) {
        // ignore: avoid_dynamic_calls
        options.data = Map<String, dynamic>.fromEntries(options.data.fields as Iterable<MapEntry<String, dynamic>>);
      }

      final String data = json.encode(options.data).replaceAll('"', r'\"');
      components.add('-d "$data"');
    }

    components.add('"${options.uri}"');

    return components.join(' \\\n\t');
  }
}
