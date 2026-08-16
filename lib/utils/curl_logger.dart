import 'dart:convert';
import 'dart:developer';

import 'package:dio/dio.dart';

/// Headers that must never be printed, matched case-insensitively. This is a
/// starter template others copy: the day an Authorization header appears, it
/// must not land in logcat.
const Set<String> _redactedHeaders = <String>{
  'authorization',
  'proxy-authorization',
  'cookie',
  'set-cookie',
  'x-api-key',
};

class CurlLogger extends Interceptor {
  CurlLogger({this.printOnSuccess = false, this.convertFormData = true});

  final bool printOnSuccess;
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
    if (printOnSuccess) {
      _renderCurlRepresentation(response.requestOptions);
    }

    return handler.next(response);
  }

  void _renderCurlRepresentation(RequestOptions requestOptions) {
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

    options.headers.forEach((String k, dynamic v) {
      components.add(
        _redactedHeaders.contains(k.toLowerCase())
            ? '-H "$k: <redacted>"'
            : '-H "$k: $v"',
      );
    });

    if (options.data != null) {
      // Into a local: assigning back to options.data would change the body
      // actually sent.
      Object? payload = options.data;
      if (payload is FormData && convertFormData) {
        payload = Map<String, dynamic>.fromEntries(payload.fields);
      }

      // Single quotes with '\'' escaping: the double-quoted form left $, `
      // and newlines live, so pasting the line into a shell could execute
      // parts of the body.
      final String data = json.encode(payload).replaceAll("'", r"'\''");
      components.add("-d '$data'");
    }

    components.add('"${options.uri}"');

    return components.join(' \\\n\t');
  }
}
