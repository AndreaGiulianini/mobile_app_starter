import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile_app_starter/core/errors/app_exception.dart';
import 'package:mobile_app_starter/cubit/pokemon_state.dart';
import 'package:mobile_app_starter/model/classes/pokemon.dart';
import 'package:mobile_app_starter/service/client.dart';

class PokemonCubit extends Cubit<PokemonState> {
  PokemonCubit(this._clientAPI) : super(const PokemonInitial());

  final ClientAPI _clientAPI;
  static const int _pageSize = 20;
  static const int _maxPokemon = 1000; // PokeAPI has ~1000 Pokemon
  int _currentOffset = 0;
  bool _isLoadingMore = false;

  Future<void> loadPokemon() async {
    emit(const PokemonLoading());
    _currentOffset = 0;

    try {
      // First, get the list of Pokemon
      final List<Pokemon> basicList = await _clientAPI.getListPokemon();

      // Parallelize fetching detailed info for better performance
      final List<Pokemon> detailedList = await _fetchPokemonDetails(basicList);

      _currentOffset += _pageSize;
      final bool hasMore = _currentOffset < _maxPokemon;

      emit(PokemonSuccess(detailedList, hasMore: hasMore));
    } on AppException catch (e) {
      emit(PokemonError(e.message));
    } catch (e) {
      emit(
        const PokemonError('An unexpected error occurred. Please try again.'),
      );
    }
  }

  Future<void> loadMore() async {
    if (_isLoadingMore) {
      return;
    }

    final PokemonState currentState = state;
    if (currentState is! PokemonSuccess) {
      return;
    }
    if (!currentState.hasMore) {
      return;
    }

    _isLoadingMore = true;
    emit(PokemonLoadingMore(currentState.pokemonList));

    try {
      // Get the next page of Pokemon
      final List<Pokemon> basicList = await _clientAPI.getListPokemon(
        offset: _currentOffset,
      );

      // Parallelize fetching detailed info
      final List<Pokemon> detailedList = await _fetchPokemonDetails(basicList);

      // Combine with existing list
      final List<Pokemon> updatedList = <Pokemon>[
        ...currentState.pokemonList,
        ...detailedList,
      ];

      _currentOffset += _pageSize;
      final bool hasMore = _currentOffset < _maxPokemon;

      emit(PokemonSuccess(updatedList, hasMore: hasMore));
    } on AppException {
      // If loading more fails, return to previous success state
      emit(
        PokemonSuccess(currentState.pokemonList, hasMore: currentState.hasMore),
      );
    } catch (_) {
      emit(
        PokemonSuccess(currentState.pokemonList, hasMore: currentState.hasMore),
      );
    } finally {
      _isLoadingMore = false;
    }
  }

  Future<List<Pokemon>> _fetchPokemonDetails(List<Pokemon> basicList) async {
    final List<Future<Pokemon>> futures = basicList.map((Pokemon pokemon) {
      if (pokemon.url == null) {
        return Future<Pokemon>.value(pokemon);
      }
      return _clientAPI
          .getPokemonDetails(pokemon.url!)
          .catchError(
            (dynamic error) => pokemon, // Return basic pokemon if details fail
          );
    }).toList();

    return Future.wait(futures);
  }

  void retry() {
    loadPokemon();
  }
}
