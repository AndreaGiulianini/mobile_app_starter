import 'dart:math' as math;

import 'package:dio/dio.dart';
import 'package:mobile_app_starter/core/config/app_config.dart';
import 'package:mobile_app_starter/core/errors/app_exception.dart';
import 'package:mobile_app_starter/model/classes/pokemon.dart';
import 'package:mobile_app_starter/model/classes/pokemon_page.dart';
import 'package:mobile_app_starter/service/client.dart';
// The endpoints live in an extension on ClientAPI, so the import has to be
// explicit even though `_client` is typed by client.dart.
import 'package:mobile_app_starter/service/pokemon_api.dart';

// The one re-export in the app, and it earns its place: it enforces a layer
// boundary, letting blocs pass a CancelToken without importing dio at all.
export 'package:dio/dio.dart' show CancelToken;

/// Sits between the blocs and [ClientAPI]. See ARCHITECTURE.md, "Layers".
class PokemonRepository {
  PokemonRepository(this._client);

  final ClientAPI _client;

  /// How many detail requests may be in flight at once: 20 simultaneous
  /// sockets against a public, rate-limited API is asking to be throttled.
  static const int _detailConcurrency = 6;

  /// Fetched at most once per app run: ~1350 entries, ~90 KB. The future is
  /// cached rather than the value, so concurrent searches share one request
  /// instead of each firing its own.
  Future<List<Pokemon>>? _nameIndexFuture;

  /// PokeAPI data is immutable, so cached details never go stale.
  final Map<int, Pokemon> _detailCache = <int, Pokemon>{};

  /// One page, each entry already populated with its detail payload.
  Future<PokemonPage> getPage({
    int limit = AppConfig.pageSize,
    int offset = 0,
    CancelToken? cancelToken,
  }) async {
    final PokemonPage page = await _client.getListPokemon(
      limit: limit,
      offset: offset,
      cancelToken: cancelToken,
    );
    return PokemonPage(
      items: await _withDetails(page.items, cancelToken: cancelToken),
      total: page.total,
    );
  }

  Future<Pokemon> getById(int id, {CancelToken? cancelToken}) async {
    final Pokemon? cached = _detailCache[id];
    if (cached != null) {
      return cached;
    }
    final Pokemon detail = await _client.getPokemonById(
      id,
      cancelToken: cancelToken,
    );
    _detailCache[id] = detail;
    return detail;
  }

  /// Pokémon whose name contains [query], case-insensitively.
  ///
  /// PokeAPI has no search endpoint, so this filters a cached index in memory
  /// and hydrates only the first [limit] matches.
  Future<List<Pokemon>> searchByName(
    String query, {
    int limit = AppConfig.pageSize,
    CancelToken? cancelToken,
  }) async {
    final String needle = query.trim().toLowerCase();
    if (needle.isEmpty) {
      return <Pokemon>[];
    }

    final List<Pokemon> index = await _loadNameIndex(cancelToken: cancelToken);
    final List<Pokemon> matches = index
        .where((Pokemon p) => p.name.toLowerCase().contains(needle))
        .take(limit)
        .toList();

    return await _withDetails(matches, cancelToken: cancelToken);
  }

  Future<List<Pokemon>> _loadNameIndex({CancelToken? cancelToken}) {
    return _nameIndexFuture ??= _fetchNameIndex(cancelToken: cancelToken);
  }

  Future<List<Pokemon>> _fetchNameIndex({CancelToken? cancelToken}) async {
    try {
      final PokemonPage page = await _client.getListPokemon(
        limit: AppConfig.nameIndexLimit,
        cancelToken: cancelToken,
      );
      return page.items;
    } catch (_) {
      // A transient failure — or the first search being cancelled — must not
      // be cached as "the index" forever.
      _nameIndexFuture = null;
      rethrow;
    }
  }

  /// Hydrates [basicList] with detail payloads, [_detailConcurrency] requests
  /// at a time. Order is preserved, and repeats cost nothing because
  /// [getById] serves them from [_detailCache].
  Future<List<Pokemon>> _withDetails(
    List<Pokemon> basicList, {
    CancelToken? cancelToken,
  }) async {
    final List<Pokemon> hydrated = <Pokemon>[];
    for (final List<Pokemon> chunk in _chunks(basicList, _detailConcurrency)) {
      hydrated.addAll(
        await Future.wait(
          chunk.map(
            (Pokemon pokemon) => _hydrate(pokemon, cancelToken: cancelToken),
          ),
        ),
      );
    }
    return hydrated;
  }

  /// A failed detail keeps the name-only entry — a dead network mid-page must
  /// not blank cards the user can already see. Cancellation is flow control,
  /// not failure, so it propagates instead.
  Future<Pokemon> _hydrate(Pokemon pokemon, {CancelToken? cancelToken}) async {
    final int id = pokemon.pokemonId;
    if (id == kUnknownPokemonId) {
      return pokemon;
    }
    try {
      return await getById(id, cancelToken: cancelToken);
    } on RequestCancelledException {
      rethrow;
    } on AppException {
      return pokemon;
    }
  }
}

/// Successive slices of [items], at most [size] each.
Iterable<List<T>> _chunks<T>(List<T> items, int size) sync* {
  for (int start = 0; start < items.length; start += size) {
    yield items.sublist(start, math.min(start + size, items.length));
  }
}
