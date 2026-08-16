import 'dart:typed_data';

import 'package:dio/dio.dart';

/// Swaps out Dio's transport, leaving interceptors and error mapping intact so
/// `_handleDioException` is exercised for real.
class FakeHttpClientAdapter implements HttpClientAdapter {
  FakeHttpClientAdapter(this.responder);

  final Future<ResponseBody> Function(RequestOptions options) responder;

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) => responder(options);

  @override
  void close({bool force = false}) {}
}
