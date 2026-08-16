import 'package:equatable/equatable.dart';
import 'package:mobile_app_starter/model/classes/pokemon.dart';

/// State of the detail route. In its own file like every other state
/// hierarchy, rather than inlined beside its cubit.
sealed class PokemonDetailState extends Equatable {
  const PokemonDetailState();

  @override
  List<Object?> get props => <Object?>[];
}

final class PokemonDetailLoading extends PokemonDetailState {
  const PokemonDetailLoading();
}

final class PokemonDetailLoaded extends PokemonDetailState {
  const PokemonDetailLoaded(this.pokemon);

  final Pokemon pokemon;

  @override
  List<Object?> get props => <Object?>[pokemon];
}

final class PokemonDetailFailure extends PokemonDetailState {
  const PokemonDetailFailure([this.message]);

  /// Null when there is no server-provided text; the UI falls back to the
  /// localized `detailLoadFailed` string.
  final String? message;

  @override
  List<Object?> get props => <Object?>[message];
}
