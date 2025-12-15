import 'package:dio/dio.dart';
import 'package:mobile_app_starter/model/classes/pokemon.dart';
import 'package:mobile_app_starter/model/dtos/pokemon_dto.dart';
import 'package:mobile_app_starter/service/client.dart';

extension PokemonAPI on ClientAPI {
  Future<List<Pokemon>> getListPokemon({int limit = 20, int offset = 0}) async {
    final Response<dynamic> response = await request(
      request: Request(
        url: '/pokemon?limit=$limit&offset=$offset',
        method: HttpMethod.get,
      ),
      errorData: <String, dynamic>{
        'reason': 'Crash getListPokemon',
        'url': '/pokemon',
        'method': HttpMethod.get,
      },
    );

    return PokemonDTO.fromJson(response.data as Map<String, dynamic>).results;
  }

  Future<Pokemon> getPokemonDetails(String url) async {
    // Extract the path from the full URL
    final Uri uri = Uri.parse(url);
    final String path = uri.path.replaceFirst('/api/v2', '');

    final Response<dynamic> response = await request(
      request: Request(url: path, method: HttpMethod.get),
      errorData: <String, dynamic>{
        'reason': 'Crash getPokemonDetails',
        'url': path,
        'method': HttpMethod.get,
      },
    );

    return Pokemon.fromJson(response.data as Map<String, dynamic>);
  }
}
