import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_app_starter/core/errors/app_exception.dart';
import 'package:mobile_app_starter/model/classes/pokemon.dart';
import 'package:mobile_app_starter/model/classes/pokemon_page.dart';
import 'package:mobile_app_starter/repository/pokemon_repository.dart';
import 'package:mobile_app_starter/service/client.dart';
import 'package:mocktail/mocktail.dart';

import '../helpers/fixtures.dart';

class MockClientAPI extends Mock implements ClientAPI;

void main() {
  late MockClientAPI client;
  late PokemonRepository repository;

  setUpAll(() {
    registerFallbackValue(Request(url: '', method: HttpMethod.get));
  });

  setUp(() {
    client = MockClientAPI();
    repository = PokemonRepository(client);
  });

  /// Stubs [ClientAPI.request], not the extension methods on top of it — those
  /// are dispatched statically and mocktail cannot intercept them. See
  /// ARCHITECTURE.md, "Two mocking seams".
  void stubTransport({
    required List<String> names,
    Set<int> failingDetailIds = const <int>{},
  }) {
    when(() => client.request(request: any(named: 'request'))).thenAnswer((
      Invocation invocation,
    ) async {
      final Request req = invocation.namedArguments[#request]! as Request;
      final RequestOptions options = RequestOptions(path: req.url);

      // The list endpoint is '/pokemon' with queryParameters; details are
      // '/pokemon/<id>'.
      if (req.url == '/pokemon') {
        return Response<dynamic>(
          requestOptions: options,
          data: <String, dynamic>{
            'count': names.length,
            'results': <Map<String, dynamic>>[
              for (int i = 0; i < names.length; i++)
                <String, dynamic>{
                  'name': names[i],
                  'url': 'https://pokeapi.co/api/v2/pokemon/${i + 1}/',
                },
            ],
          },
        );
      }

      final int id = idFromPath(req.url);
      if (failingDetailIds.contains(id)) {
        // An AppException, as the real ClientAPI guarantees: the repository
        // deliberately does not swallow anything broader.
        throw ServerException('detail $id unavailable', statusCode: 500);
      }
      return Response<dynamic>(
        requestOptions: options,
        data: <String, dynamic>{...pokemonDetailJson(id), 'name': 'detail-$id'},
      );
    });
  }

  int listCalls() => verify(
    () => client.request(
      request: any(
        named: 'request',
        that: predicate<Request>((Request r) => r.url == '/pokemon'),
      ),
    ),
  ).callCount;

  group('getPage', () {
    test('hydrates every entry with its detail payload', () async {
      stubTransport(names: <String>['a', 'b', 'c']);

      final PokemonPage page = await repository.getPage();

      expect(page.items.length, 3);
      expect(page.total, 3, reason: "the API's count must survive the layer");
      // Names come from the detail responses, proving the second request ran.
      expect(
        page.items.map((Pokemon p) => p.name),
        everyElement(startsWith('detail-')),
      );
    });

    test('degrades one failed detail request instead of failing the page', () async {
      stubTransport(names: <String>['a', 'b'], failingDetailIds: <int>{2});

      final PokemonPage page = await repository.getPage();

      expect(page.items.length, 2);
      expect(page.items[0].name, 'detail-1');
      // The failed one falls back to its name-only form rather than taking the
      // whole page down with it.
      expect(page.items[1].name, 'b');
    });
  });

  group('searchByName', () {
    test('returns nothing for a blank query, without any request', () async {
      stubTransport(names: <String>['pikachu']);

      expect(await repository.searchByName('   '), isEmpty);
      verifyNever(() => client.request(request: any(named: 'request')));
    });

    test('matches on a substring, case-insensitively', () async {
      stubTransport(names: <String>['bulbasaur', 'pikachu', 'raichu']);

      final List<Pokemon> results = await repository.searchByName('CHU');

      // pikachu and raichu, not bulbasaur.
      expect(results.length, 2);
    });

    test('fetches the name index once and reuses it', () async {
      stubTransport(names: <String>['pikachu', 'raichu']);

      await repository.searchByName('chu');
      await repository.searchByName('pika');
      await repository.searchByName('rai');

      // The real index is ~1350 entries and ~90 KB. Refetching it on every
      // keystroke is exactly what this cache exists to prevent.
      expect(listCalls(), 1);
    });

    test('caps how many matches get hydrated', () async {
      stubTransport(names: List<String>.generate(50, (int i) => 'pokemon-$i'));

      final List<Pokemon> results = await repository.searchByName(
        'pokemon',
        limit: 5,
      );

      expect(results.length, 5);
    });
  });
}
