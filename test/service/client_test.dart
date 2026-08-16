import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_app_starter/core/config/app_config.dart';
import 'package:mobile_app_starter/core/errors/app_exception.dart';
import 'package:mobile_app_starter/model/classes/pokemon_page.dart';
import 'package:mobile_app_starter/service/client.dart';
import 'package:mobile_app_starter/service/pokemon_api.dart';

import '../helpers/fake_http_client_adapter.dart';
import '../helpers/fixtures.dart';

void main() {
  setUpAll(() {
    // Points AppConfig at the test host. loadFromString is the sync test
    // hook; testLoad() is gone in dotenv v6.
    dotenv.loadFromString(envString: 'API_BASE_URL=https://api.test/v2');
  });

  ClientAPI clientReturning(
    Future<ResponseBody> Function(RequestOptions options) responder,
  ) {
    // Mirrors the DI setup: the base URL lives in BaseOptions, and relative
    // request paths resolve against it.
    final Dio dio = Dio(BaseOptions(baseUrl: AppConfig.apiBaseUrl))
      ..httpClientAdapter = FakeHttpClientAdapter(responder);
    return ClientAPI(dio: dio);
  }

  ResponseBody jsonBody(Object data, {int statusCode = 200}) {
    return ResponseBody.fromString(
      json.encode(data),
      statusCode,
      headers: <String, List<String>>{
        Headers.contentTypeHeader: <String>[Headers.jsonContentType],
      },
    );
  }

  group('ClientAPI', () {
    test('prefixes the configured base URL and parses the payload', () async {
      late String requestedPath;
      final ClientAPI client = clientReturning((RequestOptions options) async {
        requestedPath = options.uri.toString();
        return jsonBody(pokemonListJson(count: 2));
      });

      final PokemonPage page = await client.getListPokemon(limit: 2);

      expect(requestedPath, 'https://api.test/v2/pokemon?limit=2&offset=0');
      expect(page.items.length, 2);
    });

    test('maps a connection timeout onto RequestTimeoutException', () async {
      // Future.error, not an async throw: Dio needs a rejected Future.
      final ClientAPI client = clientReturning(
        (RequestOptions options) => Future<ResponseBody>.error(
          DioException.connectionTimeout(
            timeout: const Duration(seconds: 1),
            requestOptions: options,
          ),
        ),
      );

      await expectLater(
        client.getListPokemon(),
        throwsA(isA<RequestTimeoutException>()),
      );
    });

    test(
      'maps a 404 onto NotFoundException, keeping the server message',
      () async {
        final ClientAPI client = clientReturning((
          RequestOptions options,
        ) async {
          return jsonBody(<String, dynamic>{
            'message': 'no such pokemon',
          }, statusCode: 404);
        });

        await expectLater(
          client.getPokemonById(9999),
          throwsA(
            isA<NotFoundException>().having(
              (NotFoundException e) => e.message,
              'message',
              'no such pokemon',
            ),
          ),
        );
      },
    );

    test('maps a 500 onto ServerException carrying the status code', () async {
      final ClientAPI client = clientReturning((RequestOptions options) async {
        return jsonBody(<String, dynamic>{'message': 'boom'}, statusCode: 500);
      });

      await expectLater(
        client.getListPokemon(),
        throwsA(
          isA<ServerException>().having(
            (ServerException e) => e.statusCode,
            'statusCode',
            500,
          ),
        ),
      );
    });

    test('maps a connection error onto NetworkException', () async {
      final ClientAPI client = clientReturning(
        (RequestOptions options) => Future<ResponseBody>.error(
          DioException.connectionError(
            requestOptions: options,
            reason: 'offline',
          ),
        ),
      );

      await expectLater(
        client.getListPokemon(),
        throwsA(isA<NetworkException>()),
      );
    });

    test(
      'maps dio 5.11 transformTimeout onto RequestTimeoutException',
      () async {
        // Added in dio 5.11. It is a timeout and must not degrade into
        // UnknownException.
        final ClientAPI client = clientReturning(
          (RequestOptions options) => Future<ResponseBody>.error(
            DioException(
              requestOptions: options,
              type: DioExceptionType.transformTimeout,
            ),
          ),
        );

        await expectLater(
          client.getListPokemon(),
          throwsA(isA<RequestTimeoutException>()),
        );
      },
    );
  });
}
