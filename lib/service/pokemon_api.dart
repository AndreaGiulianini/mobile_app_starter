import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:mobile_app_starter/core/errors/app_exception.dart';
import 'package:mobile_app_starter/model/classes/pokemon.dart';
import 'package:mobile_app_starter/model/classes/pokemon_page.dart';
import 'package:mobile_app_starter/model/dtos/pokemon_dto.dart';
import 'package:mobile_app_starter/service/client.dart';

/// Above this many items, JSON-to-object construction moves off the UI
/// isolate: the full name index (~1350 entries) is requested on the user's
/// first search keystroke, the worst possible moment to jank.
const int _isolateParseThreshold = 200;

extension PokemonAPI on ClientAPI {
  /// One page of the index, names and urls only. Carries the API's `count` so
  /// callers know where the collection ends.
  Future<PokemonPage> getListPokemon({
    int limit = 20,
    int offset = 0,
    CancelToken? cancelToken,
  }) async {
    final Response<dynamic> response = await request(
      request: Request(
        url: '/pokemon',
        method: HttpMethod.get,
        queryParameters: <String, dynamic>{'limit': limit, 'offset': offset},
        cancelToken: cancelToken,
      ),
    );

    final Map<String, dynamic> data = _mapOrThrow(response.data);
    final PokemonDTO dto = limit > _isolateParseThreshold
        ? await compute(_parsePokemonDto, data)
        : PokemonDTO.fromJson(data);
    return PokemonPage(items: dto.results, total: dto.count);
  }

  /// Takes an id, not the absolute URL the list endpoint returns, so the base
  /// URL keeps coming from the Dio configuration.
  Future<Pokemon> getPokemonById(int id, {CancelToken? cancelToken}) async {
    final Response<dynamic> response = await request(
      request: Request(
        url: '/pokemon/$id',
        method: HttpMethod.get,
        cancelToken: cancelToken,
      ),
    );

    return Pokemon.fromJson(_mapOrThrow(response.data));
  }
}

/// Top-level so [compute] can send it to another isolate.
PokemonDTO _parsePokemonDto(Map<String, dynamic> json) =>
    PokemonDTO.fromJson(json);

/// A proxy error page, an empty body, or a content-type mismatch hands back
/// something that is not a JSON object; that must surface as an
/// [AppException], not a bare TypeError from a cast.
Map<String, dynamic> _mapOrThrow(dynamic data) {
  if (data is Map<String, dynamic>) {
    return data;
  }
  throw const ParsingException();
}
