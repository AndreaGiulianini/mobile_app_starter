import 'package:dio/dio.dart';
import 'package:mobile_app_starter/model/classes/pokemon.dart';
import 'package:mobile_app_starter/model/dtos/pokemon_dto.dart';
import 'package:mobile_app_starter/service/client.dart';

extension PokemonAPI on ClientAPI {
  Future<List<Pokemon>> getListPokemon() async {
    final Response<dynamic> response = await request(
      request: Request(
        url: '/pokemon',
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
}
