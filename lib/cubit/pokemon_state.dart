import 'package:equatable/equatable.dart';
import 'package:mobile_app_starter/model/classes/pokemon.dart';

abstract class PokemonState extends Equatable {
  const PokemonState();

  @override
  List<Object?> get props => <Object?>[];
}

class PokemonInitial extends PokemonState {
  const PokemonInitial();
}

class PokemonLoading extends PokemonState {
  const PokemonLoading({this.partialList});

  final List<Pokemon>? partialList;

  @override
  List<Object?> get props => <Object?>[partialList];
}

class PokemonSuccess extends PokemonState {
  const PokemonSuccess(this.pokemonList, {this.hasMore = true});

  final List<Pokemon> pokemonList;
  final bool hasMore;

  @override
  List<Object?> get props => <Object?>[pokemonList, hasMore];
}

class PokemonLoadingMore extends PokemonState {
  const PokemonLoadingMore(this.currentList);

  final List<Pokemon> currentList;

  @override
  List<Object?> get props => <Object?>[currentList];
}

class PokemonError extends PokemonState {
  const PokemonError(this.message);

  final String message;

  @override
  List<Object?> get props => <Object?>[message];
}
