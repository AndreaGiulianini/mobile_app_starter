import 'package:equatable/equatable.dart';
import 'package:mobile_app_starter/model/classes/pokemon.dart';

/// State of the Pokédex list. See ARCHITECTURE.md, "State design".
sealed class PokemonState extends Equatable {
  const PokemonState();

  @override
  List<Object?> get props => <Object?>[];
}

final class PokemonInitial extends PokemonState {
  const PokemonInitial();
}

final class PokemonLoading extends PokemonState {
  const PokemonLoading();
}

final class PokemonSuccess extends PokemonState {
  const PokemonSuccess(
    this.pokemonList, {
    required this.hasMore,
    required this.nextOffset,
    this.loadMoreFailed = false,
  });

  final List<Pokemon> pokemonList;

  final bool hasMore;
  final int nextOffset;

  /// True when the most recent `loadMore` failed and the previous list was
  /// kept. The UI surfaces it as a notification, not a page.
  final bool loadMoreFailed;

  @override
  List<Object?> get props => <Object?>[
    pokemonList,
    hasMore,
    nextOffset,
    loadMoreFailed,
  ];
}

/// Being a distinct state is what prevents a double fetch — see
/// [PokemonCubit.loadMore].
final class PokemonLoadingMore extends PokemonState {
  const PokemonLoadingMore(this.currentList, {required this.nextOffset});

  final List<Pokemon> currentList;
  final int nextOffset;

  @override
  List<Object?> get props => <Object?>[currentList, nextOffset];
}

final class PokemonError extends PokemonState {
  const PokemonError(this.message);

  final String message;

  @override
  List<Object?> get props => <Object?>[message];
}
