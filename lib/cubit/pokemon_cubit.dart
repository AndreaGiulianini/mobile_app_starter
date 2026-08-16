import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile_app_starter/core/bloc/safe_emit.dart';
import 'package:mobile_app_starter/core/errors/app_exception.dart';
import 'package:mobile_app_starter/cubit/pokemon_state.dart';
import 'package:mobile_app_starter/model/classes/pokemon.dart';
import 'package:mobile_app_starter/model/classes/pokemon_page.dart';
import 'package:mobile_app_starter/repository/pokemon_repository.dart';

/// Drives the paginated Pokédex list.
///
/// Pagination state lives in [PokemonState], not in fields. The one mutable
/// field, [_generation], is command plumbing: it invalidates emits from a
/// command that another command has since superseded. See ARCHITECTURE.md,
/// "Bloc or Cubit?".
class PokemonCubit extends Cubit<PokemonState> with SafeEmit<PokemonState> {
  PokemonCubit(this._repository) : super(const PokemonInitial());

  final PokemonRepository _repository;

  /// Bumped at the start of every command. A command captures the value and
  /// only emits while it still matches, so a reload started mid-`loadMore`
  /// cannot have its fresh page-0 list overwritten by the stale append.
  int _generation = 0;

  Future<void> loadPokemon() async {
    // A double-tapped retry must not fire two page-0 requests.
    if (state is PokemonLoading) {
      return;
    }
    final int generation = ++_generation;
    emit(const PokemonLoading());

    try {
      final PokemonPage page = await _repository.getPage();
      _safeEmit(
        generation,
        _successFrom(page, previous: const <Pokemon>[], offset: 0),
      );
    } on AppException catch (e, stackTrace) {
      addError(e, stackTrace);
      _safeEmit(generation, PokemonError(e.message));
    } catch (e, stackTrace) {
      addError(e, stackTrace);
      _safeEmit(
        generation,
        const PokemonError('An unexpected error occurred. Please try again.'),
      );
    }
  }

  Future<void> loadMore() async {
    final PokemonState current = state;
    // Doubles as the concurrency guard: mid-fetch the state is LoadingMore.
    if (current is! PokemonSuccess || !current.hasMore) {
      return;
    }

    final int generation = ++_generation;
    emit(
      PokemonLoadingMore(current.pokemonList, nextOffset: current.nextOffset),
    );

    try {
      final PokemonPage page = await _repository.getPage(
        offset: current.nextOffset,
      );
      _safeEmit(
        generation,
        _successFrom(
          page,
          previous: current.pokemonList,
          offset: current.nextOffset,
        ),
      );
    } catch (e, stackTrace) {
      addError(e, stackTrace);
      // A failed page must not discard what the user is already looking at;
      // the flag lets the UI say so without leaving the list.
      _safeEmit(
        generation,
        PokemonSuccess(
          current.pokemonList,
          hasMore: current.hasMore,
          nextOffset: current.nextOffset,
          loadMoreFailed: true,
        ),
      );
    }
  }

  Future<void> retry() => loadPokemon();

  /// `hasMore` compares against the API's own `total`, so pagination stops at
  /// the real end of the Pokédex rather than a hardcoded ceiling.
  PokemonSuccess _successFrom(
    PokemonPage page, {
    required List<Pokemon> previous,
    required int offset,
  }) {
    final int nextOffset = offset + page.items.length;
    return PokemonSuccess(
      // Unmodifiable: state handed to the UI must not be mutable in place —
      // an in-place add would keep Equatable equality and skip the rebuild.
      List<Pokemon>.unmodifiable(previous.followedBy(page.items)),
      hasMore: page.items.isNotEmpty && nextOffset < page.total,
      nextOffset: nextOffset,
    );
  }

  /// [SafeEmit.safeEmit] plus the generation check: a command must not emit
  /// once another command has superseded it.
  void _safeEmit(int generation, PokemonState newState) {
    if (generation == _generation) {
      safeEmit(newState);
    }
  }
}
