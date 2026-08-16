/// Test data for the Pokédex. The `...Json` helpers are realistic API payloads;
/// [buildPokemon] builds a model directly. See ARCHITECTURE.md, "Testing".
library;

import 'package:mobile_app_starter/model/classes/pokemon.dart';

/// Returns [count] entries whose ids start at `offset + 1`.
Map<String, dynamic> pokemonListJson({int offset = 0, int count = 20}) {
  return <String, dynamic>{
    'count': 1302,
    'results': List<Map<String, dynamic>>.generate(count, (int i) {
      final int id = offset + i + 1;
      return <String, dynamic>{
        'name': 'pokemon-$id',
        'url': 'https://pokeapi.co/api/v2/pokemon/$id/',
      };
    }),
  };
}

/// Response body of `GET /pokemon/{id}`.
Map<String, dynamic> pokemonDetailJson(int id) {
  return <String, dynamic>{
    'id': id,
    'name': 'pokemon-$id',
    'height': 7,
    'weight': 69,
    'sprites': <String, dynamic>{
      'front_default': 'https://img.test/$id.png',
      'other': <String, dynamic>{
        'official-artwork': <String, dynamic>{
          'front_default': 'https://img.test/official/$id.png',
        },
      },
    },
    'types': <Map<String, dynamic>>[
      <String, dynamic>{
        'slot': 1,
        'type': <String, dynamic>{
          'name': 'grass',
          'url': 'https://pokeapi.co/api/v2/type/12/',
        },
      },
    ],
  };
}

/// Extracts the trailing id from either `/pokemon/25` or `/pokemon/25/`.
int idFromPath(String path) {
  final Match? match = RegExp(r'/pokemon/(\d+)').firstMatch(path);
  return match == null ? 0 : int.parse(match.group(1)!);
}

/// No sprites, so widgets render the placeholder icon instead of loading one.
Pokemon buildPokemon({
  required int id,
  required String name,
  List<String> types = const <String>['grass'],
  int height = 7,
  int weight = 69,
}) {
  return Pokemon(
    name: name,
    id: id,
    url: 'https://pokeapi.co/api/v2/pokemon/$id/',
    height: height,
    weight: weight,
    types: types
        .map(
          (String type) => PokemonType(
            slot: types.indexOf(type) + 1,
            type: TypeInfo(
              name: type,
              url: 'https://pokeapi.co/api/v2/type/1/',
            ),
          ),
        )
        .toList(),
  );
}
